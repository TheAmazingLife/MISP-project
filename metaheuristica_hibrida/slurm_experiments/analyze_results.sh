#!/bin/bash

# Script para analizar los resultados de los experimentos Slurm
# Genera estadísticas por densidad con media y desviación estándar de las 30 iteraciones

RESULTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resultados"
OUTPUT_CSV="${RESULTS_DIR}/analisis_resultados.csv"
OUTPUT_SUMMARY_BY_DENSITY="${RESULTS_DIR}/resumen_por_densidad.csv"
OUTPUT_SUMMARY="${RESULTS_DIR}/resumen_estadistico.txt"

echo "========================================="
echo "Análisis de Resultados - BRKGA MISP"
echo "========================================="
echo ""

# Verificar que existe el directorio de resultados
if [ ! -d "$RESULTS_DIR" ]; then
    echo "Error: No existe el directorio de resultados: $RESULTS_DIR"
    exit 1
fi

# Contar archivos de resultados
TOTAL_STDOUT=$(find "$RESULTS_DIR" -name "*.stdout" | wc -l)
TOTAL_STDERR=$(find "$RESULTS_DIR" -name "*.stderr" | wc -l)

echo "Archivos encontrados:"
echo "  - .stdout: $TOTAL_STDOUT"
echo "  - .stderr: $TOTAL_STDERR"
echo ""

# Crear encabezado del CSV
echo "instancia,seed,job_id,nodo,valor_objetivo,tiempo_ejecucion,exito" > "$OUTPUT_CSV"

# Variables para estadísticas
TOTAL_EXPERIMENTOS=0
EXPERIMENTOS_EXITOSOS=0
EXPERIMENTOS_FALLIDOS=0

# Procesar cada archivo .stdout
echo "Procesando resultados..."
for stdout_file in "$RESULTS_DIR"/*.stdout; do
    [ -f "$stdout_file" ] || continue
    
    TOTAL_EXPERIMENTOS=$((TOTAL_EXPERIMENTOS + 1))
    
    # Extraer información del nombre del archivo
    filename=$(basename "$stdout_file")
    # Formato: misp_<instancia>_s<seed>_<jobid>.stdout
    
    # Extraer job_id del nombre del archivo (último número antes de .stdout)
    job_id=$(echo "$filename" | grep -oP '_\K[0-9]+(?=\.stdout)')
    
    # Extraer seed (número después de _s)
    seed=$(echo "$filename" | grep -oP '_s\K[0-9]+')
    
    # Extraer nombre de instancia (entre misp_ y _s)
    instancia=$(echo "$filename" | sed 's/^misp_//; s/_s[0-9]*_[0-9]*\.stdout$//')
    
    # Leer información del contenido
    job_id_content=$(grep "Job ID:" "$stdout_file" | awk '{print $3}')
    nodo=$(grep "Nodo:" "$stdout_file" | awk '{print $2}')
    
    # Buscar el valor objetivo (puede variar según el formato de salida)
    # Asumiendo que el programa imprime algo como "Best solution: 123" o "Objective: 123"
    valor_objetivo=$(grep -iE "(Best|Objective|Solution|Valor objetivo)" "$stdout_file" | grep -oP '\d+' | tail -1)
    
    # Buscar tiempo de ejecución
    tiempo=$(grep -iE "(Time|Tiempo|Runtime)" "$stdout_file" | grep -oP '\d+(\.\d+)?' | tail -1)
    
    # Verificar si el experimento fue exitoso
    exit_code=$(grep "código:" "$stdout_file" | grep -oP '\d+' | tail -1)
    if [ "$exit_code" == "0" ] || [ -n "$valor_objetivo" ]; then
        exito="SI"
        EXPERIMENTOS_EXITOSOS=$((EXPERIMENTOS_EXITOSOS + 1))
    else
        exito="NO"
        EXPERIMENTOS_FALLIDOS=$((EXPERIMENTOS_FALLIDOS + 1))
        valor_objetivo="N/A"
        tiempo="N/A"
    fi
    
    # Si no se encontró job_id en el contenido, usar el del nombre
    [ -z "$job_id_content" ] && job_id_content="$job_id"
    
    # Escribir al CSV
    echo "$instancia,$seed,$job_id_content,$nodo,$valor_objetivo,$tiempo,$exito" >> "$OUTPUT_CSV"
    
    # Mostrar progreso cada 100 experimentos
    if [ $((TOTAL_EXPERIMENTOS % 100)) -eq 0 ]; then
        echo "  Procesados: $TOTAL_EXPERIMENTOS experimentos..."
    fi
done

echo ""
echo "========================================="
echo "Generando resumen por densidad..."
echo "========================================="

# Generar CSV con estadísticas por densidad (tamaño, densidad, media, desv)
echo "tamaño,densidad,media,desviacion_std,min,max,n_instancias" > "$OUTPUT_SUMMARY_BY_DENSITY"

# Procesar para cada tamaño
for SIZE in 1000 2000 3000; do
    echo "Procesando tamaño n=$SIZE..."
    
    # Procesar para cada densidad
    for DENSITY in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9; do
        # Extraer valores para esta combinación tamaño-densidad
        VALUES=$(awk -F',' -v size="n${SIZE}" -v dens="${DENSITY}" '
            NR>1 && $1 ~ size && $1 ~ ("p0c"dens"_") && $5 != "N/A" {
                print $5
            }' "$OUTPUT_CSV")
        
        if [ -n "$VALUES" ]; then
            # Calcular estadísticas usando awk
            STATS=$(echo "$VALUES" | awk '{
                sum += $1
                sumsq += ($1)^2
                count++
                if (NR==1 || $1 < min) min = $1
                if (NR==1 || $1 > max) max = $1
            }
            END {
                if (count > 0) {
                    mean = sum / count
                    variance = (sumsq / count) - (mean^2)
                    std = (variance > 0) ? sqrt(variance) : 0
                    printf "%.2f,%.2f,%d,%d,%d", mean, std, min, max, count
                }
            }')
            
            if [ -n "$STATS" ]; then
                echo "$SIZE,$DENSITY,$STATS" >> "$OUTPUT_SUMMARY_BY_DENSITY"
            fi
        fi
    done
done

echo ""
echo "========================================="
echo "Generando resumen estadístico general..."
echo "========================================="

# Generar resumen estadístico general
{
    echo "========================================"
    echo "RESUMEN ESTADÍSTICO - EXPERIMENTOS SLURM"
    echo "========================================"
    echo ""
    echo "Fecha del análisis: $(date)"
    echo ""
    echo "TOTALES:"
    echo "  - Total de experimentos: $TOTAL_EXPERIMENTOS"
    echo "  - Experimentos exitosos: $EXPERIMENTOS_EXITOSOS"
    echo "  - Experimentos fallidos: $EXPERIMENTOS_FALLIDOS"
    echo "  - Tasa de éxito: $(awk "BEGIN {printf \"%.2f\", ($EXPERIMENTOS_EXITOSOS/$TOTAL_EXPERIMENTOS)*100}")%"
    echo ""
    
    # Estadísticas por instancia (contar cuántas veces aparece cada instancia)
    echo "INSTANCIAS ÚNICAS PROCESADAS:"
    echo "$(awk -F',' 'NR>1 {print $1}' "$OUTPUT_CSV" | sort -u | wc -l) instancias diferentes"
    echo ""
    
    # Semillas usadas
    echo "SEMILLAS UTILIZADAS:"
    awk -F',' 'NR>1 {print $2}' "$OUTPUT_CSV" | sort -u
    echo ""
    
    echo "========================================"
    echo "RESUMEN POR DENSIDAD Y TAMAÑO"
    echo "========================================"
    echo ""
    
    # Mostrar tabla formateada
    for SIZE in 1000 2000 3000; do
        echo "TAMAÑO: n=$SIZE"
        echo "$(printf '%-10s %-12s %-12s %-8s %-8s %-12s' 'Densidad' 'Media' 'Desv.Std' 'Min' 'Max' 'N.Instancias')"
        echo "$(printf '%s' '------------------------------------------------------------------------')"
        
        awk -F',' -v size="$SIZE" '
            NR>1 && $1 == size {
                printf "%-10s %-12.2f %-12.2f %-8d %-8d %-12d\n", $2, $3, $4, $5, $6, $7
            }
        ' "$OUTPUT_SUMMARY_BY_DENSITY"
        echo ""
    done
    
    echo "========================================"
    echo "ARCHIVOS GENERADOS:"
    echo "  - CSV completo: $OUTPUT_CSV"
    echo "  - Resumen por densidad: $OUTPUT_SUMMARY_BY_DENSITY"
    echo "  - Resumen general: $OUTPUT_SUMMARY"
    echo "========================================"
    
} | tee "$OUTPUT_SUMMARY"

echo ""
echo "Análisis completado exitosamente!"
echo "Revisa los archivos:"
echo "  - $OUTPUT_CSV"
echo "  - $OUTPUT_SUMMARY_BY_DENSITY"
echo "  - $OUTPUT_SUMMARY"

#!/bin/bash

# Script para analizar los resultados de los experimentos Slurm
# Genera un resumen en CSV con todos los resultados

RESULTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resultados"
OUTPUT_CSV="${RESULTS_DIR}/analisis_resultados.csv"
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
echo "Generando resumen estadístico..."
echo "========================================="

# Generar resumen estadístico
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
    
    # Si hay valores objetivos numéricos, calcular estadísticas
    if awk -F',' 'NR>1 && $5 != "N/A" {exit 0} END {exit 1}' "$OUTPUT_CSV"; then
        echo "ESTADÍSTICAS DE VALORES OBJETIVO:"
        awk -F',' 'NR>1 && $5 != "N/A" {sum+=$5; count++; if(min=="" || $5<min) min=$5; if($5>max) max=$5} 
                  END {
                      if(count>0) {
                          printf "  - Mínimo: %d\n", min
                          printf "  - Máximo: %d\n", max
                          printf "  - Promedio: %.2f\n", sum/count
                          printf "  - Total evaluaciones: %d\n", count
                      }
                  }' "$OUTPUT_CSV"
        echo ""
    fi
    
    echo "========================================"
    echo "ARCHIVOS GENERADOS:"
    echo "  - CSV completo: $OUTPUT_CSV"
    echo "  - Resumen: $OUTPUT_SUMMARY"
    echo "========================================"
    
} | tee "$OUTPUT_SUMMARY"

echo ""
echo "Análisis completado exitosamente!"
echo "Revisa los archivos:"
echo "  - $OUTPUT_CSV"
echo "  - $OUTPUT_SUMMARY"

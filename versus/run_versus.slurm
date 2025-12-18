#!/bin/bash
#SBATCH --job-name=versus_misp
#SBATCH --output=resultados/%x_%A.stdout
#SBATCH --error=resultados/%x_%A.stderr
#SBATCH --partition=main
#SBATCH --mem=16G
#SBATCH --time=00:20:00
#SBATCH -n 1
#SBATCH --cpus-per-task=1

# Rutas en el servidor luthier
PROJECT_DIR="/home/shared/sisadapt2/misp_project/MISP-project"
DATASET_DIR="/home/shared/sisadapt2/misp_project/dataset_grafos_no_dirigidos"
VERSUS_DIR="${PROJECT_DIR}/versus"

# Tiempo de ejecución en segundos (15 minutos)
TIME_LIMIT=900

# Mejor grafo encontrado (ajustar según tus resultados)
# Este es un ejemplo - debes elegir el mejor grafo de tus experimentos
BEST_GRAPH="${DATASET_DIR}/new_1000_dataset/erdos_n1000_p0c0.05_1.graph"

# Verificar que existen los binarios
if [ ! -f "${VERSUS_DIR}/SA" ]; then
    echo "ERROR: No se encuentra el binario SA"
    exit 1
fi

if [ ! -f "${VERSUS_DIR}/BRKGA" ]; then
    echo "ERROR: No se encuentra el binario BRKGA"
    exit 1
fi

if [ ! -f "${VERSUS_DIR}/BRKGA_hibrid" ]; then
    echo "ERROR: No se encuentra el binario BRKGA_hibrid"
    exit 1
fi

if [ ! -f "${BEST_GRAPH}" ]; then
    echo "ERROR: No se encuentra el grafo ${BEST_GRAPH}"
    exit 1
fi

# Crear directorio de resultados
RESULTS_DIR="${VERSUS_DIR}/results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "${RESULTS_DIR}"
mkdir -p "${VERSUS_DIR}/resultados"

cd "${VERSUS_DIR}"

echo "======================================"
echo "Iniciando VERSUS entre SA, BRKGA y BRKGA_hibrid"
echo "Grafo: ${BEST_GRAPH}"
echo "Tiempo límite: ${TIME_LIMIT} segundos (15 minutos)"
echo "Resultados en: ${RESULTS_DIR}"
echo "======================================"
echo ""

# Ejecutar SA
echo "Ejecutando SA..."
./SA "${BEST_GRAPH}" ${TIME_LIMIT} > "${RESULTS_DIR}/sa_anytime.txt" 2>&1
if [ $? -eq 0 ]; then
    echo "SA completado ✓"
else
    echo "SA falló ✗"
fi
echo ""

# Ejecutar BRKGA
echo "Ejecutando BRKGA..."
./BRKGA "${BEST_GRAPH}" ${TIME_LIMIT} > "${RESULTS_DIR}/brkga_anytime.txt" 2>&1
if [ $? -eq 0 ]; then
    echo "BRKGA completado ✓"
else
    echo "BRKGA falló ✗"
fi
echo ""

# Ejecutar BRKGA_hibrid
echo "Ejecutando BRKGA_hibrid..."
./BRKGA_hibrid "${BEST_GRAPH}" ${TIME_LIMIT} > "${RESULTS_DIR}/brkga_hibrid_anytime.txt" 2>&1
if [ $? -eq 0 ]; then
    echo "BRKGA_hibrid completado ✓"
else
    echo "BRKGA_hibrid falló ✗"
fi
echo ""

echo "======================================"
echo "VERSUS completado"
echo "Resultados guardados en: ${RESULTS_DIR}"
echo "======================================"

# Mostrar resumen de resultados
echo ""
echo "=== RESUMEN DE RESULTADOS ==="
for file in "${RESULTS_DIR}"/*_anytime.txt; do
    if [ -f "$file" ]; then
        echo ""
        echo "Archivo: $(basename $file)"
        echo "Líneas: $(wc -l < $file)"
        if [ -s "$file" ]; then
            echo "Primera línea: $(head -n1 $file)"
            echo "Última línea: $(tail -n1 $file)"
        fi
    fi
done

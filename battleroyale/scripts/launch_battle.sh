#!/bin/bash

# Script maestro para lanzar Battle Royale completo
# Ejecuta SA, BRKGA y BRKGA_HIBRID en el cluster

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Battle Royale - Lanzamiento de Experimentos Completos     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Parámetros
INSTANCE=$1
TIME=${2:-3600}  # Default: 60 minutos
SAMPLE=${3:-5}   # Default: cada 5 segundos

if [ -z "$INSTANCE" ]; then
    echo "Error: Falta archivo de instancia"
    echo ""
    echo "Uso: bash battleroyale/scripts/launch_battle.sh <instancia> [tiempo_segundos] [intervalo]"
    echo ""
    echo "Ejemplo:"
    echo "  bash battleroyale/scripts/launch_battle.sh dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.7_1.graph 3600 5"
    echo ""
    exit 1
fi

# Verificar que existe la instancia
if [ ! -f "$INSTANCE" ]; then
    echo "ERROR: No se encuentra el archivo $INSTANCE"
    exit 1
fi

BASENAME=$(basename "$INSTANCE")

echo "📊 Instancia:        $BASENAME"
echo "⏱️  Tiempo límite:    $TIME segundos ($((TIME/60)) minutos)"
echo "📈 Intervalo:        $SAMPLE segundos"
echo ""

# Detectar si estamos en el cluster o en local
if [ -d "/home/shared/sisadapt2/misp_project/MISP-project" ]; then
    BASE_DIR="/home/shared/sisadapt2/misp_project/MISP-project"
    SCRIPT_PREFIX="$BASE_DIR/battleroyale"
    echo "🖥️  Modo: Cluster (ruta: $BASE_DIR)"
else
    BASE_DIR=$(pwd)
    SCRIPT_PREFIX="battleroyale"
    echo "💻 Modo: Local"
fi

echo ""

# Verificar que existe la instancia
if [ ! -f "$INSTANCE" ]; then
    echo "ERROR: No se encuentra el archivo $INSTANCE"
    exit 1
fi
if [ ! -f "battleroyale/sa_standalone" ] || [ ! -f "battleroyale/brkga_standalone" ]; then
    echo "⚠️  Ejecutables no encontrados. Compilando..."
    bash battleroyale/scripts/compile_all.sh
    echo ""
fi

echo "Lanzando jobs en el cluster..."
echo "══════════════════════════════════════════════════════════════"

# Cambiar al directorio correcto para sbatch
if [ "$BASE_DIR" != "$(pwd)" ]; then
    cd "$BASE_DIR"
fi

# Lanzar SA
JOB_SA=$(sbatch --parsable ${SCRIPT_PREFIX}/run_sa_anytime.sh "$INSTANCE" "$TIME" "$SAMPLE")
echo "✓ SA lanzado         - Job ID: $JOB_SA"

# Lanzar BRKGA
JOB_BRKGA=$(sbatch --parsable ${SCRIPT_PREFIX}/run_brkga_anytime.sh "$INSTANCE" "$TIME" "$SAMPLE")
echo "✓ BRKGA lanzado      - Job ID: $JOB_BRKGA"

# Lanzar BRKGA_HIBRID
JOB_HIBRID=$(sbatch --parsable ${SCRIPT_PREFIX}/run_brkga_hibrid_anytime.sh "$INSTANCE" "$TIME" "$SAMPLE")
echo "✓ BRKGA_HIBRID lanzado - Job ID: $JOB_HIBRID"

echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✓ Todos los jobs lanzados exitosamente"
echo ""
echo "Jobs IDs:"
echo "  - SA:           $JOB_SA"
echo "  - BRKGA:        $JOB_BRKGA"
echo "  - BRKGA_HIBRID: $JOB_HIBRID"
echo ""
echo "Monitorear progreso con:"
echo "  squeue -u \$USER"
echo ""
echo "Ver estado específico:"
echo "  squeue -j $JOB_SA,$JOB_BRKGA,$JOB_HIBRID"
echo ""
echo "Cancelar todos:"
echo "  scancel $JOB_SA $JOB_BRKGA $JOB_HIBRID"
echo ""
echo "Los resultados se guardarán en battleroyale/resultados/"
echo ""

#!/bin/bash
#SBATCH --job-name=battle_sa
#SBATCH --output=resultados/sa_%x_%j.stdout
#SBATCH --error=resultados/sa_%x_%j.stderr
#SBATCH --partition=main
#SBATCH --mem=8G
#SBATCH --time=01:10:00
#SBATCH -n 1
#SBATCH --cpus-per-task=1

# Battle Royale: Ejecución de Simulated Annealing con seguimiento Anytime
# Tiempo: 60 minutos (3600 segundos)
# Muestreo: cada 5 segundos

# Captura de argumentos
INSTANCE=$1
TIME=${2:-3600}  # Default: 3600 segundos (60 minutos)
SAMPLE_INTERVAL=${3:-5}  # Default: cada 5 segundos

# Validación
if [ -z "$INSTANCE" ]; then
    echo "Error: Falta archivo de instancia"
    echo "Uso: sbatch run_sa_anytime.sh <ruta_instancia> [tiempo_segundos] [intervalo_muestreo]"
    echo "Ejemplo: sbatch run_sa_anytime.sh dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.7_1.graph 3600 5"
    exit 1
fi

# Extraer nombre base del grafo para el output
BASENAME=$(basename "$INSTANCE" .graph)
OUTPUT_FILE="${BASE_DIR}/battleroyale/resultados/sa_${BASENAME}_${TIME}s.csv"

# Información del job
echo "═══════════════════════════════════════════════════════════"
echo "  BATTLE ROYALE - Simulated Annealing Anytime"
echo "═══════════════════════════════════════════════════════════"
echo "Job ID:       $SLURM_JOB_ID"
echo "Nodo:         $SLURM_NODELIST"
echo "Instancia:    $INSTANCE"
echo "Tiempo:       $TIME segundos"
echo "Intervalo:    $SAMPLE_INTERVAL segundos"
echo "Output:       $OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Detectar ruta base (cluster o local)
if [ -d "/home/shared/sisadapt2/misp_project/MISP-project" ]; then
    BASE_DIR="/home/shared/sisadapt2/misp_project/MISP-project"
else
    BASE_DIR="."
fi

# Ruta al ejecutable
EXE="${BASE_DIR}/battleroyale/bin/sa_standalone"

# Verificar que existe el ejecutable
if [ ! -f "$EXE" ]; then
    echo "ERROR: No se encuentra el ejecutable $EXE"
    echo "Ejecuta primero: bash battleroyale/scripts/compile_all.sh"
    exit 1
fi

# Inicio del experimento
START_TIME=$(date +%s)
echo "Inicio: $(date)"
echo ""

# Ejecutar SA con seguimiento anytime
srun ${EXE} -i ${INSTANCE} -t ${TIME} -s ${SAMPLE_INTERVAL} -o ${OUTPUT_FILE}

EXIT_CODE=$?

# Fin del experimento
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Fin: $(date)"
echo "Duración real: $ELAPSED segundos"
echo "Código de salida: $EXIT_CODE"
echo "═══════════════════════════════════════════════════════════"

exit $EXIT_CODE

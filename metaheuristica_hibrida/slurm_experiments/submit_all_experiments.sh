#!/bin/bash

# Script para enviar todos los experimentos al cluster usando Slurm
# Ejecuta todas las instancias del dataset con los mejores parámetros

# Configuración
DATASET_DIR="/home/shared/sisadapt2/dataset_grafos_no_dirigidos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/resultados"
LOG_FILE="${SCRIPT_DIR}/submission.log"

# Crear directorio de resultados si no existe
mkdir -p "$RESULTS_DIR"

# Limpiar log anterior
> "$LOG_FILE"

echo "=========================================" | tee -a "$LOG_FILE"
echo "Iniciando envío de experimentos" | tee -a "$LOG_FILE"
echo "Fecha: $(date)" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Contador de jobs enviados
TOTAL_JOBS=0
FAILED_JOBS=0

# Semilla fija
SEEDS=(42)

# Buscar todas las instancias .graph
echo "Buscando instancias en: $DATASET_DIR" | tee -a "$LOG_FILE"
INSTANCES=($(find "$DATASET_DIR" -name "*.graph" -type f | sort))
TOTAL_INSTANCES=${#INSTANCES[@]}

echo "Total de instancias encontradas: $TOTAL_INSTANCES" | tee -a "$LOG_FILE"
echo "Semillas a usar: ${SEEDS[@]}" | tee -a "$LOG_FILE"
echo "Total de experimentos: $((TOTAL_INSTANCES * ${#SEEDS[@]}))" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Iterar sobre todas las instancias y semillas
for INSTANCE in "${INSTANCES[@]}"; do
    INSTANCE_NAME=$(basename "$INSTANCE")
    
    for SEED in "${SEEDS[@]}"; do
        # Enviar job a Slurm
        JOB_NAME="misp_${INSTANCE_NAME%.graph}_s${SEED}"
        
        JOBID=$(sbatch \
            --job-name="$JOB_NAME" \
            --output="${RESULTS_DIR}/${JOB_NAME}_%j.stdout" \
            --error="${RESULTS_DIR}/${JOB_NAME}_%j.stderr" \
            "${SCRIPT_DIR}/run_single_experiment.sh" \
            "$INSTANCE" \
            "$SEED" 2>&1)
        
        if [ $? -eq 0 ]; then
            TOTAL_JOBS=$((TOTAL_JOBS + 1))
            echo "[OK] Job $TOTAL_JOBS enviado: $JOB_NAME (JobID: $JOBID)" | tee -a "$LOG_FILE"
        else
            FAILED_JOBS=$((FAILED_JOBS + 1))
            echo "[ERROR] Falló el envío de: $JOB_NAME" | tee -a "$LOG_FILE"
            echo "        Error: $JOBID" >> "$LOG_FILE"
        fi
    done
done

echo "" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"
echo "Resumen del envío de jobs:" | tee -a "$LOG_FILE"
echo "  - Total jobs enviados: $TOTAL_JOBS" | tee -a "$LOG_FILE"
echo "  - Fallos: $FAILED_JOBS" | tee -a "$LOG_FILE"
echo "  - Fecha finalización: $(date)" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Para verificar el estado de los jobs, usa: squeue -u \$USER" | tee -a "$LOG_FILE"
echo "Para ver los resultados: ls -lh $RESULTS_DIR" | tee -a "$LOG_FILE"

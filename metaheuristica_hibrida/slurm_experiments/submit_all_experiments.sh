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

# Configuración de instancias específicas (igual que run_optimized.py)
SIZES=("1000" "2000" "3000")
DENSITIES=("0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9")
NUM_INSTANCES=30  # Instancias del 1 al 30

# Construir lista de instancias
INSTANCES=()
echo "Construyendo lista de instancias..." | tee -a "$LOG_FILE"
for size in "${SIZES[@]}"; do
    for density in "${DENSITIES[@]}"; do
        for i in $(seq 1 $NUM_INSTANCES); do
            instance_path="${DATASET_DIR}/new_${size}_dataset/erdos_n${size}_p0c${density}_${i}.graph"
            if [ -f "$instance_path" ]; then
                INSTANCES+=("$instance_path")
            fi
        done
    done
done

TOTAL_INSTANCES=${#INSTANCES[@]}
echo "Total de instancias encontradas: $TOTAL_INSTANCES" | tee -a "$LOG_FILE"
echo "Configuración:" | tee -a "$LOG_FILE"
echo "  - Tamaños: ${SIZES[@]}" | tee -a "$LOG_FILE"
echo "  - Densidades: ${#DENSITIES[@]} valores (${DENSITIES[0]} a ${DENSITIES[-1]})" | tee -a "$LOG_FILE"
echo "  - Instancias por combinación: $NUM_INSTANCES" | tee -a "$LOG_FILE"
echo "  - Semilla: ${SEEDS[@]}" | tee -a "$LOG_FILE"
echo "  - Total de experimentos: $TOTAL_INSTANCES" | tee -a "$LOG_FILE"
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

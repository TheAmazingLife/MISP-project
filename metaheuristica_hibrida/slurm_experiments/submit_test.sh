#!/bin/bash

# Script para enviar experimentos de prueba (solo algunas instancias)
# Útil para verificar que todo funcione antes de enviar los 8840 experimentos completos

DATASET_DIR="/home/shared/sisadapt2/misp_project/dataset_grafos_no_dirigidos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/resultados_test"
LOG_FILE="${SCRIPT_DIR}/test_submission.log"

# Crear directorio de resultados de prueba
mkdir -p "$RESULTS_DIR"

# Limpiar log anterior
> "$LOG_FILE"

echo "=========================================" | tee -a "$LOG_FILE"
echo "Envío de Experimentos de Prueba" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"
echo ""

# Configuración de prueba
NUM_INSTANCES=3  # Solo 3 instancias para probar
SEEDS=(42)  # Semilla fija

echo "Configuración de prueba:" | tee -a "$LOG_FILE"
echo "  - Número de instancias: $NUM_INSTANCES" | tee -a "$LOG_FILE"
echo "  - Semillas: ${SEEDS[@]}" | tee -a "$LOG_FILE"
echo "  - Total de experimentos: $((NUM_INSTANCES * ${#SEEDS[@]}))" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Buscar algunas instancias de prueba (una pequeña, una mediana, una grande)
echo "Buscando instancias de prueba..." | tee -a "$LOG_FILE"

INSTANCE_1000=$(find "$DATASET_DIR" -name "*n1000*.graph" -type f | head -1)
INSTANCE_2000=$(find "$DATASET_DIR" -name "*n2000*.graph" -type f | head -1)
INSTANCE_3000=$(find "$DATASET_DIR" -name "*n3000*.graph" -type f | head -1)

INSTANCES=("$INSTANCE_1000" "$INSTANCE_2000" "$INSTANCE_3000")

echo "Instancias seleccionadas:" | tee -a "$LOG_FILE"
for inst in "${INSTANCES[@]}"; do
    echo "  - $(basename "$inst")" | tee -a "$LOG_FILE"
done
echo "" | tee -a "$LOG_FILE"

# Contador de jobs
TOTAL_JOBS=0

# Enviar los jobs de prueba
echo "Enviando jobs de prueba..." | tee -a "$LOG_FILE"
for INSTANCE in "${INSTANCES[@]}"; do
    [ -f "$INSTANCE" ] || continue
    INSTANCE_NAME=$(basename "$INSTANCE")
    
    for SEED in "${SEEDS[@]}"; do
        JOB_NAME="test_misp_${INSTANCE_NAME%.graph}_s${SEED}"
        
        JOBID=$(sbatch \
            --job-name="$JOB_NAME" \
            --output="${RESULTS_DIR}/${JOB_NAME}_%j.stdout" \
            --error="${RESULTS_DIR}/${JOB_NAME}_%j.stderr" \
            "${SCRIPT_DIR}/run_single_experiment.sh" \
            "$INSTANCE" \
            "$SEED" 2>&1)
        
        if [ $? -eq 0 ]; then
            TOTAL_JOBS=$((TOTAL_JOBS + 1))
            echo "[OK] Job $TOTAL_JOBS enviado: $JOB_NAME" | tee -a "$LOG_FILE"
            echo "     JobID: $JOBID" | tee -a "$LOG_FILE"
        else
            echo "[ERROR] Falló el envío de: $JOB_NAME" | tee -a "$LOG_FILE"
            echo "        Error: $JOBID" | tee -a "$LOG_FILE"
        fi
    done
done

echo "" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"
echo "Jobs de prueba enviados: $TOTAL_JOBS" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Para verificar el estado:" | tee -a "$LOG_FILE"
echo "  squeue -u \$USER" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Los resultados estarán en:" | tee -a "$LOG_FILE"
echo "  $RESULTS_DIR" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Una vez completados, verifica los resultados:" | tee -a "$LOG_FILE"
echo "  ls -lh $RESULTS_DIR" | tee -a "$LOG_FILE"
echo "  cat $RESULTS_DIR/*.stdout" | tee -a "$LOG_FILE"

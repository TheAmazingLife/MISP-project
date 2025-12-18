#!/bin/bash

# Script para verificar el estado de los jobs en Slurm
# Útil para monitorear el progreso de los experimentos

RESULTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resultados"

echo "========================================="
echo "Estado de los Experimentos BRKGA-MISP"
echo "========================================="
echo ""

# Información del usuario
echo "Usuario: $USER"
echo "Fecha: $(date)"
echo ""

# Estado de los jobs en la cola
echo "--- JOBS EN LA COLA ---"
squeue -u $USER -o "%.18i %.12j %.8T %.10M %.9l %.6D %R" | head -20
TOTAL_QUEUE=$(squeue -u $USER | wc -l)
echo ""
echo "Total de jobs en cola: $((TOTAL_QUEUE - 1))"
echo ""

# Resumen por estado
echo "--- RESUMEN POR ESTADO ---"
squeue -u $USER -t RUNNING -h | wc -l | xargs echo "  - Running (ejecutando):"
squeue -u $USER -t PENDING -h | wc -l | xargs echo "  - Pending (en espera):"
squeue -u $USER -t COMPLETING -h | wc -l | xargs echo "  - Completing (finalizando):"
echo ""

# Jobs recientes completados
echo "--- ÚLTIMOS JOBS COMPLETADOS ---"
sacct -u $USER --starttime=$(date -d '1 day ago' +%Y-%m-%d) --format=JobID,JobName%30,State,Elapsed,ExitCode --state=COMPLETED,FAILED | tail -15
echo ""

# Archivos de resultados generados
if [ -d "$RESULTS_DIR" ]; then
    echo "--- ARCHIVOS DE RESULTADOS ---"
    TOTAL_STDOUT=$(find "$RESULTS_DIR" -name "*.stdout" -type f 2>/dev/null | wc -l)
    TOTAL_STDERR=$(find "$RESULTS_DIR" -name "*.stderr" -type f 2>/dev/null | wc -l)
    echo "  - Archivos .stdout: $TOTAL_STDOUT"
    echo "  - Archivos .stderr: $TOTAL_STDERR"
    
    # Últimos archivos modificados
    echo ""
    echo "  Últimos 5 archivos generados:"
    find "$RESULTS_DIR" -name "*.stdout" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | head -5 | \
        awk '{print "    - " $2 " (" strftime("%Y-%m-%d %H:%M:%S", $1) ")"}'
fi

echo ""
echo "========================================="
echo "Comandos útiles:"
echo "  - Ver cola completa: squeue -u \$USER"
echo "  - Ver detalles de un job: scontrol show job <JOB_ID>"
echo "  - Cancelar un job: scancel <JOB_ID>"
echo "  - Cancelar todos: scancel -u \$USER"
echo "  - Ver historial: sacct -u \$USER"
echo "========================================="

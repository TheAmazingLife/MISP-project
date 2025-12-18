#!/bin/bash
#SBATCH --job-name=brkga_misp
#SBATCH --output=resultados/%x_%A.stdout
#SBATCH --error=resultados/%x_%A.stderr
#SBATCH --partition=main
#SBATCH --mem=16G
#SBATCH --time=00:02:00
#SBATCH -n 1

# Script para ejecutar un experimento individual con los mejores parámetros encontrados
# Parámetros óptimos: -p 340 -pe 0.17 -pm 0.24 -rhoe 0.78
# Tiempo de ejecución: 60 segundos

# Captura de argumentos
INSTANCE=$1
SEED=$2

# Validación de argumentos
if [ -z "$INSTANCE" ] || [ -z "$SEED" ]; then
    echo "Error: Faltan argumentos"
    echo "Uso: sbatch run_single_experiment.sh <ruta_instancia> <seed>"
    exit 1
fi

# Configuración de rutas
EXE="/home/shared/sisadapt2/metaheuristica_hibrida/brkga_hibrid"

# Parámetros óptimos
POPULATION=340
PE=0.17
PM=0.24
RHOE=0.78
TIME=60

# Información del job
echo "========================================="
echo "Job ID: $SLURM_JOB_ID"
echo "Nodo: $SLURM_NODELIST"
echo "Instancia: $INSTANCE"
echo "Seed: $SEED"
echo "Parámetros: -p $POPULATION -pe $PE -pm $PM -rhoe $RHOE"
echo "Tiempo: $TIME segundos"
echo "========================================="
echo ""

# Ejecución del programa
srun ${EXE} -i ${INSTANCE} -t ${TIME} -seed ${SEED} -p ${POPULATION} -pe ${PE} -pm ${PM} -rhoe ${RHOE}

# Código de salida
EXIT_CODE=$?
echo ""
echo "========================================="
echo "Experimento finalizado con código: $EXIT_CODE"
echo "========================================="

exit $EXIT_CODE

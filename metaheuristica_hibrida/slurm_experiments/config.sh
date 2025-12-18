# Configuración centralizada para experimentos Slurm
# Este archivo es leído por los scripts de ejecución

# =============================================
# PARÁMETROS ÓPTIMOS DEL ALGORITMO
# =============================================
# Encontrados mediante tuning con irace
OPTIMAL_POPULATION=340
OPTIMAL_PE=0.17
OPTIMAL_PM=0.24
OPTIMAL_RHOE=0.78
OPTIMAL_TIME=60  # segundos

# =============================================
# RUTAS DEL CLUSTER
# =============================================
CLUSTER_SHARED_DIR="/home/shared/sisadapt2"
CLUSTER_EXE="${CLUSTER_SHARED_DIR}/metaheuristica_hibrida/brkga_hibrid"
CLUSTER_DATASET="${CLUSTER_SHARED_DIR}/dataset_grafos_no_dirigidos"

# =============================================
# CONFIGURACIÓN DE SLURM
# =============================================
SLURM_PARTITION="main"
SLURM_MEMORY="16G"
SLURM_TIME="00:02:00"  # 2 minutos
SLURM_TASKS=1

# =============================================
# SEMILLAS PARA EXPERIMENTOS
# =============================================
# Semilla fija para reproducibilidad
EXPERIMENT_SEEDS=(42)

# =============================================
# INFORMACIÓN DEL EXPERIMENTO
# =============================================
EXPERIMENT_NAME="BRKGA-MISP Optimal Parameters"
EXPERIMENT_DATE=$(date +%Y-%m-%d)
EXPERIMENT_DESCRIPTION="Experimentos con parámetros óptimos encontrados por irace"

# =============================================
# NOTAS
# =============================================
# - Total de instancias en dataset: ~1768
# - Total de semillas: 1 (fija: 42)
# - Total de experimentos: ~1768
# - Tiempo estimado por experimento: 60 segundos
# - Memoria por job: 16GB

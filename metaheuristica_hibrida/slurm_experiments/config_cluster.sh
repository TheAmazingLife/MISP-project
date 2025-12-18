#!/bin/bash

# Script de configuración para el cluster Luthier
# Este script debe ejecutarse en el cluster para configurar el entorno

echo "========================================="
echo "Configuración de Experimentos Slurm"
echo "========================================="
echo ""

# Configuración de rutas en el cluster
SHARED_DIR="/home/shared/sisadapt2"
LOCAL_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Directorio local: $LOCAL_SOURCE_DIR"
echo "Directorio compartido: $SHARED_DIR"
echo ""

# 1. Crear estructura de directorios en shared
echo "1. Creando estructura de directorios..."
mkdir -p "${SHARED_DIR}/metaheuristica_hibrida"
mkdir -p "${SHARED_DIR}/dataset_grafos_no_dirigidos"
echo "   ✓ Directorios creados"
echo ""

# 2. Compilar el ejecutable si es necesario
echo "2. Verificando ejecutable..."
if [ ! -f "${SHARED_DIR}/metaheuristica_hibrida/brkga_hibrid" ]; then
    echo "   El ejecutable no existe en shared. ¿Deseas compilarlo ahora? (s/n)"
    read -r respuesta
    if [ "$respuesta" = "s" ]; then
        echo "   Compilando..."
        cd "${LOCAL_SOURCE_DIR}/source" || exit 1
        make clean
        make
        if [ -f "brkga_hibrid" ]; then
            cp brkga_hibrid "${SHARED_DIR}/metaheuristica_hibrida/"
            echo "   ✓ Ejecutable compilado y copiado"
        else
            echo "   ✗ Error en la compilación"
            exit 1
        fi
    fi
else
    echo "   ✓ Ejecutable ya existe: ${SHARED_DIR}/metaheuristica_hibrida/brkga_hibrid"
fi
echo ""

# 3. Copiar dataset
echo "3. Verificando dataset..."
DATASET_COUNT=$(find "${SHARED_DIR}/dataset_grafos_no_dirigidos" -name "*.graph" 2>/dev/null | wc -l)
if [ "$DATASET_COUNT" -lt 100 ]; then
    echo "   Dataset no completo o no existe. Copiando desde local..."
    echo "   Esto puede tardar varios minutos..."
    
    LOCAL_DATASET="${LOCAL_SOURCE_DIR}/../dataset_grafos_no_dirigidos"
    if [ -d "$LOCAL_DATASET" ]; then
        rsync -av --progress "$LOCAL_DATASET/" "${SHARED_DIR}/dataset_grafos_no_dirigidos/"
        echo "   ✓ Dataset copiado"
    else
        echo "   ✗ No se encontró el dataset local en: $LOCAL_DATASET"
        echo "   Por favor, copia manualmente el dataset a: ${SHARED_DIR}/dataset_grafos_no_dirigidos/"
    fi
else
    echo "   ✓ Dataset ya existe ($DATASET_COUNT archivos .graph encontrados)"
fi
echo ""

# 4. Verificar permisos
echo "4. Verificando permisos..."
chmod +x "${LOCAL_SOURCE_DIR}/slurm_experiments"/*.sh
echo "   ✓ Scripts con permisos de ejecución"
echo ""

# 5. Crear directorio de resultados
echo "5. Creando directorio de resultados..."
mkdir -p "${LOCAL_SOURCE_DIR}/slurm_experiments/resultados"
echo "   ✓ Directorio de resultados listo"
echo ""

# 6. Verificar acceso a Slurm
echo "6. Verificando acceso a Slurm..."
if command -v squeue &> /dev/null; then
    echo "   ✓ Slurm disponible"
    echo "   Particiones disponibles:"
    sinfo -s | sed 's/^/     /'
else
    echo "   ✗ Slurm no está disponible en este nodo"
    echo "   Asegúrate de ejecutar este script en el nodo de login del cluster"
fi
echo ""

# Resumen
echo "========================================="
echo "Configuración completada"
echo "========================================="
echo ""
echo "Próximos pasos:"
echo "  1. Verifica que el ejecutable funcione:"
echo "     ${SHARED_DIR}/metaheuristica_hibrida/brkga_hibrid --help"
echo ""
echo "  2. Verifica que el dataset esté completo:"
echo "     find ${SHARED_DIR}/dataset_grafos_no_dirigidos -name '*.graph' | wc -l"
echo ""
echo "  3. Envía los experimentos:"
echo "     cd ${LOCAL_SOURCE_DIR}/slurm_experiments"
echo "     ./submit_all_experiments.sh"
echo ""
echo "========================================="

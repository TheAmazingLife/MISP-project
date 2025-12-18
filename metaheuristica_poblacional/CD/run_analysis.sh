#!/bin/bash

# Script para ejecutar el análisis estadístico completo de MISP
# Automatiza la generación de results.dat y el análisis en R

set -e  # Salir si hay errores

echo "======================================================================"
echo "  ANÁLISIS ESTADÍSTICO COMPLETO - ALGORITMOS MISP"
echo "======================================================================"
echo ""

# Directorio base
BASE_DIR="/home/amzng/Documents/GitHub/universidad/s2-25/sistemas_adaptativos/MISP-project/metaheuristica_poblacional/CD"
cd "$BASE_DIR"

# Paso 1: Generar results.dat
echo "Paso 1/3: Generando archivo results.dat..."
echo "----------------------------------------------------------------------"
python3 generate_results_dat.py

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ ERROR al generar results.dat"
    exit 1
fi

echo ""
echo "✓ results.dat generado exitosamente"
echo ""

# Paso 2: Verificar results.dat
echo "Paso 2/3: Verificando archivo results.dat..."
echo "----------------------------------------------------------------------"
python3 verify_results.py

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ ERROR en la verificación de results.dat"
    exit 1
fi

echo ""

# Paso 3: Ejecutar análisis en R
echo "Paso 3/3: Ejecutando análisis estadístico en R..."
echo "----------------------------------------------------------------------"
cd SandBox

# Ejecutar script de R
Rscript statistical_evaluation_misp.R

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ ERROR al ejecutar el análisis en R"
    echo "Verifica que la librería 'scmamp' esté instalada:"
    echo "  sudo R"
    echo "  > install.packages('devtools')"
    echo "  > devtools::install_github('b0rxa/scmamp')"
    exit 1
fi

echo ""
echo "======================================================================"
echo "  ANÁLISIS COMPLETADO EXITOSAMENTE"
echo "======================================================================"
echo ""
echo "Los gráficos PDF han sido generados en:"
echo "  $BASE_DIR/SandBox/"
echo ""
echo "Gráficos generados:"
ls -1 "$BASE_DIR/SandBox/"CD_plot_misp*.pdf 2>/dev/null || echo "  (No se encontraron gráficos PDF)"
echo ""
echo "Para ver los gráficos, abre los archivos PDF con tu visor preferido."
echo ""

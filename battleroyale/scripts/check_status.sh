#!/bin/bash

# Script para verificar el estado de los jobs del Battle Royale

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Battle Royale - Estado de Jobs                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Jobs del usuario relacionados con battle
echo "Jobs activos del Battle Royale:"
echo "────────────────────────────────────────────────────────────────"
squeue -u $USER --name=battle_sa,battle_brkga,battle_hibrid -o "%.10i %.12j %.10u %.2t %.10M %.6D %.20R"

echo ""
echo "Resumen:"
squeue -u $USER --name=battle_sa,battle_brkga,battle_hibrid | tail -n +2 | wc -l | xargs echo "  Jobs en cola/ejecución:"

echo ""
echo "Estados: PD=Pendiente, R=Ejecutando, CG=Completando"
echo ""

# Verificar resultados disponibles
echo "────────────────────────────────────────────────────────────────"
echo "Resultados disponibles:"
echo ""

if [ -d "battleroyale/resultados" ]; then
    SA_FILES=$(ls battleroyale/resultados/sa_*.csv 2>/dev/null | wc -l)
    BRKGA_FILES=$(ls battleroyale/resultados/brkga_*.csv 2>/dev/null | wc -l)
    HIBRID_FILES=$(ls battleroyale/resultados/hibrid_*.csv 2>/dev/null | wc -l)
    
    echo "  SA:           $SA_FILES archivos CSV"
    echo "  BRKGA:        $BRKGA_FILES archivos CSV"
    echo "  BRKGA_HIBRID: $HIBRID_FILES archivos CSV"
    
    if [ $SA_FILES -gt 0 ] || [ $BRKGA_FILES -gt 0 ] || [ $HIBRID_FILES -gt 0 ]; then
        echo ""
        echo "Archivos recientes:"
        ls -lht battleroyale/resultados/*.csv 2>/dev/null | head -5
    fi
else
    echo "  Carpeta de resultados no encontrada"
fi

echo ""

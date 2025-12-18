#!/bin/bash

# Script para cancelar todos los jobs del Battle Royale

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Battle Royale - Cancelar Jobs                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Obtener IDs de jobs activos
JOB_IDS=$(squeue -u $USER --name=battle_sa,battle_brkga,battle_hibrid -h -o "%i")

if [ -z "$JOB_IDS" ]; then
    echo "No hay jobs del Battle Royale en ejecución o en cola."
    exit 0
fi

echo "Jobs a cancelar:"
squeue -u $USER --name=battle_sa,battle_brkga,battle_hibrid -o "%.10i %.12j %.10u %.2t %.10M"

echo ""
read -p "¿Confirmar cancelación de todos los jobs? (s/N): " confirm

if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
    echo ""
    echo "Cancelando jobs..."
    scancel $JOB_IDS
    echo "✓ Jobs cancelados"
else
    echo "Cancelación abortada"
fi

#!/bin/bash

# Script para cancelar todos los jobs del usuario
# Útil si necesitas detener los experimentos

echo "========================================="
echo "Cancelar Jobs - BRKGA MISP"
echo "========================================="
echo ""

# Mostrar jobs actuales
TOTAL_JOBS=$(squeue -u $USER -h | wc -l)

if [ "$TOTAL_JOBS" -eq 0 ]; then
    echo "No tienes jobs en la cola."
    exit 0
fi

echo "Tienes $TOTAL_JOBS jobs en la cola:"
echo ""
squeue -u $USER -o "%.18i %.12j %.8T %.10M %.6D %R"
echo ""

# Confirmar cancelación
echo "¿Estás seguro de que quieres cancelar TODOS estos jobs? (s/n)"
read -r respuesta

if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
    echo "Cancelación abortada."
    exit 0
fi

echo ""
echo "Cancelando todos los jobs..."
scancel -u $USER

# Esperar un momento para que se procese
sleep 2

# Verificar
REMAINING=$(squeue -u $USER -h | wc -l)

if [ "$REMAINING" -eq 0 ]; then
    echo "✓ Todos los jobs han sido cancelados exitosamente."
else
    echo "Quedan $REMAINING jobs (puede tomar unos segundos en procesarse)."
    echo "Verifica con: squeue -u \$USER"
fi

echo ""
echo "========================================="

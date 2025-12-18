#!/bin/bash

# Script de inicio rápido para Battle Royale
# Guía interactiva para seleccionar el grafo y lanzar experimentos

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Battle Royale - Inicio Rápido                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar compilación
if [ ! -f "battleroyale/sa_standalone" ] || [ ! -f "battleroyale/brkga_standalone" ]; then
    echo -e "${YELLOW}⚠️  Los ejecutables no están compilados.${NC}"
    echo ""
    read -p "¿Compilar ahora? (S/n): " compile
    if [ "$compile" != "n" ] && [ "$compile" != "N" ]; then
        bash battleroyale/scripts/compile_all.sh
        if [ $? -ne 0 ]; then
            echo ""
            echo -e "${RED}✗ Error en la compilación. Abortando.${NC}"
            exit 1
        fi
    else
        echo "Abortado. Compila manualmente con: bash battleroyale/scripts/compile_all.sh"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}✓ Ejecutables listos${NC}"
echo ""

# Mostrar recomendaciones
echo "═══════════════════════════════════════════════════════════════"
echo "  Selección de Grafo"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Opciones recomendadas:"
echo ""
echo "  1. Prueba rápida (10 min)"
echo "     • 1000 nodos, densidad 0.1"
echo "     • Tiempo: 600s (10 minutos)"
echo ""
echo "  2. Experimento estándar (30 min)"
echo "     • 2000 nodos, densidad 0.5"
echo "     • Tiempo: 1800s (30 minutos)"
echo ""
echo "  3. Batalla completa (60 min) ⭐ RECOMENDADO"
echo "     • 3000 nodos, densidad 0.7"
echo "     • Tiempo: 3600s (60 minutos)"
echo ""
echo "  4. Personalizado"
echo "     • Especificar grafo y parámetros manualmente"
echo ""

read -p "Selecciona una opción (1-4): " option

case $option in
    1)
        INSTANCE="dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph"
        TIME=600
        SAMPLE=5
        ;;
    2)
        INSTANCE="dataset_grafos_no_dirigidos/new_2000_dataset/erdos_n2000_p0c0.5_1.graph"
        TIME=1800
        SAMPLE=5
        ;;
    3)
        INSTANCE="dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.7_1.graph"
        TIME=3600
        SAMPLE=5
        ;;
    4)
        echo ""
        read -p "Ruta del grafo: " INSTANCE
        read -p "Tiempo (segundos): " TIME
        read -p "Intervalo de muestreo (segundos): " SAMPLE
        ;;
    *)
        echo "Opción inválida"
        exit 1
        ;;
esac

# Verificar que existe el archivo
if [ ! -f "$INSTANCE" ]; then
    echo ""
    echo "ERROR: No se encuentra el archivo $INSTANCE"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Configuración del Experimento"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Grafo:     $(basename $INSTANCE)"
echo "  Tiempo:    ${TIME}s ($((TIME/60)) minutos)"
echo "  Muestreo:  ${SAMPLE}s"
echo ""
echo "Se lanzarán 3 jobs SLURM:"
echo "  • Simulated Annealing"
echo "  • BRKGA"
echo "  • BRKGA_HIBRID"
echo ""

read -p "¿Confirmar y lanzar? (S/n): " confirm

if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    echo "Abortado"
    exit 0
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Lanzando Battle Royale..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

bash battleroyale/scripts/launch_battle.sh "$INSTANCE" "$TIME" "$SAMPLE"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "  ${GREEN}✓ Battle Royale lanzado exitosamente${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Próximos pasos:"
    echo ""
    echo "  1. Monitorear progreso:"
    echo "     bash battleroyale/scripts/check_status.sh"
    echo ""
    echo "  2. Cuando terminen los jobs, analizar resultados:"
    BASENAME=$(basename "$INSTANCE" .graph)
    echo "     python3 battleroyale/scripts/analyze_results.py $BASENAME --time $TIME"
    echo ""
else
    echo ""
    echo "✗ Error al lanzar el Battle Royale"
    exit $EXIT_CODE
fi

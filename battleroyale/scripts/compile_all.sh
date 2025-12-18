#!/bin/bash

# Script de compilación para Battle Royale
# Compila ejecutables standalone para SA y BRKGA con modo anytime

set -e  # Salir si hay errores

echo "╔════════════════════════════════════════════════════════════╗"
echo "║       Battle Royale - Compilación de Ejecutables          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -d "battleroyale" ]; then
    echo -e "${RED}ERROR: Este script debe ejecutarse desde la raíz del proyecto${NC}"
    exit 1
fi

# 1. Compilar SA standalone
echo -e "${YELLOW}[1/2]${NC} Compilando Simulated Annealing standalone..."
g++ -std=c++17 -pthread -O3 \
    battleroyale/source/sa_standalone.cpp \
    metaheuristica/source/utils/GraphReader.cpp \
    -Ibattleroyale/source \
    -Imetaheuristica/source \
    -o battleroyale/sa_standalone

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} SA standalone compilado correctamente"
else
    echo -e "${RED}✗${NC} Error compilando SA standalone"
    exit 1
fi

echo ""

# 2. Compilar BRKGA standalone
echo -e "${YELLOW}[2/2]${NC} Compilando BRKGA standalone..."
g++ -std=c++17 -pthread -O3 \
    battleroyale/source/brkga_standalone.cpp \
    metaheuristica/source/utils/GraphReader.cpp \
    metaheuristica_poblacional/source/brkga_class.cpp \
    -Ibattleroyale/source \
    -Imetaheuristica_poblacional/source \
    -Imetaheuristica/source \
    -o battleroyale/brkga_standalone

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} BRKGA standalone compilado correctamente"
else
    echo -e "${RED}✗${NC} Error compilando BRKGA standalone"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 ✓ Compilación exitosa                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Ejecutables generados:"
echo "  • battleroyale/sa_standalone"
echo "  • battleroyale/brkga_standalone"
echo ""
echo "NOTA: BRKGA_HIBRID requiere CPLEX. Si está disponible, compílalo con:"
echo "      bash battleroyale/scripts/compile_hibrid.sh"
echo ""

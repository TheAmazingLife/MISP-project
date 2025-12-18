#!/bin/bash

# Script de compilación para BRKGA_HIBRID con CPLEX
# Este ejecutable soporta modo ANYTIME

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Battle Royale - Compilación BRKGA_HIBRID + CPLEX      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar que estamos en el directorio correcto
if [ ! -d "battleroyale" ]; then
    echo -e "${RED}ERROR: Este script debe ejecutarse desde la raíz del proyecto${NC}"
    exit 1
fi

# Rutas de CPLEX - Detectar automáticamente o usar las del cluster
CPLEX_DIR=""

# Intentar detectar CPLEX
if [ -d "/opt/ibm/ILOG/CPLEX_Studio2211" ]; then
    CPLEX_DIR="/opt/ibm/ILOG/CPLEX_Studio2211"
    echo -e "${GREEN}✓${NC} CPLEX detectado en: $CPLEX_DIR"
elif [ -d "/opt/ibm/ILOG/CPLEX_Studio221" ]; then
    CPLEX_DIR="/opt/ibm/ILOG/CPLEX_Studio221"
    echo -e "${GREEN}✓${NC} CPLEX detectado en: $CPLEX_DIR"
elif [ -d "/opt/ibm/ILOG/CPLEX_Studio_Community2211" ]; then
    CPLEX_DIR="/opt/ibm/ILOG/CPLEX_Studio_Community2211"
    echo -e "${GREEN}✓${NC} CPLEX detectado en: $CPLEX_DIR"
else
    echo -e "${RED}✗${NC} No se pudo detectar CPLEX automáticamente"
    echo ""
    read -p "Ingresa la ruta de CPLEX (ej: /opt/ibm/ILOG/CPLEX_Studio2211): " CPLEX_DIR
    
    if [ ! -d "$CPLEX_DIR" ]; then
        echo -e "${RED}ERROR: Directorio no existe: $CPLEX_DIR${NC}"
        exit 1
    fi
fi

# Crear carpeta bin si no existe
mkdir -p battleroyale/bin

echo ""
echo -e "${YELLOW}Compilando BRKGA_HIBRID standalone con modo anytime...${NC}"
echo ""

# Compilar
g++ -std=c++17 -pthread -O3 -DIL_STD \
    -I${CPLEX_DIR}/cplex/include \
    -I${CPLEX_DIR}/concert/include \
    battleroyale/source/brkga_hibrid_standalone.cpp \
    metaheuristica_hibrida/source/brkga_class.cpp \
    metaheuristica/source/utils/GraphReader.cpp \
    -Ibattleroyale/source \
    -Imetaheuristica_hibrida/source \
    -Imetaheuristica/source \
    -L${CPLEX_DIR}/cplex/lib/x86-64_linux/static_pic -lilocplex -lcplex \
    -L${CPLEX_DIR}/concert/lib/x86-64_linux/static_pic -lconcert \
    -lm -lpthread -ldl \
    -o battleroyale/bin/brkga_hibrid_standalone

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓${NC} BRKGA_HIBRID standalone compilado correctamente"
    echo ""
    echo "Ejecutable generado en battleroyale/bin/:"
    echo "  • battleroyale/bin/brkga_hibrid_standalone"
    echo ""
    echo "Este ejecutable soporta modo ANYTIME y puede usarse en:"
    echo "  • battleroyale/run_brkga_hibrid_anytime.sh"
    echo ""
else
    echo ""
    echo -e "${RED}✗${NC} Error compilando BRKGA_HIBRID"
    echo ""
    echo "Posibles causas:"
    echo "  • CPLEX no está instalado correctamente"
    echo "  • Las rutas de las librerías son incorrectas"
    echo "  • Falta alguna dependencia"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════"
echo ""

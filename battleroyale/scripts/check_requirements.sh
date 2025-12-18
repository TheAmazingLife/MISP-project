#!/bin/bash

# Script para verificar que todo está listo para ejecutar Battle Royale

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Battle Royale - Verificación del Entorno               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo "Verificando requisitos..."
echo ""

# 1. Compilador C++
echo -n "  [1/10] Compilador g++ ... "
if command -v g++ &> /dev/null; then
    VERSION=$(g++ --version | head -1)
    echo -e "${GREEN}✓${NC} ($VERSION)"
else
    echo -e "${RED}✗${NC}"
    echo "         ERROR: g++ no encontrado"
    ERRORS=$((ERRORS+1))
fi

# 2. Python 3
echo -n "  [2/10] Python 3 ... "
if command -v python3 &> /dev/null; then
    VERSION=$(python3 --version)
    echo -e "${GREEN}✓${NC} ($VERSION)"
else
    echo -e "${RED}✗${NC}"
    echo "         ERROR: python3 no encontrado"
    ERRORS=$((ERRORS+1))
fi

# 3. Pandas
echo -n "  [3/10] Librería pandas ... "
if python3 -c "import pandas" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         Instalar con: pip3 install pandas"
    WARNINGS=$((WARNINGS+1))
fi

# 4. Matplotlib
echo -n "  [4/10] Librería matplotlib ... "
if python3 -c "import matplotlib" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         Instalar con: pip3 install matplotlib"
    WARNINGS=$((WARNINGS+1))
fi

# 5. Numpy
echo -n "  [5/10] Librería numpy ... "
if python3 -c "import numpy" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         Instalar con: pip3 install numpy"
    WARNINGS=$((WARNINGS+1))
fi

# 6. SLURM
echo -n "  [6/10] SLURM (sbatch) ... "
if command -v sbatch &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         SLURM no disponible (necesario para el cluster)"
    WARNINGS=$((WARNINGS+1))
fi

# 7. Ejecutable SA
echo -n "  [7/10] Ejecutable SA ... "
if [ -f "battleroyale/sa_standalone" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         Compilar con: bash battleroyale/scripts/compile_all.sh"
    WARNINGS=$((WARNINGS+1))
fi

# 8. Ejecutable BRKGA
echo -n "  [8/10] Ejecutable BRKGA ... "
if [ -f "battleroyale/brkga_standalone" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         Compilar con: bash battleroyale/scripts/compile_all.sh"
    WARNINGS=$((WARNINGS+1))
fi

# 9. Ejecutable BRKGA_HIBRID
echo -n "  [9/10] Ejecutable BRKGA_HIBRID ... "
if [ -f "metaheuristica_hibrida/slurm_experiments/brkga_hibrid" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "         Debe existir en metaheuristica_hibrida/slurm_experiments/"
    WARNINGS=$((WARNINGS+1))
fi

# 10. Directorio de resultados
echo -n "  [10/10] Directorio resultados ... "
if [ -d "battleroyale/resultados" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    mkdir -p battleroyale/resultados
    echo "         Creado automáticamente"
fi

echo ""
echo "────────────────────────────────────────────────────────────────"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Todo listo para ejecutar Battle Royale${NC}"
    echo ""
    echo "Siguiente paso:"
    echo "  bash battleroyale/quick_start.sh"
    echo ""
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Hay $WARNINGS advertencias, pero puedes continuar${NC}"
    echo ""
    if [ ! -f "battleroyale/sa_standalone" ] || [ ! -f "battleroyale/brkga_standalone" ]; then
        echo "Compila primero los ejecutables:"
        echo "  bash battleroyale/scripts/compile_all.sh"
        echo ""
    fi
else
    echo -e "${RED}✗ Hay $ERRORS errores críticos que deben resolverse${NC}"
    echo ""
fi

echo "────────────────────────────────────────────────────────────────"

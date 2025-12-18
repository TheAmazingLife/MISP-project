# Ejecutables Compilados

Esta carpeta contiene los ejecutables compilados para el Battle Royale:

- `sa_standalone` - Simulated Annealing con modo anytime
- `brkga_standalone` - BRKGA con modo anytime  
- `brkga_hibrid_standalone` - BRKGA Híbrido (BRKGA + CPLEX) con modo anytime

## Compilar

Para compilar todos los ejecutables:

```bash
# SA y BRKGA
bash battleroyale/scripts/compile_all.sh

# BRKGA_HIBRID (requiere CPLEX)
bash battleroyale/scripts/compile_hibrid.sh
```

Los ejecutables se generarán automáticamente en esta carpeta.

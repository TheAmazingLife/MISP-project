# ⚔️ Battle Royale: Guía de Uso Rápido

## � Compilación (solo primera vez)

```bash
# Compilar SA y BRKGA
bash battleroyale/scripts/compile_all.sh

# Compilar BRKGA_HIBRID (requiere CPLEX)
bash battleroyale/scripts/compile_hibrid.sh
```

> Los ejecutables se generan en `battleroyale/bin/`

## �🚀 Inicio en 3 pasos

### 1. Ver recomendaciones de grafos
```bash
python3 battleroyale/scripts/select_best_graph.py
```

### 2. Lanzar experimento (modo guiado)
```bash
bash battleroyale/quick_start.sh
```

### 3. Analizar resultados
```bash
# Cuando terminen los experimentos
python3 battleroyale/scripts/analyze_results.py <nombre_grafo> --time <segundos>
```

## 📋 Comando Directo

Lanzar experimento completo (60 minutos) en el mejor grafo:

```bash
# Ejecutar las 10 instancias de 3000 nodos con densidad 0.5 por 15 minutos
for i in {1..10}; do
    bash battleroyale/scripts/launch_battle.sh \
        dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.5_${i}.graph \
        900 \
        5
done
```

## 📊 Monitoreo

```bash
# Ver estado de los jobs
bash battleroyale/scripts/check_status.sh

# Ver logs en tiempo real
tail -f battleroyale/resultados/sa_*.stdout
```

## ⚙️ Compilación (solo primera vez)

```bash
# SA y BRKGA
bash battleroyale/scripts/compile_all.sh

# BRKGA_HIBRID (requiere CPLEX)
bash battleroyale/scripts/compile_hibrid.sh
```

## 📖 Documentación Completa

Lee el README completo en:
- [battleroyale/README.md](battleroyale/README.md)

## 🎯 ¿Qué hace?

Compara **SA**, **BRKGA** y **BRKGA_HIBRID** ejecutándolos en paralelo durante un tiempo determinado y capturando su evolución (análisis **ANYTIME**).

### Resultados incluyen:
- ✅ Gráficos de evolución temporal
- ✅ Comparación directa entre algoritmos
- ✅ Estadísticas detalladas
- ✅ Ranking final con ganador

### ✨ Nuevo: BRKGA_HIBRID con ANYTIME real
- ✅ Ahora BRKGA_HIBRID tiene seguimiento anytime completo
- ✅ Registra fitness cada X segundos durante la ejecución
- ✅ Requiere CPLEX para compilar

---

**Proyecto**: MISP - Sistemas Adaptativos  
**Equipo**: 11

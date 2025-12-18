# Battle Royale: SA vs BRKGA vs BRKGA_HIBRID

Comparación **Anytime** de tres metaheurísticas para el problema MISP (Maximum Independent Set Problem):
- **SA** (Simulated Annealing)
- **BRKGA** (Biased Random-Key Genetic Algorithm)
- **BRKGA_HIBRID** (BRKGA con optimización local usando CPLEX)

## 📋 Descripción

Este proyecto ejecuta los tres algoritmos en paralelo durante un tiempo determinado (por defecto 60 minutos) y captura el mejor fitness encontrado a intervalos regulares. Esto permite analizar el comportamiento **anytime** de cada algoritmo: cómo evoluciona la calidad de la solución a lo largo del tiempo.

## 🏗️ Estructura

```
battleroyale/
├── bin/                         # Ejecutables compilados
│   ├── sa_standalone            # SA con anytime
│   ├── brkga_standalone         # BRKGA con anytime
│   └── brkga_hibrid_standalone  # BRKGA_HIBRID con anytime
├── source/                      # Código fuente
│   ├── sa_standalone.cpp        # SA con modo anytime
│   ├── brkga_standalone.cpp     # BRKGA con modo anytime
│   └── brkga_hibrid_standalone.cpp  # BRKGA_HIBRID con anytime
├── scripts/                     # Scripts de gestión
│   ├── compile_all.sh           # Compilar ejecutables
│   ├── launch_battle.sh         # Lanzar experimentos completos
│   ├── analyze_results.py       # Análisis y visualización
│   ├── check_status.sh          # Ver estado de jobs
│   └── cancel_all.sh            # Cancelar todos los jobs
├── resultados/                  # Resultados de experimentos
├── run_sa_anytime.sh           # Script SLURM para SA
├── run_brkga_anytime.sh        # Script SLURM para BRKGA
├── run_brkga_hibrid_anytime.sh # Script SLURM para BRKGA_HIBRID
└── README.md                   # Este archivo
```

## 🚀 Inicio Rápido

### 1. Compilar ejecutables

Primero, compila los ejecutables standalone para SA, BRKGA y BRKGA_HIBRID:

```bash
# Compilar SA y BRKGA
bash battleroyale/scripts/compile_all.sh

# Compilar BRKGA_HIBRID (requiere CPLEX)
bash battleroyale/scripts/compile_hibrid.sh
```

Esto genera los ejecutables en `battleroyale/bin/`:
- `battleroyale/bin/sa_standalone`
- `battleroyale/bin/brkga_standalone`
- `battleroyale/bin/brkga_hibrid_standalone` (con modo anytime integrado)

### 2. Lanzar experimentos en el cluster

Ejecuta la batalla completa (SA, BRKGA y BRKGA_HIBRID) con un solo comando:

```bash
# Ejecutar las 10 instancias de 3000 nodos con densidad 0.5 por 15 minutos
for i in {1..10}; do
    bash battleroyale/scripts/launch_battle.sh \
        dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.5_${i}.graph \
        900 \
        5
done
```

Parámetros:
- **Grafos**: 10 instancias `erdos_n3000_p0c0.5_*.graph` (3000 nodos, densidad 0.5)
- **Tiempo**: 900 segundos (15 minutos por instancia)
- **Muestreo**: Cada 5 segundos (~180 puntos de datos)

Esto lanzará 3 jobs SLURM independientes, uno para cada algoritmo.

### 3. Monitorear progreso

```bash
# Ver estado de los jobs
bash battleroyale/scripts/check_status.sh

# O directamente con squeue
squeue -u $USER

# Ver logs en tiempo real
tail -f battleroyale/resultados/sa_battle_sa_*.stdout
tail -f battleroyale/resultados/brkga_battle_brkga_*.stdout
tail -f battleroyale/resultados/hibrid_battle_hibrid_*.stdout
```

### 4. Analizar resultados

Una vez terminados los experimentos, analiza los resultados:

```bash
python3 battleroyale/scripts/analyze_results.py erdos_n3000_p0c0.7_1 --time 3600
```

Esto generará:
- **Gráficos comparativos** (PDF y PNG) en `battleroyale/resultados/`
- **Estadísticas detalladas** en la consola
- **Ranking final** de los algoritmos

## 📊 Salida de Resultados

Cada algoritmo genera un archivo CSV con el siguiente formato:

```csv
tiempo,fitness
0,125
5,128
10,132
...
3600,145
```

Los archivos se nombran según el patrón:
- `sa_<basename>_<tiempo>s.csv`
- `brkga_<basename>_<tiempo>s.csv`
- `hibrid_<basename>_<tiempo>s.csv`

## 🎯 Ejemplos de Uso

### Experimento de 30 minutos con muestreo cada 10 segundos

```bash
bash battleroyale/scripts/launch_battle.sh \
    dataset_grafos_no_dirigidos/new_2000_dataset/erdos_n2000_p0c0.5_1.graph \
    1800 \
    10
```

### Ejecutar solo un algoritmo

Si solo quieres probar un algoritmo:

```bash
# Solo SA
sbatch battleroyale/run_sa_anytime.sh dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph 600 5

# Solo BRKGA
sbatch battleroyale/run_brkga_anytime.sh dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph 600 5

# Solo BRKGA_HIBRID
sbatch battleroyale/run_brkga_hibrid_anytime.sh dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph 600 5
```

## ⚙️ Configuración de Parámetros

### SA (Simulated Annealing)
- Temperatura inicial: 100.0
- Temperatura mínima: 0.1
- Factor de enfriamiento (α): 0.9995
- Semilla aleatoria: 42

### BRKGA
- Tamaño población: 264
- Elite ratio (pe): 0.14
- Mutantes ratio (pm): 0.25
- Herencia (rhoe): 0.65
- Semilla aleatoria: 42

### BRKGA_HIBRID
- Tamaño población: 340
- Elite ratio (pe): 0.17
- Mutantes ratio (pm): 0.24
- Herencia (rhoe): 0.78
- Tiempo CPLEX: 1s por subproblema
- Semilla aleatoria: 42

> Estos parámetros fueron optimizados mediante **irace** en experimentos previos.

## 🛠️ Requisitos

### Software necesario
- **g++** con soporte C++17
- **SLURM** (sistema de gestión de trabajos)
- **Python 3** con las siguientes librerías:
  - pandas
  - matplotlib
  - numpy

### Instalar dependencias Python

```bash
pip3 install pandas matplotlib numpy
```

### Recursos del cluster
- **SA**: 8GB RAM, 1 core, 1h 10min
- **BRKGA**: 8GB RAM, 1 core, 1h 10min
- **BRKGA_HIBRID**: 16GB RAM, 1 core, 1h 10min (requiere CPLEX)

## 📈 Análisis de Resultados

El script `analyze_results.py` genera 4 gráficos:

1. **Evolución temporal del fitness**: Muestra cómo evoluciona el fitness de cada algoritmo
2. **Zoom inicial (60s)**: Detalle de los primeros 60 segundos
3. **Diferencias relativas**: Comparación directa entre algoritmos
4. **Tabla resumen**: Estadísticas finales y ganador

También imprime:
- Fitness inicial, final y mejora de cada algoritmo
- Ranking final
- Diferencias porcentuales

## ⚠️ Notas Importantes

### BRKGA_HIBRID con ANYTIME

✅ **BRKGA_HIBRID ahora tiene modo anytime COMPLETO**
   → Registra mejor fitness cada X segundos durante toda la ejecución
   → Usa un thread separado para el muestreo periódico
   → Ejecutable: `battleroyale/brkga_hibrid_standalone`
   → Requiere CPLEX para compilar

### Compilación de BRKGA_HIBRID

BRKGA_HIBRID requiere CPLEX instalado. El script de compilación detecta automáticamente la instalación:

```bash
bash battleroyale/scripts/compile_hibrid.sh
```

Si CPLEX no se detecta automáticamente, el script te pedirá la ruta.

### Rutas del Cluster

Los scripts detectan automáticamente si se ejecutan en el cluster o en local:
- **Cluster**: `/home/shared/sisadapt2/misp_project/MISP-project`
- **Local**: Directorio actual

No necesitas modificar nada, los scripts se adaptan automáticamente.

### Grafos recomendados para comparación

Según los resultados de experimentos previos, los mejores grafos para comparación son:

- **1000 nodos**: `erdos_n1000_p0c0.1_X.graph` (baja densidad)
- **2000 nodos**: `erdos_n2000_p0c0.5_X.graph` (densidad media)
- **3000 nodos**: `erdos_n3000_p0c0.7_X.graph` (alta densidad)

## 🔧 Troubleshooting

### Error: "No se encuentra el ejecutable"

Ejecuta los scripts de compilación:
```bash
# Para SA y BRKGA
bash battleroyale/scripts/compile_all.sh

# Para BRKGA_HIBRID (requiere CPLEX)
bash battleroyale/scripts/compile_hibrid.sh
```

### Jobs no aparecen en la cola

Verifica que estás en un nodo de acceso al cluster y que SLURM está disponible:
```bash
squeue -u $USER
```:

```bash
# El script detecta automáticamente CPLEX en estas ubicaciones:
# - /opt/ibm/ILOG/CPLEX_Studio2211
# - /opt/ibm/ILOG/CPLEX_Studio221
# - /opt/ibm/ILOG/CPLEX_Studio_Community2211

# Si está en otra ubicación, el script te pedirá la ruta
bash battleroyale/scripts/compile_hibrid.sh
```

### BRKGA_HIBRID falla con error de CPLEX

Verifica que CPLEX esté correctamente instalado y configurado en el cluster. El ejecutable requiere las librerías de CPLEX.

### Análisis no encuentra los archivos

Asegúrate de usar el nombre base correcto (sin extensión `.graph`):
```x] ~~Modificar BRKGA_HIBRID para soporte anytime real~~ ✅ COMPLETADO
- [x] ~~Añadir detección automática de rutas cluster/local~~ ✅ COMPLETADO
# Correcto
python3 battleroyale/scripts/analyze_results.py erdos_n3000_p0c0.7_1

# Incorrecto
python3 battleroyale/scripts/analyze_results.py erdos_n3000_p0c0.7_1.graph
```

## 📝 TODO / Mejoras Futuras

- [ ] Modificar BRKGA_HIBRID para soporte anytime real
- [ ] Añadir soporte para múltiples semillas aleatorias
- [ ] Implementar análisis estadístico con tests de significancia
- [ ] Crear dashboard interactivo con Plotly
- [ ] Añadir soporte para ejecutar batch de grafos automáticamente
- [ ] Generar informe LaTeX automático

## 📞 Contacto

Para preguntas o problemas, revisa los logs en `battleroyale/resultados/` o consulta con el equipo del proyecto.

## 📄 Licencia

Este proyecto es parte del curso de Sistemas Adaptativos - MISP Project.

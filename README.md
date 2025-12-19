# MISP project

El presente repositorio tiene por objetivo abordar el **Maximum Independent Set Problem (MISP)**, el cual consiste en encontrar un conjunto independiente de tamaño máximo:

$$
MIS(G) = \max\{|S| : S \subseteq V \land \forall u, v \in S, (u, v) \notin E\}
$$

Donde $G = (V, E)$ es un grafo no dirigido, $V$ es el conjunto de vértices y $E$ es el conjunto de aristas.

---

## 📁 Estructura del Proyecto

```
MISP-project/
├── dataset_grafos_no_dirigidos/    # Instancias de prueba
│   ├── new_1000_dataset/
│   ├── new_2000_dataset/
│   └── new_3000_dataset/
├── greedy/                         # Heurísticas Greedy
│   ├── source/
│   │   ├── greedyDet.cpp          # Greedy determinístico
│   │   ├── greedyRand.cpp         # Greedy aleatorizado
│   │   └── utils/
│   │       ├── GraphReader.h
│   │       └── GraphReader.cpp
│   └── testing/
├── metaheuristica/                 # Simulated Annealing
│   ├── source/
│   │   ├── meta_sa.cpp            # Simulated Annealing
│   │   └── utils/
│   │       ├── GraphReader.h
│   │       └── GraphReader.cpp
│   └── testing/
├── metaheuristica_poblacional/     # BRKGA Optimizado
│   ├── source/
│   │   ├── brkga.cpp
│   │   ├── brkga_class.cpp
│   │   ├── brkga_class.h
│   │   ├── Makefile
│   │   └── utils/
│   ├── testing/
│   ├── scripts/
│   └── CD/
├── metaheuristica_hibrida/         # BARRAKUDA (BRKGA + CPLEX)
│   ├── source/
│   │   ├── brkga.cpp
│   │   ├── brkga_class.cpp
│   │   ├── brkga_class.h
│   │   ├── Makefile
│   │   ├── obj/
│   │   └── utils/
│   ├── resultados/
│   ├── slurm_experiments/
│   ├── main.cpp
│   └── tasks.json
├── comparacion_algoritmos.csv      # Comparación de resultados
```

---

## 🚀 Entregas

### **Entrega 1** - Desarrollo de Heurística Greedy

Implementación y análisis de:
- **Greedy Determinístico**: Selección de nodos por grado ascendente
- **Greedy Aleatorizado**: Selección aleatoria desde una Lista Restringida de Candidatos (RCL)

### **Entrega 2** - Desarrollo de Metaheurística

Implementación y análisis de:
- **Simulated Annealing (SA)**: Metaheurística basada en temple simulado

### **Entrega 3** - Metaheurística Poblacional
Implementación y análisis de:

- **BRKGA (Biased Random-Key Genetic Algorithm)**: Algoritmo genético con llaves aleatorias sesgadas.

### **Entrega Final** - Metaheurística Híbrida
Implementación y análisis de:

- **BARRAKUDA**: Matheurística híbrida que integra BRKGA con un solver exacto (CPLEX) para optimizar sub-instancias prometedoras.
---

## Dependencias

### Requisitos del Sistema

- **Compilador**: `g++` con soporte para C++17 o superior
- **Sistema Operativo**: Linux, macOS o Windows (con MinGW/WSL)

Para compilar y ejecutar **BRKGA** y **BARRAKUDA**, se requiere software adicional debido a la naturaleza híbrida del algoritmo:

- **IBM ILOG CPLEX Optimization Studio**: Necesario para el componente exacto de BARRAKUDA.
  - Asegúrese de tener las librerías `ilocplex` y `cplex` instaladas y accesibles en su `LD_LIBRARY_PATH`.
  - El código requiere el header `<ilcplex/ilocplex.h>`.

### Librerías Estándar de C++ Utilizadas

- `<iostream>` - Entrada/salida estándar
- `<fstream>` - Lectura de archivos
- `<vector>` - Estructuras de datos dinámicas
- `<algorithm>` - Algoritmos de ordenamiento y búsqueda
- `<chrono>` - Medición de tiempo de ejecución
- `<random>` - Generación de números aleatorios (Greedy aleatorizado y SA)
- `<cmath>` - Funciones matemáticas (SA)
- `<string>` - Manipulación de cadenas

**Nota**: No se requieren librerías externas. Todo el código usa únicamente la biblioteca estándar de C++.

---

## Compilación

Todos los comandos deben ejecutarse desde la **raíz del proyecto**.

### Heurísticas Greedy

#### Greedy Determinístico

```bash
g++ -std=c++17 greedy/source/greedyDet.cpp greedy/source/utils/GraphReader.cpp -o greedy/testing/greedyDet
```

#### Greedy Aleatorizado

```bash
g++ -std=c++17 greedy/source/greedyRand.cpp greedy/source/utils/GraphReader.cpp -o greedy/testing/greedyRand
```

### Metaheurísticas

#### Simulated Annealing

```bash
g++ -std=c++17 metaheuristica/source/meta_sa.cpp metaheuristica/source/utils/GraphReader.cpp -o metaheuristica/testing/meta_sa
```

### Poblacional e híbrido
#### BRKGA y BARRAKUDA
Debido a la dependencia con CPLEX, el comando de compilación es más extenso y requiere vincular las librerías estáticas/dinámicas.

**Nota**: Ajuste las rutas `-I` (include) y `-L` (lib) según la ubicación de instalación de CPLEX en su sistema.

```bash
g++ -std=c++17 -DIL_STD \
    source/brkga.cpp source/brkga_class.cpp source/utils/GraphReader.cpp \
    -o source/brkga \
    -I/opt/ibm/ILOG/CPLEX_Studio_Community2212/cplex/include \
    -I/opt/ibm/ILOG/CPLEX_Studio_Community2212/concert/include \
    -L/opt/ibm/ILOG/CPLEX_Studio_Community2212/concert/lib/x86-64_linux/static_pic \
    -L/opt/ibm/ILOG/CPLEX_Studio_Community2212/cplex/lib/x86-64_linux/static_pic \
    -lconcert -lilocplex -lcplex -lm -lpthread
```

El proyecto incluye el archivo `tasks.json` en la carpeta raíz para facilitar la compilación. Dado que la configuración local `.vscode/` no se incluye en el repositorio (por `.gitignore`), debes realizar un paso de configuración sencillo si deseas usar estas automatizaciones.

#### Configuración
1.  Crea una carpeta llamada `.vscode` en la raíz del proyecto (si no existe).
2.  Mueve (o copia) el archivo `tasks.json` dentro de esa carpeta `.vscode`.

#### Uso
Una vez el archivo esté en su lugar, VS Code reconocerá las tareas de construcción:

1.  Presiona **`Ctrl+Shift+B`** (o abre la paleta de comandos y busca **"Run Build Task"**).
2.  Selecciona el algoritmo que deseas compilar del menú desplegable (ej. `Build BRKGA`, `Build Greedy`, etc.).
3.  El ejecutable se generará automáticamente en la carpeta correspondiente sin necesidad de escribir los comandos largos en la terminal.

**Nota para otros editores**: Si no utilizas VS Code, el archivo `tasks.json` sigue siendo útil como referencia. Puedes abrirlo con cualquier editor de texto para consultar los *flags* de compilación exactos y las rutas de las librerías que requiere cada algoritmo.

---

## Ejecución

### Greedy Determinístico

```bash
./greedy/testing/greedyDet -i <archivo-grafo>
```

**Ejemplo**:

```bash
./greedy/testing/greedyDet -i dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph
```

### Greedy Aleatorizado

```bash
./greedy/testing/greedyRand -i <archivo-grafo> <k>
```

Donde `<k>` es el tamaño de la Lista Restringida de Candidatos (RCL).

**Ejemplo**:

```bash
./greedy/testing/greedyRand -i dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph 20
```

### Simulated Annealing

```bash
./metaheuristica/testing/meta_sa -i <archivo-grafo> <T_inicial> <alpha>
```

**Parámetros**:

- `<T_inicial>`: Temperatura inicial
- `<alpha>`: Factor de enfriamiento (0 < α < 1)

**Parámetros Recomendados según Tamaño del Grafo**:

| Tamaño (n) | T_inicial | Alpha    | Descripción                           |
|------------|-----------|----------|---------------------------------------|
| n = 1000   | 1000      | 0.9993   | Grafos medianos (configuración base)  |
| n = 2000   | 2000      | 0.9995   | Grafos grandes (enfriamiento lento)   |
| n = 3000   | 3000      | 0.9996   | Grafos muy grandes (exploración amplia)|
| n < 100    | 100       | 0.99     | Grafos pequeños (convergencia rápida) |

**Notas sobre los parámetros**:

- **T_inicial**: Se recomienda usar un valor proporcional al tamaño del grafo (T_inicial ≈ n)
- **Alpha**: Valores cercanos a 1 (0.999+) permiten un enfriamiento gradual y mejor exploración
- Para **ajuste fino** (tuning), experimenta con valores de alpha entre 0.9990 y 0.9999
- La temperatura final y número de iteraciones se determinan internamente según el algoritmo

**Ejemplos**:

```bash
# Grafo pequeño (test)
./metaheuristica/testing/meta_sa -i metaheuristica/testing/small_graph.graph 100 0.99

# Grafo de 1000 vértices (configuración recomendada)
./metaheuristica/testing/meta_sa -i dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph 1000 0.9993

# Grafo de 2000 vértices
./metaheuristica/testing/meta_sa -i dataset_grafos_no_dirigidos/new_2000_dataset/erdos_n2000_p0c0.1_1.graph 2000 0.9995

# Grafo de 3000 vértices
./metaheuristica/testing/meta_sa -i dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.1_1.graph 3000 0.9996
```

### BRKGA y BARRAKUDA
```bash
./brkga -i <instancia> -t <tiempo> -p <pob> -pe <elite> -pm <mut> -rhoe <herencia> -seed <semilla>
```
### Parámetros

| Flag    | Descripción                                      | Valor Típico   |
|:--------|:-------------------------------------------------|:---------------|
| `-i`    | Ruta al archivo de la instancia (.graph)         | (Ruta)         |
| `-t`    | Tiempo límite de ejecución (segundos)            | `10` - `60`    |
| `-p`    | Tamaño de la población (longitud del cromosoma = n)| `n` (ej. 1000) |
| `-pe`   | Proporción de población élite (0.0 - 1.0)        | `0.15` - `0.25`|
| `-pm`   | Proporción de mutantes (0.0 - 1.0)               | `0.10` - `0.20`|
| `-rhoe` | Probabilidad de herencia de la élite             | `0.70` - `0.80`|
| `-seed` | Semilla para el generador aleatorio              | `1234`         |
**Ejemplos**:

```bash
./brkga -i dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0.1.graph
        -t 30 -p 100 -pe 0.2 -pm 0.1 -rhoe 0.7 -seed 42
```

---

## 📊 Formato de Salida

Todos los programas imprimen dos líneas:

1. **Tamaño del conjunto independiente encontrado** (valor objetivo)
2. **Tiempo de ejecución en segundos**

**Ejemplo de salida**:

```text
245
0.0234
```

---

## 📄 Formato de Archivos de Grafos

Los archivos `.graph` tienen el siguiente formato:

```text
n
u1 v1
u2 v2
...
um vm
```

Donde:

- `n`: Número de vértices del grafo
- Cada línea `ui vi` representa una arista entre los vértices `ui` y `vi`

**Ejemplo** (`small_graph.graph`):

```text
5
1 2
1 3
2 4
3 4
4 5
```

---

## 🧪 Datasets

El proyecto incluye datasets de grafos Erdős-Rényi organizados por tamaño:

- **new_1000_dataset**: Grafos de 1000 vértices
- **new_2000_dataset**: Grafos de 2000 vértices
- **new_3000_dataset**: Grafos de 3000 vértices

Cada dataset contiene grafos con diferentes densidades (parámetro `p`).

---

## 🛠️ Desarrollo

### Módulo GraphReader

Ambos directorios (`greedy/` y `metaheuristica/`) contienen su propia copia del módulo `GraphReader` en `source/utils/`, que proporciona:

- **`loadFromFile()`**: Carga un grafo desde archivo y construye lista de adyacencia
- **`loadEdgesFromFile()`**: Carga únicamente la lista de aristas

### Estructura de Includes

Los archivos fuente utilizan includes relativos:

```cpp
#include "utils/GraphReader.h"  // Desde archivos en source/
```

---

## 📝 Notas

- Los grafos son **no dirigidos**: cada arista se almacena en ambas direcciones en la lista de adyacencia
- Los vértices están numerados desde `1` hasta `n`
- El índice `0` en las estructuras de datos se reserva y no se utiliza para mantener consistencia con la numeración del grafo

---

## Algoritmos Implementados

### Greedy Determinístico

1. Calcula el grado de cada vértice
2. Ordena los vértices por grado ascendente
3. Selecciona vértices de menor a mayor grado, marcando vecinos como no disponibles

### Greedy Aleatorizado

1. Calcula el grado de cada vértice
2. Ordena los vértices por grado ascendente
3. En cada iteración:
   - Selecciona los `k` mejores candidatos no marcados (RCL)
   - Elige uno aleatoriamente
   - Marca el vértice y sus vecinos

### Simulated Annealing

1. Genera solución inicial (puede usar greedy o aleatoria)
2. Itera mientras `T > T_final`:
   - Genera vecino de la solución actual
   - Calcula diferencia de calidad (Δ)
   - Acepta vecino si mejora o con probabilidad $e^{-\Delta/T}$
   - Reduce temperatura: `T = T × α`
3. Retorna la mejor solución encontrada


### BRKGA (Biased Random-Key Genetic Algorithm)

Este enfoque evolutivo separa la genética del problema específico:

1.  **Cromosomas**: Vectores de números aleatorios (`double` entre 0 y 1).
2.  **Decodificador**: Transforma el cromosoma en una solución válida (Conjunto Independiente). Utiliza un enfoque **Greedy basado en prioridades**:
    - Ordena los nodos según el valor de su alelo (gen).
    - Selecciona nodos iterativamente si no violan la independencia, garantizando una solución **maximal** (saturada).
3.  **Evolución**:
    - Clasifica la población en **Élite** y **No-Élite**.
    - Genera la siguiente generación mediante **Elitismo** (copia directa), **Mutantes** (nuevos aleatorios) y **Cruce Sesgado** (biased crossover) donde un padre siempre es élite.

### BARRAKUDA (Matheurística Híbrida)

El "arma secreta" implementada sobre el BRKGA. Se ejecuta periódicamente durante la evolución:

1.  **Extracción de Sub-instancia ($V'$)**: Selecciona el 15% de los mejores individuos y fusiona todos los nodos presentes en sus soluciones. Esto crea un subgrafo inducido más pequeño pero prometedor.
2.  **Optimización Exacta**: Utiliza **CPLEX** para resolver el MISP de forma matemática y exacta sobre $V'$.
    - *Restricción*: Tiempo límite corto (ej. 1s) para evitar cuellos de botella.
3.  **Aprendizaje**: La solución óptima local encontrada por CPLEX se inyecta de vuelta en la población, reemplazando al peor individuo y guiando la búsqueda futura.

---

## 📈 Resultados Experimentales

### Comparación de Algoritmos

A continuación se presenta la comparación del rendimiento de los cuatro algoritmos implementados (Greedy, Simulated Annealing, BRKGA y BARRAKUDA) sobre grafos Erdős-Rényi de diferentes tamaños y densidades.

**Media y desviación estándar del tamaño del conjunto independiente encontrado:**

| N    | Densidad | Greedy<br>Media ± Std | SA<br>Media ± Std | BRKGA<br>Media ± Std | BARRAKUDA<br>Media ± Std |
|------|----------|-----------------------|-------------------|----------------------|--------------------------|
| 1000 | 0.1 | 49.23 ± 2.02 | 61.67 ± 1.65 | 61.13 ± 1.43 | **60.30 ± 2.52** |
| 1000 | 0.2 | 27.22 ± 1.73 | 34.10 ± 1.09 | 34.17 ± 1.05 | **33.60 ± 0.88** |
| 1000 | 0.3 | 18.43 ± 1.29 | 23.47 ± 0.78 | **23.73 ± 0.69** | **23.73 ± 0.51** |
| 1000 | 0.4 | 13.83 ± 1.12 | 17.53 ± 0.57 | **18.30 ± 0.47** | 18.13 ± 0.43 |
| 1000 | 0.5 | 10.88 ± 0.94 | 13.80 ± 0.55 | **14.83 ± 0.38** | 14.57 ± 0.50 |
| 1000 | 0.6 | 8.82 ± 1.17 | 11.37 ± 0.56 | 12.13 ± 0.35 | **12.10 ± 0.30** |
| 1000 | 0.7 | 7.02 ± 0.87 | 9.03 ± 0.41 | 10.00 ± 0.00 | **10.07 ± 0.25** |
| 1000 | 0.8 | 5.63 ± 0.82 | 7.40 ± 0.50 | 8.33 ± 0.48 | **8.10 ± 0.30** |
| 1000 | 0.9 | 4.45 ± 0.70 | 6.03 ± 0.18 | **6.77 ± 0.43** | 6.67 ± 0.47 |
| 2000 | 0.1 | 55.62 ± 2.60 | **68.10 ± 1.56** | 62.77 ± 1.68 | 61.87 ± 1.41 |
| 2000 | 0.2 | 30.07 ± 1.72 | **37.53 ± 0.97** | 36.27 ± 0.94 | 35.87 ± 1.09 |
| 2000 | 0.3 | 20.08 ± 1.27 | **25.63 ± 0.96** | 25.40 ± 0.50 | 25.47 ± 0.56 |
| 2000 | 0.4 | 15.18 ± 1.02 | 19.07 ± 0.74 | **19.53 ± 0.57** | 19.27 ± 0.44 |
| 2000 | 0.5 | 11.77 ± 1.00 | 14.83 ± 0.59 | **15.43 ± 0.50** | 15.40 ± 0.49 |
| 2000 | 0.6 | 9.40 ± 0.81 | 11.97 ± 0.41 | **12.83 ± 0.38** | 12.50 ± 0.50 |
| 2000 | 0.7 | 7.73 ± 0.95 | 9.77 ± 0.57 | **10.57 ± 0.50** | 10.33 ± 0.47 |
| 2000 | 0.8 | 6.18 ± 0.83 | 7.93 ± 0.37 | **8.87 ± 0.35** | 8.67 ± 0.47 |
| 2000 | 0.9 | 4.65 ± 0.80 | 6.07 ± 0.25 | **7.00 ± 0.00** | **7.00 ± 0.00** |
| 3000 | 0.1 | 59.52 ± 2.18 | **72.30 ± 1.64** | 65.33 ± 0.71 | 65.13 ± 0.85 |
| 3000 | 0.2 | 31.30 ± 1.60 | **38.90 ± 0.80** | 37.33 ± 0.96 | 36.73 ± 0.63 |
| 3000 | 0.3 | 21.17 ± 1.39 | **26.37 ± 0.85** | 26.33 ± 0.48 | 25.97 ± 0.66 |
| 3000 | 0.4 | 15.68 ± 1.28 | 19.60 ± 0.68 | **20.23 ± 0.43** | 20.07 ± 0.57 |
| 3000 | 0.5 | 12.23 ± 0.93 | 15.20 ± 0.48 | **16.10 ± 0.31** | 15.83 ± 0.37 |
| 3000 | 0.6 | 9.65 ± 0.97 | 12.17 ± 0.46 | **13.13 ± 0.35** | 13.07 ± 0.25 |
| 3000 | 0.7 | 7.83 ± 0.98 | 9.97 ± 0.32 | **11.03 ± 0.18** | 10.73 ± 0.44 |
| 3000 | 0.8 | 6.22 ± 0.89 | 7.93 ± 0.37 | **9.03 ± 0.18** | 8.90 ± 0.30 |
| 3000 | 0.9 | 4.83 ± 0.69 | 6.07 ± 0.25 | 7.07 ± 0.25 | **7.00 ± 0.00** |

**Observaciones:**

- **Greedy**: Baseline rápido pero con resultados significativamente inferiores
- **Simulated Annealing (SA)**: Mejora sustancial sobre Greedy, especialmente en densidades bajas
- **BRKGA**: Supera a SA en la mayoría de configuraciones, especialmente en densidades medias-altas
- **BARRAKUDA**: Resultados comparables a BRKGA con mayor estabilidad (menor desviación estándar)

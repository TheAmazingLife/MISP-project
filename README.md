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
│   ├── testing/
│   │   ├── comandos.txt
│   │   └── small_graph.graph
│   └── scripts/
├── metaheuristica/                 # Metaheurísticas
│   ├── source/
│   │   ├── meta_sa.cpp            # Simulated Annealing
│   │   └── utils/
│   │       ├── GraphReader.h
│   │       └── GraphReader.cpp
│   ├── testing/
│   │   └── small_graph.graph
│   └── scripts/
└── README.md
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

---

## 🔧 Dependencias

### Requisitos del Sistema

- **Compilador**: `g++` con soporte para C++17 o superior
- **Sistema Operativo**: Linux, macOS o Windows (con MinGW/WSL)

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

## 📦 Compilación

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

---

## ▶️ Ejecución

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

## 🔍 Algoritmos Implementados

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

# VERSUS en Cluster Luthier con SLURM

## Preparación

### 1. Compilar BRKGA_hibrid en el servidor
```bash
ssh sisadapt2@luthier
cd /home/shared/sisadapt2/misp_project/MISP-project/metaheuristica_hibrida/source
make clean
make
# Copiar el binario a versus
cp brkga_hibrid ../../versus/BRKGA_hibrid
```

### 2. Copiar binarios SA y BRKGA al servidor
```bash
# Desde tu máquina local
cd /home/amzng/Documents/GitHub/universidad/s2-25/sistemas_adaptativos/MISP-project/versus
scp SA BRKGA sisadapt2@luthier:/home/shared/sisadapt2/misp_project/MISP-project/versus/
scp run_versus.slurm sisadapt2@luthier:/home/shared/sisadapt2/misp_project/MISP-project/versus/
```

### 3. Elegir el mejor grafo
Antes de ejecutar, edita `run_versus.slurm` y ajusta la variable `BEST_GRAPH` con el mejor grafo de tus experimentos previos. Por ejemplo:
```bash
BEST_GRAPH="${DATASET_DIR}/new_1000_dataset/erdos_n1000_p0c0.05_15.graph"
```

## Ejecución

### Lanzar el job en SLURM
```bash
ssh sisadapt2@luthier
cd /home/shared/sisadapt2/misp_project/MISP-project/versus
sbatch run_versus.slurm
```

### Monitorear el job
```bash
# Ver estado del job
squeue -u sisadapt2

# Ver log en tiempo real
tail -f versus_<JOB_ID>.out

# Ver errores en tiempo real
tail -f versus_<JOB_ID>.err
```

### Cancelar el job si es necesario
```bash
scancel <JOB_ID>
```

## Resultados

Los resultados se guardarán en:
```
/home/shared/sisadapt2/misp_project/MISP-project/versus/results_YYYYMMDD_HHMMSS/
```

Con los archivos:
- `sa_anytime.txt` - Evolución ANYTIME de SA
- `brkga_anytime.txt` - Evolución ANYTIME de BRKGA
- `brkga_hibrid_anytime.txt` - Evolución ANYTIME de BRKGA_hibrid

### Formato esperado de archivos ANYTIME
Cada línea debe contener:
```
<valor_objetivo> <tiempo_en_segundos>
```

Ejemplo:
```
450 0.15
475 1.23
490 3.45
500 8.92
...
```

## Análisis de resultados

### Descargar resultados a tu máquina local
```bash
cd /home/amzng/Documents/GitHub/universidad/s2-25/sistemas_adaptativos/MISP-project/versus
scp -r sisadapt2@luthier:/home/shared/sisadapt2/misp_project/MISP-project/versus/results_* .
```

### Generar gráficos
```bash
python3 plot_versus.py results_YYYYMMDD_HHMMSS/
```

## Verificar que los algoritmos tengan ANYTIME

### SA
El SA debe imprimir cada vez que encuentra una mejor solución:
```
<valor> <tiempo>
```

### BRKGA
El BRKGA debe imprimir en cada generación:
```
<mejor_valor> <tiempo>
```

### BRKGA_hibrid
El BRKGA_hibrid debe imprimir cuando mejora:
```
<valor> <tiempo>
```

## Ajustes del script SLURM

Puedes modificar en `run_versus.slurm`:

- **Tiempo límite de ejecución**: Cambiar `TIME_LIMIT=900` (15 minutos en segundos)
- **Recursos del cluster**: Modificar directivas `#SBATCH`
  - `--time=00:20:00` (tiempo máximo del job, debe ser > TIME_LIMIT)
  - `--mem=4G` (memoria)
  - `--cpus-per-task=1` (CPUs)
- **Grafo a usar**: Cambiar `BEST_GRAPH`

## Troubleshooting

### Problema: Binarios no ejecutables
```bash
chmod +x /home/shared/sisadapt2/misp_project/MISP-project/versus/SA
chmod +x /home/shared/sisadapt2/misp_project/MISP-project/versus/BRKGA
chmod +x /home/shared/sisadapt2/misp_project/MISP-project/versus/BRKGA_hibrid
```

### Problema: CPLEX no encontrado para BRKGA_hibrid
Asegúrate de compilar en el servidor donde está CPLEX instalado.

### Problema: Sin output ANYTIME
Verifica que cada algoritmo imprima correctamente:
- Usa `cout << valor << " " << tiempo << endl;`
- Asegúrate de que `cout.flush()` o que la salida no esté buffereada

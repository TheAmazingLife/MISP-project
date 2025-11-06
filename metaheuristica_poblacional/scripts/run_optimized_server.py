#!/usr/bin/env python3
"""
Script para ejecutar BRKGA con parámetros OPTIMIZADOS en SERVIDOR.
Parámetros: -p 264 -pe 0.14 -pm 0.25 -rhoe 0.65

RUTAS ABSOLUTAS PARA SERVIDOR:
- Dataset: /home/shared/sisadapt2/misp_project/dataset_grafos_no_dirigidos/
- Ejecutable: /home/shared/sisadapt2/misp_project/MISP-project/metaheuristica_poblacional/source/brkga
"""

import subprocess
import csv
import os
import statistics
import time
from datetime import datetime

# ===== CONFIGURACIÓN SERVIDOR =====
BIN = "/home/shared/sisadapt2/misp_project/MISP-project/metaheuristica_poblacional/source/brkga"
DATASET_BASE = "/home/shared/sisadapt2/misp_project/dataset_grafos_no_dirigidos"
OUTPUT_BASE = "/home/shared/sisadapt2/misp_project/MISP-project/metaheuristica_poblacional/testing"

# PARÁMETROS OPTIMIZADOS POR TUNING
TIEMPO = 10  # segundos
POBLACION = 264
ELITE = 0.14  # 14%
MUTANTES = 0.25  # 25%
HERENCIA = 0.65  # 65%
SEED = 42

# Dataset
SIZES = ["1000", "2000", "3000"]
DENSITIES = ["0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9"]
INSTANCES = [str(i) for i in range(1, 31)]  # 30 instancias por densidad

def main():
    print("=" * 80)
    print("EJECUCIÓN BRKGA EN SERVIDOR - PARÁMETROS OPTIMIZADOS")
    print("=" * 80)
    print(f"Configuración:")
    print(f"  - Ejecutable: {BIN}")
    print(f"  - Dataset: {DATASET_BASE}")
    print(f"  - Salida: {OUTPUT_BASE}")
    print(f"\nParámetros del tuning:")
    print(f"  - Población: {POBLACION}")
    print(f"  - Elite: {ELITE * 100:.0f}%")
    print(f"  - Mutantes: {MUTANTES * 100:.0f}%")
    print(f"  - Herencia (rhoe): {HERENCIA * 100:.0f}%")
    print(f"  - Tiempo: {TIEMPO}s")
    print(f"  - Seed: {SEED}")
    print("=" * 80)
    print()
    
    # Verificar que el ejecutable existe
    if not os.path.exists(BIN):
        print(f"❌ ERROR: Ejecutable no encontrado en {BIN}")
        print("   Asegúrate de que el BRKGA esté compilado en el servidor.")
        return
    
    # Verificar que el dataset existe
    if not os.path.exists(DATASET_BASE):
        print(f"❌ ERROR: Dataset no encontrado en {DATASET_BASE}")
        return
    
    start_time = time.time()
    
    for size in SIZES:
        print(f"\n{'='*80}")
        print(f"PROCESANDO GRAFOS DE TAMAÑO {size}")
        print(f"{'='*80}")
        
        dataset_path = f"{DATASET_BASE}/new_{size}_dataset"
        
        # Verificar que existe el dataset de este tamaño
        if not os.path.exists(dataset_path):
            print(f"⚠️  Dataset {dataset_path} no encontrado, se omite este tamaño.")
            continue
        
        OUTPUT = f"{OUTPUT_BASE}/results{size}_brkga_optimized.csv"
        rows = []
        
        total_instances = len(DENSITIES) * len(INSTANCES)
        current_instance = 0
        
        for d in DENSITIES:
            density_values = []
            density_start = time.time()
            
            for j in INSTANCES:
                current_instance += 1
                fname = f"{dataset_path}/erdos_n{size}_p0c{d}_{j}.graph"
                
                if not os.path.exists(fname):
                    print(f"  ⚠️  [{current_instance}/{total_instances}] {fname} no encontrado")
                    continue

                try:
                    cmd = [
                        BIN,
                        "-i", fname,
                        "-t", str(TIEMPO),
                        "-p", str(POBLACION),
                        "-pe", str(ELITE),
                        "-pm", str(MUTANTES),
                        "-rhoe", str(HERENCIA),
                        "-seed", str(SEED)
                    ]
                    
                    result = subprocess.run(cmd, capture_output=True, text=True, 
                                          check=True, timeout=TIEMPO + 15)
                    out = result.stdout.strip().splitlines()

                    if len(out) >= 1:
                        valor = abs(int(out[0]))
                        density_values.append(valor)
                        rows.append([d, j, valor])
                        print(f"  ✓ [{current_instance}/{total_instances}] Densidad {d}, Inst {j}: {valor}")
                    else:
                        print(f"  ⚠️  [{current_instance}/{total_instances}] Sin salida para instancia {j}")

                except subprocess.TimeoutExpired:
                    print(f"  ⏱️  [{current_instance}/{total_instances}] Timeout en instancia {j}")
                except subprocess.CalledProcessError as e:
                    print(f"  ❌ [{current_instance}/{total_instances}] Error en instancia {j}: {e}")
                    if e.stderr:
                        print(f"     stderr: {e.stderr[:200]}")
                except Exception as e:
                    print(f"  ❌ [{current_instance}/{total_instances}] Error inesperado en instancia {j}: {e}")
            
            # Estadísticas por densidad
            if density_values:
                density_time = time.time() - density_start
                media = statistics.mean(density_values)
                desv = statistics.stdev(density_values) if len(density_values) > 1 else 0
                minimo = min(density_values)
                maximo = max(density_values)
                
                print(f"\n  📊 Densidad {d} completada en {density_time:.1f}s:")
                print(f"     Media: {media:.2f}, Desv: {desv:.2f}, Min: {minimo}, Max: {maximo}")
                print(f"     Instancias: {len(density_values)}/{len(INSTANCES)}")
        
        # Guardar resultados individuales (asegurar carpeta)
        os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
        with open(OUTPUT, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["DENSITY", "INSTANCE", "VALOR"])
            writer.writerows(rows)

        print(f"\n  ✅ Resultados individuales guardados en: {OUTPUT}")

        # Generar archivo summary con estadísticas por densidad
        SUMMARY_OUTPUT = OUTPUT.replace(".csv", "_summary.csv")
        summary_rows = []
        
        print(f"\n  📈 RESUMEN TAMAÑO {size}:")
        print(f"  {'Densidad':<12} {'Media':<12} {'Desv.Est':<12} {'N':<8}")
        print(f"  {'-'*44}")
        
        for d in DENSITIES:
            vals = [r[2] for r in rows if r[0] == d]
            if vals:
                media = statistics.mean(vals)
                desv = statistics.stdev(vals) if len(vals) > 1 else 0
                print(f"  {d:<12} {media:<12.2f} {desv:<12.2f} {len(vals):<8}")
                summary_rows.append([d, media, desv])
        
        # Guardar resumen estadístico (asegurar carpeta)
        os.makedirs(os.path.dirname(SUMMARY_OUTPUT), exist_ok=True)
        with open(SUMMARY_OUTPUT, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["DENSITY", "MEDIA_CALIDAD", "STD_CALIDAD"])
            writer.writerows(summary_rows)

        print(f"\n  ✅ Resumen estadístico guardado en: {SUMMARY_OUTPUT}")
    
    total_time = time.time() - start_time
    print(f"\n{'='*80}")
    print(f"✅ PROCESO COMPLETADO")
    print(f"Tiempo total: {total_time/60:.2f} minutos ({total_time:.1f}s)")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*80}")

if __name__ == "__main__":
    main()

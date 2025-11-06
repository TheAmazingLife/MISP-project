#!/usr/bin/env python3
"""
Script para ejecutar BRKGA en SERVIDOR con parámetros OPTIMIZADOS.
Compatible con Python 3.6+
Parámetros: -p 264 -pe 0.14 -pm 0.25 -rhoe 0.65
"""

import subprocess
import csv
import os
import statistics
import time
from datetime import datetime

# ==================== CONFIGURACIÓN SERVIDOR ====================
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
INSTANCES = [str(i) for i in range(1, 31)]

def main():
    # Verificaciones iniciales
    if not os.path.exists(BIN):
        print(f"❌ ERROR: Ejecutable no encontrado: {BIN}")
        print(f"   Compila primero con: cd {os.path.dirname(BIN)} && make")
        return 1
    
    if not os.path.exists(DATASET_BASE):
        print(f"❌ ERROR: Dataset no encontrado: {DATASET_BASE}")
        return 1
    
    print("=" * 80)
    print("EJECUCIÓN BRKGA EN SERVIDOR - PARÁMETROS OPTIMIZADOS")
    print("=" * 80)
    print(f"Configuración:")
    print(f"  - Ejecutable: {BIN}")
    print(f"  - Dataset: {DATASET_BASE}")
    print(f"  - Salida: {OUTPUT_BASE}")
    print(f"\nParámetros del tuning:")
    print(f"  - Población: {POBLACION}")
    print(f"  - Elite: {int(ELITE * 100)}%")
    print(f"  - Mutantes: {int(MUTANTES * 100)}%")
    print(f"  - Herencia (rhoe): {int(HERENCIA * 100)}%")
    print(f"  - Tiempo: {TIEMPO}s")
    print(f"  - Seed: {SEED}")
    print("=" * 80)
    print()
    
    start_time = time.time()
    
    for size in SIZES:
        print(f"\n{'='*80}")
        print(f"PROCESANDO GRAFOS DE TAMAÑO {size}")
        print(f"{'='*80}")
        
        OUTPUT = f"{OUTPUT_BASE}/results{size}_brkga_optimized.csv"
        rows = []
        
        total_instances = len(DENSITIES) * len(INSTANCES)
        counter = 0
        
        for d in DENSITIES:
            density_values = []
            density_start = time.time()
            
            for j in INSTANCES:
                counter += 1
                fname = f"{DATASET_BASE}/new_{size}_dataset/erdos_n{size}_p0c{d}_{j}.graph"
                
                if not os.path.exists(fname):
                    print(f"  ⚠️  [{counter}/{total_instances}] {fname} no encontrado")
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
                    
                    # Compatible con Python 3.6+
                    result = subprocess.run(
                        cmd, 
                        stdout=subprocess.PIPE, 
                        stderr=subprocess.PIPE,
                        universal_newlines=True,
                        timeout=TIEMPO + 15
                    )
                    
                    if result.returncode != 0:
                        print(f"  ❌ [{counter}/{total_instances}] Error en d={d}, inst={j}")
                        if result.stderr:
                            print(f"     Error: {result.stderr.strip()[:100]}")
                        continue
                    
                    out = result.stdout.strip().splitlines()

                    if len(out) >= 1:
                        valor = abs(int(out[0]))
                        rows.append([d, j, valor])
                        density_values.append(valor)
                        print(f"  ✅ [{counter}/{total_instances}] d={d}, inst={j}: {valor}")
                    else:
                        print(f"  ⚠️  [{counter}/{total_instances}] Salida vacía para d={d}, inst={j}")

                except subprocess.TimeoutExpired:
                    print(f"  ⏱️  [{counter}/{total_instances}] Timeout en d={d}, inst={j}")
                except Exception as e:
                    print(f"  ❌ [{counter}/{total_instances}] Error en d={d}, inst={j}: {e}")
            
            # Estadísticas por densidad
            if density_values:
                density_time = time.time() - density_start
                media = statistics.mean(density_values)
                desv = statistics.stdev(density_values) if len(density_values) > 1 else 0
                minimo = min(density_values)
                maximo = max(density_values)
                
                print(f"\n  📊 Densidad {d} completada en {density_time:.1f}s:")
                print(f"     Media: {media:.2f}, Desv: {desv:.2f}, Min: {minimo}, Max: {maximo}")
                print(f"     Instancias: {len(density_values)}/30")
        
        # Guardar resultados individuales (asegurar carpeta)
        os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
        with open(OUTPUT, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["DENSITY", "INSTANCE", "VALOR"])
            writer.writerows(rows)

        print(f"\n  ✅ Resultados individuales guardados en: {OUTPUT}")
        print(f"     Total de resultados: {len(rows)}/{total_instances}")

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
    
    return 0

if __name__ == "__main__":
    exit(main())

#!/usr/bin/env python3
"""
Script para generar el archivo results.dat para análisis estadístico con R.
Combina los resultados de greedy determinista, SA y BRKGA.
"""

import pandas as pd
import os

# Rutas a los archivos de resultados
BASE_PATH = "/home/amzng/Documents/GitHub/universidad/s2-25/sistemas_adaptativos/MISP-project"

# Archivos de entrada
GREEDY_FILES = {
    1000: f"{BASE_PATH}/greedy/testing/greedyDetResults/results1000_greedyDet.csv",
    2000: f"{BASE_PATH}/greedy/testing/greedyDetResults/results2000_greedyDet.csv",
    3000: f"{BASE_PATH}/greedy/testing/greedyDetResults/results3000_greedyDet.csv"
}

SA_FILES = {
    1000: f"{BASE_PATH}/metaheuristica/testing/metaSaResults/results_sa_1000.csv",
    2000: f"{BASE_PATH}/metaheuristica/testing/metaSaResults/results_sa_2000.csv",
    3000: f"{BASE_PATH}/metaheuristica/testing/metaSaResults/results_sa_3000.csv"
}

BRKGA_FILES = {
    1000: f"{BASE_PATH}/metaheuristica_poblacional/testing/results1000_brkga_optimized.csv",
    2000: f"{BASE_PATH}/metaheuristica_poblacional/testing/results2000_brkga_optimized.csv",
    3000: f"{BASE_PATH}/metaheuristica_poblacional/testing/results3000_brkga_optimized.csv"
}

# Archivo de salida
OUTPUT_FILE = f"{BASE_PATH}/metaheuristica_poblacional/CD/SandBox/results.dat"

def load_results(file_path):
    """Carga un archivo CSV de resultados."""
    return pd.read_csv(file_path)

def combine_results():
    """
    Combina los resultados de los tres algoritmos en un único DataFrame.
    """
    all_results = []
    
    # Procesar cada tamaño de grafo
    for n_nodes in [1000, 2000, 3000]:
        print(f"Procesando grafos de {n_nodes} nodos...")
        
        # Cargar resultados de cada algoritmo
        greedy_df = load_results(GREEDY_FILES[n_nodes])
        sa_df = load_results(SA_FILES[n_nodes])
        brkga_df = load_results(BRKGA_FILES[n_nodes])
        
        # Verificar que todos tengan las mismas instancias
        assert len(greedy_df) == len(sa_df) == len(brkga_df), \
            f"Diferente número de instancias para n={n_nodes}"
        
        # Crear DataFrame combinado
        for idx, row_greedy in greedy_df.iterrows():
            density = row_greedy['DENSITY']
            instance = row_greedy['INSTANCE']
            
            # Buscar la misma instancia en SA y BRKGA
            row_sa = sa_df[(sa_df['DENSITY'] == density) & (sa_df['INSTANCE'] == instance)]
            row_brkga = brkga_df[(brkga_df['DENSITY'] == density) & (brkga_df['INSTANCE'] == instance)]
            
            if row_sa.empty or row_brkga.empty:
                print(f"Advertencia: No se encontró instancia {instance} con densidad {density} para n={n_nodes}")
                continue
            
            result_row = {
                'inst': idx + 1,  # Índice de instancia
                'nstr': n_nodes,  # Número de nodos
                'length': n_nodes,  # Longitud (en este caso, igual al número de nodos)
                't': density,  # Fracción/densidad
                'GREEDY': int(row_greedy['VALOR']),
                'SA': int(row_sa['VALOR'].values[0]),
                'BRKGA': int(row_brkga['VALOR'].values[0])
            }
            
            all_results.append(result_row)
    
    # Crear DataFrame final
    results_df = pd.DataFrame(all_results)
    
    # Renumerar instancias de forma consecutiva
    results_df['inst'] = range(1, len(results_df) + 1)
    
    return results_df

def save_results_dat(df, output_file):
    """
    Guarda el DataFrame en formato .dat compatible con R.
    """
    # Guardar con tabuladores como separadores
    df.to_csv(output_file, sep='\t', index=False)
    print(f"\nArchivo guardado en: {output_file}")
    print(f"Total de instancias: {len(df)}")
    
    # Mostrar resumen
    print("\nResumen por tamaño de grafo:")
    print(df.groupby('nstr').size())
    
    print("\nResumen por densidad:")
    print(df.groupby('t').size())
    
    print("\nPrimeras 10 filas:")
    print(df.head(10))
    
    print("\nÚltimas 10 filas:")
    print(df.tail(10))

def main():
    print("="*60)
    print("Generando archivo results.dat para análisis estadístico")
    print("="*60)
    
    # Verificar que existan los archivos
    all_files = list(GREEDY_FILES.values()) + list(SA_FILES.values()) + list(BRKGA_FILES.values())
    missing_files = [f for f in all_files if not os.path.exists(f)]
    
    if missing_files:
        print("\nERROR: No se encontraron los siguientes archivos:")
        for f in missing_files:
            print(f"  - {f}")
        return
    
    # Combinar resultados
    results_df = combine_results()
    
    # Guardar archivo
    save_results_dat(results_df, OUTPUT_FILE)
    
    print("\n" + "="*60)
    print("Proceso completado exitosamente!")
    print("="*60)

if __name__ == "__main__":
    main()

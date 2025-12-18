#!/usr/bin/env python3
"""
Script para identificar el mejor grafo para el Battle Royale
Analiza los resultados previos de BRKGA y BRKGA_HIBRID para recomendar instancias
"""

import pandas as pd
import os
import sys

def analyze_brkga_results():
    """Analiza resultados de BRKGA"""
    print("="*80)
    print("ANÁLISIS DE RESULTADOS BRKGA")
    print("="*80)
    
    results = {}
    
    for size in [1000, 2000, 3000]:
        file = f"metaheuristica_poblacional/testing/results{size}_brkga_optimized_summary.csv"
        if os.path.exists(file):
            df = pd.read_csv(file)
            results[size] = df
            print(f"\n📊 Grafos de {size} nodos:")
            print(f"   Total instancias: {len(df)}")
            print(f"   Fitness promedio: {df['media'].mean():.2f}")
            print(f"   Mejor instancia:  {df.loc[df['media'].idxmax(), 'instancia']}")
            print(f"   Mejor fitness:    {df['media'].max():.2f}")
    
    return results

def analyze_hibrid_results():
    """Analiza resultados de BRKGA_HIBRID"""
    print("\n" + "="*80)
    print("ANÁLISIS DE RESULTADOS BRKGA_HIBRID")
    print("="*80)
    
    results_file = "metaheuristica_hibrida/slurm_experiments/resultados/analisis_resultados.csv"
    
    if not os.path.exists(results_file):
        print("\n⚠️  No se encontró el archivo de resultados de BRKGA_HIBRID")
        return None
    
    df = pd.read_csv(results_file)
    
    # Agrupar por tamaño y densidad
    print(f"\n📊 Total experimentos: {len(df)}")
    
    # Extraer info del nombre de instancia
    df['size'] = df['instancia'].str.extract(r'n(\d+)')[0].astype(int)
    df['density'] = df['instancia'].str.extract(r'p0c([\d.]+)')[0].astype(float)
    
    for size in df['size'].unique():
        df_size = df[df['size'] == size]
        print(f"\n   Grafos de {size} nodos:")
        print(f"      Instancias: {len(df_size)}")
        print(f"      Fitness promedio: {df_size['media'].mean():.2f}")
        
        # Mejor por densidad
        for density in sorted(df_size['density'].unique()):
            df_dens = df_size[df_size['density'] == density]
            if len(df_dens) > 0:
                best = df_dens.loc[df_dens['media'].idxmax()]
                print(f"      Densidad {density}: mejor={best['media']:.2f} en {best['instancia']}")
    
    return df

def recommend_best_graphs():
    """Recomienda los mejores grafos para el Battle Royale"""
    print("\n" + "="*80)
    print("🏆 RECOMENDACIONES DE GRAFOS PARA BATTLE ROYALE")
    print("="*80)
    
    recommendations = [
        {
            'size': 1000,
            'density': 0.1,
            'reason': 'Rápido para pruebas iniciales',
            'time': '600-1800',
            'sample': '5',
            'path': 'dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.1_1.graph'
        },
        {
            'size': 2000,
            'density': 0.5,
            'reason': 'Balance entre complejidad y tiempo',
            'time': '1800-3600',
            'sample': '5',
            'path': 'dataset_grafos_no_dirigidos/new_2000_dataset/erdos_n2000_p0c0.5_1.graph'
        },
        {
            'size': 3000,
            'density': 0.7,
            'reason': 'Desafío computacional significativo - RECOMENDADO',
            'time': '3600',
            'sample': '5-10',
            'path': 'dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.7_1.graph'
        }
    ]
    
    for i, rec in enumerate(recommendations, 1):
        print(f"\n{i}. Grafo de {rec['size']} nodos, densidad {rec['density']}")
        print(f"   Razón: {rec['reason']}")
        print(f"   Tiempo sugerido: {rec['time']}s")
        print(f"   Intervalo: {rec['sample']}s")
        print(f"   Ruta: {rec['path']}")
        print(f"\n   Comando:")
        time = rec['time'].split('-')[-1]  # Tomar el valor máximo si hay rango
        print(f"   bash battleroyale/scripts/launch_battle.sh {rec['path']} {time} {rec['sample'].split('-')[0]}")
    
    print("\n" + "="*80)
    print("💡 CONSEJOS:")
    print("="*80)
    print("  • Empieza con grafos pequeños (1000) para verificar que todo funciona")
    print("  • Los grafos de 3000 nodos son ideales para análisis de 60 minutos")
    print("  • Mayor densidad = más desafiante = mejor para ver diferencias")
    print("  • Intervalo de 5s da suficiente granularidad sin llenar el disco")
    print("")

def main():
    print("╔════════════════════════════════════════════════════════════════╗")
    print("║     Battle Royale - Selector de Mejores Grafos                ║")
    print("╚════════════════════════════════════════════════════════════════╝")
    print()
    
    # Verificar que estamos en el directorio correcto
    if not os.path.exists("battleroyale"):
        print("ERROR: Este script debe ejecutarse desde la raíz del proyecto")
        sys.exit(1)
    
    # Analizar resultados existentes
    brkga_results = analyze_brkga_results()
    hibrid_results = analyze_hibrid_results()
    
    # Dar recomendaciones
    recommend_best_graphs()

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Script para verificar y analizar el archivo results.dat antes del análisis en R.
Muestra estadísticas descriptivas básicas y detecta posibles problemas.
"""

import pandas as pd
import sys

def verify_results_dat(file_path):
    """Verifica el archivo results.dat y muestra estadísticas."""
    
    print("="*70)
    print("VERIFICACIÓN DEL ARCHIVO results.dat")
    print("="*70)
    
    try:
        # Leer el archivo
        df = pd.read_csv(file_path, sep='\t')
        print(f"\n✓ Archivo cargado exitosamente: {file_path}")
        print(f"✓ Total de filas: {len(df)}")
        print(f"✓ Total de columnas: {len(df.columns)}")
        
        # Verificar columnas esperadas
        expected_cols = ['inst', 'nstr', 'length', 't', 'GREEDY', 'SA', 'BRKGA']
        missing_cols = set(expected_cols) - set(df.columns)
        
        if missing_cols:
            print(f"\n✗ ERROR: Faltan columnas: {missing_cols}")
            return False
        
        print(f"\n✓ Columnas correctas: {list(df.columns)}")
        
        # Verificar valores nulos
        null_counts = df.isnull().sum()
        if null_counts.sum() > 0:
            print("\n✗ ADVERTENCIA: Se encontraron valores nulos:")
            print(null_counts[null_counts > 0])
        else:
            print("\n✓ No hay valores nulos")
        
        # Estadísticas por tamaño de grafo
        print("\n" + "="*70)
        print("DISTRIBUCIÓN POR TAMAÑO DE GRAFO (nstr)")
        print("="*70)
        for nstr in sorted(df['nstr'].unique()):
            count = len(df[df['nstr'] == nstr])
            print(f"  {nstr} nodos: {count} instancias")
        
        # Estadísticas por densidad
        print("\n" + "="*70)
        print("DISTRIBUCIÓN POR DENSIDAD (t)")
        print("="*70)
        for t in sorted(df['t'].unique()):
            count = len(df[df['t'] == t])
            print(f"  Densidad {t:.1f}: {count} instancias")
        
        # Estadísticas descriptivas por algoritmo
        print("\n" + "="*70)
        print("ESTADÍSTICAS DESCRIPTIVAS POR ALGORITMO")
        print("="*70)
        
        algorithms = ['GREEDY', 'SA', 'BRKGA']
        
        for alg in algorithms:
            print(f"\n{alg}:")
            print(f"  Media:        {df[alg].mean():.2f}")
            print(f"  Mediana:      {df[alg].median():.2f}")
            print(f"  Desv. Est.:   {df[alg].std():.2f}")
            print(f"  Mínimo:       {df[alg].min():.0f}")
            print(f"  Máximo:       {df[alg].max():.0f}")
        
        # Comparación de promedios
        print("\n" + "="*70)
        print("RANKING DE ALGORITMOS (por media global)")
        print("="*70)
        
        means = {alg: df[alg].mean() for alg in algorithms}
        ranked = sorted(means.items(), key=lambda x: x[1], reverse=True)
        
        for i, (alg, mean) in enumerate(ranked, 1):
            print(f"  {i}. {alg:10s} - Media: {mean:.2f}")
        
        # Análisis por tamaño
        print("\n" + "="*70)
        print("RANKING POR TAMAÑO DE GRAFO")
        print("="*70)
        
        for nstr in sorted(df['nstr'].unique()):
            subset = df[df['nstr'] == nstr]
            print(f"\nGrafos de {nstr} nodos:")
            means = {alg: subset[alg].mean() for alg in algorithms}
            ranked = sorted(means.items(), key=lambda x: x[1], reverse=True)
            for i, (alg, mean) in enumerate(ranked, 1):
                print(f"  {i}. {alg:10s} - Media: {mean:.2f}")
        
        # Análisis por densidad
        print("\n" + "="*70)
        print("RANKING POR DENSIDAD (solo primeras 3 densidades)")
        print("="*70)
        
        for t in sorted(df['t'].unique())[:3]:
            subset = df[df['t'] == t]
            print(f"\nDensidad {t:.1f}:")
            means = {alg: subset[alg].mean() for alg in algorithms}
            ranked = sorted(means.items(), key=lambda x: x[1], reverse=True)
            for i, (alg, mean) in enumerate(ranked, 1):
                print(f"  {i}. {alg:10s} - Media: {mean:.2f}")
        
        # Verificar consistencia de datos
        print("\n" + "="*70)
        print("VERIFICACIÓN DE CONSISTENCIA")
        print("="*70)
        
        # Verificar que cada combinación (nstr, t) tenga el mismo número de instancias
        groups = df.groupby(['nstr', 't']).size()
        if groups.nunique() == 1:
            print(f"✓ Todas las combinaciones (nstr, t) tienen {groups.iloc[0]} instancias")
        else:
            print("✗ ADVERTENCIA: Número inconsistente de instancias por configuración")
            print(groups.value_counts())
        
        # Verificar que no haya instancias duplicadas
        duplicates = df.duplicated(subset=['nstr', 't', 'GREEDY', 'SA', 'BRKGA']).sum()
        if duplicates == 0:
            print("✓ No hay filas duplicadas")
        else:
            print(f"✗ ADVERTENCIA: Se encontraron {duplicates} filas duplicadas")
        
        print("\n" + "="*70)
        print("VERIFICACIÓN COMPLETADA")
        print("="*70)
        print("\nEl archivo está listo para ser analizado en R.")
        print("Ejecuta: cd SandBox && R")
        print("Y luego: source('statistical_evaluation_misp.R')")
        
        return True
        
    except FileNotFoundError:
        print(f"\n✗ ERROR: No se encontró el archivo {file_path}")
        print("Ejecuta primero: python3 generate_results_dat.py")
        return False
    except Exception as e:
        print(f"\n✗ ERROR: {str(e)}")
        return False

if __name__ == "__main__":
    file_path = "SandBox/results.dat"
    
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
    
    success = verify_results_dat(file_path)
    sys.exit(0 if success else 1)

#!/usr/bin/env python3
"""
Script para visualizar los resultados del versus entre SA, BRKGA y BRKGA_hibrid
Genera gráficos de la evolución ANYTIME de cada algoritmo
"""

import pandas as pd
import matplotlib.pyplot as plt
import os
import sys

def load_anytime_data(filename, algorithm_name):
    """Carga los datos ANYTIME de un archivo"""
    if not os.path.exists(filename):
        print(f"ADVERTENCIA: No se encuentra {filename}")
        return None
    
    data = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                parts = line.split()
                if len(parts) == 2:
                    try:
                        valor = int(parts[0])
                        tiempo = float(parts[1])
                        data.append({'tiempo': tiempo, 'valor': valor, 'algoritmo': algorithm_name})
                    except ValueError:
                        continue
    
    if not data:
        print(f"ADVERTENCIA: No se pudieron parsear datos de {filename}")
        return None
    
    return pd.DataFrame(data)

def plot_anytime_comparison(sa_df, brkga_df, hibrid_df):
    """Genera gráfico comparativo de la evolución ANYTIME"""
    plt.figure(figsize=(14, 8))
    
    # Gráfico principal
    if sa_df is not None:
        plt.plot(sa_df['tiempo'], sa_df['valor'], 'o-', label='SA', 
                linewidth=2, markersize=4, alpha=0.7)
    
    if brkga_df is not None:
        plt.plot(brkga_df['tiempo'], brkga_df['valor'], 's-', label='BRKGA', 
                linewidth=2, markersize=4, alpha=0.7)
    
    if hibrid_df is not None:
        plt.plot(hibrid_df['tiempo'], hibrid_df['valor'], '^-', label='BRKGA Híbrido', 
                linewidth=2, markersize=4, alpha=0.7)
    
    plt.xlabel('Tiempo (segundos)', fontsize=12)
    plt.ylabel('Tamaño del Conjunto Independiente', fontsize=12)
    plt.title('Comparación ANYTIME: SA vs BRKGA vs BRKGA Híbrido\n(15 minutos de ejecución)', 
              fontsize=14, fontweight='bold')
    plt.legend(fontsize=11, loc='lower right')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    
    # Guardar figura
    plt.savefig('results/versus_anytime_comparison.png', dpi=300, bbox_inches='tight')
    print("✓ Gráfico guardado: results/versus_anytime_comparison.png")
    
    # Mostrar figura
    plt.show()

def print_statistics(sa_df, brkga_df, hibrid_df):
    """Imprime estadísticas de cada algoritmo"""
    print("\n" + "="*70)
    print(" ESTADÍSTICAS DEL VERSUS ".center(70))
    print("="*70)
    
    algorithms = [
        ('SA', sa_df),
        ('BRKGA', brkga_df),
        ('BRKGA Híbrido', hibrid_df)
    ]
    
    for name, df in algorithms:
        if df is not None and not df.empty:
            mejor = df['valor'].max()
            tiempo_mejor = df[df['valor'] == mejor]['tiempo'].min()
            mejoras = len(df)
            tiempo_total = df['tiempo'].max()
            
            print(f"\n{name}:")
            print(f"  • Mejor solución: {mejor}")
            print(f"  • Tiempo para mejor solución: {tiempo_mejor:.2f}s")
            print(f"  • Número de mejoras: {mejoras}")
            print(f"  • Tiempo total: {tiempo_total:.2f}s")
            
            if len(df) > 1:
                mejora_inicial = df.iloc[0]['valor']
                mejora_final = mejor
                porcentaje_mejora = ((mejora_final - mejora_inicial) / mejora_inicial) * 100
                print(f"  • Mejora respecto a inicial: {porcentaje_mejora:.2f}%")
        else:
            print(f"\n{name}: Sin datos")
    
    print("\n" + "="*70)
    
    # Comparación final
    resultados = []
    for name, df in algorithms:
        if df is not None and not df.empty:
            resultados.append((name, df['valor'].max()))
    
    if resultados:
        resultados.sort(key=lambda x: x[1], reverse=True)
        print("\nRANKING FINAL:")
        for i, (name, valor) in enumerate(resultados, 1):
            print(f"  {i}. {name}: {valor}")
        print("="*70 + "\n")

def main():
    # Verificar que existe el directorio de resultados
    if not os.path.exists('results'):
        print("ERROR: No existe el directorio 'results'. Ejecuta primero run_versus.sh")
        sys.exit(1)
    
    # Cargar datos
    print("Cargando datos ANYTIME...")
    sa_df = load_anytime_data('results/sa_anytime.txt', 'SA')
    brkga_df = load_anytime_data('results/brkga_anytime.txt', 'BRKGA')
    hibrid_df = load_anytime_data('results/brkga_hibrid_anytime.txt', 'BRKGA Híbrido')
    
    # Verificar que hay al menos un dataset
    if sa_df is None and brkga_df is None and hibrid_df is None:
        print("ERROR: No se pudieron cargar datos de ningún algoritmo")
        sys.exit(1)
    
    # Generar gráfico
    print("\nGenerando gráfico comparativo...")
    plot_anytime_comparison(sa_df, brkga_df, hibrid_df)
    
    # Imprimir estadísticas
    print_statistics(sa_df, brkga_df, hibrid_df)

if __name__ == "__main__":
    main()

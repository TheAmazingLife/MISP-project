#!/usr/bin/env python3
"""
Battle Royale - Análisis y visualización de resultados
Combina los resultados de SA, BRKGA y BRKGA_HIBRID y genera gráficos comparativos

Uso:
    python3 battleroyale/scripts/analyze_results.py <basename> [--time 3600]
    
Ejemplo:
    python3 battleroyale/scripts/analyze_results.py erdos_n3000_p0c0.7_1 --time 3600
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import argparse
import os
import sys
from pathlib import Path

def load_results(basename, time, results_dir="battleroyale/resultados"):
    """Carga los resultados de los tres algoritmos"""
    
    results = {}
    missing = []
    
    # Archivos esperados
    files = {
        'SA': f"{results_dir}/sa_{basename}_{time}s.csv",
        'BRKGA': f"{results_dir}/brkga_{basename}_{time}s.csv",
        'BRKGA_HIBRID': f"{results_dir}/hibrid_{basename}_{time}s.csv"
    }
    
    for algo, filepath in files.items():
        if os.path.exists(filepath):
            try:
                df = pd.read_csv(filepath)
                results[algo] = df
                print(f"✓ {algo:15} - {len(df)} muestras cargadas")
            except Exception as e:
                print(f"✗ {algo:15} - Error leyendo: {e}")
                missing.append(algo)
        else:
            print(f"✗ {algo:15} - Archivo no encontrado: {filepath}")
            missing.append(algo)
    
    return results, missing

def plot_comparison(results, basename, time, output_dir="battleroyale/resultados"):
    """Genera gráficos de comparación"""
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle(f'Battle Royale: SA vs BRKGA vs BRKGA_HIBRID\n{basename} ({time}s = {time/60:.0f} min)', 
                 fontsize=16, fontweight='bold')
    
    # Colores
    colors = {
        'SA': '#A23B72',
        'BRKGA': '#2E86AB',
        'BRKGA_HIBRID': '#F18F01'
    }
    
    # --- Gráfico 1: Evolución del fitness ---
    ax1 = axes[0, 0]
    for algo, df in results.items():
        ax1.plot(df['tiempo'], df['fitness'], 
                label=algo, linewidth=2.5, color=colors[algo], 
                marker='o', markersize=2, markevery=max(1, len(df)//50))
    
    ax1.set_xlabel('Tiempo (segundos)', fontsize=12)
    ax1.set_ylabel('Fitness (tamaño del conjunto independiente)', fontsize=12)
    ax1.set_title('Evolución Temporal del Fitness', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11, loc='lower right')
    ax1.grid(True, alpha=0.3)
    
    # --- Gráfico 2: Primeros 60 segundos (zoom inicial) ---
    ax2 = axes[0, 1]
    for algo, df in results.items():
        df_zoom = df[df['tiempo'] <= 60]
        if len(df_zoom) > 0:
            ax2.plot(df_zoom['tiempo'], df_zoom['fitness'], 
                    label=algo, linewidth=2.5, color=colors[algo],
                    marker='o', markersize=3)
    
    ax2.set_xlabel('Tiempo (segundos)', fontsize=12)
    ax2.set_ylabel('Fitness', fontsize=12)
    ax2.set_title('Zoom: Primeros 60 segundos', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    # --- Gráfico 3: Diferencias relativas ---
    ax3 = axes[1, 0]
    
    # Necesitamos un tiempo común para comparar
    if 'BRKGA' in results and 'SA' in results:
        # Interpolar a los mismos tiempos
        common_times = results['BRKGA']['tiempo'].values
        
        brkga_fitness = results['BRKGA']['fitness'].values
        sa_fitness = np.interp(common_times, results['SA']['tiempo'], results['SA']['fitness'])
        
        diff_brkga_sa = brkga_fitness - sa_fitness
        ax3.plot(common_times, diff_brkga_sa, 
                label='BRKGA - SA', linewidth=2, color='#06A77D')
        
        if 'BRKGA_HIBRID' in results:
            hibrid_fitness = np.interp(common_times, results['BRKGA_HIBRID']['tiempo'], results['BRKGA_HIBRID']['fitness'])
            diff_hibrid_sa = hibrid_fitness - sa_fitness
            diff_hibrid_brkga = hibrid_fitness - brkga_fitness
            
            ax3.plot(common_times, diff_hibrid_sa, 
                    label='HIBRID - SA', linewidth=2, color='#C73E1D')
            ax3.plot(common_times, diff_hibrid_brkga, 
                    label='HIBRID - BRKGA', linewidth=2, color='#6A4C93')
        
        ax3.axhline(y=0, color='black', linestyle='--', linewidth=1, alpha=0.5)
        ax3.set_xlabel('Tiempo (segundos)', fontsize=12)
        ax3.set_ylabel('Diferencia de Fitness', fontsize=12)
        ax3.set_title('Diferencias entre Algoritmos', fontsize=13, fontweight='bold')
        ax3.legend(fontsize=11)
        ax3.grid(True, alpha=0.3)
    
    # --- Gráfico 4: Tabla de resumen ---
    ax4 = axes[1, 1]
    ax4.axis('off')
    
    # Calcular estadísticas
    stats_data = []
    for algo, df in results.items():
        fitness_values = df['fitness'].values
        stats_data.append([
            algo,
            f"{fitness_values[0]:.0f}",
            f"{fitness_values[-1]:.0f}",
            f"{fitness_values[-1] - fitness_values[0]:.0f}",
            f"{fitness_values.max():.0f}",
            f"{fitness_values.mean():.1f}"
        ])
    
    # Crear tabla
    table = ax4.table(cellText=stats_data,
                     colLabels=['Algoritmo', 'Inicial', 'Final', 'Mejora', 'Máximo', 'Promedio'],
                     cellLoc='center',
                     loc='center',
                     bbox=[0, 0.3, 1, 0.6])
    
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 2)
    
    # Estilo de la tabla
    for i in range(len(stats_data) + 1):
        for j in range(6):
            cell = table[(i, j)]
            if i == 0:
                cell.set_facecolor('#40466e')
                cell.set_text_props(weight='bold', color='white')
            else:
                cell.set_facecolor('#f0f0f0' if i % 2 == 0 else 'white')
    
    # Determinar ganador
    final_values = {algo: df['fitness'].values[-1] for algo, df in results.items()}
    winner = max(final_values, key=final_values.get)
    winner_fitness = final_values[winner]
    
    ax4.text(0.5, 0.15, f'🏆 GANADOR: {winner}', 
            ha='center', va='center', fontsize=14, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='gold', alpha=0.7))
    
    ax4.text(0.5, 0.05, f'Fitness final: {winner_fitness:.0f}', 
            ha='center', va='center', fontsize=12)
    
    plt.tight_layout()
    
    # Guardar
    output_file = f"{output_dir}/battle_{basename}_{time}s_comparison.pdf"
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"\n✓ Gráfico guardado: {output_file}")
    
    # También en PNG
    output_png = f"{output_dir}/battle_{basename}_{time}s_comparison.png"
    plt.savefig(output_png, dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico guardado: {output_png}")
    
    plt.close()

def print_summary(results):
    """Imprime resumen estadístico"""
    
    print("\n" + "="*70)
    print("RESUMEN ESTADÍSTICO")
    print("="*70)
    
    for algo, df in results.items():
        fitness = df['fitness'].values
        print(f"\n{algo}:")
        print(f"  Fitness inicial:  {fitness[0]:.0f}")
        print(f"  Fitness final:    {fitness[-1]:.0f}")
        print(f"  Mejora total:     {fitness[-1] - fitness[0]:.0f} ({(fitness[-1] - fitness[0]) / fitness[0] * 100:.1f}%)")
        print(f"  Fitness máximo:   {fitness.max():.0f}")
        print(f"  Fitness promedio: {fitness.mean():.1f}")
        print(f"  Desv. estándar:   {fitness.std():.2f}")
    
    # Comparación final
    print(f"\n{'='*70}")
    print("COMPARACIÓN FINAL")
    print("="*70)
    
    final_values = {algo: df['fitness'].values[-1] for algo, df in results.items()}
    sorted_algos = sorted(final_values.items(), key=lambda x: x[1], reverse=True)
    
    print(f"\nRanking por fitness final:")
    for i, (algo, fitness) in enumerate(sorted_algos, 1):
        emoji = "🥇" if i == 1 else "🥈" if i == 2 else "🥉"
        print(f"  {emoji} {i}. {algo:15} - {fitness:.0f}")
    
    if len(sorted_algos) >= 2:
        diff = sorted_algos[0][1] - sorted_algos[1][1]
        pct = diff / sorted_algos[1][1] * 100
        print(f"\nDiferencia 1º vs 2º: {diff:.0f} ({pct:.1f}%)")
    
    print(f"\n{'='*70}\n")

def main():
    parser = argparse.ArgumentParser(description='Análisis de resultados Battle Royale')
    parser.add_argument('basename', help='Nombre base del grafo (ej: erdos_n3000_p0c0.7_1)')
    parser.add_argument('--time', type=int, default=3600, help='Tiempo de ejecución en segundos')
    parser.add_argument('--results-dir', default='battleroyale/resultados', help='Directorio de resultados')
    
    args = parser.parse_args()
    
    print("╔════════════════════════════════════════════════════════════════╗")
    print("║        Battle Royale - Análisis de Resultados                 ║")
    print("╚════════════════════════════════════════════════════════════════╝")
    print()
    print(f"Grafo:    {args.basename}")
    print(f"Tiempo:   {args.time}s ({args.time/60:.0f} minutos)")
    print()
    print("Cargando resultados...")
    print()
    
    results, missing = load_results(args.basename, args.time, args.results_dir)
    
    if not results:
        print("\n✗ No se encontraron resultados. Verifica que los experimentos hayan terminado.")
        sys.exit(1)
    
    if missing:
        print(f"\n⚠️  Advertencia: Faltan resultados de {', '.join(missing)}")
    
    print("\nGenerando visualizaciones...")
    plot_comparison(results, args.basename, args.time, args.results_dir)
    
    print_summary(results)
    
    print("✓ Análisis completado exitosamente")

if __name__ == '__main__':
    main()

/*
Battle Royale: Comparación Anytime de SA vs BRKGA vs BRKGA_HIBRID
Ejecuta los tres algoritmos en paralelo durante un tiempo determinado (default: 60 minutos)
Captura la mejor solución a intervalos regulares para análisis anytime

Cada algoritmo corre en su propio thread y registra su progreso independientemente.
La salida es un CSV con el fitness de cada algoritmo en cada punto de tiempo.

Compilar:
g++ -std=c++17 -pthread -O3 \
    battleroyale/source/battleroyale_anytime.cpp \
    metaheuristica/source/utils/GraphReader.cpp \
    metaheuristica_poblacional/source/brkga_class.cpp \
    -Ibattleroyale/source \
    -Imetaheuristica_poblacional/source \
    -Imetaheuristica/source \
    -o battleroyale/battleroyale_anytime

Ejecutar:
./battleroyale/battleroyale_anytime -i <grafo> -t <segundos> -s <intervalo> -o <output.csv>

Ejemplo:
./battleroyale/battleroyale_anytime -i dataset_grafos_no_dirigidos/new_3000_dataset/erdos_n3000_p0c0.7_1.graph -t 3600 -s 5 -o resultados/battle_3600s.csv
*/

#include "../../metaheuristica/source/utils/GraphReader.h"
#include "../../metaheuristica_poblacional/source/brkga_class.h"
#include <algorithm>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>
#include <iomanip>
#include <thread>
#include <atomic>
#include <mutex>

using namespace std;
using namespace std::chrono;

// ==================== SIMULATED ANNEALING ====================

vector<int> random_neighbor_solution(const vector<int> &S,
                                     const vector<vector<int>> &adj, int V,
                                     mt19937 &gen) {
    vector<int> S_prime;
    bool valid = false;
    int attempts = 0;

    uniform_int_distribution<> node_dist(1, V);

    while (!valid && attempts < 1000) {
        attempts++;
        S_prime = S;
        int v = node_dist(gen);

        auto it = find(S_prime.begin(), S_prime.end(), v);
        if (it != S_prime.end()) {
            S_prime.erase(it);
        } else {
            bool conflict = false;
            for (int neighbor : adj[v]) {
                if (find(S_prime.begin(), S_prime.end(), neighbor) != S_prime.end()) {
                    conflict = true;
                    break;
                }
            }
            if (!conflict) {
                S_prime.push_back(v);
            }
        }

        if (!S_prime.empty()) {
            valid = true;
        }
    }

    return valid ? S_prime : S;
}

vector<int> greedy_initial_solution(const vector<vector<int>> &adj, int V) {
    vector<int> S;
    vector<bool> included(V + 1, false);

    for (int v = 1; v <= V; v++) {
        bool can_add = true;
        for (int neighbor : adj[v]) {
            if (included[neighbor]) {
                can_add = false;
                break;
            }
        }
        if (can_add) {
            S.push_back(v);
            included[v] = true;
        }
    }
    return S;
}

void run_simulated_annealing(const vector<vector<int>> &adj, int V,
                             int time_limit, atomic<int> &best_fitness,
                             atomic<bool> &running) {
    mt19937 gen(42);
    
    vector<int> S = greedy_initial_solution(adj, V);
    int best_size = S.size();
    best_fitness.store(best_size);

    double T = 100.0;
    double T_min = 0.1;
    double alpha = 0.9995;
    
    auto start_time = high_resolution_clock::now();
    
    while (running.load()) {
        auto current_time = high_resolution_clock::now();
        auto elapsed = duration_cast<seconds>(current_time - start_time).count();
        
        if (elapsed >= time_limit) {
            break;
        }

        vector<int> S_prime = random_neighbor_solution(S, adj, V, gen);
        int delta = S_prime.size() - S.size();

        if (delta > 0 || exp(delta / T) > uniform_real_distribution<>(0.0, 1.0)(gen)) {
            S = S_prime;
            if ((int)S.size() > best_size) {
                best_size = S.size();
                best_fitness.store(best_size);
            }
        }

        T = max(T_min, T * alpha);
    }
    
    running.store(false);
}

void run_brkga(const vector<vector<int>> &adj, int V,
               int time_limit, atomic<int> &best_fitness,
               atomic<bool> &running) {
    
    // Parámetros optimizados para BRKGA
    int p = 264;
    double pe = 0.14;
    double pm = 0.25;
    double rhoe = 0.65;
    unsigned seed = 42;

    BRKGA_MISP brkga(adj, V, p, pe, pm, rhoe, seed);
    
    int best_size = 0;
    auto start_time = high_resolution_clock::now();
    
    while (running.load()) {
        auto current_time = high_resolution_clock::now();
        auto elapsed = duration_cast<seconds>(current_time - start_time).count();
        
        if (elapsed >= time_limit) {
            break;
        }

        brkga.evolve();
        vector<int> best_solution = brkga.getBestSolution();
        
        if ((int)best_solution.size() > best_size) {
            best_size = best_solution.size();
            best_fitness.store(best_size);
        }
    }
    
    running.store(false);
}

// ==================== MAIN ====================

int main(int argc, char *argv[]) {
    string input_file;
    int time_limit = 3600;  // 60 minutos por defecto
    int sample_interval = 5; // Muestrear cada 5 segundos
    string output_file = "battleroyale_results.csv";

    // Parsear argumentos
    for (int i = 1; i < argc; i++) {
        string arg = argv[i];
        if (arg == "-i" && i + 1 < argc) {
            input_file = argv[++i];
        } else if (arg == "-t" && i + 1 < argc) {
            time_limit = stoi(argv[++i]);
        } else if (arg == "-s" && i + 1 < argc) {
            sample_interval = stoi(argv[++i]);
        } else if (arg == "-o" && i + 1 < argc) {
            output_file = argv[++i];
        }
    }

    if (input_file.empty()) {
        cerr << "Error: Falta archivo de entrada (-i)" << endl;
        cerr << "Uso: " << argv[0] << " -i <grafo> [-t <segundos>] [-s <intervalo>] [-o <output>]" << endl;
        return 1;
    }

    cout << "╔════════════════════════════════════════════════════════════════╗" << endl;
    cout << "║              BATTLE ROYALE: SA vs BRKGA vs BRKGA_HIBRID       ║" << endl;
    cout << "╚════════════════════════════════════════════════════════════════╝" << endl;
    cout << endl;
    cout << "📊 Grafo: " << input_file << endl;
    cout << "⏱️  Tiempo límite: " << time_limit << " segundos (" << time_limit/60.0 << " minutos)" << endl;
    cout << "📈 Intervalo de muestreo: " << sample_interval << " segundos" << endl;
    cout << "💾 Salida: " << output_file << endl;
    cout << endl;

    // Leer grafo
    cout << "Leyendo grafo..." << flush;
    int V, E;
    vector<vector<int>> adj = GraphReader::readGraphFromFile(input_file, V, E);
    cout << " ✓" << endl;
    cout << "Vértices: " << V << ", Aristas: " << E << endl;
    cout << endl;

    // Variables atómicas para compartir entre threads
    atomic<int> sa_best(0);
    atomic<int> brkga_best(0);
    atomic<bool> sa_running(true);
    atomic<bool> brkga_running(true);

    // Iniciar threads
    cout << "🚀 Iniciando algoritmos..." << endl;
    cout << "   - Simulated Annealing" << endl;
    cout << "   - BRKGA" << endl;
    cout << endl;
    
    auto global_start = high_resolution_clock::now();
    
    thread sa_thread(run_simulated_annealing, ref(adj), V, time_limit, ref(sa_best), ref(sa_running));
    thread brkga_thread(run_brkga, ref(adj), V, time_limit, ref(brkga_best), ref(brkga_running));

    // Archivo de salida
    ofstream out(output_file);
    out << "tiempo,sa_fitness,brkga_fitness" << endl;

    // Monitoreo y muestreo
    cout << "Tiempo\tSA\tBRKGA" << endl;
    cout << "──────\t──────\t──────" << endl;

    int elapsed = 0;
    while (elapsed < time_limit) {
        this_thread::sleep_for(seconds(sample_interval));
        
        auto current_time = high_resolution_clock::now();
        elapsed = duration_cast<seconds>(current_time - global_start).count();
        
        int sa_current = sa_best.load();
        int brkga_current = brkga_best.load();
        
        out << elapsed << "," << sa_current << "," << brkga_current << endl;
        
        cout << elapsed << "s\t" << sa_current << "\t" << brkga_current << endl;
        
        // Si ambos terminaron antes, salir
        if (!sa_running.load() && !brkga_running.load()) {
            break;
        }
    }

    // Detener threads
    sa_running.store(false);
    brkga_running.store(false);
    
    sa_thread.join();
    brkga_thread.join();
    
    out.close();

    // Resultados finales
    cout << endl;
    cout << "╔════════════════════════════════════════════════════════════════╗" << endl;
    cout << "║                      RESULTADOS FINALES                        ║" << endl;
    cout << "╚════════════════════════════════════════════════════════════════╝" << endl;
    cout << endl;
    cout << "Simulated Annealing: " << sa_best.load() << endl;
    cout << "BRKGA:               " << brkga_best.load() << endl;
    cout << endl;
    
    int winner_fitness = max(sa_best.load(), brkga_best.load());
    string winner = (sa_best.load() == winner_fitness) ? "SA" : "BRKGA";
    
    if (sa_best.load() == brkga_best.load()) {
        cout << "🏆 EMPATE" << endl;
    } else {
        cout << "🏆 GANADOR: " << winner << " con fitness " << winner_fitness << endl;
    }
    
    cout << endl;
    cout << "Resultados guardados en: " << output_file << endl;

    return 0;
}

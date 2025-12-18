/*
Simulated Annealing Standalone con modo Anytime
Ejecuta SA y registra el mejor fitness a intervalos regulares

Compilar:
g++ -std=c++17 -O3 battleroyale/source/sa_standalone.cpp metaheuristica/source/utils/GraphReader.cpp -Ibattleroyale/source -Imetaheuristica/source -o battleroyale/sa_standalone

Ejecutar:
./battleroyale/sa_standalone -i <grafo> -t <segundos> -s <intervalo> -o <output.csv>
*/

#include "../../metaheuristica/source/utils/GraphReader.h"
#include <algorithm>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>
#include <iomanip>

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
                if (find(S_prime.begin(), S_prime.end(), neighbor) !=
                    S_prime.end()) {
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

int main(int argc, char *argv[]) {
    string input_file;
    int time_limit = 3600;
    int sample_interval = 5;
    string output_file = "sa_results.csv";

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
        return 1;
    }

    // Leer grafo
    int V, E;
    vector<vector<int>> adj = GraphReader::readGraphFromFile(input_file, V, E);

    // Inicialización
    mt19937 gen(42);
    vector<int> S = greedy_initial_solution(adj, V);
    int best_size = S.size();

    double T = 100.0;
    double T_min = 0.1;
    double alpha = 0.9995;

    // Archivo de salida
    ofstream out(output_file);
    out << "tiempo,fitness" << endl;

    auto start_time = high_resolution_clock::now();
    auto last_sample = start_time;

    long long iteration = 0;

    while (true) {
        auto current_time = high_resolution_clock::now();
        auto elapsed = duration_cast<seconds>(current_time - start_time).count();
        auto since_sample = duration_cast<seconds>(current_time - last_sample).count();

        // Salir si se acabó el tiempo
        if (elapsed >= time_limit) {
            break;
        }

        // Guardar muestra si es momento
        if (since_sample >= sample_interval) {
            out << elapsed << "," << best_size << endl;
            last_sample = current_time;
        }

        // Iteración de SA
        vector<int> S_prime = random_neighbor_solution(S, adj, V, gen);
        int delta = S_prime.size() - S.size();

        if (delta > 0 || exp(delta / T) > uniform_real_distribution<>(0.0, 1.0)(gen)) {
            S = S_prime;
            if ((int)S.size() > best_size) {
                best_size = S.size();
            }
        }

        T = max(T_min, T * alpha);
        iteration++;
    }

    // Última muestra
    out << time_limit << "," << best_size << endl;
    out.close();

    cout << best_size << endl;  // Resultado final

    return 0;
}

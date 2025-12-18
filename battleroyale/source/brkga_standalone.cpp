/*
BRKGA Standalone con modo Anytime
Ejecuta BRKGA y registra el mejor fitness a intervalos regulares

Compilar:
g++ -std=c++17 -O3 battleroyale/source/brkga_standalone.cpp metaheuristica/source/utils/GraphReader.cpp metaheuristica_poblacional/source/brkga_class.cpp -Ibattleroyale/source -Imetaheuristica_poblacional/source -Imetaheuristica/source -o battleroyale/brkga_standalone

Ejecutar:
./battleroyale/brkga_standalone -i <grafo> -t <segundos> -s <intervalo> -o <output.csv>
*/

#include "../../metaheuristica/source/utils/GraphReader.h"
#include "../../metaheuristica_poblacional/source/brkga_class.h"
#include <chrono>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

using namespace std;
using namespace std::chrono;

int main(int argc, char *argv[]) {
    string input_file;
    int time_limit = 3600;
    int sample_interval = 5;
    string output_file = "brkga_results.csv";

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
    int V;
    vector<vector<int>> adj;
    if (!GraphReader::loadFromFile(input_file, V, adj)) {
        cerr << "Error: No se pudo cargar el grafo" << endl;
        return 1;
    }

    // Parámetros optimizados para BRKGA
    int p = 264;
    double pe = 0.14;
    double pm = 0.25;
    double rhoe = 0.65;
    double s = 0.0; // No usado en modo anytime
    unsigned seed = 42;

    // Crear instancia BRKGA (n, p, pe, pm, rhoe, s, adj, seed)
    BRKGA brkga(V, p, pe, pm, rhoe, s, adj, seed);
    brkga.inicializar_poblacion();

    int best_size = 0;

    // Archivo de salida
    ofstream out(output_file);
    out << "tiempo,fitness" << endl;

    auto start_time = high_resolution_clock::now();
    auto last_sample = start_time;

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

        // Evolucionar BRKGA
        brkga.generacion();
        vector<int> best_solution = brkga.getSolution();

        if ((int)best_solution.size() > best_size) {
            best_size = best_solution.size();
        }
    }

    // Última muestra
    out << time_limit << "," << best_size << endl;
    out.close();

    cout << best_size << endl;  // Resultado final

    return 0;
}

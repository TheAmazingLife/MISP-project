/*
BRKGA_HIBRID Standalone con modo Anytime
Ejecuta BRKGA con hibridación CPLEX y registra el mejor fitness a intervalos regulares

Este código es una versión modificada del BRKGA_HIBRID para soportar modo anytime.
Registra el mejor fitness encontrado cada X segundos durante la ejecución.

Compilar (requiere CPLEX):
g++ -std=c++17 -O3 -DIL_STD \
    -I/opt/ibm/ILOG/CPLEX_Studio2211/cplex/include \
    -I/opt/ibm/ILOG/CPLEX_Studio2211/concert/include \
    battleroyale/source/brkga_hibrid_standalone.cpp \
    metaheuristica_hibrida/source/brkga_class.cpp \
    metaheuristica/source/utils/GraphReader.cpp \
    -Ibattleroyale/source \
    -Imetaheuristica_hibrida/source \
    -Imetaheuristica/source \
    -L/opt/ibm/ILOG/CPLEX_Studio2211/cplex/lib/x86-64_linux/static_pic -lilocplex -lcplex \
    -L/opt/ibm/ILOG/CPLEX_Studio2211/concert/lib/x86-64_linux/static_pic -lconcert \
    -lm -lpthread -ldl \
    -o battleroyale/brkga_hibrid_standalone

Ejecutar:
./battleroyale/brkga_hibrid_standalone -i <grafo> -t <segundos> -s <intervalo> -o <output.csv>
*/

#include "../../metaheuristica_hibrida/source/brkga_class.h"
#include "../../metaheuristica/source/utils/GraphReader.h"
#include <algorithm>
#include <chrono>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>
#include <thread>
#include <atomic>
#include <mutex>

using namespace std;
using namespace std::chrono;

// Variables globales para compartir entre threads
atomic<int> current_best_fitness(0);
atomic<bool> algorithm_running(true);
mutex fitness_mutex;

// Thread que ejecuta BRKGA_HIBRID
void run_brkga_hibrid(const string& filename, int time_limit, 
                      int p, double pe, double pm, double rhoe, unsigned int seed) {
    int V;
    vector<vector<int>> adj;

    if (!GraphReader::loadFromFile(filename, V, adj)) {
        cerr << "Error loading graph" << endl;
        algorithm_running.store(false);
        return;
    }

    // Crear BRKGA
    BRKGA brkga(V, p, pe, pm, rhoe, time_limit, adj, seed);
    
    auto start = high_resolution_clock::now();
    auto end = start + seconds(time_limit);

    brkga.inicializar_poblacion();
    
    // Actualizar fitness inicial
    {
        lock_guard<mutex> lock(fitness_mutex);
        vector<int> initial_sol = brkga.decoder(brkga.getBestIndividual());
        current_best_fitness.store(initial_sol.size());
    }

    int generation_count = 0;
    int k_frecuencia = 10;

    while (high_resolution_clock::now() < end) {
        brkga.generacion();

        if (generation_count % k_frecuencia == 0) {
            brkga.runBarrakuda();
        }

        // Actualizar fitness actual
        {
            lock_guard<mutex> lock(fitness_mutex);
            vector<int> best_sol = brkga.decoder(brkga.getBestIndividual());
            current_best_fitness.store(best_sol.size());
        }

        generation_count++;
    }

    algorithm_running.store(false);
}

int main(int argc, char *argv[]) {
    string input_file;
    int time_limit = 3600;
    int sample_interval = 5;
    string output_file = "brkga_hibrid_results.csv";

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

    // Parámetros optimizados para BRKGA_HIBRID
    int p = 340;
    double pe = 0.17;
    double pm = 0.24;
    double rhoe = 0.78;
    unsigned seed = 42;

    // Archivo de salida
    ofstream out(output_file);
    out << "tiempo,fitness" << endl;

    // Iniciar thread de BRKGA
    thread brkga_thread(run_brkga_hibrid, ref(input_file), time_limit, 
                        p, pe, pm, rhoe, seed);

    auto start_time = high_resolution_clock::now();
    auto last_sample = start_time;

    // Muestreo periódico
    while (algorithm_running.load()) {
        this_thread::sleep_for(seconds(sample_interval));
        
        auto current_time = high_resolution_clock::now();
        auto elapsed = duration_cast<seconds>(current_time - start_time).count();
        
        if (elapsed >= time_limit) {
            break;
        }

        int fitness = current_best_fitness.load();
        out << elapsed << "," << fitness << endl;
    }

    // Esperar a que termine
    brkga_thread.join();

    // Última muestra
    int final_fitness = current_best_fitness.load();
    out << time_limit << "," << final_fitness << endl;
    out.close();

    cout << final_fitness << endl;

    return 0;
}

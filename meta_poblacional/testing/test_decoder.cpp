// Test del decodificador MISP
#include "../source/misp_decoder.hpp"
#include <iostream>
#include <random>
#include <chrono>

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Uso: test_decoder <archivo_grafo>\n";
        return 1;
    }
    std::string path = argv[1];

    try {
        auto inst = MISPInstance::loadFromFile(path);
        std::cout << "Grafo cargado: n=" << inst.n << "\n";

        MISPDecoder decoder(inst);

        // Crear cromosoma aleatorio
        std::vector<double> chrom(inst.n);
        std::mt19937_64 rng((unsigned)std::chrono::high_resolution_clock::now().time_since_epoch().count());
        std::uniform_real_distribution<double> dist(0.0, 1.0);
        for (int i = 0; i < inst.n; ++i) chrom[i] = dist(rng);

        std::vector<int> sol;
        double fitness = MISPDecoder::decodeChromosome(inst, chrom, sol);
        std::cout << "Fitness=" << fitness << ", Tamaño solución=" << sol.size() << "\n";

        // Verificar conjunto independiente
        std::vector<char> inS(inst.n, 0);
        for (int v : sol) inS[v] = 1;
        bool ok = true;
        for (int v : sol) {
            for (int u : inst.adj[v]) {
                if (inS[u]) {
                    std::cerr << "Violación: arista (" << v << "," << u << ") con ambos en S\n";
                    ok = false;
                }
            }
        }
        if (ok) std::cout << "Solución es conjunto independiente válido.\n";
        else std::cout << "Solución NO es válida.\n";

    } catch (const std::exception &ex) {
        std::cerr << "Error: " << ex.what() << "\n";
        return 2;
    }

    return 0;
}
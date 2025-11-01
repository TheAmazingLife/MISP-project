// Implementación del decodificador MISP
#include "misp_decoder.hpp"

#include <fstream>
#include <sstream>
#include <algorithm>
#include <stdexcept>
#include "../utils/GraphReader.h"

MISPInstance MISPInstance::loadFromFile(const std::string &path) {
    MISPInstance inst;
    int n = 0;
    std::vector<std::vector<int>> raw_adj;

    // Usa GraphReader del proyecto (en meta_poblacional/utils)
    if (!GraphReader::loadFromFile(path, n, raw_adj)) {
        throw std::runtime_error("GraphReader no pudo cargar: " + path);
    }

    // GraphReader devuelve indexación 1-based con tamaño n+1
    // Normalizamos a indexación 0-based de tamaño n
    inst.n = n;
    inst.adj.assign(n, {});

    bool raw_is_one_based = (static_cast<int>(raw_adj.size()) == n + 1);

    if (raw_is_one_based) {
        for (int i = 1; i <= n; ++i) {
            for (int v : raw_adj[i]) {
                int u = i - 1;
                int w = v - 1;
                if (w < 0 || w >= n || u < 0 || u >= n) continue;
                if (u == w) continue;
                inst.adj[u].push_back(w);
            }
        }
    } else {
        for (int i = 0; i < n && i < (int)raw_adj.size(); ++i) {
            for (int v : raw_adj[i]) {
                int u = i;
                int w = v;
                if (w < 0 || w >= n || u < 0 || u >= n) continue;
                if (u == w) continue;
                inst.adj[u].push_back(w);
            }
        }
    }

    // Elimina duplicados y ordena vecinos
    for (int i = 0; i < inst.n; ++i) {
        auto &neis = inst.adj[i];
        std::sort(neis.begin(), neis.end());
        neis.erase(std::unique(neis.begin(), neis.end()), neis.end());
    }

    return inst;
}

MISPDecoder::MISPDecoder(const MISPInstance &inst)
    : instance_(inst) {
}

double MISPDecoder::decode(const std::vector<double> &chromosome) const {
    std::vector<int> out;
    return decodeChromosome(instance_, chromosome, out);
}

double MISPDecoder::decodeChromosome(const MISPInstance &inst,
                                     const std::vector<double> &chromosome,
                                     std::vector<int> &out_solution) {
    int n = inst.n;
    if ((int)chromosome.size() != n) {
        throw std::invalid_argument("Tamaño de cromosoma no coincide con n");
    }

    // Ordena vértices por clave descendente
    std::vector<int> order(n);
    for (int i = 0; i < n; ++i) order[i] = i;
    std::stable_sort(order.begin(), order.end(), [&](int a, int b){
        return chromosome[a] > chromosome[b];
    });

    // Construcción greedy: selecciona vértice si no está bloqueado
    std::vector<char> blocked(n, 0);
    std::vector<int> selected;
    selected.reserve(n);

    for (int v : order) {
        if (!blocked[v]) {
            selected.push_back(v);
            blocked[v] = 1;
            for (int u : inst.adj[v]) {
                blocked[u] = 1;
            }
        }
    }

    out_solution.swap(selected);
    return static_cast<double>(out_solution.size());
}
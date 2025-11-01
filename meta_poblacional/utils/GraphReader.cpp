#include "GraphReader.h"
#include <fstream>
#include <iostream>

bool GraphReader::loadFromFile(const std::string& filename, int& n, std::vector<std::vector<int>>& adj) {
    std::ifstream file(filename);

    if (!file.is_open()) {
        std::cerr << "Error: no se pudo abrir el archivo " << filename << "\n";
        return false;
    }

    file >> n; 
    adj.assign(n + 1, std::vector<int>()); 

    int u, v;
    while (file >> u >> v) {
        adj[u].push_back(v);
        adj[v].push_back(u); 
    }

    file.close();
    return true;
}

std::vector<Edge> GraphReader::loadEdgesFromFile(const std::string& filename) {
    std::vector<Edge> edges;
    std::ifstream file(filename);

    if (!file.is_open()) {
        std::cerr << "Error: no se pudo abrir el archivo " << filename << "\n";
        return edges;
    }

    int n;
    file >> n;

    int u, v;
    while (file >> u >> v) {
        edges.push_back({u, v});
    }

    file.close();
    return edges;
}

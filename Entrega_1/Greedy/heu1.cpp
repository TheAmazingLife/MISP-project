#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <filesystem>
#include <algorithm>
#include <vector>
#include "GraphReader.h"
namespace fs = std::filesystem;

int main() {
    std::string dataset_choice;
    std::cout << "Elige el dataset (1000, 2000, 3000): ";
    std::cin >> dataset_choice;

    std::string dataset_path = "../dataset_grafos_no_dirigidos/new_" + dataset_choice + "_dataset";

    if (!fs::exists(dataset_path) || !fs::is_directory(dataset_path)) {
        std::cerr << "Error: El directorio del dataset no existe: " << dataset_path << std::endl;
        return 1;
    }

    std::vector<std::string> graph_files;
    std::cout << "\nArchivos de grafos disponibles:" << std::endl;
    for (const auto& entry : fs::directory_iterator(dataset_path)) {
        if (entry.path().extension() == ".graph") {
            graph_files.push_back(entry.path().filename().string());
        }
    }
    
    std::sort(graph_files.begin(), graph_files.end());
    for(const auto& file_name : graph_files) {
        std::cout << "- " << file_name << std::endl;
    }

    std::string file_name;
    std::cout << "\nEscribe el nombre del archivo que quieres usar: ";
    std::cin >> file_name;

    std::string full_path = dataset_path + "/" + file_name;

    int n_nodes;
    std::vector<std::vector<int>> adj;

    if (GraphReader::loadFromFile(full_path, n_nodes, adj)) {
        std::cout << "\nGrafo leido correctamente!" << std::endl;
        std::cout << "Numero de nodos: " << n_nodes << std::endl;
        
        // Opcional: Imprimir la lista de adyacencia para verificar
        /*
        for (int i = 1; i <= n_nodes; ++i) {
            std::cout << "Nodo " << i << ": ";
            for (int neighbor : adj[i]) {
                std::cout << neighbor << " ";
            }
            std::cout << std::endl;
        }
        */
    } else {
        std::cerr << "Hubo un error al leer el grafo." << std::endl;
        return 1;
    }

    // A partir de aquí puedes trabajar con el grafo en 'adj'

    return 0;
}

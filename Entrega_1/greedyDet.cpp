/*
Compilar:
g++ -std=c++17 <fuente> <dependencias> -o <greedyDet>

Ejecutar:
<greedyDet> -i <instancia-problema>

Ejemplo de compilación:
g++ -std=c++17 Entrega_1/greedyDet.cpp utils/GraphReader.cpp -o Entrega_1/testing/greedyDet

Ejemplo de ejecución:
./Entrega_1/testing/greedyDet -i Entrega_1/testing/small_graph.graph
*/


#include "../utils/GraphReader.h"
#include <algorithm>
#include <chrono>
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char *argv[]) {

  // Graph reading:
  if (argc != 3 || std::string(argv[1]) != "-i") {
    std::cerr << "Usage: <Greedy> -i <problem-instance>\n";
    return 1;
  }

  std::string filename = argv[2];
  int V;
  std::vector<std::vector<int>> adj;

  if (!GraphReader::loadFromFile(filename, V, adj)) {
    std::cerr << "Error loading the graph from the file." << std::endl;
    return 1;
  }

  // std::cout << "Graph loaded successfully. Number of nodes: " << V <<
  // std::endl;

  // Greedy Algorithm:
  // Step 1: Get the degrees of each node
  std::vector<std::pair<int, int>> degrees(V + 1);
  for (int i = 0; i <= V; i++) {
    degrees[i] = {adj[i].size(), i}; // {degree, index}
  }

  // Step 2: Sort the nodes by degree (ascending)
  std::sort(degrees.begin(), degrees.end());

  /*
  std::cout << "Nodes sorted by degree:\n";
  for (const auto &par : degrees) {
    std::cout << "Node: " << par.second << ", Degree: " << par.first << '\n';
  }
  */

  // Step 3: Node selection
  std::vector<int> independentSet;
  std::vector<bool> marked(V + 1, 0);

  auto start = std::chrono::high_resolution_clock::now();

  for (const auto &par : degrees) {
    int node = par.second;
    if (node == 0)
      continue; // Ignore index 0
    if (!marked[node]) {
      independentSet.push_back(node);
      marked[node] = true;
      for (const auto &neighbor : adj[node])
        marked[neighbor] = true;
    }
  }

  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end - start;

  std::cout << independentSet.size()
            << "\n";                    // Objective value (solution quality)
  std::cout << elapsed.count() << "\n"; // Time used

  return 0;
}
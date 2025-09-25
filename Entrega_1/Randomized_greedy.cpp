#include "../utils/GraphReader.h"
#include <algorithm>
#include <chrono>
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char *argv[]) {

  // Graph reading:
  if (argc < 4 || std::string(argv[1]) != "-i") {
    std::cerr << "Usage: <Greedy-probabilista> -i <instancia-problema> "
                 "[parámetros-adicionales]\n";
    return 1;
  }

  std::string filename = argv[2];
  int k = std::stoi(argv[3]);
  int V;
  std::vector<std::vector<int>> adj;

  if (!GraphReader::loadFromFile(filename, V, adj)) {
    std::cerr << "Error loading the graph from the file." << std::endl;
    return 1;
  }

  // std::cout << "Graph loaded successfully. Number of nodes: " << V <<
  // std::endl;

  // Randomized Greedy Algorithm:
  // Step 1: Get the degrees of each node
  std::vector<std::pair<int, int>> degrees(V + 1);
  std::vector<int> rcl(V + 1);

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
  int unmarked = V;

  auto start = std::chrono::high_resolution_clock::now();

  while (unmarked > 0) {
    rcl.clear();
    int tam = degrees.size();
    int counter = 0;
    for (int i = 1; i < tam && counter != k; i++) {
      int node = degrees[i].second;
      if (!marked[node]) {
        rcl.push_back(node);
        counter++;
      }
    }

    // if (rcl.empty())
    //  break;
    int idx = rand() % rcl.size();
    int node = rcl[idx];

    if (node == 0)
      continue;

    if (!marked[node]) {
      independentSet.push_back(node);
      marked[node] = true;
      unmarked--;

      for (const auto &neighbor : adj[node]) {
        if (!marked[neighbor]) {
          marked[neighbor] = true;
          unmarked--;
        }
      }
    }
  }

  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end - start;

  std::cout << independentSet.size()
            << "\n";                    // Objective value (solution quality)
  std::cout << elapsed.count() << "\n"; // Time used
  std::cout << "{";
  /*
    for (int i = 0; i < independentSet.size(); i++) {
      if (i == independentSet.size() - 1) {
        std::cout << independentSet[i];
      } else {
        std::cout << independentSet[i] << ',';
      }
    }
    std::cout << "} /n";
    */
  return 0;
}
/*
Compilar:
g++ -std=c++17 <fuente> <dependencias> -o <meta_sa>

Ejecutar: CAMBIAR ESTO AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
<meta_sa> -i <instancia-problema> <Longitud-RCL>

donde <Longitud-RCL> corresponde al tamaño de la lista restringida de candidatos
(k).

Ejemplo de compilación:
g++ -std=c++17 Entrega_1/meta_sa.cpp utils/GraphReader.cpp -o
Entrega_1/testing/meta_sa

Ejemplo de ejecución:
./Entrega_1/testing/meta_sa -i Entrega_1/testing/small_graph.graph 3
*/

#include "../utils/GraphReader.h"
#include <algorithm>
#include <chrono>
#include <cmath>
#include <iostream>
#include <random>
#include <string>
#include <vector>

#include <algorithm>
#include <cstdlib>
#include <vector>

std::vector<int>
random_neighbor_solution(const std::vector<int> &S,
                         const std::vector<std::vector<int>> &adj, int V,
                         std::mt19937 &gen) {
  std::vector<int> S_prime;
  bool valid = false;
  int attempts = 0;

  // distribution objects
  std::uniform_int_distribution<> node_dist(1, V);
  std::uniform_real_distribution<> prob_dist(0.0, 1.0);

  while (!valid && attempts < 100) {
    attempts++;
    S_prime = S;

    std::vector<bool> inSet(V + 1, false);
    for (int v : S)
      inSet[v] = true;

    int node = node_dist(gen);
    double p = prob_dist(gen);

    if (p < 0.5) {
      if (!inSet[node]) {
        bool conflict = false;
        for (int neigh : adj[node]) {
          if (inSet[neigh]) {
            conflict = true;
            break;
          }
        }

        if (!conflict) {
          S_prime.push_back(node);
          valid = true;
        }
      }
    }

    else {
      if (!S.empty()) {
        int removeIdx = rand() % S.size();
        int removeNode = S[removeIdx];
        S_prime.erase(std::remove(S_prime.begin(), S_prime.end(), removeNode),
                      S_prime.end());
        inSet[removeNode] = false;

        bool conflict = false;
        for (int neigh : adj[node]) {
          if (inSet[neigh]) {
            conflict = true;
            break;
          }
        }

        if (!conflict && !inSet[node]) {
          S_prime.push_back(node);
          valid = true;
        }
      }
    }
  }

  if (!valid)
    S_prime = S;

  return S_prime;
}

std::vector<int> greedyDet(int V, const std::vector<std::vector<int>> &adj) {
  std::vector<std::pair<int, int>> degrees(V + 1);
  for (int i = 0; i <= V; i++) {
    degrees[i] = {adj[i].size(), i}; // {degree, index}
  }

  std::sort(degrees.begin(), degrees.end());

  std::vector<int> independentSet;
  std::vector<bool> marked(V + 1, 0);

  for (const auto &par : degrees) {
    int node = par.second;
    if (node == 0)
      continue;
    if (!marked[node]) {
      independentSet.push_back(node);
      marked[node] = true;
      for (const auto &neighbor : adj[node])
        marked[neighbor] = true;
    }
  }

  return independentSet;
}

int main(int argc, char *argv[]) {

  // Graph reading:
  if (argc < 5 || std::string(argv[1]) != "-i") {
    std::cerr << "Usage: <meta_sa> -i <instancia-problema> "
                 "<temperatura-inicial> <decay>\n";
    return 1;
  }

  std::string filename = argv[2];
  double initial_temp = std::stod(argv[3]);
  double alpha = std::stod(argv[4]);
  int V;
  std::vector<std::vector<int>> adj;

  if (!GraphReader::loadFromFile(filename, V, adj)) {
    std::cerr << "Error loading the graph from the file." << std::endl;
    return 1;
  }

  // --- Simulated Annealing Algorithm ---
  std::vector<int> actual_solution = greedyDet(V, adj);

  auto start_time = std::chrono::steady_clock::now();
  const double time_limit_seconds = 10.0;

  double temp = initial_temp;

  // initialization of random number generator
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_real_distribution<> dis(0.0, 1.0);

  // time condition (10 seconds)
  while (std::chrono::duration<double>(std::chrono::steady_clock::now() -
                                       start_time)
             .count() < time_limit_seconds) {

    std::vector<int> S_prime =
        random_neighbor_solution(actual_solution, adj, V, gen);

    // Calculate the “cost” of each solution
    int actual_cost = -actual_solution.size();
    int neighbor_cost = -S_prime.size();

    // If it is better, it is accepted immediately
    if (neighbor_cost < actual_cost) {
      actual_solution = S_prime;
    } else {

      // 1. (ΔE)
      double delta_E = neighbor_cost - actual_cost;

      // 2. Calculate Boltzmann
      double probability_acceptance = std::exp(-delta_E / temp);

      // 3. random number between 0.0 and 1.0.
      double numero_aleatorio = dis(gen);

      // 4. If the random number is less than the probability,
      //    we accept the worst solution.
      if (numero_aleatorio < probability_acceptance) {
        actual_solution = S_prime;
      }
    }
    temp *= alpha; // geometric cooling
  }

  std::cout << actual_solution.size() << "\n";
  for (int i = 0; i < actual_solution.size(); i++)
    std::cout << actual_solution[i] << " ";
  std::cout << "\n";

  return 0;
}
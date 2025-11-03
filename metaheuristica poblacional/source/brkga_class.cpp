#include "brkga_class.h"
#include <algorithm>
#include <chrono>
#include <iostream>
#include <random>

bool Individuo::operator<(const Individuo &other) const {
  return fitness > other.fitness;
}

BRKGA::BRKGA(int n, int p, double pe, double pm, double rhoe, double s,
             std::vector<std::vector<int>> &adj, unsigned int seed)
    : n(n), p(p), pe(pe), pm(pm), rhoe(rhoe), s(s), poblacion(p),
      nueva_poblacion(p), adj(adj), rng(seed) {
  best_global_fitness = 0;
}

BRKGA::~BRKGA() {}

/*
Inicializamos la población generando p individuos con cromosomas aleatorios.
Cada gen del cromosoma se genera de manera uniforme en el rango [0,1].
Definimos el fitness de cada individuo como -1 inicialmente, indicando que aún
no ha sido evaluado.
*/
void BRKGA::inicializar_poblacion() {
  std::uniform_real_distribution<double> dist(0.0, 1.0);
  for (int i = 0; i < p; i++) {
    Individuo individuo;
    cromosoma cr(n);
    for (int j = 0; j < n; j++) {
      cr[j].first = dist(rng);
      cr[j].second = j + 1;
    }
    individuo.cr = cr;
    individuo.fitness = getFitness(decoder(individuo));

    poblacion[i] = individuo;
  }
  std::sort(poblacion.begin(), poblacion.end());

  // Actualiza el mejor global
  best_global = poblacion[0];
  best_global_fitness = getFitness(decoder(best_global));

  // Imprime el primer log "Any-Time"
  auto now = std::chrono::high_resolution_clock::now();
  double elapsed_s = std::chrono::duration<double>(now - start_time).count();

  std::cerr << best_global_fitness << " " << elapsed_s << "\n";
}

std::vector<int> BRKGA::decoder(Individuo ind) {
  std::vector<int> independentSet;
  std::vector<bool> marked(n + 1, 0);

  // ordenar individuo segun su cromosoma.first de mayor a menor
  std::sort(ind.cr.begin(), ind.cr.end(),
            [](const std::pair<double, int> &a,
               const std::pair<double, int> &b) { return a.first > b.first; });

  // enfoque greddy, se toma el primer vertice al siguiente
  for (const auto &par : ind.cr) {
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
  // calcular calidad de la solucion
  return independentSet;
}

int BRKGA::getFitness(std::vector<int> decodified) { return decodified.size(); }

void BRKGA::generacion() {
  /*
    nElite = número de individuos elite
    nMutante = número de individuos mutantes
    nCruce = número de individuos por cruce
  */
  int nElite = p * pe;
  int nMutante = p * pm;
  int nCruce = p - nElite - nMutante;

  // Ordenamos la población por fitness para poder seleccionar a los elite.
  std::sort(poblacion.begin(), poblacion.end());

  // Any-Time
  if (poblacion[0].fitness > best_global_fitness) {
    best_global_fitness = poblacion[0].fitness;
    best_global = poblacion[0];

    // Imprime el log "Any-Time"
    auto now = std::chrono::high_resolution_clock::now();
    double elapsed_s = std::chrono::duration<double>(now - start_time).count();

    std::cerr << best_global_fitness << " " << elapsed_s << "\n";
  }

  for (int i = 0; i < nElite; i++) {
    nueva_poblacion[i] =
        poblacion[i]; // la elite pasa directamente a la nueva generación.
  }

  // Se crean mutantes
  std::uniform_real_distribution<double> dist(0.0, 1.0);
  for (int i = 0; i < nMutante; i++) {
    Individuo individuo;
    cromosoma cr(n);
    for (int j = 0; j < n; j++) {
      cr[j].first = dist(rng);
      cr[j].second = j + 1;
    }
    individuo.cr = cr;
    individuo.fitness = getFitness(decoder(individuo));

    nueva_poblacion[nElite + i] = individuo;
  }

  /* Realizamos los cruces para generar los individuos restantes de la nueva
  población. Lo que hacemos es seleccionar un padre elite y otro no elite de
  manera aleatoria. Generamos un hijo tomando cada gen del padre elite con
  probabilidad rhoe y del padre no elite con probabilidad 1 - rhoe.
  */

  // Generamos dos distribuciones uniformes para seleccionar padres elite y no
  // elite de manera aleatoria.
  std::uniform_int_distribution<int> distElite(0, nElite - 1);
  std::uniform_int_distribution<int> distNonElite(nElite, p - 1);

  for (int i = 0; i < nCruce; i++) {
    Individuo padre_elite = poblacion[distElite(rng)];
    Individuo padre_no_elite = poblacion[distNonElite(rng)];

    Individuo hijo;
    hijo.cr.resize(n);

    std::uniform_real_distribution<double> coin(0.0, 1.0);
    for (int j = 0; j < n; ++j) {
      if (coin(rng) < rhoe) {
        hijo.cr[j].first = padre_elite.cr[j].first;
        hijo.cr[j].second = padre_elite.cr[j].second;
      } else {
        hijo.cr[j].first = padre_no_elite.cr[j].first;
        hijo.cr[j].second = padre_no_elite.cr[j].second;
      }
    }
    /*ahora toca evaluar al hijo*/
    hijo.fitness = getFitness(decoder(hijo));
    nueva_poblacion[nElite + nMutante + i] = hijo;
  }
  poblacion = nueva_poblacion;
}

std::vector<int> BRKGA::getSolution() {
  auto start = std::chrono::high_resolution_clock::now();
  auto end = start + std::chrono::seconds(static_cast<int>(s));

  inicializar_poblacion();
  while (std::chrono::high_resolution_clock::now() < end) {
    generacion();
  }

  return decoder(best_global);
}
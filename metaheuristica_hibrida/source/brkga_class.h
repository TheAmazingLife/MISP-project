#ifndef BRKGA_CLASS_H
#define BRKGA_CLASS_H

#include <chrono>
#include <random>
#include <utility>
#include <vector>
#include <set> 
#include <ilcplex/ilocplex.h> 

// tipo de cromosoma: vector de pares (valor double usado para orden/ranking, id
// entero)
using cromosoma = std::vector<std::pair<double, int>>;

// respresenta un individuo de la poblacion
struct Individuo {
  int fitness;  // valor de aptitud (fitness) del individuo
  cromosoma cr; // cromosoma: lista de (valor, id)

  // comparador por fitness (usado para ordenar poblaciones)
  bool operator<(const Individuo &other) const;
};

// implementacion de BRKGA
class BRKGA {
public:
  /*
  n: tamaño del problema
  p: tamaño de la población
  pe: proporción de la elite
  pm: proporcion de mutados
  rhoe: probabilidad de heredar el gen elite al cruzar
  s: segundos
  adj: lista de adyacencia del grafo
  */

  BRKGA(int n, int p, double pe, double pm, double rhoe, double s,
        std::vector<std::vector<int>> &adj, unsigned int seed);
  ~BRKGA();

  // inicializa la poblacion de manera aleatorea
  void inicializar_poblacion();

  // decodifica un individuo (cromosoma) a una solucion concreta
  std::vector<int> decoder(Individuo ind);

  // calcula el fitness de una solucion decodifiacada
  int getFitness(std::vector<int> decodified);

  // ejecuta la generacion: crea una nueva poblacion aplicando elite,
  // cruzamiento y mutacion
  void generacion(); // definimos elite, mutados y normales

  // devuelve la mejor solucion encontrada (decodificada)
  std::vector<int> getSolution();

private:
  int n;       // tamaño del problema
  int p;       // tamaño de la poblacion
  double pe;   // proporcion de elite
  double pm;   // proporcion de mutados
  double rhoe; // probabilidad de herencia desde la elite
  double s;    // segundos

  std::vector<Individuo> poblacion;       // poblacion actual
  std::vector<Individuo> nueva_poblacion; // vector para la siguiente generacion
  std::vector<std::vector<int>> adj;      // grafo (matriz de adyacencia)
  std::mt19937 rng;
  Individuo best_global;
  int best_global_fitness;
  std::chrono::high_resolution_clock::time_point start_time;
  std::vector<int> solveSubInstance(const std::set<int>& V_prime);
  void runBarrakuda();
};

#endif
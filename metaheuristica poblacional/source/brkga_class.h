#ifndef BRKGA_CLASS_H
#define BRKGA_CLASS_H

#include <vector>

using cromosoma = std::vector<double>;

struct Individuo {
  double fitness;
  cromosoma cr;

  bool operator<(const Individuo &other) const;
};

class BRKGA {
public:
  BRKGA(int n, int p, double pe, double pm, double rhoe, int g);
  ~BRKGA();

  double getFitness(std::vector<int> decodified);
  void inicializar_poblacion();
  std::vector<int> decoder();
  std::vector<int> getSolution();

private:
  int n;
  int p;
  double pe;
  double pm;
  double rhoe;
  int g;
  std::vector<Individuo> poblacion;
  std::vector<Individuo> nueva_poblacion;
};

#endif
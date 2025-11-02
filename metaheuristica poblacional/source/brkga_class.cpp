#include "brkga_class.h"

bool Individuo::operator<(const Individuo &other) const {
  return fitness > other.fitness;
}

BRKGA::BRKGA(int n, int p, double pe, double pm, double rhoe, int g)
    : n(n), p(p), pe(pe), pm(pm), rhoe(rhoe), g(g) {}

BRKGA::~BRKGA() {}

double BRKGA::getFitness(std::vector<int> decodified) {
  return decodified.size();
}

void BRKGA::inicializar_poblacion() {}

std::vector<int> BRKGA::decoder() { return std::vector<int>(); }

std::vector<int> BRKGA::getSolution() { return std::vector<int>(); }
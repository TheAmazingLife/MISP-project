#include "utils/GraphReader.h"
#include "utils/brkga_mp_ipr/brkga_mp_ipr.hpp"
#include <iostream>

int main(int argc, char *argv[]) {

  // Graph reading:
  if (argc != 3 || std::string(argv[1]) != "-i") {
    std::cerr << "Usage: <BRKGA> -i <problem-instance> -t tiempoMaximoSegundos\n";
    return 1;
  }

  std::string filename = argv[2];
  int V;
  std::vector<std::vector<int>> adj;

  if (!GraphReader::loadFromFile(filename, V, adj)) {
    std::cerr << "Error loading the graph from the file." << std::endl;
    return 1;
  }

  // --- BRKGA Algorithm ---
  std::cout << "Testing sense: " << static_cast<int>(BRKGA::Sense::MINIMIZE)
            << std::endl;

  return 0;
}

/*
- parámetros: n:tamaño del cromosoma, convención: usar el tamaño del grafo
int p:Tamaño de la población, pe: proporción elite, pm: proporción de mutantes,
rhoe: probabilidad de heredar del elite. g : generaciones
pc : proporción de crossover (implícito)

1. Se crea la población inicial con p individuos
2. Bucle:
    1. el cromosoma pasa el decoder, el decoder da la solucion,
    el fitness calcula el valor de la solucion, se guarda el fitness de cada inividuo
    2. se ordena la poblacion segun su fitness: la elite(pe)  (ej: = 15%superior), y la no elite (pn), el resto.
    3. se crea la nueva poblacion, con p individuos: Esta se llena un porcentaje con pe, con pm (mutantes) aleatorios
        y pc (cruce).
        3.1 el crossover selecciona un padre elite, un padre no elite, y con un porcentaje rho_e elige un gen de elite,
            del resto del no elite, gen por gen.
    4. la poblacion anterior se descarta, la nueva poblacion es la creada.
    6. se repite bucle.
3. Tras g generaciones, el algoritmo se detiene.
4. La mejor solucion sera el individuo con mejor fitnes del grupo de elite de la ultima generacion.



- Cromosoma
- Decoder
- poblacion
- bucle evolutivo
- fitness

*/
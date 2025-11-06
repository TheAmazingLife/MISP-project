#include "brkga_class.h"
#include "utils/GraphReader.h"
#include <iostream>

int main(int argc, char *argv[]) {

  /*
  p = tamaño población
  pe = población elite
  pm = población mutante
  rhoe = probabilidad de heredar del elite
  */

  // Graph reading:
  if (argc != 15) {
    std::cerr << "Uso: ./brkga -i <instancia.txt> -t <tiempoSegundos> "
                 "-p <poblacion> -pe <elite> -pm <mutantes> -rhoe <herencia> "
                 "-seed <semilla>\n";
    return 1;
  }

  std::string filename;
  double s = 0, pe = 0, pm = 0, rhoe = 0;
  int p = 0;
  unsigned int seed = 0;

  // --- Leer argumentos ---
  for (int i = 1; i < argc; i++) {
    std::string arg = argv[i];
    if (arg == "-i")
      filename = argv[++i];
    else if (arg == "-t")
      s = std::stod(argv[++i]);
    else if (arg == "-p")
      p = std::stoi(argv[++i]);
    else if (arg == "-pe")
      pe = std::stod(argv[++i]);
    else if (arg == "-pm")
      pm = std::stod(argv[++i]);
    else if (arg == "-rhoe")
      rhoe = std::stod(argv[++i]);
    else if (arg == "-seed")
      seed = std::stoul(argv[++i]);
    else {
      std::cerr << "Argumento desconocido: " << arg << "\n";
      return 1;
    }
  }

  int V;
  std::vector<std::vector<int>> adj;

  if (!GraphReader::loadFromFile(filename, V, adj)) {
    std::cerr << "Error loading the graph from the file." << std::endl;
    return 1;
  }

  // --- BRKGA Algorithm ---
  BRKGA brkga(V, p, pe, pm, rhoe, s, adj, seed);
  std::vector<int> independentSet = brkga.getSolution();

  // for (int i = 0; i < independentSet.size(); i++) {
  //   std::cout << independentSet[i] << " ";
  // }
  // std::cout << "\n";

  std::cout << independentSet.size() << "\n";

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
    el fitness calcula el valor de la solucion, se guarda el fitness de cada
inividuo
    2. se ordena la poblacion segun su fitness: la elite(pe)  (ej: =
15%superior), y la no elite (pn), el resto.
    3. se crea la nueva poblacion, con p individuos: Esta se llena un porcentaje
con pe, con pm (mutantes) aleatorios y pc (cruce). 3.1 el crossover selecciona
un padre elite, un padre no elite, y con un porcentaje rho_e elige un gen de
elite, del resto del no elite, gen por gen.
    4. la poblacion anterior se descarta, la nueva poblacion es la creada.
    6. se repite bucle.
3. Tras g generaciones, el algoritmo se detiene.
4. La mejor solucion sera el individuo con mejor fitnes del grupo de elite de la
ultima generacion.



- Cromosoma
- Decoder
- poblacion
- bucle evolutivo
- fitness

*/

// Decodificador MISP - cabecera
#ifndef MISP_DECODER_HPP
#define MISP_DECODER_HPP

#include <string>
#include <vector>

// Representación en memoria de una instancia de grafo para MISP
struct MISPInstance {
    int n = 0; // número de vértices
    std::vector<std::vector<int>> adj; // lista de adyacencia

    // Carga desde archivo: lee lista de aristas (u v), ignora líneas con '#'
    static MISPInstance loadFromFile(const std::string &path);
};

// Decodificador: transforma cromosoma random-key a conjunto independiente
class MISPDecoder {
public:
    explicit MISPDecoder(const MISPInstance &inst);

    // Decodifica cromosoma (tamaño debe ser == n). Devuelve fitness.
    // Es thread-safe (no modifica estado mutable).
    double decode(const std::vector<double> &chromosome) const;

    // Función estática: decodifica y devuelve vértices seleccionados en out_solution.
    // Thread-safe. Usada por BRKGA y para post-procesamiento.
    static double decodeChromosome(const MISPInstance &inst,
                                   const std::vector<double> &chromosome,
                                   std::vector<int> &out_solution);

private:
    MISPInstance instance_;
};

#endif // MISP_DECODER_HPP

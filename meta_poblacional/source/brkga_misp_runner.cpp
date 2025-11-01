// Runner BRKGA para MISP
// Ejecuta el algoritmo BRKGA sobre instancias de MISP

#include <chrono>
#include <iostream>
#include <string>
#include <vector>

#include "misp_decoder.hpp"
#include <type_traits>

#include "brkga_shims.hpp"

#include "../utils/brkga_mp_ipr_cpp-master/brkga_mp_ipr/brkga_mp_ipr.hpp"

using namespace std;

// Adaptador para conectar MISPDecoder con la API de BRKGA
class BRKGA_MISP_Decoder {
public:
    BRKGA_MISP_Decoder(const MISPInstance &inst) : inner_(inst) {}

    BRKGA::fitness_t decode(BRKGA::Chromosome& chromosome, bool /*rewrite*/) {
        const double f = inner_.decode(chromosome);
        return static_cast<BRKGA::fitness_t>(f);
    }

private:
    MISPDecoder inner_;
};

int main(int argc, char* argv[]) {
    if (argc < 5) {
        cerr << "Uso: " << argv[0]
             << " <seed> <archivo-config> <tiempo-maximo-segundos> <archivo-instancia> [num-threads]" << endl;
        return 1;
    }

    try {
        const unsigned seed = static_cast<unsigned>(stoul(argv[1]));
        const string config_file = argv[2];
        const unsigned max_seconds = static_cast<unsigned>(stoul(argv[3]));
        const string instance_file = argv[4];
        const unsigned num_threads = (argc >= 6) ? static_cast<unsigned>(stoul(argv[5])) : 1u;

        cout << "Leyendo instancia '" << instance_file << "'...\n";
        const auto inst = MISPInstance::loadFromFile(instance_file);
        cout << "  n = " << inst.n << " vértices\n";

        cout << "Leyendo parámetros BRKGA desde '" << config_file << "'...\n";

        // Parser local para evitar problemas de compilación con readConfiguration
        BRKGA::BrkgaParams brkga_params;
        BRKGA::ControlParams control_params;

        auto parseBRKGAConfig = [&](const std::string &filename,
                                    BRKGA::BrkgaParams &bp,
                                    BRKGA::ControlParams &cp) {
            std::ifstream input(filename);
            if(!input) throw std::runtime_error("No se puede abrir config: " + filename);

            std::string line; unsigned line_count = 0;
            while(std::getline(input, line)) {
                ++line_count;
                auto pos = line.find_first_not_of(" \t\n\v");
                if(pos == std::string::npos || line[pos] == '#') continue;

                std::stringstream ss(line);
                std::string token, data;
                ss >> token >> data;
                for(auto &c : token) c = std::tolower(c);

                try {
                    if(token == "population_size") bp.population_size = std::stoul(data);
                    else if(token == "elite_percentage") bp.elite_percentage = std::stod(data);
                    else if(token == "mutants_percentage") bp.mutants_percentage = std::stod(data);
                    else if(token == "num_elite_parents") bp.num_elite_parents = std::stoul(data);
                    else if(token == "total_parents") bp.total_parents = std::stoul(data);
                    else if(token == "num_independent_populations") bp.num_independent_populations = std::stoul(data);
                    else if(token == "pr_number_pairs") bp.pr_number_pairs = std::stoul(data);
                    else if(token == "pr_minimum_distance") bp.pr_minimum_distance = std::stod(data);
                    else if(token == "alpha_block_size") bp.alpha_block_size = std::stod(data);
                    else if(token == "pr_percentage") bp.pr_percentage = std::stod(data);
                    else if(token == "num_exchange_individuals") bp.num_exchange_individuals = std::stoul(data);
                    else if(token == "shaking_intensity_lower_bound") bp.shaking_intensity_lower_bound = std::stod(data);
                    else if(token == "shaking_intensity_upper_bound") bp.shaking_intensity_upper_bound = std::stod(data);
                    else if(token == "maximum_running_time") {
                        cp.maximum_running_time = std::chrono::seconds{static_cast<int>(std::stoll(data))};
                    }
                    else if(token == "exchange_interval") cp.exchange_interval = std::stoul(data);
                    else if(token == "shake_interval") cp.shake_interval = std::stoul(data);
                    else if(token == "ipr_interval") cp.ipr_interval = std::stoul(data);
                    else if(token == "reset_interval") cp.reset_interval = std::stoul(data);
                    else if(token == "stall_offset") cp.stall_offset = std::stoul(data);
                    else if(token == "bias_type") {
                        if(data == "CONSTANT") bp.bias_type = BRKGA::BiasFunctionType::CONSTANT;
                        else if(data == "CUBIC") bp.bias_type = BRKGA::BiasFunctionType::CUBIC;
                        else if(data == "EXPONENTIAL") bp.bias_type = BRKGA::BiasFunctionType::EXPONENTIAL;
                        else if(data == "LINEAR") bp.bias_type = BRKGA::BiasFunctionType::LINEAR;
                        else if(data == "LOGINVERSE") bp.bias_type = BRKGA::BiasFunctionType::LOGINVERSE;
                        else if(data == "QUADRATIC") bp.bias_type = BRKGA::BiasFunctionType::QUADRATIC;
                        else bp.bias_type = BRKGA::BiasFunctionType::CUSTOM;
                    }
                    else if(token == "pr_type") {
                        if(data == "DIRECT") bp.pr_type = BRKGA::PathRelinking::Type::DIRECT;
                        else bp.pr_type = BRKGA::PathRelinking::Type::PERMUTATION;
                    }
                    else if(token == "pr_selection") {
                        if(data == "BESTSOLUTION") bp.pr_selection = BRKGA::PathRelinking::Selection::BESTSOLUTION;
                        else bp.pr_selection = BRKGA::PathRelinking::Selection::RANDOMELITE;
                    }
                    else if(token == "pr_distance_function_type") {
                        if(data == "HAMMING") bp.pr_distance_function_type = BRKGA::PathRelinking::DistanceFunctionType::HAMMING;
                        else if(data == "KENDALLTAU") bp.pr_distance_function_type = BRKGA::PathRelinking::DistanceFunctionType::KENDALLTAU;
                        else bp.pr_distance_function_type = BRKGA::PathRelinking::DistanceFunctionType::CUSTOM;
                    }
                    else if(token == "shaking_type") {
                        if(data == "CHANGE") bp.shaking_type = BRKGA::ShakingType::CHANGE;
                        else if(data == "SWAP") bp.shaking_type = BRKGA::ShakingType::SWAP;
                        else bp.shaking_type = BRKGA::ShakingType::CUSTOM;
                    }
                } catch(const std::exception &e) {
                    throw std::runtime_error("Error parseando config línea " + std::to_string(line_count) + ": " + e.what());
                }
            }
        };

        parseBRKGAConfig(config_file, brkga_params, control_params);

        // Sobrescribir tiempo de ejecución con valor CLI
        control_params.maximum_running_time = chrono::seconds{static_cast<int>(max_seconds)};

        // Inicializar functor de distancia para IPR
        switch(brkga_params.pr_distance_function_type) {
            case BRKGA::PathRelinking::DistanceFunctionType::HAMMING:
                brkga_params.pr_distance_function = std::shared_ptr<BRKGA::DistanceFunctionBase>(new BRKGA::HammingDistance);
                break;
            case BRKGA::PathRelinking::DistanceFunctionType::KENDALLTAU:
                brkga_params.pr_distance_function = std::shared_ptr<BRKGA::DistanceFunctionBase>(new BRKGA::KendallTauDistance);
                break;
            default:
                break;
        }

        // Desactivar IPR si no hay functor de distancia
        if(control_params.ipr_interval > 0 && !brkga_params.pr_distance_function) {
            std::cerr << "Advertencia: IPR desactivado (falta functor de distancia)\n";
            control_params.ipr_interval = 0;
        }

        cout << "Construyendo estructuras BRKGA (threads=" << num_threads << ")...\n";
        BRKGA_MISP_Decoder decoder(inst);

        // Maximizar tamaño del conjunto independiente
        BRKGA::BRKGA_MP_IPR<BRKGA_MISP_Decoder> algorithm(
            decoder, BRKGA::Sense::MAXIMIZE, seed,
            inst.n, brkga_params, num_threads
        );

        cout << "Ejecutando por " << control_params.maximum_running_time.count() << " segundos...\n";
        const auto final_status = algorithm.run(control_params, nullptr);

        cout << "\nAlgoritmo finalizado.\n";
        cout << "Mejor fitness: " << final_status.best_fitness << "\n";

        // Decodificar mejor solución
        const auto &best_chr = algorithm.getBestChromosome();
        std::vector<int> sol;
        MISPDecoder::decodeChromosome(inst, best_chr, sol);
        cout << "Tamaño conjunto independiente: " << sol.size() << "\n";
        cout << "Vértices (0-based): ";
        for (size_t i = 0; i < sol.size(); ++i) {
            if (i) cout << ',' ;
            cout << sol[i];
        }
        cout << "\n";
    }
    catch (const exception &e) {
        cerr << "Excepción: " << e.what() << "\n";
        return 1;
    }

    return 0;
}

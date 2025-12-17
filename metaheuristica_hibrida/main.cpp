#include <iostream>
#include <vector>
#include <map>
#include <algorithm>
#include <ilcplex/ilocplex.h>


ILOSTLBEGIN //macro de CPLEX Concert Technology es usado para evitar usar "using namespace std"

// Ahora la función retorna el MIS encontrado y recibe el grafo y el subconjunto V_prime
// NOTA: V_prime es una sub instancia, el conjunto de vértices permitidos.
// Si la solución A= 1,2,3; B= 4,5,6 => V'= 1,2,3,4,5,6
std::vector<int> solveSubInstanceMISP(
    std::map<int, std::vector<int>>& adj_list, // Grafo completo (Referencia para no copiar)
    std::set<int>& V_prime,                    // El subconjunto de vértices elegidos por BRKGA
    int time_limit_seconds                     // Límite de tiempo para CPLEX
)
{
    IloEnv env;
    std::vector<int> solution_mis; // Para guardar el resultado

    try {
        IloModel model(env, "SubInstanceMISP");
        
        // Creamos variables PARA TODOS los nodos del grafo original
        // (Es más fácil fijar a 0 los que sobran que reconstruir el grafo)
        std::map<int, IloNumVar> x;
        
        for (auto const& [u, neighbors] : adj_list) {
            x[u] = IloNumVar(env, 0, 1, ILOINT); // x[u] binaria
            
            // --- BARRAKUDA  ---
            // Si el nodo u NO está en V_prime, forzamos x[u] = 0
            if (V_prime.find(u) == V_prime.end()) {
                model.add(x[u] == 0); 
            }
        }

        // Restricciones del MISP: x[u] + x[v] <= 1 para cada arista
        for (auto const& [u, neighbors] : adj_list) {
            for (int v : neighbors) {
                // Solo agregamos la restricción si ambos extremos existen en el mapa
                // y para evitar duplicados u < v
                if (u < v) { 
                    /* OPTIMIZACIÓN: Solo necesitamos agregar la restricción si AMBOS
                       están en V_prime. Si uno ya está forzado a 0, la restricción se cumple sola.
                       Pero dejarla no hace daño, CPLEX hace presolve. */
                    
                    IloExpr expr(env);
                    expr += x[u];
                    expr += x[v];
                    model.add(expr <= 1);
                    expr.end();
                }
            }
        }

        // Función Objetivo: Maximizar tamaño del conjunto
        IloExpr objective(env);
        for (auto const& [u, var] : x) {
            objective += var;
        }
        model.add(IloMaximize(env, objective));
        objective.end();

        // Configurar Solver
        IloCplex cplex(model);
        cplex.setOut(env.getNullStream()); // Apagar logs de consola (molesto en loops genéticos)
        cplex.setParam(IloCplex::Param::TimeLimit, time_limit_seconds); // Límite de tiempo

        // Resolver
        if (cplex.solve()) {
            // Extraer solución
            for (auto const& [u, var] : x) {
                // Verificamos si CPLEX eligió este nodo (valor cercano a 1)
                if (cplex.getValue(var) > 0.5) {
                    solution_mis.push_back(u);
                }
            }
        } 
    }
    catch (IloException& e) {
        std::cerr << "CPLEX Error: " << e << std::endl;
    }
    env.end();
    
    return solution_mis;
}



// void solveMISP() {
//     IloEnv env;//es nuestro "ambiente CPLEX", es donde se crean todos los objetos de CPLEX

//     try {
//         /*
//         hay que modificar esto para que sea en base a los vértices del subproblema,
//         el cual se construye con un ranking de los vértices más comunes entre los cromosomas generados.
//         */
//         std::map<int, std::vector<int>> adj_list = {
//             {1, {2, 3}},
//             {2, {1, 3}}, 
//             {3, {1, 2}}, 
//             {4, {5}},   
//             {5, {4}}
//         };
//         std::vector<int> R = {1, 2, 3, 4, 5};//conjunto de Vértices R (índices para las variables)
//         IloModel model(env, "MISP"); //el modelo en si

//         /*
//         x es un mapa que asocia a cada vértice u con una variable binaria x[u]. 
//         Como es una variable binaria, solo queremos saber si el vértice es o no parte
//         del MIS.
//         IloNumVar(env, lower_bound, upper_bound, type, name). lb = 0, ub = 1, type = ILOINT
//         crea una variable entera binaria en el entorno env.
//         name solo es para identificar a la variable al debuggear, no es relevante para el modelo.
//         */
//         std::map<int, IloNumVar> x;
//         for (int u : R) {
//             x[u] = IloNumVar(env, 0, 1, ILOINT, ("x" + std::to_string(u)).c_str());
//         }






//         /*
//         Explicación de las restricciones:
//         Vemos todas las aristas u,v y para cada arista agregamos la restricción de que
//         x[u] + x[v] <= 1. Es decir, uno de los dos vértices de la arista no puede pertenecer}
//         al conjunto independiente.     
//         */
//         for (int u : R) {
//             for (int v : adj_list.at(u)) {
//                 // Evitar duplicados y auto-bucles: solo considerar (u, v) si u < v
//                 if (v > u && std::find(R.begin(), R.end(), v) != R.end()) {
//                     IloExpr constraint_expr(env);
//                     constraint_expr += x.at(u);
//                     constraint_expr += x.at(v);
//                     model.add(constraint_expr <= 1);
//                     //todo lo anterior es x[u] + x[v] <= 1
//                     constraint_expr.end();  //liberamos la memoria de la expresión temporal
//                 }
//             }
//         }

//         IloExpr objective(env);
//         for (int u : R) {
//             objective += x.at(u); //definimos la función objetuvo, el cual es la suma da de todas las variables
//         }
//         model.add(IloMaximize(env, objective, "Objective")); //maximizamos.
//         objective.end();

//         IloCplex cplex(model); //acá se crea la instancia del solver con el modelo definido
        
//         cplex.setOut(std::cout); //para que nos muestre el log
        
//         if (cplex.solve()) {
//             std::cout << "Solución status: " << cplex.getStatus() << std::endl;
//             std::cout << "Z = " << cplex.getObjValue() << std::endl;
            
//             std::vector<int> mis;
//             for (int u : R) {
//                 if (cplex.getValue(x.at(u)) > 0.5) {
//                     mis.push_back(u);
//                 }
//             } 
//             /*
//             acá lo único que hacemos es revisar variable por variable y almacenar solo las
//             que son parte del MIS, es decir, las que tienen x[u] = 1
//             */

//             std::cout << "MIS: {";
//             for (size_t i = 0; i < mis.size(); ++i) {
//                 std::cout << mis[i] << (i < mis.size() - 1 ? ", " : "");
//             }
//             std::cout << "}" << std::endl;
            
//         } else {
//             std::cout << "PLEX no pudo resolver el modelo MISP." << std::endl;
//         }
//     }
//     catch (IloException& e) {
//         std::cerr << "ERROR CPLEX: " << e << std::endl;
//     }
//     catch (...) {
//         std::cerr << "Error desconocido." << std::endl;
//     }
//     env.end();
// }

// int main() {
//     solveMISP();
//     return 0;
// }

/*
Esto se debe integrar en BRKGA con cambios sutiles en la entrada y salida.
El sistema de rankings de vértices anteriormente mencionado es parte de otra función
previa al uso de esta función
*/
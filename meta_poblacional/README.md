# Integración BRKGA ↔ MISP (meta_poblacional)

Este directorio contiene el adaptador que integra la librería BRKGA-MP-IPR con
el problema MISP (Maximum Independent Set Problem) usando un decodificador
"random-key" y un runner CLI para ejecutar el algoritmo.

Contenido
- `source/brkga_misp_runner.cpp` — Runner/adapter que crea la instancia del
  algoritmo BRKGA_MP_IPR y conecta el decodificador de MISP.
- `source/misp_decoder.cpp/.hpp` — Decodificador greedy random-key que transforma
  cromosomas (vector<double>) en soluciones independientes (fitness = tamaño).
- `source/brkga_shims.hpp` — Shims mínimos para permitir streaming de
  `std::chrono::duration` en plataformas que no lo implementan; importante
  cuando se compila con libstdc++ más antigua.
- `Makefile` — Makefile sencillo que compila el runner con `-std=c++20`.

Requisitos y notas importantes
- Compilador: Se recomienda usar un compilador moderno que soporte C++20
  (ej. g++ 11/12/13). La librería BRKGA usa conceptos (C++20) en helpers.
- Build: desde la raíz del repo ejecutar:

```bash
cd meta_poblacional
make
```

- Ejecutar una prueba rápida:

```bash
make run-sample
```

Explicación técnica (resumen)
- Decodificador (Random-Key → MISP): se ordenan vértices por la clave aleatoria
  (mayor prioridad primero). Luego se construye la solución de forma golosa:
  seleccionar vértice si no está bloqueado por vecinos ya seleccionados. Esto
  garantiza un conjunto independiente válido. El fitness devuelto al BRKGA es
  el tamaño del conjunto independiente.

- Integración con BRKGA:
  - `BRKGA_MISP_Decoder` adapta la interfaz existente del decodificador al
    tipo esperado por la librería BRKGA.
  - `brkga_misp_runner.cpp` incluye un parser local de configuración para evitar
    instanciaciones problemáticas de templates en algunos toolchains. Si usas
    la función `BRKGA::readConfiguration`, asegúrate de compilar con C++20.

IPR (Implicit Path Relinking) y pr_distance_function
- La librería soporta IPR que requiere un "distance functor" (Hamming,
  KendallTau, u otro). El archivo de configuración puede solicitar IPR
  (`ipr_interval > 0`) y también indicar `pr_distance_function_type`.
- Si se detecta que IPR está activo en la configuración pero no hay un
  functor asociado, el runner deshabilita IPR automáticamente e imprime una
  advertencia. Para habilitar IPR correctamente, puedes:
  1. Usar la función `BRKGA::readConfiguration` y compilar con C++20, o
  2. Extender el parser local para crear/inyectar la implementación de la
     distancia requerida (ej. `HammingDistance` o `KendallTauDistance`).

Comentarios y estilo
- Comentarios en el código fuente están en español.

Siguientes pasos recomendados
- Añadir tests automatizados que ejecuten el runner en instancias pequeñas y
  verifiquen que la solución es independiente.
- Integrar esta compilación en CI (usar `-std=c++20`).
- Si necesitas permanencia C++17, puedo aplicar un parche más invasivo para
  adaptar `enum_io.hpp` a C++17, pero es más laborioso.

Contacta si quieres que:
- Actualice el parser local para soportar más opciones de configuración.
- Añada tests y scripts para ejecutar la grilla de parámetros y recolectar
  métricas.

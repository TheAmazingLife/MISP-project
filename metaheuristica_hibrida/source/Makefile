# Makefile para BRKGA - MISP
# Compilador y flags
CXX = g++
# CXXFLAGS = -std=c++17 -O3 -Wall -Wextra
CXXFLAGS = -std=c++17 -O3
LDFLAGS = 

# Directorios
SRC_DIR = .
UTILS_DIR = utils
OBJ_DIR = obj

# Archivos
TARGET = brkga
SOURCES = brkga.cpp brkga_class.cpp $(UTILS_DIR)/GraphReader.cpp
OBJECTS = $(OBJ_DIR)/brkga.o $(OBJ_DIR)/brkga_class.o $(OBJ_DIR)/GraphReader.o
HEADERS = brkga_class.h $(UTILS_DIR)/GraphReader.h

# Regla principal
all: $(TARGET)

# Crear directorio de objetos si no existe
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# Compilar el ejecutable
$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "Compilación exitosa: $(TARGET)"

# Compilar archivos objeto
$(OBJ_DIR)/brkga.o: brkga.cpp $(HEADERS) | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/brkga_class.o: brkga_class.cpp brkga_class.h | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/GraphReader.o: $(UTILS_DIR)/GraphReader.cpp $(UTILS_DIR)/GraphReader.h | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Limpiar archivos compilados
clean:
	rm -rf $(OBJ_DIR) $(TARGET)
	@echo "Archivos limpiados"

# Recompilar desde cero
rebuild: clean all

# Reglas que no son archivos
.PHONY: all clean rebuild

# Información de ayuda
help:
	@echo "Makefile para BRKGA - MISP"
	@echo ""
	@echo "Uso:"
	@echo "  make          - Compila el proyecto"
	@echo "  make clean    - Elimina archivos compilados"
	@echo "  make rebuild  - Recompila desde cero"
	@echo "  make help     - Muestra esta ayuda"
	@echo ""
	@echo "Ejecutable generado: $(TARGET)"

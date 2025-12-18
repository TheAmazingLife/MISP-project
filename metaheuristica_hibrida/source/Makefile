# Makefile para BRKGA - MISP con CPLEX Studio 2211
# Compilador y flags
CXX = g++

# Directorios de CPLEX
CPLEX_DIR = /home/shared/sisadapt2/CPLEX_Studio2211
CPLEX_INC = $(CPLEX_DIR)/cplex/include
CONCERT_INC = $(CPLEX_DIR)/concert/include
CPLEX_LIB = $(CPLEX_DIR)/cplex/lib/x86-64_linux/static_pic
CONCERT_LIB = $(CPLEX_DIR)/concert/lib/x86-64_linux/static_pic

# Flags de compilación
CXXFLAGS = -std=c++17 -O3 -fPIC -fexceptions -DIL_STD \
           -I$(CPLEX_INC) -I$(CONCERT_INC)

# Flags de linkeo (ORDEN IMPORTANTE)
LDFLAGS = -L$(CPLEX_LIB) -L$(CONCERT_LIB) \
          -lilocplex -lcplex -lconcert -lm -lpthread -ldl

# Directorios
SRC_DIR = .
UTILS_DIR = utils
OBJ_DIR = obj

# Archivos
TARGET = brkga_hibrid
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

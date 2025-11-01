# Makefile para meta_poblacional

CXX := g++
CXXFLAGS := -std=c++20 -O2 -pthread -Isource -Iutils/brkga_mp_ipr_cpp-master -Iutils
SRCS := source/brkga_misp_runner.cpp source/misp_decoder.cpp utils/GraphReader.cpp
OUT := bin/brkga_misp_runner

.PHONY: all clean run-sample

all: $(OUT)

$(OUT): $(SRCS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(SRCS) -o $@

run-sample: $(OUT)
	@echo "Ejecutando prueba de 2s con instancia de ejemplo..."
	$(OUT) 42 utils/brkga_mp_ipr_cpp-master/test/config_full.conf 2 ../dataset_grafos_no_dirigidos/new_1000_dataset/erdos_n1000_p0c0.05_1.graph 1

clean:
	rm -f $(OUT)

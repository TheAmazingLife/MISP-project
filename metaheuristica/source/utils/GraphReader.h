#ifndef GRAPHREADER_H
#define GRAPHREADER_H

#include <vector>
#include <string>

struct Edge {
    int u, v;
};

class GraphReader {
public:
    static bool loadFromFile(const std::string& filename, int& n, std::vector<std::vector<int>>& adj);
    static std::vector<Edge> loadEdgesFromFile(const std::string& filename);
};

#endif

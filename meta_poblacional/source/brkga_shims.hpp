// Compatibilidad para compilar BRKGA con C++20
// Proporciona operadores de streaming para std::chrono::duration

#pragma once

#include <ostream>
#include <chrono>

namespace std {

// Imprime duraciones en segundos
inline ostream& operator<<(ostream& os, const chrono::duration<double>& d) {
    os << d.count() << "s";
    return os;
}

template<class Rep, class Period>
inline ostream& operator<<(ostream& os, const chrono::duration<Rep, Period>& d) {
    using double_sec = chrono::duration<double>;
    double_sec ds = chrono::duration_cast<double_sec>(d);
    os << ds.count() << "s";
    return os;
}

// Lee duraciones desde stream
template<class Rep, class Period>
inline istream& operator>>(istream& is, chrono::duration<Rep, Period>& d) {
    Rep value;
    is >> value;
    d = chrono::duration<Rep, Period>(value);
    return is;
}

} // namespace std

// Nota: streaming de enums no incluido para evitar conflictos con BRKGA

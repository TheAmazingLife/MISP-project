#' ---
#' title: "Statistical Assessment of MISP Algorithms"
#' author: "Análisis estadístico de Greedy, SA y BRKGA"
#' date: "2025"
#' output: pdf_document
#' ---
#' 

#' Este documento contiene el código para la evaluación estadística de los resultados
#' empíricos de los algoritmos implementados para el problema MISP
#' 
#' ## Carga de datos e inicialización de variables
#' 
#' Cargar el paquete y crear directorios para los resultados del análisis

library(scmamp)

data.file <- "results.dat"
sep <- "\t"
plot.dir <- "./"

#' Primero, cargaremos los resultados.

data <- read.csv(data.file, sep=sep)

#' Mostrar las primeras filas para verificar la carga de datos

head(data)

#' Mostrar resumen estadístico básico

summary(data)

#' ## Creación de tabla resumen
#'
#' Ahora creamos una tabla de resumen con los resultados promedio por instancia

average.function <- mean
instance.descriptors <- c("nstr", "length", "t")
to.ignore <- c("inst")

summary.data <- summarizeData(data=data, fun=average.function, 
                              group.by=instance.descriptors, ignore=to.ignore)

print("Tabla resumen por configuración:")
print(summary.data)

#' ## Evaluación estadística
#' 
#' Primero, verificar que existe al menos un algoritmo que es diferente del resto.
#' Para eso usamos el test de Friedman

alg.columns <- c("GREEDY", "SA", "BRKGA")
friedman.result <- friedmanTest(data[, alg.columns])

print("Resultado del test de Friedman:")
print(friedman.result)

#' ## Post-hoc comparisons
#' 
#' Ahora, comparación post-hoc de dos maneras:
#' 1. Para la tabla: el mejor en cada instancia vs. el resto
#' 

# Para el problema MISP, los valores MÁS ALTOS son mejores
all.vs.best.results <- postHocTest(data=data, algorithms=alg.columns, 
                                   group.by=instance.descriptors, test="friedman",
                                   control="max", use.rank=FALSE, sum.fun=average.function,
                                   correct="finner", alpha=0.05)

print("Resultados post-hoc (todos vs. mejor):")
print(all.vs.best.results)

#' 2. Todos vs. todos para los gráficos
#' 

# decreasing=FALSE porque valores MAYORES son mejores en MISP
all.vs.all <- postHocTest(data=data, algorithms=alg.columns, test="friedman", 
                          control=NULL, use.rank=TRUE, sum.fun=average.function,
                          correct="finner", alpha=0.05, decreasing=FALSE)

print("Resultados post-hoc (todos vs. todos):")
print(all.vs.all)

#' ## Gráficos
#' 
#' Crear un gráfico similar al Critical Difference plot de Demsar.
#' 
#' Gráfico general (todas las instancias)

pdf(file=paste0(plot.dir, "CD_plot_misp_all.pdf"), width=6, height=2.2)
## Asegurarse de pasar una matriz y un vector numérico a plotRanking
xmat <- as.matrix(all.vs.all$corrected.pval)
summary_vec <- as.numeric(unlist(all.vs.all$summary))
names(summary_vec) <- colnames(xmat)
plotRanking(xmat, summary=summary_vec, alpha=0.05)
dev.off()

print("Gráfico CD guardado en: CD_plot_misp_all.pdf")

#' ## Análisis agrupado por tamaño de grafo
#'
#' Análisis separado para cada tamaño de grafo (1000, 2000, 3000 nodos)

all.vs.all.by.size <- postHocTest(data=data, algorithms=alg.columns, test="friedman",
                                  group.by=c("nstr"), control=NULL, use.rank=TRUE,
                                  sum.fun=average.function, correct="finner", alpha=0.05, 
                                  decreasing=FALSE)

print("Resultados agrupados por tamaño de grafo:")
print(all.vs.all.by.size)

#' Crear gráficos CD para cada tamaño de grafo

for (i in 1:dim(all.vs.all.by.size$corrected.pval)[3]){
  pdf(file=paste0(plot.dir, "CD_plot_misp_nstr_",
                  gsub("/","-",all.vs.all.by.size$summary[i,1]),
                  ".pdf"), width=6, height=2.2)
  ## Convertir slice a matriz y resumen a vector numérico antes de plotRanking
  xmat <- as.matrix(all.vs.all.by.size$corrected.pval[, , i])
  summary_vec <- as.numeric(unlist(all.vs.all.by.size$summary[i, -1]))
  names(summary_vec) <- colnames(xmat)
  plotRanking(xmat, summary=summary_vec, alpha=0.05)
  dev.off()
  print(paste("Gráfico CD guardado para tamaño", all.vs.all.by.size$summary[i,1]))
}

#' ## Análisis agrupado por densidad
#'
#' Análisis separado para cada densidad del grafo

all.vs.all.by.density <- postHocTest(data=data, algorithms=alg.columns, test="friedman",
                                     group.by=c("t"), control=NULL, use.rank=TRUE,
                                     sum.fun=average.function, correct="finner", alpha=0.05, 
                                     decreasing=FALSE)

print("Resultados agrupados por densidad:")
print(all.vs.all.by.density)

#' Crear gráficos CD para cada densidad

for (i in 1:dim(all.vs.all.by.density$corrected.pval)[3]){
  density_val <- all.vs.all.by.density$summary[i,1]
  pdf(file=paste0(plot.dir, "CD_plot_misp_density_",
                  gsub("\\.","-", density_val),
                  ".pdf"), width=6, height=2.2)
  ## Convertir slice a matriz y resumen a vector numérico antes de plotRanking
  xmat <- as.matrix(all.vs.all.by.density$corrected.pval[, , i])
  summary_vec <- as.numeric(unlist(all.vs.all.by.density$summary[i, -1]))
  names(summary_vec) <- colnames(xmat)
  plotRanking(xmat, summary=summary_vec, alpha=0.05)
  dev.off()
  print(paste("Gráfico CD guardado para densidad", density_val))
}

#' ## Estadísticas descriptivas por algoritmo
#' 

print("\n=== ESTADÍSTICAS DESCRIPTIVAS POR ALGORITMO ===\n")

for (alg in alg.columns) {
  cat(paste("\nAlgoritmo:", alg, "\n"))
  cat(paste("Media:", mean(data[[alg]]), "\n"))
  cat(paste("Mediana:", median(data[[alg]]), "\n"))
  cat(paste("Desviación estándar:", sd(data[[alg]]), "\n"))
  cat(paste("Mínimo:", min(data[[alg]]), "\n"))
  cat(paste("Máximo:", max(data[[alg]]), "\n"))
}

#' ## Referencias
#' Demšar, J. (2006) Statistical Comparisons of Classifiers over Multiple Data Sets. 
#' _Journal of Machine Learning Research_, 7, 1-30.

print("\n=== ANÁLISIS COMPLETADO ===")
print("Todos los gráficos PDF han sido generados en el directorio actual.")

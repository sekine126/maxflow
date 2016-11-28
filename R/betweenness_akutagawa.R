# rootディレクトリで
# R --vanilla < R/betweenness_akutagawa.R
library(igraph)
load_data <- read.table("./matrix/akutagawa_20160720.txt")
matrix_data <- data.matrix(load_data)
g <- graph.adjacency(matrix_data, mode = "undirected")
b <- betweenness(g)
out <- file("./R/betweenness_akutagawa_20160720.txt", "w")
for (i in 1:(length(b))) {
  writeLines(paste(i), out, sep=",")
  writeLines(paste(b[i]), out, sep="\n")
}
close(out)

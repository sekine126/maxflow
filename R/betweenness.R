# rootディレクトリで
# R --vanilla < R/betweenness.R
library(igraph)
load_data <- read.table("./data/matrix/bet_koike_20161220.txt")
matrix_data <- data.matrix(load_data)
g <- graph.adjacency(matrix_data, mode = "undirected")
b <- betweenness(g)
out <- file("./data/R/bet_koike_20161220.txt", "w")
for (i in 1:(length(b))) {
  writeLines(paste(i), out, sep=",")
  writeLines(paste(b[i]), out, sep="\n")
}
close(out)

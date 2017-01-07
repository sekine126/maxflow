# rootディレクトリで
# R --vanilla < R/pagerank.R
library(igraph)
load_data <- read.table("./data/matrix/shad_20161229.txt")
matrix_data <- data.matrix(load_data)
g <- graph.adjacency(matrix_data, mode = "directed")
b <- page.rank(g, directed = TRUE)$vector
out <- file("./data/R/prank_shad_20161229.txt", "w")
for (i in 1:(length(b))) {
  writeLines(paste(i), out, sep=",")
  writeLines(paste(b[i]), out, sep="\n")
}
close(out)

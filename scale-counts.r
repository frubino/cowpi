#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library("DESeq2")
count_matrix <- read.delim(args[1], stringsAsFactors=TRUE, header = TRUE, row.names=1)
# Adding 1 to avoid problems, size factors are then used
scaled <- count_matrix / estimateSizeFactorsForMatrix(count_matrix + 1)
write.table(scaled, file=args[1], sep= "\t", row.names=TRUE, col.names=TRUE)

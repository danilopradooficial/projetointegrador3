# 05c-ficha-corpus.R
# Imprime ficha tecnica de csv/05-corpus.csv

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

corpus <- read.csv(file.path("csv", "05-corpus.csv"),
                   stringsAsFactors = FALSE, fileEncoding = "UTF-8")

cat("linhas :", nrow(corpus), "\n")
cat("colunas:", paste(names(corpus), collapse = ", "), "\n\n")

for (col in names(corpus)) {
  v <- as.character(corpus[[col]])
  cheio <- sum(!is.na(v) & trimws(v) != "")
  cat(sprintf("%-14s %5.1f%% preenchido\n", col, 100 * cheio / nrow(corpus)))
}

palavras <- sapply(strsplit(corpus$texto, "\\s+"), length)
cat("\npalavras por documento:\n")
print(summary(palavras))
cat("\nids duplicados:", sum(duplicated(corpus$id)), "\n")

if ("fonte" %in% names(corpus)) {
  cat("\ndocumentos por fonte:\n")
  print(table(corpus$fonte))
}

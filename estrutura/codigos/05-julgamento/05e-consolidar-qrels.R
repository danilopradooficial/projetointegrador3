# 05e-consolidar-qrels.R
# Junta csv/05-qrels-respostas/*.csv -> csv/05-qrels.csv

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

dir_resp <- file.path("csv", "05-qrels-respostas")
arquivos <- list.files(dir_resp, pattern = "^05-qrels-.*\\.csv$", full.names = TRUE)
if (!length(arquivos)) stop("Nenhum 05-qrels-*.csv em ", dir_resp)

partes <- lapply(arquivos, function(f) {
  read.csv(f, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
})
qrels <- do.call(rbind, partes)
need <- c("consulta", "documento", "grau", "juiz", "timestamp", "segundos")
faltam <- setdiff(need, names(qrels))
if (length(faltam)) stop("Colunas faltando: ", paste(faltam, collapse = ", "))

qrels <- qrels[, need]
qrels <- qrels[order(qrels$juiz, qrels$consulta, qrels$documento), ]
rownames(qrels) <- NULL

out <- file.path("csv", "05-qrels.csv")
write.csv(qrels, out, row.names = FALSE, fileEncoding = "UTF-8")
cat("gravado", out, "| linhas:", nrow(qrels), "\n")
print(table(qrels$juiz))
print(table(grau = qrels$grau))

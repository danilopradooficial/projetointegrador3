# 05d-gerar-pool.R
# csv/05-necessidades.csv x csv/05-corpus.csv -> csv/05-pool.csv

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

dir_csv <- "csv"
corpus <- read.csv(file.path(dir_csv, "05-corpus.csv"),
                   stringsAsFactors = FALSE, fileEncoding = "UTF-8")
necs <- read.csv(file.path(dir_csv, "05-necessidades.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8")

pool <- expand.grid(
  consulta = necs$consulta,
  documento = corpus$id,
  stringsAsFactors = FALSE
)
pool <- pool[order(pool$consulta, pool$documento), ]
rownames(pool) <- NULL

out <- file.path(dir_csv, "05-pool.csv")
write.csv(pool, out, row.names = FALSE, fileEncoding = "UTF-8")
cat(out, ":", nrow(pool), "linhas\n")

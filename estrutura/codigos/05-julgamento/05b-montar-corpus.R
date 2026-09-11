# 05b-montar-corpus.R
# Paragrafos d1.1, d1.2, ... -> csv/05-corpus.csv
# Fonte: estrutura/corpus/*.txt · R base

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

pasta_txt <- file.path("..", "..", "corpus")
dir_csv <- "csv"
dir.create(dir_csv, showWarnings = FALSE)

artigos <- c(
  d1 = "porto_de_santos.txt",
  d2 = "autoridade_portuaria_de_santos.txt",
  d3 = "francisco_de_paula_ribeiro.txt"
)
titulos <- c(
  d1 = "Porto de Santos",
  d2 = "Autoridade Portuária de Santos",
  d3 = "Francisco de Paula Ribeiro"
)
urls <- c(
  d1 = "https://pt.wikipedia.org/wiki/Porto_de_Santos",
  d2 = "https://pt.wikipedia.org/wiki/Autoridade_Portuária_de_Santos",
  d3 = "https://pt.wikipedia.org/wiki/Francisco_de_Paula_Ribeiro"
)

ler_paragrafos <- function(caminho) {
  linhas <- readLines(caminho, warn = FALSE, encoding = "UTF-8")
  texto <- paste(linhas, collapse = "\n")
  blocos <- unlist(strsplit(texto, "\n[[:space:]]*\n+"))
  blocos <- trimws(blocos)
  blocos[nzchar(blocos)]
}

linhas <- list()
for (aid in names(artigos)) {
  caminho <- file.path(pasta_txt, artigos[[aid]])
  if (!file.exists(caminho)) stop("Arquivo nao encontrado: ", caminho)
  pars <- ler_paragrafos(caminho)
  for (i in seq_along(pars)) {
    txt <- gsub("[\r\n]+", " ", pars[[i]])
    txt <- gsub("\\s+", " ", txt)
    doc_id <- paste0(aid, ".", i)
    linhas[[length(linhas) + 1L]] <- data.frame(
      id = doc_id,
      titulo = sprintf("%s (%s)", titulos[[aid]], doc_id),
      texto = txt,
      data = "",
      fonte = paste0("Wikipedia PT | ", titulos[[aid]]),
      url = urls[[aid]],
      stringsAsFactors = FALSE
    )
  }
}

corpus <- do.call(rbind, linhas)
rownames(corpus) <- NULL
if (any(duplicated(corpus$id))) stop("ids duplicados")

out <- file.path(dir_csv, "05-corpus.csv")
write.csv(corpus, out, row.names = FALSE, fileEncoding = "UTF-8")
cat("gravado", out, "| docs:", nrow(corpus), "\n")
print(table(sub("\\.[0-9]+$", "", corpus$id)))
cat("ids:", paste(corpus$id, collapse = ", "), "\n")

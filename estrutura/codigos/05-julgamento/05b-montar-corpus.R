# 05b-montar-corpus.R
# Frases canonicas d1.1, d1.2, ... -> csv/05-corpus.csv
# Mesma regra da Ativ. 01a (01a-ler-frases.R)
# Fonte: estrutura/corpus/*.txt · R base

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

source(file.path("..", "01a-ler-frases.R"))

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

linhas <- list()
canon <- list()
for (aid in names(artigos)) {
  caminho <- file.path(pasta_txt, artigos[[aid]])
  if (!file.exists(caminho)) stop("Arquivo nao encontrado: ", caminho)
  frases <- ler_frases(caminho)
  for (i in seq_along(frases)) {
    txt <- frases[[i]]
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
    canon[[length(canon) + 1L]] <- data.frame(
      id = doc_id,
      artigo = aid,
      titulo_artigo = titulos[[aid]],
      n_palavras = length(unlist(strsplit(txt, "\\s+"))),
      texto = txt,
      stringsAsFactors = FALSE
    )
  }
}

corpus <- do.call(rbind, linhas)
rownames(corpus) <- NULL
if (any(duplicated(corpus$id))) stop("ids duplicados")

# Catalogo canonico compartilhado com 01a/03/04
canon_df <- do.call(rbind, canon)
rownames(canon_df) <- NULL
canon_path <- file.path(pasta_txt, "frases-canonicas.csv")
write.csv(canon_df, canon_path, row.names = FALSE, fileEncoding = "UTF-8")

npal <- sapply(strsplit(corpus$texto, "\\s+"), length)

out <- file.path(dir_csv, "05-corpus.csv")
write.csv(corpus, out, row.names = FALSE, fileEncoding = "UTF-8")
cat("gravado", out, "| docs:", nrow(corpus), "\n")
cat("catalogo", canon_path, "\n")
print(table(sub("\\.[0-9]+$", "", corpus$id)))
cat("palavras/frase: min=", min(npal), " max=", max(npal),
    " mediana=", median(npal), "\n", sep = "")
cat("ids (amostra):", paste(head(corpus$id, 8), collapse = ", "), "...\n")
cat("d1.1 =", corpus$texto[corpus$id == "d1.1"], "\n")

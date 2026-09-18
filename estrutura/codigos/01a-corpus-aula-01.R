# =============================================================
# PI III - Motor de Busca - Atividade 01 · Parte A / Aula 01
# Fatec Rubens Lara - Ciência de Dados
# Para casa - parte 2: meu primeiro corpus real
# Fonte: Wikipédia (CC BY-SA), pt.wikipedia.org
#
# Artigos:
#   d1  = Porto de Santos
#   d2  = Autoridade Portuária de Santos
#   d3  = Francisco de Paula Ribeiro
# Frases (unidade de recuperacao):
#   d1.1, d1.2, ...  = frases (ponto final) de d1
#   d2.1, d2.2, ...  = frases (ponto final) de d2
#   d3.1, d3.2, ...  = frases (ponto final) de d3
# =============================================================

## cwd = pasta do script; corpus em ../corpus
args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}
pasta_corpus <- file.path("..", "corpus")

## Unidade de recuperacao CANONICA (mesmo d1.1 em 01a/03/04/05)
source("ler-frases-comum.R")
docs <- carregar_docs_canonico(pasta_corpus)

length(docs)
names(docs)

docs["d1"]   # Porto de Santos (artigo)
docs["d2"]   # Autoridade Portuária de Santos (artigo)
docs["d3"]   # Francisco de Paula Ribeiro (artigo)
docs["d1.1"] # 1ª frase de d1
docs["d2.1"] # 1ª frase de d2
docs["d3.1"] # 1ª frase de d3

## 3) Tokenizando e montando o vocabulário
tokenizar <- function(texto) {
  texto <- tolower(texto)
  unlist(strsplit(texto, "\\s+"))
}

# Vocabulario / frequencias nos ARTIGOS (d1, d2, d3) - sem contar
# as frases de novo (evita duplicar tokens do mesmo texto).
ids_artigos <- c("d1", "d2", "d3")
ids_frases <- setdiff(names(docs), ids_artigos)

tokens_artigos <- lapply(docs[ids_artigos], tokenizar)
tokens_fr      <- lapply(docs[ids_frases], tokenizar)

tokens_artigos[["d1"]][1:15]
tokens_artigos[["d2"]][1:15]
tokens_artigos[["d3"]][1:15]

vocab <- sort(unique(unlist(tokens_artigos)))
length(vocab)

cat("\n--- Resumo dos artigos (d1, d2, d3) ---\n")
resumo_artigos <- data.frame(
  documento        = ids_artigos,
  frases           = sapply(ids_artigos, function(id) {
    sum(startsWith(ids_frases, paste0(id, ".")))
  }),
  caracteres       = sapply(docs[ids_artigos], nchar),
  tokens           = sapply(tokens_artigos, length),
  termos_distintos = sapply(tokens_artigos, function(tk) length(unique(tk)))
)
print(resumo_artigos, row.names = FALSE)

cat("\n--- Resumo das frases (d1.1, d1.2, ...; por ponto final) ---\n")
resumo_fr <- data.frame(
  documento        = ids_frases,
  palavras         = sapply(docs[ids_frases], function(x) length(unlist(strsplit(x, "\\s+")))),
  caracteres       = sapply(docs[ids_frases], nchar),
  tokens           = sapply(tokens_fr, length),
  termos_distintos = sapply(tokens_fr, function(tk) length(unique(tk)))
)
print(resumo_fr, row.names = FALSE)
cat("palavras/frase: min=", min(resumo_fr$palavras),
    " max=", max(resumo_fr$palavras),
    " mediana=", median(resumo_fr$palavras), "\n", sep = "")

cat("\n--- Comparação com o corpus de brinquedo ---\n")
cat("Vocabulário do corpus de brinquedo (aula): 45 termos\n")
cat("Vocabulário do nosso corpus real (artigos):", length(vocab), "termos\n")
cat("Razão:", round(length(vocab) / 45, 1), "x maior\n")
cat("Artigos:", length(ids_artigos), "| Frases:", length(ids_frases), "\n")

## 4) Liste os 10 termos mais frequentes (nos artigos)
freq <- table(unlist(tokens_artigos))
top10 <- sort(freq, decreasing = TRUE)[1:10]

cat("\n--- Top 10 termos mais frequentes (artigos) ---\n")
print(top10)

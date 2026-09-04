# =============================================================
# PI III - Motor de Busca - Atividade 02 / Aula 02 (3ª entrega)
# Fatec Rubens Lara - Ciência de Dados
# Vetores TF-IDF e similaridade do cosseno
# Corpus de brinquedo da Aula 01 (8 documentos, 45 termos)
# =============================================================

## 1) Corpus da Aula 01
docs <- c(
  d1 = "recuperacao de informacao ordena documentos por relevancia",
  d2 = "o modelo de espaco vetorial representa documentos como vetores",
  d3 = "bm25 e um modelo probabilistico de ranqueamento de texto",
  d4 = "aprendizado estatistico fundamenta a recuperacao moderna",
  d5 = "o indice invertido acelera a busca em muitos documentos",
  d6 = "embeddings capturam a semantica de palavras e documentos",
  d7 = "a avaliacao mede a relevancia dos resultados da busca",
  d8 = "ciencia de dados combina estatistica e programacao"
)

## 2) Tokenizacao, vocabulario e matriz termo-documento
tok <- function(x) unlist(strsplit(tolower(x), "\\s+"))
tokens <- lapply(docs, tok)
vocab <- sort(unique(unlist(tokens)))

tdm <- sapply(tokens, function(t) {
  as.integer(table(factor(t, levels = vocab)))
})
rownames(tdm) <- vocab

cat("Dimensao TDM (termos x docs):", paste(dim(tdm), collapse = " x "), "\n")
cat("Vocabulario:", length(vocab), "termos\n\n")

## 3) Pesos TF-IDF (log natural, como na Aula 02)
tf <- tdm
N <- ncol(tdm)
df <- rowSums(tdm > 0)
idf <- log(N / df)
w <- tf * idf

cat("--- Amostra TF-IDF ---\n")
print(round(w[c("documentos", "modelo", "de"), ], 2))
cat("\n")

## 4) Similaridade do cosseno
cosseno <- function(a, b) {
  na <- sqrt(sum(a^2))
  nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(0)
  sum(a * b) / (na * nb)
}

## 5) Ranquear uma consulta
ranquear <- function(consulta, w, idf, vocab) {
  q <- as.integer(table(factor(tok(consulta), levels = vocab)))
  qw <- q * idf
  scores <- apply(w, 2, function(dvec) cosseno(qw, dvec))
  sort(scores, decreasing = TRUE)
}

## 6) Tres consultas (entrega)
consultas <- c(
  "modelo de recuperacao",
  "busca documentos indice",
  "ciencia de dados estatistica"
)

for (q in consultas) {
  cat("============================================================\n")
  cat("Consulta:", q, "\n")
  scores <- ranquear(q, w, idf, vocab)
  print(round(scores, 3))
  melhor <- names(which.max(scores))
  cat("Melhor:", melhor, "->", docs[[melhor]], "\n\n")
}

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

## 7) O mesmo motor no NOSSO corpus (frases dN.k)
# Tokenizacao da Aula 01: minusculas e sem pontuacao.
# Stopwords e radicais so entram na Aula 03.
cat("============================================================\n")
cat("NOSSO CORPUS - Porto de Santos, APS, Francisco de Paula Ribeiro\n")
cat("============================================================\n")

args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
source("01a-ler-frases.R")
docs_c <- carregar_docs_canonico(file.path("..", "corpus"))
docs_c <- docs_c[grepl("^d[0-9]+\\.[0-9]+$", names(docs_c))]

tok_c <- function(x) {
  t <- unlist(strsplit(gsub("[[:punct:]]", " ", tolower(x)), "\\s+"))
  t[nzchar(t)]
}
tokens_c <- lapply(docs_c, tok_c)
vocab_c <- sort(unique(unlist(tokens_c)))
tdm_c <- sapply(tokens_c, function(t) as.integer(table(factor(t, levels = vocab_c))))
rownames(tdm_c) <- vocab_c
idf_c <- log(ncol(tdm_c) / rowSums(tdm_c > 0))
w_c <- tdm_c * idf_c
cat("Dimensao TDM (termos x frases):", paste(dim(tdm_c), collapse = " x "),
    "| celulas nao nulas:", round(100 * mean(tdm_c > 0), 1), "%\n\n")

ranquear_c <- function(consulta) {
  qw <- as.integer(table(factor(tok_c(consulta), levels = vocab_c))) * idf_c
  sort(apply(w_c, 2, function(d) cosseno(qw, d)), decreasing = TRUE)
}
soma_tfidf <- function(consulta) {
  t <- intersect(tok_c(consulta), vocab_c)
  sort(colSums(w_c[t, , drop = FALSE]), decreasing = TRUE)
}

perguntas_c <- c(
  q_local    = "localização porto santos guarujá cubatão",
  q_aps      = "quem administra porto santos autoridade",
  q_fundador = "francisco de paula ribeiro porto"
)
for (cq in names(perguntas_c)) {
  q <- perguntas_c[[cq]]
  cos_r <- ranquear_c(q)
  soma_r <- soma_tfidf(q)
  cat("------------------------------------------------------------\n")
  cat(cq, "- consulta:", q, "\n")
  cat("Termos fora do vocabulario:", paste(setdiff(tok_c(q), vocab_c), collapse = ", "), "\n")
  cat("Top-5 cosseno:\n")
  for (id in names(cos_r)[1:5]) {
    cat(sprintf("  %-6s %.3f  %s\n", id, cos_r[[id]], substr(docs_c[[id]], 1, 70)))
  }
  cat("Top-5 soma TF-IDF (sem normalizar):", paste(names(soma_r)[1:5], collapse = " "), "\n")
  cat("Melhor (cosseno):", names(cos_r)[1], "->", docs_c[[names(cos_r)[1]]], "\n\n")
}

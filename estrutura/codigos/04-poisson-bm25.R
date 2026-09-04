# =============================================================
# PI III - Motor de Busca - Atividade 04 / Aula 04 (5ª entrega)
# Fatec Rubens Lara - Ciência de Dados
# Poisson → saturação → BM25 no corpus real (Porto de Santos)
# Continua o pré-processamento da Atividade 03 (SnowballC)
# =============================================================

user_lib <- path.expand("~/R/win-library/4.6")
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))
if (!requireNamespace("SnowballC", quietly = TRUE)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  install.packages("SnowballC", lib = user_lib, repos = "https://cloud.r-project.org")
  .libPaths(c(user_lib, .libPaths()))
}
library(SnowballC)

## cwd = pasta do script; corpus em ../corpus
args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}
pasta_corpus <- file.path("..", "corpus")


## ============================================================
## 1) Corpus real (mesmo das Atividades 01 e 03)
## ============================================================
artigos <- c(
  d1 = "porto_de_santos.txt",
  d2 = "autoridade_portuaria_de_santos.txt",
  d3 = "francisco_de_paula_ribeiro.txt"
)

ler_paragrafos <- function(caminho) {
  linhas <- readLines(caminho, encoding = "UTF-8", warn = FALSE)
  texto <- paste(linhas, collapse = "\n")
  blocos <- unlist(strsplit(texto, "\n[[:space:]]*\n+"))
  trimws(blocos[nzchar(trimws(blocos))])
}

docs <- character(0)
for (id in names(artigos)) {
  paragrafos <- ler_paragrafos(file.path(pasta_corpus, artigos[[id]]))
  docs[[id]] <- paste(paragrafos, collapse = " ")
  if (length(paragrafos) > 0) {
    docs[paste0(id, ".", seq_along(paragrafos))] <- paragrafos
  }
}

## ============================================================
## 2) Pré-processamento (igual Atividade 03 / Aula 03)
## ============================================================
limpar <- function(x) {
  x <- tolower(x)
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  x[is.na(x)] <- ""
  x <- gsub("[^a-z0-9 ]", " ", x)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

stopwords <- unique(c(
  "de", "o", "a", "e", "um", "uma", "uns", "umas",
  "por", "como", "que", "da", "do", "das", "dos",
  "em", "no", "na", "nos", "nas", "ao", "aos", "as", "os",
  "com", "para", "pelo", "pela", "pelos", "pelas",
  "se", "sua", "seu", "seus", "suas",
  "ou", "mais", "menos", "muito", "muitos", "ja", "tambem",
  "entre", "sobre", "ate", "sem", "sob", "apos",
  "foi", "ser", "sao", "esta", "este", "essa", "esse",
  "isso", "isto", "ele", "ela", "eles", "elas",
  "lhe", "lhes", "me", "te", "vos",
  "ha", "tem", "ter", "pode", "podem"
))

prep <- function(x) {
  t <- unlist(strsplit(limpar(x), " "))
  t <- t[nzchar(t)]
  t <- t[!t %in% stopwords]
  if (length(t) == 0) return(character(0))
  SnowballC::wordStem(t, language = "portuguese")
}

tokens <- lapply(docs, prep)
ids <- names(docs)
vocab <- sort(unique(unlist(tokens)))

## Matriz TF (termo x documento)
tf <- sapply(tokens, function(t) {
  as.integer(table(factor(t, levels = vocab)))
})
rownames(tf) <- vocab

dl <- colSums(tf)
avgdl <- mean(dl)
N <- ncol(tf)
df <- rowSums(tf > 0)

cat("Docs:", N, "| vocab (stems):", length(vocab),
    "| avgdl:", round(avgdl, 1), "\n")
cat("Tamanhos |d| (artigos): d1=", dl["d1"],
    " d2=", dl["d2"], " d3=", dl["d3"], "\n\n")

## ============================================================
## 3) Poisson: probabilidade de ver f ocorrencias
## ============================================================
# P(X=f) = e^{-lambda} * lambda^f / f!
poisson_p <- function(f, lambda) {
  exp(-lambda) * lambda^f / factorial(f)
}

cat("=== Poisson unica (exemplo da aula: lambda = 2) ===\n")
f_vals <- c(0, 1, 2, 3, 5)
print(round(sapply(f_vals, poisson_p, lambda = 2), 3))
cat("\n")

## No nosso corpus: taxa empirica do stem "port" (media de tf por doc)
termo_ex <- "port"
if (termo_ex %in% vocab) {
  freqs <- as.integer(tf[termo_ex, ])
  lambda_hat <- mean(freqs)
  cat("=== Poisson no corpus: stem '", termo_ex, "' ===\n", sep = "")
  cat("lambda empirico (media de tf):", round(lambda_hat, 3), "\n")
  cat("tf observado por doc (amostra dos >0):\n")
  print(freqs[freqs > 0][1:min(10, sum(freqs > 0))])
  cat("P(X=f) sob Poisson(lambda_hat):\n")
  print(round(sapply(0:5, poisson_p, lambda = lambda_hat), 4))
  cat("Obs: texto real e 'burstiness' — a Poisson unica subestima\n")
  cat("os extremos (docs que falam muito do termo).\n\n")
}

## ============================================================
## 4) Duas Poissons (eliteness) → peso w(f) e saturacao
## ============================================================
# Parametros do slide da Aula 04
lambda <- 3; mu <- 0.2; p <- 0.6; q <- 0.1

# w(f) = log P(f|R) / P(f|not R)  (mistura; f! cancela)
w_cru <- function(f, lambda, mu, p, q) {
  num <- p * exp(-lambda) * lambda^f + (1 - p) * exp(-mu) * mu^f
  den <- q * exp(-lambda) * lambda^f + (1 - q) * exp(-mu) * mu^f
  log(num / den)
}

w0 <- w_cru(0, lambda, mu, p, q)
w_norm <- function(f) w_cru(f, lambda, mu, p, q) - w0

cat("=== Peso 2-Poisson (lambda=3, mu=0.2, p=0.6, q=0.1) ===\n")
cat("w(0) cru =", round(w0, 4), "\n")
cat("teto w(inf)-w(0) = log(p/q) - w(0) =",
    round(log(p / q) - w0, 4), "\n")
curva <- sapply(0:8, w_norm)
names(curva) <- paste0("f=", 0:8)
print(round(curva, 3))
cat("A partir de f~3 o peso quase nao sobe mais → saturacao.\n\n")

## ============================================================
## 5) Aproximacao BM25 da saturacao: f*(k1+1)/(f+k1)
## ============================================================
k1 <- 1.2
b  <- 0.75
sat <- function(f, k1 = 1.2) (f * (k1 + 1)) / (f + k1)

cat("=== Saturacao BM25 (k1 = 1.2, b=0) ===\n")
print(round(sapply(1:5, sat), 3))
cat("Teto teorico = k1+1 =", k1 + 1, "\n\n")

## ============================================================
## 6) IDF do BM25 (Aula 04)
## ============================================================
idf <- log((N - df + 0.5) / (df + 0.5) + 1)

cat("=== IDF BM25 (amostra) ===\n")
amostra_idf <- c("port", "sant", "autor", "ribeir", "carg", "codesp")
amostra_idf <- amostra_idf[amostra_idf %in% vocab]
print(round(idf[amostra_idf], 3))
cat("\n")

## ============================================================
## 7) BM25 no corpus
## ============================================================
bm25_doc <- function(termos, d, k1 = 1.2, b = 0.75) {
  s <- 0
  for (t in termos) {
    if (!(t %in% vocab)) next
    f <- as.numeric(tf[t, d])
    K <- k1 * (1 - b + b * as.numeric(dl[d]) / avgdl)
    # as.numeric evita herdar o nome do termo (idf[t] e nomeado)
    s <- s + as.numeric(idf[t]) * (f * (k1 + 1)) / (f + K)
  }
  as.numeric(s)
}

ranquear_bm25 <- function(consulta, k1 = 1.2, b = 0.75) {
  termos <- prep(consulta)
  scores <- sapply(ids, function(d) bm25_doc(termos, d, k1, b))
  sort(scores, decreasing = TRUE)
}

## TF-IDF + cosseno (baseline da Atividade 02, agora no corpus real limpo)
idf_classico <- log(N / df)
w_tfidf <- tf * idf_classico
cosseno <- function(a, b) {
  na <- sqrt(sum(a^2)); nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(0)
  sum(a * b) / (na * nb)
}
ranquear_tfidf <- function(consulta) {
  q <- as.integer(table(factor(prep(consulta), levels = vocab)))
  qw <- q * idf_classico
  scores <- apply(w_tfidf, 2, function(dvec) cosseno(qw, dvec))
  sort(scores, decreasing = TRUE)
}

consultas <- c(
  "porto de santos",
  "autoridade portuaria",
  "francisco ribeiro"
)

cat("=== Ranking BM25 vs TF-IDF (so artigos d1, d2, d3) ===\n")
for (q in consultas) {
  cat("------------------------------------------------------------\n")
  cat("Consulta:", q, "\n")
  cat("  stems:", paste(prep(q), collapse = " | "), "\n")
  bm <- ranquear_bm25(q)
  tfidf <- ranquear_tfidf(q)
  bm_art <- bm[names(bm) %in% c("d1", "d2", "d3")]
  tf_art <- tfidf[names(tfidf) %in% c("d1", "d2", "d3")]
  cat("  BM25  artigos:",
      paste(sprintf("%s=%.3f", names(bm_art), unname(bm_art)), collapse = ", "), "\n")
  cat("  TFIDF artigos:",
      paste(sprintf("%s=%.3f", names(tf_art), unname(tf_art)), collapse = ", "), "\n")
  cat("  BM25  top5 docs:",
      paste(sprintf("%s=%.3f", names(bm)[1:5], unname(bm[1:5])), collapse = ", "), "\n")
  cat("  TFIDF top5 docs:",
      paste(sprintf("%s=%.3f", names(tfidf)[1:5], unname(tfidf[1:5])), collapse = ", "), "\n")
}
cat("\n")

## ============================================================
## 8) Variar k1 e b (para casa item 3)
## ============================================================
cat("=== Efeito de k1 e b na consulta 'porto autoridade' ===\n")
q_var <- "porto autoridade"
grid <- expand.grid(k1 = c(0.5, 1.2, 2.0), b = c(0, 0.75, 1))
for (i in seq_len(nrow(grid))) {
  kk <- grid$k1[i]; bb <- grid$b[i]
  r <- ranquear_bm25(q_var, k1 = kk, b = bb)
  cat(sprintf("k1=%.1f b=%.2f → top3: %s\n",
              kk, bb, paste(names(r)[1:3], collapse = ", ")))
}

cat("\nPronto: Poisson, peso/saturacao, BM25 e comparacao com TF-IDF.\n")

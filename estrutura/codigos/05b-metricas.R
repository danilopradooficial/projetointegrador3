# =============================================================
# PI III - Motor de Busca - Atividade 05b / Aula 5,5 (7ª entrega)
# Fatec Rubens Lara - Ciência de Dados · Team Shannon
# Métricas: P@k, R@k, AP/MAP, MRR, nDCG (binário e graduado)
# =============================================================
# Parte A — exemplo canônico da aula (8 docs, 1 consulta)
# Parte B — TF-IDF (cosseno) e BM25 vs qrels do nosso julgamento
# =============================================================

user_lib <- path.expand("~/R/win-library/4.6")
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))
if (!requireNamespace("SnowballC", quietly = TRUE)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  install.packages("SnowballC", lib = user_lib, repos = "https://cloud.r-project.org")
  .libPaths(c(user_lib, .libPaths()))
}
library(SnowballC)

args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

## ------------------------------------------------------------
## Funções de métrica (usadas nas duas partes)
## ------------------------------------------------------------
dcg <- function(r) {
  r <- as.numeric(r)
  if (length(r) == 0) return(0)
  sum(r / log2(seq_along(r) + 1))
}

metricas_ranking <- function(ranking, grau, limiar = 2L) {
  ranking <- as.character(ranking)
  g <- as.numeric(grau[ranking])
  g[is.na(g)] <- 0
  relevantes <- names(grau)[as.numeric(grau) >= limiar]
  R <- length(relevantes)
  rel <- as.integer(ranking %in% relevantes)
  k <- seq_along(ranking)
  acertos <- cumsum(rel)
  precisao <- if (length(k)) acertos / k else numeric(0)
  recall <- if (R > 0) acertos / R else rep(NA_real_, length(k))
  ap <- if (R > 0) sum(precisao[rel == 1]) / R else NA_real_
  pos1 <- which(rel == 1)
  mrr <- if (length(pos1)) 1 / pos1[[1]] else 0
  ndcg_bin <- if (sum(rel) > 0) dcg(rel) / dcg(sort(rel, decreasing = TRUE)) else NA_real_
  ndcg_g <- if (sum(g) > 0) dcg(g) / dcg(sort(g, decreasing = TRUE)) else NA_real_
  p_at_3 <- if (length(precisao) >= 3) precisao[[3]] else {
    if (length(precisao)) precisao[[length(precisao)]] else NA_real_
  }
  list(
    rel = rel, g = g, R = R,
    precisao = precisao, recall = recall,
    P_at_3 = p_at_3, AP = ap, MRR = mrr,
    nDCG_bin = ndcg_bin, nDCG_grad = ndcg_g
  )
}

## ============================================================
## PARTE A — cenário canônico da Aula 5,5 (Guia 01)
## ============================================================
cat("=== PARTE A — ranking canônico BM25 × gabarito da aula ===\n")
ranking_aula <- c("d3", "d1", "d2", "d4", "d8", "d6", "d5", "d7")
grau_aula <- c(d1 = 1, d2 = 2, d3 = 2, d4 = 0, d5 = 0, d6 = 1, d7 = 0, d8 = 0)

mA <- metricas_ranking(ranking_aula, grau_aula, limiar = 2L)
cat("relevantes (grau >= 2):", paste(names(grau_aula)[grau_aula >= 2], collapse = ", "), "\n")
cat("rel:", paste(mA$rel, collapse = " "), "\n")
cat("P@k: ", paste(sprintf("%.3f", mA$precisao), collapse = " "), "\n")
cat("R@k: ", paste(sprintf("%.3f", mA$recall), collapse = " "), "\n")
resumoA <- c(
  P_at_3 = mA$P_at_3, AP = mA$AP, MRR = mA$MRR,
  nDCG_bin = mA$nDCG_bin, nDCG_grad = mA$nDCG_grad
)
print(round(resumoA, 3))
cat("\n")

## ============================================================
## PARTE B — nosso corpus + qrels (Aula 05a)
## ============================================================
cat("=== PARTE B — cosseno vs BM25 no gabarito Team Shannon ===\n")

source("01a-ler-frases.R")
pasta_corpus <- file.path("..", "corpus")
docs <- carregar_docs_canonico(pasta_corpus)
# só unidades de frase (dN.k); artigos d1/d2/d3 ficam de fora do ranking
docs <- docs[grepl("^d[0-9]+\\.[0-9]+$", names(docs))]

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
tf <- sapply(tokens, function(t) {
  as.integer(table(factor(t, levels = vocab)))
})
rownames(tf) <- vocab
dl <- colSums(tf)
avgdl <- mean(dl)
N <- ncol(tf)
df <- rowSums(tf > 0)
# mesma fórmula da Atividade 04
idf_bm25 <- log((N - df + 0.5) / (df + 0.5) + 1)
idf_classico <- log(N / df)
w_tfidf <- tf * idf_classico

bm25_doc <- function(termos, d, k1 = 1.2, b = 0.75) {
  s <- 0
  for (t in termos) {
    if (!(t %in% vocab)) next
    f <- as.numeric(tf[t, d])
    K <- k1 * (1 - b + b * as.numeric(dl[d]) / avgdl)
    s <- s + as.numeric(idf_bm25[t]) * (f * (k1 + 1)) / (f + K)
  }
  as.numeric(s)
}

ranquear_bm25 <- function(consulta) {
  termos <- prep(consulta)
  scores <- sapply(ids, function(d) bm25_doc(termos, d))
  sort(scores, decreasing = TRUE)
}

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

qrels_path <- file.path("05-julgamento", "csv", "05-qrels.csv")
need_path <- file.path("05-julgamento", "csv", "05-necessidades.csv")
qrels <- read.csv(qrels_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
need <- read.csv(need_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# Limiar escolhido ANTES de medir: relevante = grau >= 2
# (só o que “responde”; grau 1 fica no nDCG graduado)
limiar <- 2L
cat("Limiar de binarizacao: grau >=", limiar, "\n")
cat("Docs frase:", N, "| vocab:", length(vocab), "\n\n")

consultas <- sort(unique(qrels$consulta))
aps_bm25 <- c(); aps_cos <- c()
resumo_linhas <- list()

for (qid in consultas) {
  linhas <- qrels[qrels$consulta == qid, ]
  grau <- setNames(as.numeric(linhas$grau), linhas$documento)
  # se houver voto duplicado no mesmo doc, fica o último
  grau <- grau[!duplicated(names(grau), fromLast = TRUE)]
  R <- sum(grau >= limiar)
  texto_q <- need$texto_consulta[need$consulta == qid]
  if (!length(texto_q) || !nzchar(texto_q[[1]])) {
    cat(qid, ": sem texto de consulta — pulada\n")
    next
  }
  texto_q <- texto_q[[1]]

  if (R == 0) {
    cat(sprintf("%s: R=0 com limiar>=%d — fora da avaliacao binaria\n", qid, limiar))
    next
  }

  rank_bm <- names(ranquear_bm25(texto_q))
  rank_cos <- names(ranquear_tfidf(texto_q))
  mb <- metricas_ranking(rank_bm, grau, limiar)
  mc <- metricas_ranking(rank_cos, grau, limiar)
  aps_bm25[[qid]] <- mb$AP
  aps_cos[[qid]] <- mc$AP

  cat(sprintf(
    "%s | R=%d | texto: %s\n  BM25  P@3=%.3f AP=%.3f MRR=%.3f nDCG=%.3f nDCGg=%.3f | top3: %s\n  cos   P@3=%.3f AP=%.3f MRR=%.3f nDCG=%.3f nDCGg=%.3f | top3: %s\n",
    qid, R, texto_q,
    mb$P_at_3, mb$AP, mb$MRR, mb$nDCG_bin, mb$nDCG_grad,
    paste(rank_bm[1:3], collapse = ", "),
    mc$P_at_3, mc$AP, mc$MRR, mc$nDCG_bin, mc$nDCG_grad,
    paste(rank_cos[1:3], collapse = ", ")
  ))

  resumo_linhas[[qid]] <- data.frame(
    consulta = qid, R = R,
    sistema = c("bm25", "cosseno"),
    P_at_3 = c(mb$P_at_3, mc$P_at_3),
    AP = c(mb$AP, mc$AP),
    MRR = c(mb$MRR, mc$MRR),
    nDCG_bin = c(mb$nDCG_bin, mc$nDCG_bin),
    nDCG_grad = c(mb$nDCG_grad, mc$nDCG_grad),
    stringsAsFactors = FALSE
  )
}

aps_bm25 <- unlist(aps_bm25)
aps_cos <- unlist(aps_cos)
cat("\n=== MAP (consultas com R>0) ===\n")
cat(sprintf("MAP BM25  = %.3f  (n=%d)\n", mean(aps_bm25), length(aps_bm25)))
cat(sprintf("MAP cosseno = %.3f  (n=%d)\n", mean(aps_cos), length(aps_cos)))
cat("APs BM25 :", paste(sprintf("%s=%.3f", names(aps_bm25), aps_bm25), collapse = ", "), "\n")
cat("APs cos  :", paste(sprintf("%s=%.3f", names(aps_cos), aps_cos), collapse = ", "), "\n")

if (length(resumo_linhas)) {
  tab <- do.call(rbind, resumo_linhas)
  out_csv <- file.path("05-julgamento", "csv", "05b-metricas-por-consulta.csv")
  write.csv(tab, out_csv, row.names = FALSE, fileEncoding = "UTF-8")
  cat("\nTabela salva em", out_csv, "\n")
}

cat("\nPronto: Parte A (canônico) + Parte B (qrels próprios).\n")
cat("Ressalva: poucas consultas / pool parcial — diferença nao e teste de significancia (Aula 16).\n")

# =============================================================
# entrega-meio-semestre-demo.R
# Auditoria senior: 3 consultas × Booleano / TF-IDF / cosseno /
# BM25 / peso do julgamento (qrels)
# Team Shannon · PI III · Entrega de meio de semestre
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
## Corpus canônico (frases dN.k)
## ------------------------------------------------------------
source("01a-ler-frases.R")
docs <- carregar_docs_canonico(file.path("..", "corpus"))
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
tf <- sapply(tokens, function(t) as.integer(table(factor(t, levels = vocab))))
rownames(tf) <- vocab
dl <- colSums(tf)
avgdl <- mean(dl)
N <- ncol(tf)
df <- rowSums(tf > 0)
idf_classico <- log(N / df)
idf_bm25 <- log((N - df + 0.5) / (df + 0.5) + 1)
w_tfidf <- tf * idf_classico

## Índice invertido (Aula 03)
postings <- lapply(setNames(vocab, vocab), function(t) {
  ids[tf[t, ] > 0]
})

## ------------------------------------------------------------
## Métodos
## ------------------------------------------------------------
busca_AND <- function(consulta) {
  termos <- prep(consulta)
  if (length(termos) == 0) return(character(0))
  if (!all(termos %in% names(postings))) return(character(0))
  Reduce(intersect, postings[termos])
}
busca_OR <- function(consulta) {
  termos <- prep(consulta)
  termos <- termos[termos %in% names(postings)]
  if (length(termos) == 0) return(character(0))
  unique(unlist(postings[termos], use.names = FALSE))
}

ranquear_tfidf <- function(consulta) {
  termos <- prep(consulta)
  scores <- sapply(ids, function(d) {
    s <- 0
    for (t in termos) {
      if (t %in% vocab) s <- s + as.numeric(w_tfidf[t, d])
    }
    s
  })
  sort(scores, decreasing = TRUE)
}

cosseno <- function(a, b) {
  na <- sqrt(sum(a^2)); nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(0)
  sum(a * b) / (na * nb)
}
ranquear_cosseno <- function(consulta) {
  q <- as.integer(table(factor(prep(consulta), levels = vocab)))
  qw <- q * idf_classico
  scores <- apply(w_tfidf, 2, function(dvec) cosseno(qw, dvec))
  sort(scores, decreasing = TRUE)
}

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

dcg <- function(r) {
  r <- as.numeric(r)
  if (!length(r)) return(0)
  sum(r / log2(seq_along(r) + 1))
}

## qrels (Aula 05a) — mapa consulta-demo → id do julgamento
qrels_path <- file.path("05-julgamento", "csv", "05-qrels.csv")
qrels <- if (file.exists(qrels_path)) {
  read.csv(qrels_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
} else {
  data.frame()
}

consultas <- c(
  q_local = "localizacao porto santos guarujá cubatão",
  q_aps = "quem administra porto santos autoridade",
  q_fundador = "francisco de paula ribeiro porto"
)
qrels_map <- c(q_local = "q15", q_aps = "q02", q_fundador = "q04")

fmt_top <- function(scores, k = 5) {
  if (!length(scores)) return("")
  top <- scores[seq_len(min(k, length(scores)))]
  paste(sprintf("%s:%.4f", names(top), unname(top)), collapse = ";")
}

jaccard <- function(a, b) {
  a <- unique(a); b <- unique(b)
  if (!length(a) && !length(b)) return(1)
  length(intersect(a, b)) / length(union(a, b))
}

qualidade <- function(ranking_ids, grau, limiar = 2L) {
  if (!length(grau)) {
    return(list(R = NA, P3 = NA, nDCG = NA, note = "sem qrels"))
  }
  relevantes <- names(grau)[as.numeric(grau) >= limiar]
  R <- length(relevantes)
  if (R == 0) {
    return(list(R = 0, P3 = NA, nDCG = NA, note = "R=0 limiar>=2"))
  }
  if (!length(ranking_ids)) {
    return(list(R = R, P3 = 0, nDCG = 0, note = "ranking vazio"))
  }
  rel <- as.integer(ranking_ids %in% relevantes)
  g <- as.numeric(grau[ranking_ids]); g[is.na(g)] <- 0
  acertos <- cumsum(rel)
  precisao <- acertos / seq_along(ranking_ids)
  p3 <- if (length(precisao) >= 3) precisao[[3]] else precisao[[length(precisao)]]
  ndcg <- if (sum(g) > 0) dcg(g) / dcg(sort(g, decreasing = TRUE)) else NA_real_
  list(R = R, P3 = p3, nDCG = ndcg, note = "")
}

dir.create("csv", showWarnings = FALSE)
linhas <- list()

cat("=== Entrega meio de semestre — auditoria multi-método ===\n")
cat("Docs:", N, "| vocab:", length(vocab), "| avgdl:", round(avgdl, 1), "\n\n")

for (nome in names(consultas)) {
  q <- consultas[[nome]]
  qid <- qrels_map[[nome]]
  cat("################################################################\n")
  cat("Consulta", nome, "|", q, "\n")
  cat("stems:", paste(prep(q), collapse = " | "), "\n")
  cat("qrels:", qid, "\n\n")

  grau <- numeric(0)
  if (nrow(qrels)) {
    sub <- qrels[qrels$consulta == qid, ]
    if (nrow(sub)) {
      grau <- setNames(as.numeric(sub$grau), sub$documento)
      grau <- grau[!duplicated(names(grau), fromLast = TRUE)]
    }
  }

  ## AND
  t0 <- proc.time()[["elapsed"]]
  and_ids <- busca_AND(q)
  ms_and <- (proc.time()[["elapsed"]] - t0) * 1000
  and_sc <- setNames(rep(1, length(and_ids)), and_ids)

  ## OR (sem ordem — listamos os 5 primeiros IDs estáveis)
  t0 <- proc.time()[["elapsed"]]
  or_ids <- busca_OR(q)
  ms_or <- (proc.time()[["elapsed"]] - t0) * 1000
  or_sc <- setNames(rep(1, length(or_ids)), or_ids)

  ## TF-IDF (soma dos pesos)
  t0 <- proc.time()[["elapsed"]]
  r_tf <- ranquear_tfidf(q)
  ms_tf <- (proc.time()[["elapsed"]] - t0) * 1000

  ## Cosseno
  t0 <- proc.time()[["elapsed"]]
  r_cos <- ranquear_cosseno(q)
  ms_cos <- (proc.time()[["elapsed"]] - t0) * 1000

  ## BM25
  t0 <- proc.time()[["elapsed"]]
  r_bm <- ranquear_bm25(q)
  ms_bm <- (proc.time()[["elapsed"]] - t0) * 1000

  blocos <- list(
    AND = list(sc = and_sc, ms = ms_and, n = length(and_ids)),
    OR = list(sc = or_sc, ms = ms_or, n = length(or_ids)),
    TFIDF = list(sc = r_tf, ms = ms_tf, n = length(r_tf)),
    cosseno = list(sc = r_cos, ms = ms_cos, n = length(r_cos)),
    BM25 = list(sc = r_bm, ms = ms_bm, n = length(r_bm))
  )

  for (met in names(blocos)) {
    sc <- blocos[[met]]$sc
    top_ids <- names(sc)[seq_len(min(5, length(sc)))]
    qlt <- qualidade(top_ids, grau)
    cat(sprintf(
      "  %-8s  ms=%6.1f  |hits|=%-4s  top5=%s\n",
      met, blocos[[met]]$ms,
      if (met %in% c("AND", "OR")) as.character(blocos[[met]]$n) else "—",
      fmt_top(sc, 5)
    ))
    if (length(top_ids)) {
      cat("           1o:", substr(docs[[top_ids[[1]]]], 1, 110), "...\n")
    }
    if (!is.na(qlt$R)) {
      cat(sprintf(
        "           qualidade (limiar>=2): R=%s  P@3=%s  nDCG=%s  %s\n",
        qlt$R,
        ifelse(is.na(qlt$P3), "—", sprintf("%.3f", qlt$P3)),
        ifelse(is.na(qlt$nDCG), "—", sprintf("%.3f", qlt$nDCG)),
        qlt$note
      ))
    }
    ## graus dos top-5 (peso do julgamento)
    if (length(grau) && length(top_ids)) {
      gs <- as.numeric(grau[top_ids]); gs[is.na(gs)] <- 0
      cat("           graus top-5:", paste(sprintf("%s=%s", top_ids, gs), collapse = ", "), "\n")
    }
    cat("\n")
    linhas[[length(linhas) + 1]] <- data.frame(
      consulta = nome,
      texto = q,
      metodo = met,
      ms = round(blocos[[met]]$ms, 2),
      top5 = fmt_top(sc, 5),
      P_at_3 = ifelse(is.na(qlt$P3), "", round(qlt$P3, 3)),
      nDCG_grad = ifelse(is.na(qlt$nDCG), "", round(qlt$nDCG, 3)),
      R = ifelse(is.na(qlt$R), "", qlt$R),
      note = qlt$note,
      qrels_id = qid,
      stringsAsFactors = FALSE
    )
  }

  ## Overlap top-5 entre métodos ranqueados
  t5_cos <- names(r_cos)[1:5]
  t5_bm <- names(r_bm)[1:5]
  t5_tf <- names(r_tf)[1:5]
  cat(sprintf(
    "  Jaccard top-5 | cos∩BM25=%.2f  cos∩TFIDF=%.2f  BM25∩TFIDF=%.2f\n\n",
    jaccard(t5_cos, t5_bm), jaccard(t5_cos, t5_tf), jaccard(t5_bm, t5_tf)
  ))
}

tab <- do.call(rbind, linhas)
out_csv <- file.path("csv", "entrega-meio-semestre-auditoria.csv")
write.csv(tab, out_csv, row.names = FALSE, fileEncoding = "UTF-8")
cat("CSV salvo em", normalizePath(out_csv), "\n")
cat("\nVeredito rápido: AND costuma esvaziar (exige todos os stems);\n")
cat("OR é conjunto sem ordem; cosseno e BM25 ordenam — use números (score, P@3).\n")
cat("q_aps mapeia q02 do julgamento: R=0 com limiar>=2 (só grau 0/1 na pool).\n")

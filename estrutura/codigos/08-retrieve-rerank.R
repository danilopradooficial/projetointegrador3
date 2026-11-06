# =============================================================
# PI III - Motor de Busca - Atividade 08 / Aula 08 (10a entrega)
# Fatec Rubens Lara - Ciencia de Dados · Team Shannon
# Retrieve & rerank: proximidade ordenada no top-k
# =============================================================
# Nota (guia v2): o cross-encoder neural ficou so como conceito;
# o estagio 2 pratico e a proximidade ordenada em R.
#
# Parte A - exemplo canonico dos slides (8 docs)
# Parte B - nosso corpus (122 frases): top-5 estagio1 x rerank
# Parte C - grade k x janela no dev; teste uma vez; config.R
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

# decisoes da Aula 07 (estagio 1)
if (file.exists("config.R")) source("config.R")
if (!exists("modelo"))  modelo  <- "hibrido"
if (!exists("lsa_k"))   lsa_k   <- 20L
if (!exists("rrf_c"))   rrf_c   <- 60
if (!exists("limiar"))  limiar  <- 2L
if (!exists("consultas_dev")) {
  consultas_dev   <- c("q01", "q03", "q05", "q06", "q09", "q10", "q13")
  consultas_teste <- c("q04", "q07", "q11", "q15")
}

## ------------------------------------------------------------
## Funcoes comuns
## ------------------------------------------------------------
cosseno <- function(a, b) {
  na <- sqrt(sum(a^2)); nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(0)
  sum(a * b) / (na * nb)
}

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
  precisao <- if (length(k)) cumsum(rel) / k else numeric(0)
  ap <- if (R > 0) sum(precisao[rel == 1]) / R else NA_real_
  pos1 <- which(rel == 1)
  c(
    P_at_k = if (length(precisao) >= 3) precisao[[3]] else NA_real_,
    AP = ap,
    RR = if (length(pos1)) 1 / pos1[[1]] else 0,
    nDCG_bin = if (sum(rel) > 0) dcg(rel) / dcg(sort(rel, decreasing = TRUE)) else NA_real_,
    nDCG_grad = if (sum(g) > 0) dcg(g) / dcg(sort(g, decreasing = TRUE)) else NA_real_
  )
}

# Estagio 2 (brinquedo da aula): proximidade ordenada
proximidade <- function(qt, dt, janela = 3) {
  s <- 0
  for (i in seq_along(qt)) for (j in seq_along(qt)) {
    if (i < j && qt[i] != qt[j]) {
      pos_i <- which(dt == qt[i])
      pos_j <- which(dt == qt[j])
      if (length(pos_i) && length(pos_j)) {
        d <- outer(pos_j, pos_i, "-")
        d <- d[d > 0 & d <= janela]
        if (length(d)) s <- s + 1 / min(d)
      }
    }
  }
  s
}

reordenar <- function(rk, k, sc) {
  k <- min(k, length(rk))
  if (k <= 0) return(names(rk))
  top <- names(rk)[1:k]
  nova <- top[order(-sc[top], seq_along(top))]
  c(nova, names(rk)[-(1:k)])
}

rerank_prox <- function(rk, qt, tokens, k, janela) {
  if (k == 0) return(names(rk))
  top <- head(names(rk), k)
  sc <- sapply(tokens[top], function(dt) proximidade(qt, dt, janela))
  # completa sc para reordenar (cauda nao e usada no order da cabeca)
  sc_full <- setNames(rep(0, length(rk)), names(rk))
  sc_full[names(sc)] <- sc
  reordenar(rk, k, sc_full)
}

lsa_fit <- function(w, k) {
  k <- min(k, min(dim(w)) - 1L)
  s <- svd(w)
  Uk <- s$u[, 1:k, drop = FALSE]
  Sk <- s$d[1:k]
  Dk <- s$v[, 1:k, drop = FALSE] %*% diag(Sk, nrow = k)
  rownames(Dk) <- colnames(w)
  list(Uk = Uk, Sk = Sk, Dk = Dk, k = k)
}

rank_lsa <- function(q0, fit) {
  qk <- as.numeric(t(fit$Uk) %*% q0)
  scores <- apply(fit$Dk, 1, function(d) cosseno(qk, d))
  sort(scores, decreasing = TRUE)
}

rrf <- function(..., c = 60) {
  ranks <- list(...)
  ids <- unique(unlist(lapply(ranks, names), use.names = FALSE))
  s <- setNames(rep(0, length(ids)), ids)
  for (r in ranks) {
    pos <- match(ids, names(r))
    s <- s + ifelse(is.na(pos), 0, 1 / (c + pos))
  }
  sort(s, decreasing = TRUE)
}

## ============================================================
## PARTE A - slides (8 docs)
## ============================================================
cat("=== PARTE A - proximidade + reordenar (slides) ===\n")

docs_a <- c(
  d1 = "recuperacao de informacao ordena documentos por relevancia",
  d2 = "o modelo de espaco vetorial representa documentos como vetores",
  d3 = "bm25 e um modelo probabilistico de ranqueamento de texto",
  d4 = "aprendizado estatistico fundamenta a recuperacao moderna",
  d5 = "o indice invertido acelera a busca em muitos documentos",
  d6 = "embeddings capturam a semantica de palavras e documentos",
  d7 = "a avaliacao mede a relevancia dos resultados da busca",
  d8 = "ciencia de dados combina estatistica e programacao"
)
tok_a <- function(x) unlist(strsplit(tolower(x), "\\s+"))
tokens_a <- lapply(docs_a, tok_a)
vocab_a <- sort(unique(unlist(tokens_a)))
tf_a <- sapply(tokens_a, function(t) as.integer(table(factor(t, levels = vocab_a))))
rownames(tf_a) <- vocab_a
N_a <- ncol(tf_a); dl_a <- colSums(tf_a); avgdl_a <- mean(dl_a)
df_a <- rowSums(tf_a > 0)
idf_bm25_a <- log((N_a - df_a + 0.5) / (df_a + 0.5) + 1)

rank_bm25_a <- function(texto, k1 = 1.2, b = 0.75) {
  termos <- intersect(tok_a(texto), vocab_a)
  s <- setNames(rep(0, N_a), names(docs_a))
  for (t in termos) {
    f <- tf_a[t, ]
    K <- k1 * (1 - b + b * dl_a / avgdl_a)
    s <- s + idf_bm25_a[[t]] * f * (k1 + 1) / (f + K)
  }
  sort(s, decreasing = TRUE)
}

q_a <- "modelo de recuperacao"
r_bm25_a <- rank_bm25_a(q_a)
grau_a <- c(d1 = 1, d2 = 2, d3 = 2, d4 = 0, d5 = 0, d6 = 1, d7 = 0, d8 = 0)
sc_a <- sapply(tokens_a, function(dt) proximidade(tok_a(q_a), dt, 3))

cat("BM25:", paste(sprintf("%s=%.3f", names(r_bm25_a), r_bm25_a), collapse = " "), "\n")
cat("prox:", paste(sprintf("%s=%.1f", names(sc_a), sc_a), collapse = " "), "\n")
stopifnot(abs(sc_a[["d2"]] - 1.0) < 1e-9)
stopifnot(abs(sc_a[["d3"]] - 0.5) < 1e-9)
stopifnot(abs(sc_a[["d1"]] - 0.0) < 1e-9)

r2 <- reordenar(r_bm25_a, 2, sc_a)
r3 <- reordenar(r_bm25_a, 3, sc_a)
cat("k=2:", paste(r2, collapse = " "), "\n")
cat("k=3:", paste(r3, collapse = " "), "\n")
stopifnot(identical(r2[1:2], c("d3", "d1")))
stopifnot(identical(r3[1:3], c("d2", "d3", "d1")))

m0 <- metricas_ranking(names(r_bm25_a), grau_a)
m2 <- metricas_ranking(r2, grau_a)
m3 <- metricas_ranking(r3, grau_a)
cat("metricas BM25 / k2 / k3:\n")
print(round(rbind(bm25 = m0, k2 = m2, k3 = m3), 3))
stopifnot(abs(m3[["AP"]] - 1) < 1e-9)
cat("Parte A OK (numeros dos slides conferidos)\n\n")

# testes unitarios do guia
stopifnot(abs(proximidade(c("a", "b"), c("a", "x", "b")) - 0.5) < 1e-9)
stopifnot(identical(
  reordenar(c(a = 3, b = 2, c = 1), 2, c(a = 0.1, b = 0.9, c = 5)),
  c("b", "a", "c")
))

## ============================================================
## Nosso corpus
## ============================================================
source("01a-ler-frases.R")
docs <- carregar_docs_canonico(file.path("..", "corpus"))
docs <- docs[grepl("^d[0-9]+\\.[0-9]+$", names(docs))]

limpar <- function(x) {
  x <- tolower(x)
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  x[is.na(x)] <- ""
  x <- gsub("[^a-z0-9 ]", " ", x)
  trimws(gsub("\\s+", " ", x))
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
  t <- t[nzchar(t) & !t %in% stopwords]
  if (!length(t)) return(character(0))
  wordStem(t, language = "portuguese")
}

tokens <- lapply(docs, prep)
ids <- names(docs)
vocab <- sort(unique(unlist(tokens)))
tf <- sapply(tokens, function(t) as.integer(table(factor(t, levels = vocab))))
rownames(tf) <- vocab
N <- ncol(tf); dl <- colSums(tf); avgdl <- mean(dl)
df <- rowSums(tf > 0)
idf <- log(N / df)
idf_bm25 <- log((N - df + 0.5) / (df + 0.5) + 1)
w <- tf * idf

consulta_vetor <- function(texto) {
  qv <- as.integer(table(factor(prep(texto), levels = vocab))) * idf
  names(qv) <- vocab
  qv
}

rank_bm25 <- function(texto, k1 = 1.2, b = 0.75) {
  termos <- intersect(prep(texto), vocab)
  s <- setNames(rep(0, N), ids)
  for (t in termos) {
    f <- tf[t, ]
    K <- k1 * (1 - b + b * dl / avgdl)
    s <- s + idf_bm25[[t]] * f * (k1 + 1) / (f + K)
  }
  sort(s, decreasing = TRUE)
}

fit_lsa <- lsa_fit(w, as.integer(lsa_k))

estagio1 <- function(texto) {
  rb <- rank_bm25(texto)
  if (modelo == "bm25") return(rb)
  rl <- rank_lsa(consulta_vetor(texto), fit_lsa)
  if (modelo == "lsa") return(rl)
  rrf(rb, rl, c = rrf_c)
}

trecho <- function(id, n = 100) {
  t <- docs[[id]]
  if (nchar(t) > n) paste0(substr(t, 1, n), "...") else t
}

cat("=== Corpus Team Shannon ===\n")
cat("Frases:", N, "| vocab:", length(vocab),
    "| estagio1 =", modelo, "| lsa_k =", lsa_k, "| rrf_c =", rrf_c, "\n\n")

## ============================================================
## PARTE B - uma consulta: top-5 antes x depois
## ============================================================
cat("=== PARTE B - top-5 estagio1 x rerank (leitura) ===\n")

# consulta de trabalho com R > 0 (localizacao)
q_leitura <- "q15"
need <- read.csv(file.path("05-julgamento", "csv", "05-necessidades.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8")
qrels <- read.csv(file.path("05-julgamento", "csv", "05-qrels.csv"),
                  stringsAsFactors = FALSE, fileEncoding = "UTF-8")

texto_leitura <- need$texto_consulta[need$consulta == q_leitura][[1]]
qt_leitura <- prep(texto_leitura)
rk0 <- estagio1(texto_leitura)
# k=10, janela=3 como no guia (modulo 7)
rn <- rerank_prox(rk0, qt_leitura, tokens, 10, 3)

cat("Consulta", q_leitura, ":", texto_leitura, "\n")
cat("Tokens consulta:", paste(qt_leitura, collapse = " "), "\n\n")
cat("Top-5 estagio1 (", modelo, "):\n", sep = "")
for (i in 1:5) {
  id <- names(rk0)[i]
  px <- proximidade(qt_leitura, tokens[[id]], 3)
  cat(sprintf("  %d. %-6s score=%.4f prox=%.3f  %s\n",
              i, id, unname(rk0[i]), px, trecho(id)))
}
cat("\nTop-5 apos rerank (k=10, janela=3):\n")
for (i in 1:5) {
  id <- rn[i]
  px <- proximidade(qt_leitura, tokens[[id]], 3)
  cat(sprintf("  %d. %-6s prox=%.3f  %s\n", i, id, px, trecho(id)))
}
subiram <- setdiff(rn[1:5], names(rk0)[1:5])
desceram <- setdiff(names(rk0)[1:5], rn[1:5])
cat("\nSubiram para o top-5:", if (length(subiram)) paste(subiram, collapse = " ") else "(nenhum)", "\n")
cat("Saíram do top-5:", if (length(desceram)) paste(desceram, collapse = " ") else "(nenhum)", "\n")
if (length(subiram)) {
  cat("Textos que subiram:\n")
  for (id in subiram) cat(" ", id, ":", docs[[id]], "\n")
}

linhas_top <- list()
for (i in 1:5) {
  linhas_top[[length(linhas_top) + 1]] <- data.frame(
    consulta = q_leitura, metodo = "estagio1", pos = i,
    frase = names(rk0)[i], score = round(unname(rk0[i]), 4),
    prox = round(proximidade(qt_leitura, tokens[[names(rk0)[i]]], 3), 3),
    texto = trecho(names(rk0)[i], 120), stringsAsFactors = FALSE
  )
  linhas_top[[length(linhas_top) + 1]] <- data.frame(
    consulta = q_leitura, metodo = "rerank", pos = i,
    frase = rn[i], score = NA_real_,
    prox = round(proximidade(qt_leitura, tokens[[rn[i]]], 3), 3),
    texto = trecho(rn[i], 120), stringsAsFactors = FALSE
  )
}
out_top <- file.path("05-julgamento", "csv", "08-rerank-top5.csv")
write.csv(do.call(rbind, linhas_top), out_top, row.names = FALSE, fileEncoding = "UTF-8")
cat("Top-5 salvo em", out_top, "\n\n")

## ============================================================
## PARTE C - grade k x janela no DEV; teste uma vez
## ============================================================
cat("=== PARTE C - MAP estagio1 x rerank (grade) ===\n")

grau_de <- function(qid) {
  s <- qrels[qrels$consulta == qid, ]
  g <- setNames(as.numeric(s$grau), s$documento)
  g[!duplicated(names(g), fromLast = TRUE)]
}
texto_de <- function(qid) {
  t <- need$texto_consulta[need$consulta == qid]
  if (!length(t) || !nzchar(t[[1]])) NA_character_ else t[[1]]
}
com_R <- function(qids) {
  Filter(function(q) sum(grau_de(q) >= limiar) > 0, qids)
}

dev   <- com_R(consultas_dev)
teste <- com_R(consultas_teste)
cat("dev  :", paste(dev, collapse = ", "), "\n")
cat("teste:", paste(teste, collapse = ", "), "\n")
cat("estagio1 =", modelo, "| limiar =", limiar, "\n\n")

# cache estagio 1 e tokens de consulta
rks <- lapply(setNames(dev, dev), function(q) estagio1(texto_de(q)))
qts <- lapply(setNames(dev, dev), function(q) prep(texto_de(q)))
rks_te <- lapply(setNames(teste, teste), function(q) estagio1(texto_de(q)))
qts_te <- lapply(setNames(teste, teste), function(q) prep(texto_de(q)))

ap_rerank <- function(rk, qt, grau, k, janela) {
  ranking <- rerank_prox(rk, qt, tokens, k, janela)
  metricas_ranking(ranking, grau, limiar)[["AP"]]
}

map_conjunto <- function(qs, rks_list, qts_list, k, janela) {
  mean(vapply(qs, function(q) {
    ap_rerank(rks_list[[q]], qts_list[[q]], grau_de(q), k, janela)
  }, numeric(1)))
}

ks_grid <- c(3L, 5L, 10L)
janelas <- c(2L, 3L, 5L)

map0_dev <- map_conjunto(dev, rks, qts, 0L, 3L)
cat(sprintf("MAP_dev estagio1 (k=0) = %.3f\n\n", map0_dev))

grade <- matrix(NA_real_, nrow = length(ks_grid), ncol = length(janelas),
                dimnames = list(paste0("k", ks_grid), paste0("janela", janelas)))
linhas_grade <- list()
linhas_grade[[1]] <- data.frame(
  conjunto = "dev", metodo = "estagio1", k = 0L, janela = NA_integer_, MAP = map0_dev
)

cat("--- grade MAP_dev (k x janela) ---\n")
for (ki in seq_along(ks_grid)) {
  for (wi in seq_along(janelas)) {
    m <- map_conjunto(dev, rks, qts, ks_grid[ki], janelas[wi])
    grade[ki, wi] <- m
    linhas_grade[[length(linhas_grade) + 1]] <- data.frame(
      conjunto = "dev", metodo = "rerank", k = ks_grid[ki],
      janela = janelas[wi], MAP = m
    )
  }
}
print(round(grade, 3))

# escolha: maior MAP_dev; empate -> menor k; empate -> janela 3 (teoria)
melhor_val <- max(grade)
cands <- which(abs(grade - melhor_val) < 1e-12, arr.ind = TRUE)
# ordena por k crescente, depois preferencia janela=3
ord <- order(ks_grid[cands[, 1]],
             abs(janelas[cands[, 2]] - 3L),
             janelas[cands[, 2]])
pick <- cands[ord[1], ]
k_esc <- ks_grid[pick[1]]
j_esc <- janelas[pick[2]]

# se o melhor nao supera o estagio 1, escolher k=0
if (melhor_val <= map0_dev + 1e-12) {
  k_esc <- 0L
  j_esc <- 3L
  cat("\nEscolha: NAO reordenar (nenhuma celula > MAP estagio1)\n")
} else {
  cat(sprintf("\nEscolha no DEV: rerank_k = %d | janela = %d | MAP_dev = %.3f (estagio1 = %.3f)\n",
              k_esc, j_esc, melhor_val, map0_dev))
}

# onde a escolha perde no dev
ap0 <- vapply(dev, function(q) ap_rerank(rks[[q]], qts[[q]], grau_de(q), 0L, 3L), numeric(1))
ap1 <- vapply(dev, function(q) ap_rerank(rks[[q]], qts[[q]], grau_de(q), k_esc, j_esc), numeric(1))
cat("\nAP por consulta (dev):\n")
print(round(rbind(estagio1 = ap0, rerank = ap1), 3))
perde <- names(ap0)[ap1 + 1e-12 < ap0]
cat("Perde vs estagio1 em:", if (length(perde)) paste(perde, collapse = " ") else "(nenhuma)", "\n")

# teste UMA vez
cat("\n--- MAP no teste (uma vez) ---\n")
map0_te <- map_conjunto(teste, rks_te, qts_te, 0L, 3L)
map1_te <- map_conjunto(teste, rks_te, qts_te, k_esc, j_esc)
cat(sprintf("MAP_teste estagio1 = %.3f\n", map0_te))
cat(sprintf("MAP_teste rerank   = %.3f  (k=%d, janela=%d)\n", map1_te, k_esc, j_esc))

linhas_grade[[length(linhas_grade) + 1]] <- data.frame(
  conjunto = "teste", metodo = "estagio1", k = 0L, janela = NA_integer_, MAP = map0_te
)
linhas_grade[[length(linhas_grade) + 1]] <- data.frame(
  conjunto = "teste", metodo = "rerank", k = k_esc, janela = j_esc, MAP = map1_te
)

out_grade <- file.path("05-julgamento", "csv", "08-rerank-map-grade.csv")
write.csv(do.call(rbind, linhas_grade), out_grade, row.names = FALSE, fileEncoding = "UTF-8")
cat("Grade salva em", out_grade, "\n")

# por consulta
linhas_q <- list()
for (conj in list(
  list(nome = "dev", qs = dev, rks = rks, qts = qts),
  list(nome = "teste", qs = teste, rks = rks_te, qts = qts_te)
)) {
  for (qid in conj$qs) {
    grau <- grau_de(qid)
    rk <- conj$rks[[qid]]
    qt <- conj$qts[[qid]]
    r0 <- names(rk)
    r1 <- rerank_prox(rk, qt, tokens, k_esc, j_esc)
    m0 <- metricas_ranking(r0, grau, limiar)
    m1 <- metricas_ranking(r1, grau, limiar)
    linhas_q[[length(linhas_q) + 1]] <- data.frame(
      conjunto = conj$nome, consulta = qid, R = sum(grau >= limiar),
      n_termos = length(qt),
      AP_estagio1 = m0[["AP"]], AP_rerank = m1[["AP"]],
      nDCGg_estagio1 = m0[["nDCG_grad"]], nDCGg_rerank = m1[["nDCG_grad"]],
      top5_estagio1 = paste(r0[1:5], collapse = " "),
      top5_rerank = paste(r1[1:5], collapse = " "),
      stringsAsFactors = FALSE
    )
  }
}
tab_q <- do.call(rbind, linhas_q)
out_q <- file.path("05-julgamento", "csv", "08-rerank-por-consulta.csv")
write.csv(tab_q, out_q, row.names = FALSE, fileEncoding = "UTF-8")
cat("Por consulta salvo em", out_q, "\n")
cat("\nTabela (escolha k=", k_esc, ", janela=", j_esc, "):\n", sep = "")
print(within(tab_q, {
  AP_estagio1 <- round(AP_estagio1, 3)
  AP_rerank <- round(AP_rerank, 3)
}), row.names = FALSE)

## ============================================================
## Grava config.R (mantem Aula 07 + adiciona Aula 08)
## ============================================================
cfg_path <- "config.R"
cfg_txt <- paste0(
  "# =============================================================\n",
  "# config.R - decisoes do motor · Team Shannon · PI III\n",
  "# Atualizado por 08-retrieve-rerank.R (Aula 08)\n",
  "# =============================================================\n",
  "\n",
  "# Modelo de ranqueamento - estagio 1 (Aula 07)\n",
  "# \"bm25\" | \"lsa\" | \"hibrido\" (RRF de BM25 + LSA)\n",
  "modelo  <- \"", modelo, "\"\n",
  "lsa_k   <- ", as.integer(lsa_k), "L\n",
  "rrf_c   <- ", rrf_c, "\n",
  "\n",
  "# Avaliacao (Aula 05b)\n",
  "limiar  <- ", as.integer(limiar), "L   # grau >= limiar conta como relevante binario\n",
  "\n",
  "# Split (sem coluna conjunto nas necessidades)\n",
  "consultas_dev   <- c(", paste0("\"", consultas_dev, "\"", collapse = ", "), ")\n",
  "consultas_teste <- c(", paste0("\"", consultas_teste, "\"", collapse = ", "), ")\n",
  "\n",
  "# --- Aula 08: reordenacao (proximidade ordenada) ---\n",
  "rerank_k <- ", as.integer(k_esc), "L   # quantos do topo reordenar (0 = nao)\n",
  "janela   <- ", as.integer(j_esc), "L   # distancia maxima da proximidade\n",
  "\n",
  "# Numeros da escolha Aula 08 (nao retocar apos ver o teste)\n",
  "# MAP_dev_estagio1 = ", sprintf("%.4f", map0_dev), "\n",
  "# MAP_dev_rerank   = ", sprintf("%.4f", if (k_esc == 0) map0_dev else melhor_val), "\n",
  "# MAP_teste_estagio1 = ", sprintf("%.4f", map0_te), "\n",
  "# MAP_teste_rerank   = ", sprintf("%.4f", map1_te), "\n"
)
writeLines(cfg_txt, cfg_path, useBytes = FALSE)
cat("\nconfig.R atualizado:", cfg_path, "\n")
cat("modelo =", modelo, "| rerank_k =", k_esc, "| janela =", j_esc, "\n")
cat("OK\n")

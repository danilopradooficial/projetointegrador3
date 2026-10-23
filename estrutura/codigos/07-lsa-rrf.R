# =============================================================
# PI III - Motor de Busca - Atividade 07 / Aula 07 (9a entrega)
# Fatec Rubens Lara - Ciencia de Dados · Team Shannon
# Vetores densos pela SVD (LSA) e fusao de rankings (RRF)
# =============================================================
# Parte A - exemplo canonico dos slides (conferencia dos numeros)
# Parte B - nosso corpus (122 frases): top-5 BM25 x LSA x RRF
#           nas 3 perguntas do projeto, lendo os textos
# Parte C - MAP no dev (escolhe k/modelo) e uma vez no teste;
#           grava config.R com modelo, lsa_k, rrf_c
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
    P_at_3 = if (length(precisao) >= 3) precisao[[3]] else NA_real_,
    AP = ap,
    MRR = if (length(pos1)) 1 / pos1[[1]] else 0,
    nDCG_bin = if (sum(rel) > 0) dcg(rel) / dcg(sort(rel, decreasing = TRUE)) else NA_real_,
    nDCG_grad = if (sum(g) > 0) dcg(g) / dcg(sort(g, decreasing = TRUE)) else NA_real_
  )
}

# LSA: W ~= Uk Sk Vk'; docs em Dk = Vk Sk; consulta qk = t(Uk) %*% q0
lsa_fit <- function(w, k) {
  k <- min(k, min(dim(w)) - 1L)
  s <- svd(w)
  Uk <- s$u[, 1:k, drop = FALSE]
  Sk <- s$d[1:k]
  Dk <- s$v[, 1:k, drop = FALSE] %*% diag(Sk, nrow = k)
  rownames(Dk) <- colnames(w)
  list(Uk = Uk, Sk = Sk, Dk = Dk, k = k, energia = sum(Sk^2) / sum(s$d^2))
}

rank_lsa <- function(q0, fit) {
  qk <- as.numeric(t(fit$Uk) %*% q0)
  scores <- apply(fit$Dk, 1, function(d) cosseno(qk, d))
  sort(scores, decreasing = TRUE)
}

# RRF: soma 1/(c + posicao) sobre varios rankings (nomes = ids)
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
cat("=== PARTE A - LSA + RRF canonico (slides) ===\n")

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
tok <- function(x) unlist(strsplit(tolower(x), "\\s+"))
tokens_a <- lapply(docs_a, tok)
vocab_a <- sort(unique(unlist(tokens_a)))
tf_a <- sapply(tokens_a, function(t) as.integer(table(factor(t, levels = vocab_a))))
rownames(tf_a) <- vocab_a
idf_a <- log(ncol(tf_a) / rowSums(tf_a > 0))
w_a <- tf_a * idf_a

s_a <- svd(w_a)
energia_a <- cumsum(s_a$d^2) / sum(s_a$d^2)
cat("Energia acumulada (k=1..8):\n")
print(round(energia_a, 3))
cat("k=2 guarda", round(100 * energia_a[2], 1), "% da energia\n")

grau_a <- c(d1 = 1, d2 = 2, d3 = 2, d4 = 0, d5 = 0, d6 = 1, d7 = 0, d8 = 0)
q0_a <- as.integer(table(factor(tok("modelo de recuperacao"), levels = vocab_a))) * idf_a

# BM25 nos 8 docs (mesma formula Robertson)
N_a <- ncol(tf_a); dl_a <- colSums(tf_a); avgdl_a <- mean(dl_a)
df_a <- rowSums(tf_a > 0)
idf_bm_a <- log((N_a - df_a + 0.5) / (df_a + 0.5) + 1)
rank_bm25_a <- function(texto) {
  termos <- intersect(tok(texto), vocab_a)
  s <- setNames(rep(0, N_a), names(docs_a))
  for (t in termos) {
    f <- tf_a[t, ]
    K <- 1.2 * (1 - 0.75 + 0.75 * dl_a / avgdl_a)
    s <- s + idf_bm_a[[t]] * f * (1.2 + 1) / (f + K)
  }
  sort(s, decreasing = TRUE)
}
rank_cos_a <- function(q) {
  sort(apply(w_a, 2, function(d) cosseno(q, d)), decreasing = TRUE)
}

bm_a <- rank_bm25_a("modelo de recuperacao")
cos_a <- rank_cos_a(q0_a)
fit2 <- lsa_fit(w_a, 2)
lsa2 <- rank_lsa(q0_a, fit2)
rrf_a <- rrf(bm_a, lsa2, c = 60)

cat("\nRanking BM25:", paste(names(bm_a), collapse = " "), "\n")
cat("Ranking LSA k=2:", paste(names(lsa2), collapse = " "), "\n")
cat("Ranking RRF:", paste(names(rrf_a), collapse = " "), "\n")
cat("Scores LSA k=2:\n"); print(round(lsa2, 3))

cat("\nMetricas (limiar grau >= 2):\n")
print(round(rbind(
  bm25 = metricas_ranking(names(bm_a), grau_a),
  cosseno = metricas_ranking(names(cos_a), grau_a),
  lsa_k2 = metricas_ranking(names(lsa2), grau_a),
  rrf = metricas_ranking(names(rrf_a), grau_a)
), 3))

cat("\nLSA com k=2,3,4 (AP):\n")
for (kk in 2:4) {
  fk <- lsa_fit(w_a, kk)
  rk <- rank_lsa(q0_a, fk)
  cat(sprintf("  k=%d AP=%.3f energia=%.1f%% top=%s\n", kk,
              metricas_ranking(names(rk), grau_a)[["AP"]],
              100 * fk$energia, paste(names(rk)[1:4], collapse = " ")))
}
cat("\n")

## ============================================================
## Nosso corpus (frases dN.k)
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

svd_full <- svd(w)
energia_c <- cumsum(svd_full$d^2) / sum(svd_full$d^2)
cat("=== Corpus Team Shannon ===\n")
cat("Frases:", N, "| vocab:", length(vocab),
    "| rank SVD:", length(svd_full$d), "\n")
cat("Energia: k=10", round(100 * energia_c[min(10, length(energia_c))], 1),
    "% | k=20", round(100 * energia_c[min(20, length(energia_c))], 1),
    "% | k=50", round(100 * energia_c[min(50, length(energia_c))], 1),
    "% | k=80", round(100 * energia_c[min(80, length(energia_c))], 1), "%\n\n")

# cache de fits LSA por k (evita recomputar SVD)
fits <- list()
get_fit <- function(k) {
  key <- as.character(k)
  if (is.null(fits[[key]])) fits[[key]] <<- lsa_fit(w, k)
  fits[[key]]
}

trecho <- function(id, n = 90) {
  t <- docs[[id]]
  if (nchar(t) > n) paste0(substr(t, 1, n), "...") else t
}

## ============================================================
## PARTE B - top-5 nas 3 perguntas do projeto
## ============================================================
cat("=== PARTE B - top-5 BM25 x LSA x RRF (nosso corpus) ===\n")

# k de trabalho para a leitura qualitativa (depois Parte C pode escolher outro)
k_leitura <- 20L
fit_b <- get_fit(k_leitura)
cat("LSA com k =", fit_b$k, "(energia", round(100 * fit_b$energia, 1), "%)\n")

perguntas <- list(
  q_local = list(
    qid = "q15",
    pergunta = "Onde fica o Porto de Santos?",
    texto = "localizacao porto santos guaruja cubatao"
  ),
  q_aps = list(
    qid = "q02",
    pergunta = "Quem administra o porto hoje?",
    texto = "quem administra porto santos autoridade"
  ),
  q_fundador = list(
    qid = "q04",
    pergunta = "Quem foi Francisco de Paula Ribeiro e qual a ligacao com o porto?",
    texto = "francisco de paula ribeiro porto"
  )
)

linhas_top5 <- list()
for (cq in names(perguntas)) {
  tq <- perguntas[[cq]]
  bm <- rank_bm25(tq$texto)
  ls <- rank_lsa(consulta_vetor(tq$texto), fit_b)
  hy <- rrf(bm, ls, c = 60)

  cat("\n------------------------------------------------------------\n")
  cat(cq, "-", tq$pergunta, "\n")
  cat("Consulta:", tq$texto, "\n\n")

  for (metodo in c("bm25", "lsa", "rrf")) {
    r <- switch(metodo, bm25 = bm, lsa = ls, rrf = hy)
    cat(sprintf("--- %s (top-5) ---\n", metodo))
    for (i in 1:5) {
      id <- names(r)[i]
      cat(sprintf("  %d. %-6s %.4f  %s\n", i, id, r[[i]], trecho(id)))
      linhas_top5[[length(linhas_top5) + 1]] <- data.frame(
        consulta = cq, qid = tq$qid, metodo = metodo, pos = i,
        frase = id, score = round(unname(r[i]), 4),
        texto = trecho(id, 120), stringsAsFactors = FALSE
      )
    }
  }
}

out_top5 <- file.path("05-julgamento", "csv", "07-lsa-top5.csv")
write.csv(do.call(rbind, linhas_top5), out_top5, row.names = FALSE, fileEncoding = "UTF-8")
cat("\nTop-5 salvo em", out_top5, "\n\n")

## ============================================================
## PARTE C - MAP no dev (escolhe) e no teste (uma vez)
## ============================================================
cat("=== PARTE C - MAP BM25 / LSA(k) / RRF ===\n")

qrels <- read.csv(file.path("05-julgamento", "csv", "05-qrels.csv"),
                  stringsAsFactors = FALSE, fileEncoding = "UTF-8")
need <- read.csv(file.path("05-julgamento", "csv", "05-necessidades.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8")

limiar <- 2L
# split fixo (plano): sem coluna conjunto nas necessidades
dev_ids   <- c("q01", "q03", "q05", "q06", "q09", "q10", "q13")
teste_ids <- c("q04", "q07", "q11", "q15")
ks <- c(10L, 20L, 50L, 80L)
rrf_c <- 60

grau_de <- function(qid) {
  s <- qrels[qrels$consulta == qid, ]
  g <- setNames(as.numeric(s$grau), s$documento)
  g[!duplicated(names(g), fromLast = TRUE)]
}

texto_de <- function(qid) {
  t <- need$texto_consulta[need$consulta == qid]
  if (!length(t) || !nzchar(t[[1]])) NA_character_ else t[[1]]
}

# so consultas com R > 0 no limiar
com_R <- function(qids) {
  Filter(function(q) sum(grau_de(q) >= limiar) > 0, qids)
}
dev   <- com_R(dev_ids)
teste <- com_R(teste_ids)
cat("dev  :", paste(dev, collapse = ", "), "\n")
cat("teste:", paste(teste, collapse = ", "), "\n")
cat("ks   :", paste(ks, collapse = ", "), "| rrf_c =", rrf_c, "\n\n")

ap_consulta <- function(qid, metodo, k = NA_integer_) {
  grau <- grau_de(qid)
  texto <- texto_de(qid)
  bm <- rank_bm25(texto)
  if (metodo == "bm25") {
    r <- bm
  } else if (metodo == "lsa") {
    r <- rank_lsa(consulta_vetor(texto), get_fit(k))
  } else if (metodo == "rrf") {
    r <- rrf(bm, rank_lsa(consulta_vetor(texto), get_fit(k)), c = rrf_c)
  } else stop("metodo desconhecido")
  metricas_ranking(names(r), grau, limiar)[["AP"]]
}

map_conjunto <- function(qids, metodo, k = NA_integer_) {
  aps <- vapply(qids, function(q) ap_consulta(q, metodo, k), numeric(1))
  mean(aps)
}

# --- varredura no DEV ---
cat("--- MAP no desenvolvimento ---\n")
linhas_map <- list()
map_bm25_dev <- map_conjunto(dev, "bm25")
linhas_map[[1]] <- data.frame(conjunto = "dev", metodo = "bm25", k = NA,
                              MAP = map_bm25_dev)
cat(sprintf("BM25          MAP_dev = %.3f\n", map_bm25_dev))

map_lsa_dev <- setNames(numeric(length(ks)), paste0("k", ks))
map_rrf_dev <- setNames(numeric(length(ks)), paste0("k", ks))
for (k in ks) {
  ml <- map_conjunto(dev, "lsa", k)
  mr <- map_conjunto(dev, "rrf", k)
  map_lsa_dev[[paste0("k", k)]] <- ml
  map_rrf_dev[[paste0("k", k)]] <- mr
  linhas_map[[length(linhas_map) + 1]] <- data.frame(
    conjunto = "dev", metodo = "lsa", k = k, MAP = ml)
  linhas_map[[length(linhas_map) + 1]] <- data.frame(
    conjunto = "dev", metodo = "rrf", k = k, MAP = mr)
  cat(sprintf("LSA k=%-2d      MAP_dev = %.3f\n", k, ml))
  cat(sprintf("RRF(BM25,LSA) k=%-2d MAP_dev = %.3f\n", k, mr))
}

# escolha: maior MAP_dev entre bm25, melhor LSA, melhor RRF
cand <- c(
  bm25 = map_bm25_dev,
  setNames(map_lsa_dev, paste0("lsa_", names(map_lsa_dev))),
  setNames(map_rrf_dev, paste0("rrf_", names(map_rrf_dev)))
)
melhor <- names(cand)[which.max(cand)]
if (melhor == "bm25") {
  modelo_escolhido <- "bm25"
  lsa_k_escolhido <- as.integer(ks[which.max(map_lsa_dev)])  # registra k visto mesmo assim
} else if (startsWith(melhor, "lsa_")) {
  modelo_escolhido <- "lsa"
  lsa_k_escolhido <- as.integer(sub("lsa_k", "", melhor))
} else {
  modelo_escolhido <- "hibrido"
  lsa_k_escolhido <- as.integer(sub("rrf_k", "", melhor))
}

cat(sprintf("\nEscolha no DEV: modelo = '%s' | lsa_k = %d | rrf_c = %d | MAP_dev = %.3f\n",
            modelo_escolhido, lsa_k_escolhido, rrf_c, max(cand)))

# --- teste UMA vez ---
cat("\n--- MAP no teste (uma vez, sem retocar k) ---\n")
map_bm25_te <- map_conjunto(teste, "bm25")
map_lsa_te  <- map_conjunto(teste, "lsa", lsa_k_escolhido)
map_rrf_te  <- map_conjunto(teste, "rrf", lsa_k_escolhido)
linhas_map[[length(linhas_map) + 1]] <- data.frame(
  conjunto = "teste", metodo = "bm25", k = NA, MAP = map_bm25_te)
linhas_map[[length(linhas_map) + 1]] <- data.frame(
  conjunto = "teste", metodo = "lsa", k = lsa_k_escolhido, MAP = map_lsa_te)
linhas_map[[length(linhas_map) + 1]] <- data.frame(
  conjunto = "teste", metodo = "rrf", k = lsa_k_escolhido, MAP = map_rrf_te)

cat(sprintf("BM25          MAP_teste = %.3f\n", map_bm25_te))
cat(sprintf("LSA k=%d      MAP_teste = %.3f\n", lsa_k_escolhido, map_lsa_te))
cat(sprintf("RRF k=%d      MAP_teste = %.3f\n", lsa_k_escolhido, map_rrf_te))

map_escolhido_te <- switch(modelo_escolhido,
  bm25 = map_bm25_te, lsa = map_lsa_te, hibrido = map_rrf_te)
cat(sprintf("Modelo escolhido ('%s') no teste: MAP = %.3f\n",
            modelo_escolhido, map_escolhido_te))

out_map <- file.path("05-julgamento", "csv", "07-lsa-map-por-k.csv")
write.csv(do.call(rbind, linhas_map), out_map, row.names = FALSE, fileEncoding = "UTF-8")
cat("MAP por k salvo em", out_map, "\n")

# por consulta no teste + no dev (com k escolhido)
linhas_q <- list()
for (conj in list(list(nome = "dev", qs = dev), list(nome = "teste", qs = teste))) {
  for (qid in conj$qs) {
    grau <- grau_de(qid)
    texto <- texto_de(qid)
    bm <- rank_bm25(texto)
    ls <- rank_lsa(consulta_vetor(texto), get_fit(lsa_k_escolhido))
    hy <- rrf(bm, ls, c = rrf_c)
    mb <- metricas_ranking(names(bm), grau, limiar)
    ml <- metricas_ranking(names(ls), grau, limiar)
    mh <- metricas_ranking(names(hy), grau, limiar)
    linhas_q[[length(linhas_q) + 1]] <- data.frame(
      conjunto = conj$nome, consulta = qid, R = sum(grau >= limiar),
      AP_bm25 = mb[["AP"]], AP_lsa = ml[["AP"]], AP_rrf = mh[["AP"]],
      nDCGg_bm25 = mb[["nDCG_grad"]], nDCGg_lsa = ml[["nDCG_grad"]],
      nDCGg_rrf = mh[["nDCG_grad"]],
      top3_bm25 = paste(names(bm)[1:3], collapse = " "),
      top3_lsa = paste(names(ls)[1:3], collapse = " "),
      top3_rrf = paste(names(hy)[1:3], collapse = " "),
      stringsAsFactors = FALSE
    )
  }
}
tab_q <- do.call(rbind, linhas_q)
out_q <- file.path("05-julgamento", "csv", "07-lsa-por-consulta.csv")
write.csv(tab_q, out_q, row.names = FALSE, fileEncoding = "UTF-8")
cat("Por consulta salvo em", out_q, "\n")
cat("\nTabela (k escolhido =", lsa_k_escolhido, "):\n")
print(within(tab_q, {
  AP_bm25 <- round(AP_bm25, 3); AP_lsa <- round(AP_lsa, 3); AP_rrf <- round(AP_rrf, 3)
}), row.names = FALSE)

## ============================================================
## Grava config.R com a decisao
## ============================================================
cfg_path <- "config.R"
cfg_txt <- paste0(
  "# =============================================================\n",
  "# config.R - decisoes do motor · Team Shannon · PI III\n",
  "# Gerado/atualizado por 07-lsa-rrf.R (Aula 07)\n",
  "# =============================================================\n",
  "\n",
  "# Modelo de ranqueamento em producao\n",
  "# \"bm25\" | \"lsa\" | \"hibrido\" (RRF de BM25 + LSA)\n",
  "modelo  <- \"", modelo_escolhido, "\"\n",
  "lsa_k   <- ", lsa_k_escolhido, "L\n",
  "rrf_c   <- ", rrf_c, "\n",
  "\n",
  "# Avaliacao (Aula 05b)\n",
  "limiar  <- ", limiar, "L   # grau >= limiar conta como relevante binario\n",
  "\n",
  "# Split Aula 07 (sem coluna conjunto nas necessidades)\n",
  "consultas_dev   <- c(", paste0("\"", dev, "\"", collapse = ", "), ")\n",
  "consultas_teste <- c(", paste0("\"", teste, "\"", collapse = ", "), ")\n",
  "\n",
  "# Numeros da escolha (nao retocar apos ver o teste)\n",
  "# MAP_dev_", modelo_escolhido, " = ", sprintf("%.4f", max(cand)), "\n",
  "# MAP_teste_", modelo_escolhido, " = ", sprintf("%.4f", map_escolhido_te), "\n",
  "# MAP_dev_bm25 = ", sprintf("%.4f", map_bm25_dev),
  " | MAP_teste_bm25 = ", sprintf("%.4f", map_bm25_te), "\n"
)
writeLines(cfg_txt, cfg_path, useBytes = FALSE)
cat("\nconfig.R atualizado:", cfg_path, "\n")
cat("modelo =", modelo_escolhido, "| lsa_k =", lsa_k_escolhido, "| rrf_c =", rrf_c, "\n")
cat("OK\n")

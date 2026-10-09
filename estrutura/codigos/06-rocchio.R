# =============================================================
# PI III - Motor de Busca - Atividade 06 / Aula 06 (8ª entrega)
# Fatec Rubens Lara - Ciência de Dados · Team Shannon
# Realimentação de relevância: Rocchio, expansão de consulta
# e pseudo-feedback (top-k)
# =============================================================
# Parte A  — exemplo canônico dos slides (conferência dos números)
# Parte A2 — a tarefa literal no corpus de 8 docs dos slides (conferência)
# Parte B  — a tarefa no NOSSO corpus (frases dN.k): as 3 perguntas do
#            projeto, feedback marcado pela equipe, antes/depois e PRF top-2
# Parte C  — nosso corpus + qrels da 05a, medido com as métricas da 05b
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
## Funções comuns
## ------------------------------------------------------------
cosseno <- function(a, b) {
  na <- sqrt(sum(a^2)); nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(0)
  sum(a * b) / (na * nb)
}

ranquear_vetor <- function(qv, w) {
  sort(apply(w, 2, function(d) cosseno(qv, d)), decreasing = TRUE)
}

# q_m = a*q0 + b*centroide(Dr) - g*centroide(Dnr)
# Dr ou Dnr vazios contribuem com zero.
rocchio <- function(q, w, Dr, Dnr = character(0),
                    a = 1, b = 0.75, g = 0.15, zerar_neg = FALSE) {
  cr <- if (length(Dr)) rowMeans(w[, Dr, drop = FALSE]) else 0
  cnr <- if (length(Dnr)) rowMeans(w[, Dnr, drop = FALSE]) else 0
  qm <- a * q + b * cr - g * cnr
  if (zerar_neg) qm[qm < 0] <- 0
  qm
}

# pseudo-feedback: os top-k da 1ª busca viram Dr, sem Dnr
pseudo_feedback <- function(q, w, k = 2, b = 0.75) {
  topk <- names(ranquear_vetor(q, w))[seq_len(k)]
  rocchio(q, w, Dr = topk, b = b)
}

dcg <- function(r) {
  r <- as.numeric(r)
  if (length(r) == 0) return(0)
  sum(r / log2(seq_along(r) + 1))
}

# mesmas métricas da 05b (P@3, AP, MRR, nDCG binário e graduado)
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

mostrar_ranking <- function(titulo, scores) {
  cat(titulo, "\n")
  print(round(scores, 3))
}

## ============================================================
## PARTE A — exemplo canônico dos slides
## ============================================================
cat("=== PARTE A — Rocchio canônico (slides 10–12) ===\n")

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
tok <- function(x) unlist(strsplit(tolower(x), "\\s+"))
tokens <- lapply(docs, tok)
vocab <- sort(unique(unlist(tokens)))
tf <- sapply(tokens, function(t) as.integer(table(factor(t, levels = vocab))))
rownames(tf) <- vocab
idf <- log(ncol(tf) / rowSums(tf > 0))
w <- tf * idf

vetor_consulta <- function(texto) {
  qv <- as.integer(table(factor(tok(texto), levels = vocab))) * idf
  names(qv) <- vocab
  qv
}

# gabarito da Aula 05 (o mesmo da Parte A da 05b)
grau_aula <- c(d1 = 1, d2 = 2, d3 = 2, d4 = 0, d5 = 0, d6 = 1, d7 = 0, d8 = 0)

qw <- vetor_consulta("modelo de recuperacao")
base <- ranquear_vetor(qw, w)
mostrar_ranking("Ranking base (cosseno) — 'modelo de recuperacao':", base)

qm <- rocchio(qw, w, Dr = c("d2", "d3"), Dnr = "d4")
cat("\nTermos de maior peso em q_m:\n")
print(round(sort(qm, decreasing = TRUE)[1:6], 3))
cat("Termos com peso em q0:", sum(qw != 0), "| em q_m:", sum(qm != 0),
    "| negativos:", paste(names(qm)[qm < 0], collapse = ", "), "\n\n")

novo <- ranquear_vetor(qm, w)
mostrar_ranking("Novo ranking após o feedback (Dr = d2, d3; Dnr = d4):", novo)

qm0 <- rocchio(qw, w, Dr = c("d2", "d3"), Dnr = "d4", zerar_neg = TRUE)
mostrar_ranking("\nVariante com pesos negativos zerados (passo 5 opcional):",
                ranquear_vetor(qm0, w))

cat("\nMétricas no gabarito da aula (limiar grau >= 2):\n")
print(round(rbind(
  base = metricas_ranking(names(base), grau_aula),
  rocchio = metricas_ranking(names(novo), grau_aula)
), 3))
cat("(Ressalva: d2, d3 e d4 foram usados como feedback e entram na medição — otimista.)\n\n")

## ============================================================
## PARTE A2 — a tarefa literal no corpus de 8 docs (conferência)
## ============================================================
cat("=== PARTE A2 — tarefa no corpus dos slides: consulta própria + pseudo-feedback ===\n")

# Tarefa 2: consulta escolhida pela equipe; marcamos 2 relevantes e 1 não relevante.
# Necessidade: "como o motor encontra documentos para uma busca".
consulta_b <- "busca de documentos"
Dr_b <- c("d5", "d1")    # índice invertido; recuperação ordena documentos
Dnr_b <- "d6"            # embeddings de palavras: fala de documentos, não de busca

qb <- vetor_consulta(consulta_b)
base_b <- ranquear_vetor(qb, w)
qm_b <- rocchio(qb, w, Dr = Dr_b, Dnr = Dnr_b)
novo_b <- ranquear_vetor(qm_b, w)

mostrar_ranking(sprintf("Ranking base — '%s':", consulta_b), base_b)
cat("\nTermos de maior peso em q_m:\n")
print(round(sort(qm_b, decreasing = TRUE)[1:6], 3))
mostrar_ranking(sprintf("\nApós Rocchio (Dr = %s; Dnr = %s):",
                        paste(Dr_b, collapse = ", "), Dnr_b), novo_b)

cat("\nPosição antes -> depois:\n")
pos <- data.frame(
  doc = names(docs),
  antes = match(names(docs), names(base_b)),
  depois = match(names(docs), names(novo_b))
)
print(pos[order(pos$depois), ], row.names = FALSE)

# Tarefa 3: pseudo-feedback com os top-2, nas duas consultas
cat("\n--- Pseudo-feedback (top-2 viram Dr, sem Dnr) ---\n")
for (cq in c("modelo de recuperacao", consulta_b)) {
  q0 <- vetor_consulta(cq)
  b0 <- ranquear_vetor(q0, w)
  top2 <- names(b0)[1:2]
  qp <- pseudo_feedback(q0, w, k = 2)
  prf <- ranquear_vetor(qp, w)
  novos <- setdiff(names(qp)[qp > 0], names(q0)[q0 > 0])
  cat(sprintf("\nConsulta '%s' | top-2 assumidos relevantes: %s\n",
              cq, paste(top2, collapse = ", ")))
  cat("Termos que entraram por expansão:", paste(novos, collapse = ", "), "\n")
  cat("base:", paste(names(b0), collapse = " "), "\n")
  cat("PRF :", paste(names(prf), collapse = " "), "\n")
  if (cq == "modelo de recuperacao") {
    print(round(rbind(
      base = metricas_ranking(names(b0), grau_aula),
      prf_top2 = metricas_ranking(names(prf), grau_aula)
    ), 3))
  }
}
cat("\n")

## ============================================================
## Nosso corpus (frases dN.k): mesmo pré-processamento da 05b
## ============================================================

source("01a-ler-frases.R")
docs_c <- carregar_docs_canonico(file.path("..", "corpus"))
docs_c <- docs_c[grepl("^d[0-9]+\\.[0-9]+$", names(docs_c))]

limpar <- function(x) {
  x <- tolower(x)
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  x[is.na(x)] <- ""
  x <- gsub("[^a-z0-9 ]", " ", x)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

# mesma lista da 05b
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

tokens_c <- lapply(docs_c, prep)
vocab_c <- sort(unique(unlist(tokens_c)))
tf_c <- sapply(tokens_c, function(t) as.integer(table(factor(t, levels = vocab_c))))
rownames(tf_c) <- vocab_c
idf_c <- log(ncol(tf_c) / rowSums(tf_c > 0))
w_c <- tf_c * idf_c

consulta_vetor_c <- function(texto) {
  qv <- as.integer(table(factor(prep(texto), levels = vocab_c))) * idf_c
  names(qv) <- vocab_c
  qv
}

## ============================================================
## PARTE B — a tarefa no nosso corpus: as 3 perguntas do projeto
## ============================================================
cat("=== PARTE B — tarefa no corpus Team Shannon (", ncol(w_c), " frases) ===\n", sep = "")

# A equipe leu o top-5 da 1ª busca e marcou relevantes (Dr) e não relevantes (Dnr).
# 'acompanhar' = frases que respondem à pergunta, para ver onde elas vão parar.
tarefa <- list(
  q_local = list(
    pergunta = "Onde fica o Porto de Santos?",
    texto = "localizacao porto santos guaruja cubatao",
    Dr = c("d1.1", "d1.61"),       # municípios; margens do estuário
    Dnr = c("d1.30", "d1.52"),     # vila da usina de Itatinga; incêndio da Cargill
    acompanhar = c("d1.1", "d1.61", "d1.83", "d1.82")
  ),
  q_aps = list(
    pergunta = "Quem administra o porto hoje?",
    texto = "quem administra porto santos autoridade",
    Dr = c("d2.4"),                # "Desde então, a APS administra..."
    Dnr = c("d1.36", "d2.9"),      # mesma frase nas duas páginas: define Porto Organizado
    acompanhar = c("d2.4", "d2.2", "d1.43", "d2.16")
  ),
  q_fundador = list(
    pergunta = "Quem foi Francisco de Paula Ribeiro e qual a ligação com o porto?",
    texto = "francisco de paula ribeiro porto",
    Dr = c("d3.1", "d1.17"),       # quem ele foi; superintendente da Docas
    Dnr = c("d3.4", "d3.5"),       # família, sem o porto
    acompanhar = c("d3.1", "d1.17", "d3.2", "d3.4")
  )
)

trecho <- function(id, n = 80) {
  t <- docs_c[[id]]
  if (nchar(t) > n) paste0(substr(t, 1, n), "...") else t
}
top_txt <- function(r, k = 8) paste(sprintf("%s(%.3f)", names(r)[1:k], r[1:k]), collapse = " ")

saida_b <- list()
for (cq in names(tarefa)) {
  tq <- tarefa[[cq]]
  q0 <- consulta_vetor_c(tq$texto)
  base <- ranquear_vetor(q0, w_c)
  qm <- rocchio(q0, w_c, Dr = tq$Dr, Dnr = tq$Dnr)
  roc <- ranquear_vetor(qm, w_c)
  top2 <- names(base)[1:2]
  qp <- pseudo_feedback(q0, w_c, k = 2)
  prf <- ranquear_vetor(qp, w_c)

  cat("\n------------------------------------------------------------\n")
  cat(sprintf("%s  %s\nConsulta digitada: '%s'\n", cq, tq$pergunta, tq$texto))
  cat("Relevantes marcados (Dr):\n");     for (d in tq$Dr)  cat(sprintf("  + %-6s %s\n", d, trecho(d)))
  cat("Não relevantes marcados (Dnr):\n"); for (d in tq$Dnr) cat(sprintf("  - %-6s %s\n", d, trecho(d)))

  novos <- setdiff(names(qm)[qm > 0], names(q0)[q0 > 0])
  novos <- novos[order(qm[novos], decreasing = TRUE)]
  cat(sprintf("Termos com peso: q0 = %d | q_m = %d (%d negativos)\n",
              sum(q0 != 0), sum(qm != 0), sum(qm < 0)))
  cat("Expansão (maiores pesos novos):",
      paste(sprintf("%s %.2f", novos[1:8], qm[novos[1:8]]), collapse = ", "), "\n")

  cat("\nbase    :", top_txt(base), "\n")
  cat("Rocchio :", top_txt(roc), "\n")
  cat(sprintf("PRF top-2 (assume %s relevantes):\n          %s\n",
              paste(top2, collapse = ", "), top_txt(prf)))

  pos <- data.frame(
    frase = tq$acompanhar,
    base = match(tq$acompanhar, names(base)),
    rocchio = match(tq$acompanhar, names(roc)),
    prf = match(tq$acompanhar, names(prf)),
    texto = vapply(tq$acompanhar, trecho, "", n = 60)
  )
  cat("\nPosição das frases que respondem (de", ncol(w_c), "):\n")
  print(pos, row.names = FALSE)

  for (m in c("base", "rocchio", "prf")) {
    r <- switch(m, base = base, rocchio = roc, prf = prf)
    saida_b[[length(saida_b) + 1]] <- data.frame(
      consulta = cq, metodo = m, pos = 1:10, frase = names(r)[1:10],
      score = round(unname(r[1:10]), 4))
  }
}
out_b <- file.path("05-julgamento", "csv", "06-rocchio-tarefa-corpus.csv")
write.csv(do.call(rbind, saida_b), out_b, row.names = FALSE, fileEncoding = "UTF-8")
cat("\nRankings (top-10) salvos em", out_b, "\n\n")

## ============================================================
## PARTE C — Rocchio e PRF nas consultas julgadas (qrels da 05a)
## ============================================================
cat("=== PARTE C — Rocchio e PRF no gabarito Team Shannon ===\n")

qrels <- read.csv(file.path("05-julgamento", "csv", "05-qrels.csv"),
                  stringsAsFactors = FALSE, fileEncoding = "UTF-8")
need <- read.csv(file.path("05-julgamento", "csv", "05-necessidades.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8")

limiar <- 2L
k_user <- 5L   # o "usuário" olha os top-5 da 1ª busca e marca o que foi julgado
k_prf <- 2L    # pseudo-feedback: top-2 da tarefa
cat("Frases:", ncol(w_c), "| vocab:", nrow(w_c), "| limiar grau >=", limiar,
    "| usuário olha top-", k_user, " | PRF top-", k_prf, "\n\n", sep = "")

linhas <- list()
for (qid in sort(unique(qrels$consulta))) {
  lq <- qrels[qrels$consulta == qid, ]
  grau <- setNames(as.numeric(lq$grau), lq$documento)
  grau <- grau[!duplicated(names(grau), fromLast = TRUE)]
  if (sum(grau >= limiar) == 0) next
  texto_q <- need$texto_consulta[need$consulta == qid][[1]]

  q0 <- consulta_vetor_c(texto_q)
  base_c <- names(ranquear_vetor(q0, w_c))

  # PRF: sem usuário, avaliado na coleção inteira
  prf_c <- names(ranquear_vetor(pseudo_feedback(q0, w_c, k = k_prf), w_c))

  # Rocchio com usuário simulado pelo gabarito, só sobre o que ele viu (top-5)
  vistos <- base_c[seq_len(k_user)]
  julgados <- vistos[vistos %in% names(grau)]
  Dr <- julgados[grau[julgados] >= limiar]
  Dnr <- julgados[grau[julgados] == 0]
  roc_c <- if (length(Dr)) names(ranquear_vetor(rocchio(q0, w_c, Dr, Dnr), w_c)) else base_c

  # coleção residual: tira o que o usuário já viu, para não premiar o óbvio
  resid <- function(r) r[!r %in% vistos]
  grau_res <- grau[!names(grau) %in% vistos]
  tem_res <- sum(grau_res >= limiar) > 0

  mb <- metricas_ranking(base_c, grau)
  mp <- metricas_ranking(prf_c, grau)
  mbr <- if (tem_res) metricas_ranking(resid(base_c), grau_res) else NA
  mrr <- if (tem_res) metricas_ranking(resid(roc_c), grau_res) else NA

  linhas[[qid]] <- data.frame(
    consulta = qid, R = sum(grau >= limiar),
    Dr = length(Dr), Dnr = length(Dnr),
    AP_base = mb[["AP"]], AP_prf = mp[["AP"]],
    nDCGg_base = mb[["nDCG_grad"]], nDCGg_prf = mp[["nDCG_grad"]],
    AP_res_base = if (tem_res) mbr[["AP"]] else NA_real_,
    AP_res_rocchio = if (tem_res) mrr[["AP"]] else NA_real_,
    top3_base = paste(base_c[1:3], collapse = " "),
    top3_prf = paste(prf_c[1:3], collapse = " "),
    stringsAsFactors = FALSE
  )
}

tab <- do.call(rbind, linhas)
num <- sapply(tab, is.numeric)
tab_print <- tab
tab_print[num] <- lapply(tab[num], round, 3)
print(tab_print, row.names = FALSE)

cat("\n=== Resumo ===\n")
cat(sprintf("MAP base     = %.3f | MAP PRF top-%d = %.3f  (n=%d, coleção inteira)\n",
            mean(tab$AP_base), k_prf, mean(tab$AP_prf), nrow(tab)))
cat(sprintf("PRF: melhora %d · piora %d · empate %d consultas (AP)\n",
            sum(tab$AP_prf > tab$AP_base + 1e-9),
            sum(tab$AP_prf < tab$AP_base - 1e-9),
            sum(abs(tab$AP_prf - tab$AP_base) <= 1e-9)))
com_fb <- tab[tab$Dr > 0 & !is.na(tab$AP_res_rocchio), ]
cat(sprintf("Rocchio (usuário, residual): %d consultas com Dr > 0 | MAP base = %.3f -> Rocchio = %.3f\n",
            nrow(com_fb), mean(com_fb$AP_res_base), mean(com_fb$AP_res_rocchio)))

out_csv <- file.path("05-julgamento", "csv", "06-rocchio-por-consulta.csv")
write.csv(tab, out_csv, row.names = FALSE, fileEncoding = "UTF-8")
cat("\nTabela salva em", out_csv, "\n")
cat("Ressalva: poucas consultas e pool parcial — diferença não é significância (Aula 16).\n")

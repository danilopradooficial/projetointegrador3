# =============================================================
# buscar.R — demonstração / auditoria senior (Team Shannon)
# 3 consultas × Booleano · TF-IDF · Cosseno · BM25 · julgamento
# Saída diagramada para terminal (entrega de meio de semestre)
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

## ======================== helpers de layout (ASCII, largura fixa) ========================
W <- 78L
hr <- function(ch = "=", n = W) cat(paste(rep(ch, n), collapse = ""), "\n", sep = "")
box_title <- function(titulo) {
  hr("=")
  cat(sprintf("  %s\n", titulo))
  hr("=")
}
section <- function(titulo) {
  cat("\n")
  hr("-")
  cat(sprintf("  >> %s\n", titulo))
  hr("-")
}
wrap_txt <- function(txt, width = 70L, prefix = "     ") {
  txt <- gsub("\\s+", " ", trimws(txt))
  if (!nzchar(txt)) return(invisible())
  words <- unlist(strsplit(txt, " ", fixed = TRUE))
  line <- prefix
  for (w in words) {
    if (nchar(line) + nchar(w) + 1L > width) {
      cat(line, "\n", sep = "")
      line <- paste0(prefix, w)
    } else {
      line <- if (line == prefix) paste0(prefix, w) else paste(line, w)
    }
  }
  if (nzchar(trimws(line))) cat(line, "\n", sep = "")
}

## Pad ASCII-only to exact width (evita desalinhamento com Unicode no Windows)
pad <- function(x, width, side = "left") {
  x <- ifelse(is.na(x), "-", as.character(x))
  x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
  x[is.na(x)] <- "-"
  x <- gsub("[^ -~]", "?", x)  # so ASCII imprimivel
  n <- nchar(x, type = "chars")
  pad_n <- pmax(0L, width - n)
  sp <- vapply(pad_n, function(k) paste(rep(" ", k), collapse = ""), character(1))
  if (side == "left") paste0(sp, x) else paste0(x, sp)
}
col <- function(..., widths, sep = " ") {
  vals <- list(...)
  stopifnot(length(vals) == length(widths))
  parts <- mapply(function(v, w) pad(v, w, "right"), vals, widths, SIMPLIFY = TRUE)
  # numeric-looking: right-align inside pad already right for labels;
  # for numbers we pass left-padded strings
  paste(parts, collapse = sep)
}
col_row <- function(vals, widths, align = NULL) {
  if (is.null(align)) align <- rep("left", length(vals))
  parts <- character(length(vals))
  for (i in seq_along(vals)) {
    side <- if (align[i] == "right") "left" else "right"  # pad side opposite to align
    parts[i] <- pad(vals[i], widths[i], side = side)
  }
  paste0("  ", paste(parts, collapse = "  "))
}
print_table <- function(headers, rows, widths, align = NULL) {
  cat(col_row(headers, widths, align), "\n", sep = "")
  sep_vals <- vapply(widths, function(w) paste(rep("-", w), collapse = ""), character(1))
  cat(col_row(sep_vals, widths, rep("left", length(widths))), "\n", sep = "")
  for (r in rows) cat(col_row(r, widths, align), "\n", sep = "")
}
barra <- function(x, max_x, width = 12L) {
  if (is.na(x) || max_x <= 0) return(paste(rep(".", width), collapse = ""))
  n <- max(0L, min(width, as.integer(round(width * x / max_x))))
  paste0(paste(rep("#", n), collapse = ""), paste(rep(".", width - n), collapse = ""))
}
fmt_ms <- function(ms) sprintf("%.0f", round(ms))
fmt_metric <- function(x, d = 3L) {
  if (length(x) == 0 || is.na(x)) return("   -")
  sprintf(paste0("%.", d, "f"), x)
}

## ======================== corpus ========================
raiz <- file.path("..", "..")
source(file.path(raiz, "estrutura", "codigos", "01a-ler-frases.R"))
docs_all <- carregar_docs_canonico(file.path(raiz, "estrutura", "corpus"))
docs <- docs_all[grepl("^d[0-9]+\\.[0-9]+$", names(docs_all))]
titulos_artigo <- c(
  d1 = "Porto de Santos (local / economia)",
  d2 = "Autoridade Portuaria (empresa publica)",
  d3 = "Francisco de Paula Ribeiro (fundador)"
)
artigo_de <- function(id) sub("\\..*$", "", id)

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
postings <- lapply(setNames(vocab, vocab), function(t) ids[tf[t, ] > 0])

## ======================== metodos ========================
busca_AND <- function(consulta) {
  termos <- prep(consulta)
  if (!length(termos) || !all(termos %in% names(postings))) return(character(0))
  Reduce(intersect, postings[termos])
}
busca_OR <- function(consulta) {
  termos <- prep(consulta)
  termos <- termos[termos %in% names(postings)]
  if (!length(termos)) return(character(0))
  unique(unlist(postings[termos], use.names = FALSE))
}
ranquear_tfidf <- function(consulta) {
  termos <- prep(consulta)
  scores <- sapply(ids, function(d) {
    s <- 0
    for (t in termos) if (t %in% vocab) s <- s + as.numeric(w_tfidf[t, d])
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
jaccard <- function(a, b) {
  a <- unique(a); b <- unique(b)
  if (!length(a) && !length(b)) return(1)
  length(intersect(a, b)) / length(union(a, b))
}
qualidade <- function(ranking_ids, grau, limiar = 2L) {
  if (!length(grau)) return(list(R = NA, P3 = NA, nDCG = NA, note = "sem qrels"))
  relevantes <- names(grau)[as.numeric(grau) >= limiar]
  R <- length(relevantes)
  if (R == 0) return(list(R = 0, P3 = NA, nDCG = NA, note = "R=0 (limiar>=2)"))
  if (!length(ranking_ids)) return(list(R = R, P3 = 0, nDCG = 0, note = "ranking vazio"))
  rel <- as.integer(ranking_ids %in% relevantes)
  g <- as.numeric(grau[ranking_ids]); g[is.na(g)] <- 0
  precisao <- cumsum(rel) / seq_along(ranking_ids)
  p3 <- if (length(precisao) >= 3) precisao[[3]] else precisao[[length(precisao)]]
  ndcg <- if (sum(g) > 0) dcg(g) / dcg(sort(g, decreasing = TRUE)) else NA_real_
  list(R = R, P3 = p3, nDCG = ndcg, note = "")
}

## qrels
qrels_path <- file.path(raiz, "estrutura", "codigos", "05-julgamento", "csv", "05-qrels.csv")
qrels <- if (file.exists(qrels_path)) {
  read.csv(qrels_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
} else data.frame()

consultas <- c(
  q_local = "localizacao porto santos guarujá cubatão",
  q_aps = "quem administra porto santos autoridade",
  q_fundador = "francisco de paula ribeiro porto"
)
perguntas <- c(
  q_local = "Onde fica o Porto de Santos? (municipios / estuario)",
  q_aps = "Quem administra o Porto de Santos hoje (APS / autoridade)?",
  q_fundador = "Quem foi Francisco de Paula Ribeiro e qual a ligacao com o porto?"
)
eixos <- c(
  q_local = "LUGAR (Baixada Santista)",
  q_aps = "EMPRESA PUBLICA (Autoridade Portuaria)",
  q_fundador = "FUNDADOR (biografia / origem)"
)
qrels_map <- c(q_local = "q15", q_aps = "q02", q_fundador = "q04")

## ======================== CABECALHO ========================
box_title("TEAM SHANNON  |  Motor de busca - Porto de Santos")
cat("  Entrega de meio de semestre  |  script: buscar.R\n")
cat(sprintf("  Corpus: %d frases  |  vocab (stems PT): %d  |  avgdl: %.1f\n",
            N, length(vocab), avgdl))
cat("  Fontes: d1 Porto | d2 Autoridade Portuaria | d3 F. de Paula Ribeiro\n")
cat("  Metodos: AND | OR | TF-IDF | Cosseno | BM25 + graus qrels (Aula 05a)\n")
hr("=")

## contagem por artigo
n_por <- table(sapply(ids, artigo_de))
cat("\n  CARA DO CORPUS\n")
cw <- c(4L, 40L, 6L)
print_table(
  c("ID", "Artigo", "Frases"),
  list(
    c("d1", titulos_artigo[["d1"]], as.character(n_por[["d1"]])),
    c("d2", titulos_artigo[["d2"]], as.character(n_por[["d2"]])),
    c("d3", titulos_artigo[["d3"]], as.character(n_por[["d3"]])),
    c("", "TOTAL", as.character(N))
  ),
  widths = cw,
  align = c("left", "left", "right")
)

cat("\n  TRES PERGUNTAS DE TRABALHO\n")
cwq <- c(4L, 12L, 58L)
print_table(
  c("#", "ID", "Pergunta (o que o usuario quer saber)"),
  list(
    c("1", "q_local", perguntas[["q_local"]]),
    c("2", "q_aps", perguntas[["q_aps"]]),
    c("3", "q_fundador", perguntas[["q_fundador"]])
  ),
  widths = cwq,
  align = c("right", "left", "left")
)

resumo_global <- list()

## ======================== POR CONSULTA ========================
for (qi in seq_along(consultas)) {
  nome <- names(consultas)[qi]
  q <- consultas[[nome]]
  qid <- qrels_map[[nome]]
  stems <- prep(q)

  cat("\n\n")
  box_title(sprintf("CONSULTA %d/%d  |  %s", qi, length(consultas), nome))
  cat(sprintf("  Eixo     : %s\n", eixos[[nome]]))
  cat(sprintf("  Pergunta : %s\n", perguntas[[nome]]))
  cat(sprintf("  Digitado : %s\n", q))
  cat(sprintf("  Stems    : %s\n", paste(stems, collapse = " | ")))
  cat(sprintf("  Gabarito : %s (julgamento 05a)\n", qid))

  grau <- numeric(0)
  if (nrow(qrels)) {
    sub <- qrels[qrels$consulta == qid, ]
    if (nrow(sub)) {
      grau <- setNames(as.numeric(sub$grau), sub$documento)
      grau <- grau[!duplicated(names(grau), fromLast = TRUE)]
    }
  }
  if (length(grau)) {
    cat(sprintf("  Votos na pool: %d  |  grau 0/1/2 = %d / %d / %d\n",
                length(grau),
                sum(grau == 0), sum(grau == 1), sum(grau == 2)))
  } else {
    cat("  Votos na pool: (arquivo qrels ausente)\n")
  }

  ## --- timing + rankings ---
  t0 <- proc.time()[["elapsed"]]; and_ids <- busca_AND(q)
  ms_and <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; or_ids <- busca_OR(q)
  ms_or <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; r_tf <- ranquear_tfidf(q)
  ms_tf <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; r_cos <- ranquear_cosseno(q)
  ms_cos <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; r_bm <- ranquear_bm25(q)
  ms_bm <- (proc.time()[["elapsed"]] - t0) * 1000

  and_sc <- setNames(rep(1, length(and_ids)), and_ids)
  or_sc <- setNames(rep(1, length(or_ids)), or_ids)

  blocos <- list(
    list(nome = "AND",     sc = and_sc, ms = ms_and, tipo = "conjunto"),
    list(nome = "OR",      sc = or_sc,  ms = ms_or,  tipo = "conjunto"),
    list(nome = "TF-IDF",  sc = r_tf,   ms = ms_tf,  tipo = "ranking"),
    list(nome = "Cosseno", sc = r_cos,  ms = ms_cos, tipo = "ranking"),
    list(nome = "BM25",    sc = r_bm,   ms = ms_bm,  tipo = "ranking")
  )

  ## --- tabela comparativa (ASCII, colunas fixas) ---
  section("COMPARATIVO DE METODOS")
  cat("  Ranqueadores: P@3 / nDCG / MRR usam limiar grau>=2.\n")
  cat("  AND/OR: conjunto (sem ordem) -> metricas de ranking = '-'.\n\n")

  tw <- c(8L, 7L, 6L, 6L, 6L, 6L, 10L)
  ta <- c("left", "right", "right", "right", "right", "right", "left")
  rows_cmp <- list()
  top5_por <- list()

  for (b in blocos) {
    sc <- b$sc
    top_ids <- names(sc)[seq_len(min(5L, length(sc)))]
    if (b$tipo == "conjunto") top_ids <- sort(names(sc))[seq_len(min(5L, length(sc)))]
    top5_por[[b$nome]] <- top_ids

    if (b$tipo == "conjunto") {
      hits <- length(sc)
      p3 <- "-"; nd <- "-"; mrr_s <- "-"
      top1 <- if (!length(sc)) "(vazio)" else "conjunto"
      obs <- sprintf("hits=%d", hits)
    } else {
      qlt <- qualidade(top_ids, grau)
      hits <- "-"
      p3 <- fmt_metric(qlt$P3)
      nd <- fmt_metric(qlt$nDCG)
      rel_bin <- if (length(grau) && length(top_ids)) {
        as.integer(top_ids %in% names(grau)[grau >= 2])
      } else integer(0)
      mrr_v <- if (length(rel_bin) && any(rel_bin == 1)) 1 / which(rel_bin == 1)[1] else NA_real_
      mrr_s <- fmt_metric(mrr_v)
      top1 <- if (length(top_ids)) top_ids[[1]] else "(vazio)"
      obs <- if (nzchar(qlt$note)) qlt$note else ""
    }
    rows_cmp[[length(rows_cmp) + 1]] <- c(
      b$nome, fmt_ms(b$ms), as.character(hits), p3, nd, mrr_s, top1
    )
    if (nzchar(obs) && b$tipo == "ranking" && grepl("R=0", obs)) {
      ## guarda obs para rodape unico
    }
  }
  print_table(
    c("Metodo", "ms", "hits", "P@3", "nDCG", "MRR", "Top-1"),
    rows_cmp,
    widths = tw,
    align = ta
  )
  if (length(grau) && sum(grau >= 2) == 0) {
    cat("  Obs: nesta consulta R=0 (nenhum grau>=2 na pool) -> P@3/nDCG/MRR = '-'.\n")
  }
  cat("  Obs: AND/OR nao ranqueiam; coluna Top-1 fica 'conjunto' (so |hits| importa).\n")

  ## --- ranking detalhado dos tres ranqueadores ---
  section("RANKING DETALHADO (top-5) - TF-IDF | Cosseno | BM25")
  rw <- c(2L, 8L, 8L, 12L, 4L, 6L)
  ra <- c("right", "left", "right", "left", "right", "left")
  for (met in c("TF-IDF", "Cosseno", "BM25")) {
    sc <- if (met == "TF-IDF") r_tf else if (met == "Cosseno") r_cos else r_bm
    top <- sc[seq_len(min(5L, length(sc)))]
    max_s <- max(unname(top), na.rm = TRUE)
    cat(sprintf("\n  [%s]\n", met))
    rows_r <- lapply(seq_along(top), function(i) {
      id <- names(top)[i]
      g <- if (length(grau) && id %in% names(grau)) as.character(as.integer(grau[[id]])) else "-"
      c(as.character(i), id, sprintf("%.4f", unname(top[i])),
        barra(unname(top[i]), max_s), g, artigo_de(id))
    })
    print_table(c("#", "Doc", "Score", "Barra", "Grau", "Art."),
                rows_r, widths = rw, align = ra)
  }

  ## --- texto do vencedor (cosseno e BM25) ---
  section("QUALIDADE TEXTUAL - 1o colocado")
  for (par in list(
    list(lab = "Cosseno", id = names(r_cos)[1]),
    list(lab = "BM25",    id = names(r_bm)[1])
  )) {
    cat(sprintf("\n  (%s)  %s  |  %s\n",
                par$lab, par$id, titulos_artigo[[artigo_de(par$id)]]))
    wrap_txt(docs[[par$id]], width = 74L, prefix = "     ")
  }

  ## --- Booleano ---
  section("BOOLEANO (Aula 03) - conjunto, sem ordem de relevancia")
  cat(sprintf("  AND: %d documento(s)", length(and_ids)))
  if (length(and_ids)) {
    cat(" -> ", paste(head(sort(and_ids), 8), collapse = ", "))
    if (length(and_ids) > 8) cat(" ...")
  } else {
    cat(" -> (vazio: exige TODOS os stems no mesmo documento)")
  }
  cat("\n")
  cat(sprintf("  OR : %d documento(s)  (amostra: 8 primeiras IDs ordenadas)\n",
              length(or_ids)))
  if (length(or_ids)) {
    cat("       ", paste(head(sort(or_ids), 8), collapse = ", "))
    if (length(or_ids) > 8) cat(" ...")
    cat("\n")
  }

  ## --- overlap ---
  section("ACORDO ENTRE RANQUEADORES (Jaccard top-5)")
  jw <- c(18L, 6L, 14L)
  ja <- c("left", "right", "left")
  jrows <- list()
  for (p in list(c("Cosseno", "BM25"), c("Cosseno", "TF-IDF"), c("BM25", "TF-IDF"))) {
    j <- jaccard(top5_por[[p[1]]], top5_por[[p[2]]])
    jrows[[length(jrows) + 1]] <- c(
      sprintf("%s x %s", p[1], p[2]),
      sprintf("%.2f", j),
      barra(j, 1, 14)
    )
  }
  print_table(c("Par", "Jac", "Barra"), jrows, widths = jw, align = ja)
  comuns <- Reduce(intersect, list(top5_por[["Cosseno"]], top5_por[["BM25"]], top5_por[["TF-IDF"]]))
  cat(sprintf("  Intersecao dos 3 top-5: %s\n",
              if (length(comuns)) paste(comuns, collapse = ", ") else "(vazia)"))

  ## leitura rapida
  section("LEITURA RAPIDA (auditoria)")
  mesmo_top <- names(r_cos)[1] == names(r_bm)[1]
  cat(sprintf("  - Top-1 Cosseno vs BM25: %s\n",
              if (mesmo_top) paste0("IGUAL (", names(r_cos)[1], ")")
              else sprintf("DIFERENTE (cos=%s | bm25=%s)", names(r_cos)[1], names(r_bm)[1])))
  cat(sprintf("  - AND vazio? %s - consultas longas costumam falhar no AND estrito.\n",
              if (!length(and_ids)) "SIM" else "NAO"))
  cat(sprintf("  - Latencia: Cosseno %.0f ms | BM25 %.0f ms neste corpus.\n",
              ms_cos, ms_bm))
  if (length(grau) && sum(grau >= 2) == 0) {
    cat("  - Gabarito: nenhum grau>=2 nesta necessidade - metricas binarias nao discriminam.\n")
  }

  resumo_global[[nome]] <- list(
    cos1 = names(r_cos)[1],
    bm1 = names(r_bm)[1],
    ms_cos = ms_cos,
    ms_bm = ms_bm,
    j_cos_bm = jaccard(top5_por[["Cosseno"]], top5_por[["BM25"]])
  )
}

## ======================== RESUMO EXECUTIVO ========================
cat("\n\n")
box_title("RESUMO EXECUTIVO - as 3 consultas lado a lado")
sw <- c(12L, 10L, 10L, 8L, 8L, 6L)
sa <- c("left", "left", "left", "right", "right", "right")
srows <- lapply(names(resumo_global), function(nome) {
  r <- resumo_global[[nome]]
  c(nome, r$cos1, r$bm1, fmt_ms(r$ms_cos), fmt_ms(r$ms_bm), sprintf("%.2f", r$j_cos_bm))
})
print_table(
  c("Consulta", "Top1 Cos", "Top1 BM25", "ms Cos", "ms BM25", "Jac@5"),
  srows, widths = sw, align = sa
)

cat("\n")
hr("=")
cat("  VEREDITO (padrao auditoria senior)\n")
hr("-")
cat("  1. Qualidade textual: localizacao e fundador acertam o 1o lugar nos ranqueadores.\n")
cat("  2. Booleano AND e filtro, nao ranking; OR nao ordena - use so para recall bruto.\n")
cat("  3. Cosseno ~ BM25 no top-1 destas 3; BM25 e competitivo em latencia.\n")
cat("  4. Julgamento (graus) e a regua; com R=0 no limiar, declare - nao invente MAP.\n")
cat("  5. Tres consultas bastam para demo de 5 min; nao coroam modelo (Aula 16 = teste).\n")
hr("=")

## CSV
dir.create("csv", showWarnings = FALSE)
## regrava auditoria enxuta a partir do ultimo loop? melhor re-rodar coleta
## (ja temos linhas por consulta no loop — reabrir coleta simples)
out_csv <- file.path("csv", "entrega-meio-semestre-auditoria.csv")
## regenera CSV completo
todas <- list()
for (nome in names(consultas)) {
  q <- consultas[[nome]]
  qid <- qrels_map[[nome]]
  grau <- numeric(0)
  if (nrow(qrels)) {
    sub <- qrels[qrels$consulta == qid, ]
    if (nrow(sub)) {
      grau <- setNames(as.numeric(sub$grau), sub$documento)
      grau <- grau[!duplicated(names(grau), fromLast = TRUE)]
    }
  }
  t0 <- proc.time()[["elapsed"]]; and_ids <- busca_AND(q); ms_and <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; or_ids <- busca_OR(q); ms_or <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; r_tf <- ranquear_tfidf(q); ms_tf <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; r_cos <- ranquear_cosseno(q); ms_cos <- (proc.time()[["elapsed"]] - t0) * 1000
  t0 <- proc.time()[["elapsed"]]; r_bm <- ranquear_bm25(q); ms_bm <- (proc.time()[["elapsed"]] - t0) * 1000
  packs <- list(
    AND = list(ids = and_ids, ms = ms_and, sc = setNames(rep(1, length(and_ids)), and_ids)),
    OR = list(ids = or_ids, ms = ms_or, sc = setNames(rep(1, length(or_ids)), or_ids)),
    TFIDF = list(ids = names(r_tf)[1:5], ms = ms_tf, sc = r_tf),
    cosseno = list(ids = names(r_cos)[1:5], ms = ms_cos, sc = r_cos),
    BM25 = list(ids = names(r_bm)[1:5], ms = ms_bm, sc = r_bm)
  )
  for (nm in names(packs)) {
    sc <- packs[[nm]]$sc
    top <- names(sc)[seq_len(min(5, length(sc)))]
    qlt <- qualidade(top, grau)
    top_str <- if (!length(top)) "" else paste(sprintf("%s:%.4f", top, unname(sc[top])), collapse = ";")
    todas[[length(todas) + 1]] <- data.frame(
      consulta = nome, texto = q, metodo = nm, ms = round(packs[[nm]]$ms, 2),
      top5 = top_str,
      P_at_3 = ifelse(is.na(qlt$P3), "", round(qlt$P3, 3)),
      nDCG_grad = ifelse(is.na(qlt$nDCG), "", round(qlt$nDCG, 3)),
      R = ifelse(is.na(qlt$R), "", qlt$R),
      note = qlt$note, qrels_id = qid,
      stringsAsFactors = FALSE
    )
  }
}
write.csv(do.call(rbind, todas), out_csv, row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("\n  CSV de auditoria → %s\n", normalizePath(out_csv)))
cat("  Proximos: Rscript aula02.R (so cosseno)  ·  Rscript coletar.R (regenera corpus)\n")
hr("=")

# Entrega 1 - O corpus do projeto
# Na raiz: Rscript entregas/entrega-1/entrega-1-corpus.R
# Le estrutura/corpus/*.txt (regra de frase de estrutura/codigos/01a-ler-frases.R)
# e grava em entregas/entrega-1/:
#   entrega-1-docs.csv        (um documento por linha, lido pelo .Rnw)
#   entrega-1-paginas.csv     (paragrafos, frases e tokens por pagina)
#   entrega-1-metodos.csv     (3 consultas x 5 metodos: tempo e qualidade)
#   entrega-1-rankings.csv    (top-5 de cada metodo ranqueado)
#   entrega-1-julgamento.csv  (graus 0/1/2 por consulta, de 05-qrels.csv)
#   entrega-1-top10.csv       (10 termos mais frequentes, tokenizacao bruta)
#   entrega-1-resultados.csv  (numeros soltos citados no texto)
#   entrega-1-numeros.txt     (tudo o que o texto cita, para conferencia)

user.lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", "4.6")
dir.create(user.lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user.lib, .libPaths()))
if (!requireNamespace("SnowballC", quietly = TRUE)) {
  install.packages("SnowballC", lib = user.lib, repos = "https://cloud.r-project.org")
}
library(SnowballC)

root <- if (file.exists(file.path("estrutura", "corpus"))) {
  "."
} else if (file.exists(file.path("..", "..", "estrutura", "corpus"))) {
  file.path("..", "..")
} else {
  stop("Rode na raiz do repositorio.")
}
setwd(root)
saida <- file.path("entregas", "entrega-1")

# ---- 1) corpus: tres paginas da Wikipedia, documento = frase pontuada ----
source(file.path("estrutura", "codigos", "01a-ler-frases.R"))
pasta <- file.path("estrutura", "corpus")
arquivos <- c(d1 = "porto_de_santos.txt",
              d2 = "autoridade_portuaria_de_santos.txt",
              d3 = "francisco_de_paula_ribeiro.txt")
paginas <- c(d1 = "Porto de Santos",
             d2 = "Autoridade Portuaria de Santos",
             d3 = "Francisco de Paula Ribeiro")

docs <- character(0); origem <- character(0); paragrafos <- integer(0)
for (a in names(arquivos)) {
  f <- file.path(pasta, arquivos[[a]])
  linhas <- readLines(f, encoding = "UTF-8", warn = FALSE)
  paragrafos[[a]] <- sum(nzchar(trimws(linhas)))
  fr <- ler_frases(f)
  docs <- c(docs, setNames(fr, paste0(a, ".", seq_along(fr))))
  origem <- c(origem, rep(a, length(fr)))
}
names(origem) <- names(docs)

# tokenizacao da Aula 01 (bruta): minusculas e quebra por espaco
tokenizar <- function(x) unlist(strsplit(tolower(x), "\\s+"))
tok.bruto <- lapply(docs, tokenizar)
tam <- sapply(tok.bruto, length)
freq <- sort(table(unlist(tok.bruto)), decreasing = TRUE)

write.csv(data.frame(id = names(docs), artigo = origem, n_tokens = tam,
                     texto = unname(docs)),
          file.path(saida, "entrega-1-docs.csv"), row.names = FALSE, fileEncoding = "UTF-8")

pag <- data.frame(
  artigo     = names(arquivos),
  pagina     = unname(paginas),
  paragrafos = as.integer(paragrafos[names(arquivos)]),
  frases     = as.integer(table(factor(origem, levels = names(arquivos)))),
  tokens.med = round(as.numeric(tapply(tam, factor(origem, levels = names(arquivos)), mean)), 1)
)
write.csv(pag, file.path(saida, "entrega-1-paginas.csv"), row.names = FALSE)

# ---- 2) motor: limpeza + Snowball (Aula 03), indice, TF-IDF, cosseno, BM25 ----
limpar <- function(x) {
  x <- tolower(x)
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  x[is.na(x)] <- ""
  x <- gsub("[^a-z0-9 ]", " ", x)
  trimws(gsub("\\s+", " ", x))
}
stopwords <- unique(c(
  "de", "o", "a", "e", "um", "uma", "uns", "umas", "por", "como", "que", "da", "do",
  "das", "dos", "em", "no", "na", "nos", "nas", "ao", "aos", "as", "os", "com", "para",
  "pelo", "pela", "pelos", "pelas", "se", "sua", "seu", "seus", "suas", "ou", "mais",
  "menos", "muito", "muitos", "ja", "tambem", "entre", "sobre", "ate", "sem", "sob",
  "apos", "foi", "ser", "sao", "esta", "este", "essa", "esse", "isso", "isto", "ele",
  "ela", "eles", "elas", "lhe", "lhes", "me", "te", "vos", "ha", "tem", "ter", "pode", "podem"
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
N <- ncol(tf); dl <- colSums(tf); avgdl <- mean(dl); df <- rowSums(tf > 0)
idf <- log(N / df)
idf.bm25 <- log((N - df + 0.5) / (df + 0.5) + 1)
w <- tf * idf
postings <- lapply(setNames(vocab, vocab), function(t) ids[tf[t, ] > 0])

busca.and <- function(q) {
  t <- prep(q)
  if (!length(t) || !all(t %in% vocab)) return(character(0))
  Reduce(intersect, postings[t])
}
busca.or <- function(q) {
  t <- intersect(prep(q), vocab)
  if (!length(t)) return(character(0))
  sort(unique(unlist(postings[t], use.names = FALSE)))
}
rank.tfidf <- function(q) {
  t <- intersect(prep(q), vocab)
  s <- if (length(t)) colSums(w[t, , drop = FALSE]) else setNames(rep(0, N), ids)
  sort(s, decreasing = TRUE)
}
rank.cos <- function(q) {
  qw <- as.integer(table(factor(prep(q), levels = vocab))) * idf
  nq <- sqrt(sum(qw^2)); nd <- sqrt(colSums(w^2))
  s <- if (nq == 0) setNames(rep(0, N), ids) else as.numeric(crossprod(w, qw)) / (nq * nd)
  names(s) <- ids
  s[!is.finite(s)] <- 0
  sort(s, decreasing = TRUE)
}
rank.bm25 <- function(q, k1 = 1.2, b = 0.75) {
  t <- intersect(prep(q), vocab)
  K <- k1 * (1 - b + b * dl / avgdl)
  s <- setNames(rep(0, N), ids)
  for (term in t) {
    f <- tf[term, ]
    s <- s + idf.bm25[[term]] * f * (k1 + 1) / (f + K)
  }
  sort(s, decreasing = TRUE)
}

# ---- 3) tres consultas de trabalho, julgadas na Aula 05a ----
consultas <- c(q.local    = "localizacao porto santos guaruja cubatao",
               q.aps      = "quem administra porto santos autoridade",
               q.fundador = "francisco de paula ribeiro porto")
qrels.id <- c(q.local = "q15", q.aps = "q02", q.fundador = "q04")
qrels <- read.csv(file.path("estrutura", "codigos", "05-julgamento", "csv", "05-qrels.csv"),
                  stringsAsFactors = FALSE)

grau.de <- function(qid) {
  s <- qrels[qrels$consulta == qid, ]
  g <- setNames(as.numeric(s$grau), s$documento)
  g[!duplicated(names(g), fromLast = TRUE)]
}
dcg <- function(g) sum(g / log2(seq_along(g) + 1))
qualidade <- function(top, grau, k = 5) {
  g <- grau[top[1:k]]; g[is.na(g)] <- 0          # nao julgado = 0 (pooling)
  rel <- as.integer(g >= 2)
  ideal <- sort(grau, decreasing = TRUE)[1:k]; ideal[is.na(ideal)] <- 0
  c(p3   = mean(rel[1:3]),
    rr   = if (any(rel == 1)) 1 / which(rel == 1)[1] else 0,
    ndcg = if (sum(ideal) > 0) dcg(g) / dcg(ideal) else NA)
}
# relogio do Windows tem resolucao de ~10 ms: mede o bloco e divide
cronometro <- function(f, q, reps = 200) {
  t <- system.time(for (i in seq_len(reps)) f(q))[["elapsed"]]
  1000 * t / reps
}

metodos <- list(); rankings <- list()
for (cq in names(consultas)) {
  q <- consultas[[cq]]; grau <- grau.de(qrels.id[[cq]])
  and <- busca.and(q); or <- busca.or(q)
  r <- list(tfidf = rank.tfidf(q), cosseno = rank.cos(q), bm25 = rank.bm25(q))
  metodos[[length(metodos) + 1]] <- data.frame(
    consulta = cq, metodo = c("and", "or"), ms = c(cronometro(busca.and, q), cronometro(busca.or, q)),
    hits = c(length(and), length(or)), top1 = NA, p3 = NA, rr = NA, ndcg = NA)
  for (m in names(r)) {
    top <- names(r[[m]])[1:5]
    qq <- qualidade(top, grau)
    f <- switch(m, tfidf = rank.tfidf, cosseno = rank.cos, bm25 = rank.bm25)
    metodos[[length(metodos) + 1]] <- data.frame(
      consulta = cq, metodo = m, ms = cronometro(f, q), hits = sum(r[[m]] > 0),
      top1 = top[1], p3 = qq[["p3"]], rr = qq[["rr"]], ndcg = qq[["ndcg"]])
    g <- grau[top]; g[is.na(g)] <- NA
    rankings[[length(rankings) + 1]] <- data.frame(
      consulta = cq, metodo = m, pos = 1:5, doc = top,
      score = round(unname(r[[m]][1:5]), 4), grau = unname(g))
  }
}
metodos <- do.call(rbind, metodos)
rankings <- do.call(rbind, rankings)
write.csv(metodos, file.path(saida, "entrega-1-metodos.csv"), row.names = FALSE)
write.csv(rankings, file.path(saida, "entrega-1-rankings.csv"), row.names = FALSE)

julg <- do.call(rbind, lapply(names(qrels.id), function(cq) {
  g <- grau.de(qrels.id[[cq]])
  data.frame(consulta = cq, julgados = length(g), g0 = sum(g == 0), g1 = sum(g == 1), g2 = sum(g == 2))
}))
write.csv(julg, file.path(saida, "entrega-1-julgamento.csv"), row.names = FALSE)

# ---- 4) diagnostico (os quatro descartes do modelo) ----
curto <- 5; longo <- 60
resultados <- data.frame(
  medida = c("n.docs", "n.paginas", "n.paragrafos", "n.vocab.bruto", "n.tokens",
             "n.vocab.stem", "tam.min", "tam.max", "tam.media", "tam.mediana",
             "curto", "longo", "n.curtos", "n.longos",
             "dom.n", "dom.pct", "com.acento", "com.pont", "com.digito",
             "avgdl.stem"),
  valor = c(N, length(arquivos), sum(paragrafos), length(freq), sum(tam),
            length(vocab), min(tam), max(tam), mean(tam), median(tam),
            curto, longo, sum(tam < curto), sum(tam > longo),
            max(table(origem)), 100 * max(table(origem)) / N,
            sum(grepl("[^ -~]", docs)), sum(grepl("[[:punct:]]", docs)),
            sum(grepl("[0-9]", docs)), avgdl)
)
write.csv(resultados, file.path(saida, "entrega-1-resultados.csv"), row.names = FALSE)
write.csv(data.frame(termo = names(freq)[1:10], n = as.integer(freq[1:10])),
          file.path(saida, "entrega-1-top10.csv"), row.names = FALSE, fileEncoding = "UTF-8")

sink(file.path(saida, "entrega-1-numeros.txt"))
cat("=== corpus ===\n"); print(pag)
print(resultados, digits = 4)
cat("\n=== 10 termos mais frequentes (tokenizacao bruta da Aula 01) ===\n"); print(freq[1:10])
cat("\n=== documentos curtos (<", curto, " tokens) ===\n"); print(docs[tam < curto])
cat("\n=== documentos longos (>", longo, " tokens) ===\n"); print(names(docs)[tam > longo])
cat("\n=== julgamento das 3 consultas (05-qrels.csv) ===\n"); print(julg)
cat("\n=== metodos: ms medio de 200 execucoes; P@3 e RR com grau>=2; nDCG@5 graduado ===\n")
print(metodos, digits = 3)
cat("\n=== top-5 ===\n"); print(rankings)
sink()

print(metodos, digits = 3)
cat("OK\n")

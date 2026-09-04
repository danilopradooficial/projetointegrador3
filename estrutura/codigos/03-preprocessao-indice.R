# =============================================================
# PI III - Motor de Busca - Atividade 03 / Aula 03 (4ª entrega)
# Fatec Rubens Lara - Ciência de Dados
# Limpeza · stopwords · Snowball · índice invertido
# Corpus real: Porto de Santos / APS / Francisco (CC BY-SA)
# Pacote: SnowballC (wordStem, language = "portuguese")
# =============================================================

user_lib <- path.expand("~/R/win-library/4.6")
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

if (!requireNamespace("SnowballC", quietly = TRUE)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  install.packages("SnowballC", lib = user_lib, repos = "https://cloud.r-project.org")
  .libPaths(c(user_lib, .libPaths()))
}
library(SnowballC)

## 1) Corpus real (mesmos artigos da Atividade 01)
## cwd = pasta do script; corpus em ../corpus
args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}
pasta_corpus <- file.path("..", "corpus")

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

# Indexamos artigos e paragrafos (unidades de busca)
ids_docs <- names(docs)
ids_artigos <- c("d1", "d2", "d3")

cat("Documentos carregados:", length(docs),
    "| artigos:", length(ids_artigos),
    "| paragrafos:", length(docs) - length(ids_artigos), "\n\n")

## 2) Limpeza (Aula 03) + remocao de acentos (texto real em PT)
limpar <- function(x) {
  x <- tolower(x)
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  x[is.na(x)] <- ""
  x <- gsub("[^a-z0-9 ]", " ", x)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

## 3) Stopwords em portugues (lista da aula + comuns do top-10 da Ativ 01)
stopwords <- c(
  "de", "o", "a", "e", "um", "uma", "uns", "umas",
  "por", "como", "que", "da", "do", "das", "dos",
  "em", "no", "na", "nos", "nas", "ao", "aos", "as", "os",
  "com", "para", "pelo", "pela", "pelos", "pelas",
  "se", "su", "sua", "seu", "seus", "suas",
  "ou", "mais", "menos", "muito", "muitos", "ja", "tambem",
  "entre", "sobre", "ate", "sem", "sob", "apos",
  "foi", "ser", "sao", "esta", "este", "essa", "esse",
  "isso", "isto", "ele", "ela", "eles", "elas",
  "lhe", "lhes", "me", "te", "nos", "vos",
  "ha", "tem", "ter", "pode", "podem", "seu", "sua"
)
stopwords <- unique(stopwords)

## 4) Pipeline: limpar → tokenizar → stopwords → Snowball
tok <- function(x) {
  t <- unlist(strsplit(limpar(x), " "))
  t[nzchar(t)]
}

sem_stop <- function(x) {
  t <- tok(x)
  t[!t %in% stopwords]
}

prep <- function(x) {
  t <- sem_stop(x)
  if (length(t) == 0) return(character(0))
  SnowballC::wordStem(t, language = "portuguese")
}

## 5) Comparacao: bruto vs limpo vs sem stop vs stem (amostra d1.1)
amostra <- docs[["d1.1"]]
cat("=== Amostra de pre-processamento (d1.1) ===\n")
cat("Bruto (80 chars):", substr(amostra, 1, 80), "...\n")
cat("Limpo  (80 chars):", substr(limpar(amostra), 1, 80), "...\n")
cat("Tokens brutos:", length(tok(amostra)), "\n")
cat("Sem stopwords:", length(sem_stop(amostra)), "\n")
cat("Apos Snowball:", length(prep(amostra)), "\n")
cat("Stems (15 primeiros):", paste(head(prep(amostra), 15), collapse = " "), "\n\n")

## 6) Vocabulario: efeito de cada etapa (so artigos, sem duplicar paragrafos)
tok_bruto   <- lapply(docs[ids_artigos], tok)
tok_semstop <- lapply(docs[ids_artigos], sem_stop)
tok_stem    <- lapply(docs[ids_artigos], prep)

n_bruto   <- length(unique(unlist(tok_bruto)))
n_semstop <- length(unique(unlist(tok_semstop)))
n_stem    <- length(unique(unlist(tok_stem)))

cat("=== Vocabulario nos artigos (d1, d2, d3) ===\n")
cat(sprintf("Apos limpeza:           %5d termos\n", n_bruto))
cat(sprintf("Apos stopwords:         %5d termos  (%.1f%% a menos)\n",
            n_semstop, 100 * (1 - n_semstop / n_bruto)))
cat(sprintf("Apos Snowball (stem):   %5d termos  (%.1f%% a menos vs limpo)\n\n",
            n_stem, 100 * (1 - n_stem / n_bruto)))

freq_bruto <- sort(table(unlist(tok_bruto)), decreasing = TRUE)
freq_stem  <- sort(table(unlist(tok_stem)), decreasing = TRUE)

cat("--- Top 10 ANTES (limpo, com stopwords) ---\n")
print(head(freq_bruto, 10))
cat("\n--- Top 10 DEPOIS (sem stop + Snowball) ---\n")
print(head(freq_stem, 10))
cat("\n")

## 7) Indice invertido (Aula 03) — todos os docs (artigos + paragrafos)
postings <- list()
for (d in ids_docs) {
  for (termo in unique(prep(docs[[d]]))) {
    postings[[termo]] <- c(postings[[termo]], d)
  }
}

cat("=== Indice invertido ===\n")
cat("Termos no dicionario:", length(postings), "\n")
cat("Docs indexados:", length(ids_docs), "\n\n")

cat("--- Exemplos de postagens ---\n")
for (t in c("port", "santos", "autoridad", "ribeir", "carg")) {
  if (!is.null(postings[[t]])) {
    cat(sprintf("%-12s -> %s\n", t, paste(postings[[t]], collapse = ", ")))
  } else {
    cat(sprintf("%-12s -> (ausente)\n", t))
  }
}
cat("\n")

maiores <- sort(lengths(postings), decreasing = TRUE)[1:8]
cat("--- Termos com mais postagens (df alto) ---\n")
print(maiores)
cat("\n")

## 8) Busca AND / OR (mesma prep da indexacao)
busca_AND <- function(consulta, idx = postings) {
  termos <- prep(consulta)
  if (length(termos) == 0) return(character(0))
  presentes <- termos[termos %in% names(idx)]
  if (length(presentes) == 0) return(character(0))
  if (length(presentes) < length(termos)) {
    faltando <- setdiff(termos, presentes)
    cat("  (aviso AND: stems ausentes no indice:",
        paste(faltando, collapse = ", "), ")\n")
    return(character(0))
  }
  Reduce(intersect, idx[presentes])
}

busca_OR <- function(consulta, idx = postings) {
  termos <- prep(consulta)
  if (length(termos) == 0) return(character(0))
  presentes <- termos[termos %in% names(idx)]
  if (length(presentes) == 0) return(character(0))
  unique(unlist(idx[presentes], use.names = FALSE))
}

consultas <- c(
  "porto de santos",
  "autoridade portuaria",
  "francisco ribeiro",
  "carga container",
  "porto autoridade"
)

cat("=== Consultas: AND vs OR ===\n")
for (q in consultas) {
  cat("------------------------------------------------------------\n")
  cat("Consulta:", q, "\n")
  cat("  stems :", paste(prep(q), collapse = " | "), "\n")
  and_hit <- busca_AND(q)
  or_hit  <- busca_OR(q)
  cat("  AND   :", if (length(and_hit)) paste(and_hit, collapse = ", ") else "(vazio)", "\n")
  cat("  OR    :", if (length(or_hit)) paste(or_hit, collapse = ", ") else "(vazio)", "\n")
  cat("  |AND| =", length(and_hit), " |OR| =", length(or_hit), "\n")
}
cat("\n")

## 9) Stemming destrutivo: formas que colapsam
pares <- c("documentos", "documento", "portuaria", "portuario",
           "cargas", "carga", "navios", "navio")
cat("=== SnowballC (portuguese) — colapso de formas ===\n")
print(data.frame(
  forma = pares,
  stem  = wordStem(pares, language = "portuguese"),
  row.names = NULL
))
cat("\nPronto: limpeza + stopwords + Snowball + indice + AND/OR.\n")

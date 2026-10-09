# =============================================================
# PI III - Motor de Busca - Atividade 01 · Parte B / Aula 01.5
# Fatec Rubens Lara - Ciência de Dados
# De Shannon aos pesos dos termos
# Corpus de brinquedo da Aula 01 (8 documentos)
# =============================================================

## Corpus da aula
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
N <- length(docs)

contem <- function(t) {
  names(docs)[sapply(docs, function(d) t %in% tok(d))]
}

df_termo <- function(t) length(contem(t))

I_bits <- function(t) log2(N / df_termo(t))

# -------------------------------------------------------------
# PARTE 1 - Blocos da aula (Explicar / Explorar / Prever)
# -------------------------------------------------------------

cat("=== Parte 1: blocos da aula ===\n\n")

## Bloco 1 - incerteza inicial (bits para achar 1 entre N)
cat("--- Bloco 1: log2(N) ---\n")
cat("N =", N, "| log2(N) =", log2(N), "bits\n\n")

## Bloco 2 - pista "busca" vs "de"
cat("--- Bloco 2: pistas busca / de ---\n")
print(contem("busca"))
cat("I(busca) =", I_bits("busca"), "bits\n")
print(contem("de"))
cat("I(de) =", round(I_bits("de"), 3), "bits\n\n")

## Bloco 3 - autoinformacao = IDF
cat("--- Bloco 3: IDF em bits ---\n")
df <- c(modelo = 2, de = 5, recuperacao = 2)
print(round(log2(N / df), 3))
cat("\n")

## Bloco 4/5 - consulta em bits (tf * I)
cat("--- Bloco 5: consulta 'modelo de recuperacao' (bits) ---\n")
consulta <- c("modelo", "de", "recuperacao")
idf_bits <- sapply(consulta, I_bits)

contribuicao <- sapply(names(docs), function(d) {
  tf <- table(factor(tokens[[d]], levels = consulta))
  as.numeric(tf * idf_bits)
})
rownames(contribuicao) <- consulta
totais <- colSums(contribuicao)
print(round(rbind(contribuicao, total = totais), 2))
cat("\nRanking:\n")
print(sort(totais, decreasing = TRUE))
cat("\n")

## Bloco 6 - independencia vs correlacao
cat("--- Bloco 6: soma de bits vs informacao real ---\n")
pares <- list(
  c("busca", "documentos"),
  c("recuperacao", "relevancia"),
  c("aprendizado", "estatistico"),
  c("modelo", "vetorial")
)
for (par in pares) {
  a <- par[1]; b <- par[2]
  inter <- intersect(contem(a), contem(b))
  soma <- I_bits(a) + I_bits(b)
  real <- if (length(inter) > 0) log2(N / length(inter)) else NA
  cat(sprintf(
    "%s + %s | inter=%s | soma=%.3f | real=%.3f | excesso=%.3f\n",
    a, b, paste(inter, collapse = ","), soma, real, soma - real
  ))
}
cat("\n")

## Bloco 7 - rotas da Baixada (bag of words)
cat("--- Bloco 7: rotas (mesmo vocabulario, ordem diferente) ---\n")
rotas <- c(
  r1 = "santos cubatao guaruja bertioga",
  r2 = "santos guaruja cubatao bertioga",
  r3 = "santos bertioga guaruja cubatao",
  r4 = "cubatao santos bertioga guaruja",
  r5 = "guaruja bertioga santos cubatao",
  r6 = "bertioga cubatao santos guaruja",
  r7 = "guaruja santos cubatao bertioga",
  r8 = "bertioga guaruja cubatao santos"
)
# TF-IDF das rotas: todos os termos em todas as rotas => IDF = 0
vocab_r <- sort(unique(unlist(lapply(rotas, tok))))
tdm_r <- sapply(rotas, function(r) {
  as.integer(table(factor(tok(r), levels = vocab_r)))
})
rownames(tdm_r) <- vocab_r
Nr <- length(rotas)
df_r <- rowSums(tdm_r > 0)
idf_r <- log2(Nr / df_r)
cat("N rotas =", Nr, "| bits necessarios =", log2(Nr), "\n")
cat("IDF das cidades (todas aparecem em todas as rotas):\n")
print(idf_r)
cat("Bits disponiveis no vocabulario: 0. Busca impossivel (bag of words).\n\n")

# -------------------------------------------------------------
# PARTE 2 - Perguntas para investigar
# -------------------------------------------------------------

cat("=== Parte 2: investigar ===\n\n")

## 1) 1024 e 2048 documentos
cat("--- Pergunta 1: custo em bits ---\n")
cat("1024 docs ->", log2(1024), "bits\n")
cat("2048 docs ->", log2(2048), "bits\n")
cat("Dobrar N adiciona exatamente 1 bit.\n\n")

## 2) par que superestima (alem de recuperacao/relevancia)
cat("--- Pergunta 2: par que superestima ---\n")
cat("Exemplo: aprendizado + estatistico\n")
cat("  contem(aprendizado):"); print(contem("aprendizado"))
cat("  contem(estatistico):"); print(contem("estatistico"))
cat("  intersecao:"); print(intersect(contem("aprendizado"), contem("estatistico")))
cat("  soma I =", I_bits("aprendizado") + I_bits("estatistico"),
    "| real =", log2(N / 1), "\n")
cat("  Correlacao: ambos so aparecem em d4 (mesmo assunto).\n\n")

## 3) log2 vs log no ranking
cat("--- Pergunta 3: log2 vs log ---\n")
rank_por_base <- function(logfn) {
  idf <- sapply(consulta, function(t) logfn(N / df_termo(t)))
  scores <- sapply(names(docs), function(d) {
    tf <- table(factor(tokens[[d]], levels = consulta))
    sum(as.numeric(tf) * idf)
  })
  names(sort(scores, decreasing = TRUE))
}
r2 <- rank_por_base(log2)
rn <- rank_por_base(log)
cat("Ranking log2:", paste(r2, collapse = " > "), "\n")
cat("Ranking log :", paste(rn, collapse = " > "), "\n")
cat("Mesma ordem?", identical(r2, rn), "\n")
cat("Motivo: log_b(x) = ln(x)/ln(b) - so muda a escala, nao a ordem.\n\n")

## 4) termo em todos os documentos
cat("--- Pergunta 4: termo em todos os docs ---\n")
cat("I = log2(N/N) =", log2(N / N), "bits\n")
cat("Stopwords proximas disso: discriminam pouco (ex.: 'de' com df=5).\n")
cat("I(de) =", round(I_bits("de"), 3), "bits\n\n")

# -------------------------------------------------------------
# PARTE 3 - Os mesmos blocos no NOSSO corpus (frases dN.k)
# -------------------------------------------------------------
# Tokenizacao da Aula 01: minusculas e sem pontuacao.
# Stopwords e radicais so entram na Aula 03.

cat("=== Parte 3: nosso corpus (Porto de Santos, APS, Paula Ribeiro) ===\n\n")

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
N_c <- length(docs_c)
df_c <- table(unlist(lapply(tokens_c, unique)))
I_c <- function(t) log2(N_c / as.numeric(df_c[t]))
contem_c <- function(t) names(docs_c)[vapply(tokens_c, function(x) t %in% x, logical(1))]

## Bloco 1 - incerteza inicial
cat("--- Bloco 1: log2(N) ---\n")
cat("N =", N_c, "frases | log2(N) =", round(log2(N_c), 3), "bits\n\n")

## Blocos 2/3 - quanto cada pista informa
cat("--- Blocos 2/3: bits de algumas pistas (I = log2(N/df)) ---\n")
pistas <- c("de", "porto", "santos", "autoridade", "cubatão", "guarujá",
            "ribeiro", "francisco", "administra", "estuarino")
print(data.frame(termo = pistas, df = as.integer(df_c[pistas]),
                 bits = round(sapply(pistas, I_c), 3)), row.names = FALSE)
cat("\nTermos que menos informam (maior df):\n")
print(round(sapply(names(sort(df_c, decreasing = TRUE))[1:8], I_c), 3))
cat("Termos que aparecem em 1 frase so valem log2(N) =", round(log2(N_c), 3),
    "bits:", sum(df_c == 1), "de", length(df_c), "termos\n\n")

## Bloco 5 - as 3 perguntas do projeto em bits (soma de tf * I)
cat("--- Bloco 5: as 3 perguntas do projeto, ranking em bits ---\n")
perguntas_c <- c(
  q_local    = "localização porto santos guarujá cubatão",
  q_aps      = "quem administra porto santos autoridade",
  q_fundador = "francisco de paula ribeiro porto"
)
for (cq in names(perguntas_c)) {
  termos <- tok_c(perguntas_c[[cq]])
  termos <- termos[termos %in% names(df_c)]
  score <- vapply(tokens_c, function(x) sum(table(factor(x, levels = termos)) * sapply(termos, I_c)), 0)
  top <- sort(score, decreasing = TRUE)[1:5]
  cat(sprintf("%s '%s'\n", cq, perguntas_c[[cq]]))
  cat("  bits por termo:", paste(sprintf("%s=%.2f", termos, sapply(termos, I_c)), collapse = " "), "\n")
  for (id in names(top)) cat(sprintf("  %-6s %6.2f bits  %s\n", id, top[[id]], substr(docs_c[[id]], 1, 70)))
}
cat("\n")

## Bloco 6 - independencia vs correlacao
cat("--- Bloco 6: soma de bits vs informacao real ---\n")
pares_c <- list(c("francisco", "ribeiro"), c("autoridade", "portuária"),
                c("guarujá", "cubatão"), c("companhia", "docas"))
for (par in pares_c) {
  a <- par[1]; b <- par[2]
  inter <- intersect(contem_c(a), contem_c(b))
  soma <- I_c(a) + I_c(b)
  real <- if (length(inter) > 0) log2(N_c / length(inter)) else NA
  cat(sprintf("%s + %s | df=%d,%d | juntos=%d | soma=%.2f | real=%.2f | excesso=%.2f\n",
              a, b, length(contem_c(a)), length(contem_c(b)), length(inter), soma, real, soma - real))
}

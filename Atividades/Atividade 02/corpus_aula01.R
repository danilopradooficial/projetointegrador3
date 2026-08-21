# =============================================================
# PI III - Motor de Busca - Aula 01
# Para casa - parte 2: meu primeiro corpus real
# Fonte: Wikipédia (CC BY-SA), pt.wikipedia.org
#
# Artigos:
#   d1  = Porto de Santos
#   d2  = Autoridade Portuária de Santos
#   d3  = Francisco de Paula Ribeiro
# Parágrafos:
#   d1.1, d1.2, ...  = parágrafos de d1
#   d2.1, d2.2, ...  = parágrafos de d2
#   d3.1, d3.2, ...  = parágrafos de d3
# =============================================================

## 1) Arquivos locais (extraídos da Wikipédia, 1 parágrafo por bloco)
pasta <- "."

artigos <- c(
  d1 = "porto_de_santos.txt",
  d2 = "autoridade_portuaria_de_santos.txt",
  d3 = "francisco_de_paula_ribeiro.txt"
)

## 2) Lê cada .txt: artigo completo (dN) + parágrafos (dN.1, dN.2, ...)
ler_paragrafos <- function(caminho) {
  linhas <- readLines(caminho, encoding = "UTF-8", warn = FALSE)
  # blocos separados por linha em branco
  texto <- paste(linhas, collapse = "\n")
  blocos <- unlist(strsplit(texto, "\n[[:space:]]*\n+"))
  trimws(blocos[nzchar(trimws(blocos))])
}

docs <- character(0)

for (id in names(artigos)) {
  arq <- file.path(pasta, artigos[[id]])
  paragrafos <- ler_paragrafos(arq)

  # d1 / d2 / d3 = artigo inteiro
  docs[[id]] <- paste(paragrafos, collapse = " ")

  # d1.1, d1.2, ... = cada parágrafo
  if (length(paragrafos) > 0) {
    nomes_par <- paste0(id, ".", seq_along(paragrafos))
    docs[nomes_par] <- paragrafos
  }
}

length(docs)
names(docs)

docs["d1"]   # Porto de Santos (artigo)
docs["d2"]   # Autoridade Portuária de Santos (artigo)
docs["d3"]   # Francisco de Paula Ribeiro (artigo)
docs["d1.1"] # 1º parágrafo de d1
docs["d2.1"] # 1º parágrafo de d2
docs["d3.1"] # 1º parágrafo de d3

## 3) Tokenizando e montando o vocabulário
tokenizar <- function(texto) {
  texto <- tolower(texto)
  unlist(strsplit(texto, "\\s+"))
}

# Vocabulário / frequências nos ARTIGOS (d1, d2, d3) — sem contar
# os parágrafos de novo (evita duplicar tokens do mesmo texto).
ids_artigos <- c("d1", "d2", "d3")
ids_paragrafos <- setdiff(names(docs), ids_artigos)

tokens_artigos <- lapply(docs[ids_artigos], tokenizar)
tokens_par     <- lapply(docs[ids_paragrafos], tokenizar)

tokens_artigos[["d1"]][1:15]
tokens_artigos[["d2"]][1:15]
tokens_artigos[["d3"]][1:15]

vocab <- sort(unique(unlist(tokens_artigos)))
length(vocab)

cat("\n--- Resumo dos artigos (d1, d2, d3) ---\n")
resumo_artigos <- data.frame(
  documento        = ids_artigos,
  paragrafos       = sapply(ids_artigos, function(id) {
    sum(startsWith(ids_paragrafos, paste0(id, ".")))
  }),
  caracteres       = sapply(docs[ids_artigos], nchar),
  tokens           = sapply(tokens_artigos, length),
  termos_distintos = sapply(tokens_artigos, function(tk) length(unique(tk)))
)
print(resumo_artigos, row.names = FALSE)

cat("\n--- Resumo dos parágrafos (d1.1, d1.2, ...) ---\n")
resumo_par <- data.frame(
  documento        = ids_paragrafos,
  caracteres       = sapply(docs[ids_paragrafos], nchar),
  tokens           = sapply(tokens_par, length),
  termos_distintos = sapply(tokens_par, function(tk) length(unique(tk)))
)
print(resumo_par, row.names = FALSE)

cat("\n--- Comparação com o corpus de brinquedo ---\n")
cat("Vocabulário do corpus de brinquedo (aula): 45 termos\n")
cat("Vocabulário do nosso corpus real (artigos):", length(vocab), "termos\n")
cat("Razão:", round(length(vocab) / 45, 1), "x maior\n")
cat("Artigos:", length(ids_artigos), "| Parágrafos:", length(ids_paragrafos), "\n")

## 4) Liste os 10 termos mais frequentes (nos artigos)
freq <- table(unlist(tokens_artigos))
top10 <- sort(freq, decreasing = TRUE)[1:10]

cat("\n--- Top 10 termos mais frequentes (artigos) ---\n")
print(top10)

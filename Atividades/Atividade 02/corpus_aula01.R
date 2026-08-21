# =============================================================
# PI III - Motor de Busca - Aula 01
# Para casa - parte 2: meu primeiro corpus real
# Fonte: Wikipédia (CC BY-SA), pt.wikipedia.org
# Artigos: Autoridade Portuária de Santos, Porto de Santos,
#          Francisco de Paula Ribeiro
# =============================================================

## 1) Baixe da Wikipédia os artigos (3 documentos da região)
##    Os .txt já foram salvos localmente a partir da Wikipédia
##    (equivalente ao que baixar_wiki() faria em aula).
pasta <- "corpus"

arquivos <- c(
  d1 = "autoridade_portuaria_de_santos.txt",
  d2 = "porto_de_santos.txt",
  d3 = "francisco_de_paula_ribeiro.txt"
)

## 2) Guarde-os num vetor nomeado docs, como fizemos em aula
docs <- sapply(arquivos, function(arq) {
  linhas <- readLines(file.path(pasta, arq), encoding = "UTF-8", warn = FALSE)
  paste(linhas, collapse = " ")
})
names(docs) <- names(arquivos)

length(docs)
docs["d1"]  # Autoridade Portuária de Santos
docs["d2"]  # Porto de Santos
docs["d3"]  # Francisco de Paula Ribeiro

## 3) Tokenize e monte o vocabulário (mesma função da aula)
tokenizar <- function(texto) {
  texto <- tolower(texto)
  unlist(strsplit(texto, "\\s+"))
}

tokens <- lapply(docs, tokenizar)
tokens[["d1"]][1:15]  # amostra dos primeiros tokens de d1 (Autoridade Portuária de Santos)
tokens[["d2"]][1:15]  # amostra dos primeiros tokens de d2 (Porto de Santos)
tokens[["d3"]][1:15]  # amostra dos primeiros tokens de d3 (Francisco de Paula Ribeiro)

vocab <- sort(unique(unlist(tokens)))
length(vocab)

cat("\n--- Resumo por documento ---\n")
resumo <- data.frame(
  documento       = names(docs),
  caracteres      = sapply(docs, nchar),
  tokens          = sapply(tokens, length),
  termos_distintos = sapply(tokens, function(tk) length(unique(tk)))
)
print(resumo, row.names = FALSE)

cat("\n--- Comparação com o corpus de brinquedo ---\n")
cat("Vocabulário do corpus de brinquedo (aula): 45 termos\n")
cat("Vocabulário do nosso corpus real:", length(vocab), "termos\n")
cat("Razão:", round(length(vocab) / 45, 1), "x maior\n")

## 4) Liste os 10 termos mais frequentes
freq <- table(unlist(tokens))
top10 <- sort(freq, decreasing = TRUE)[1:10]

cat("\n--- Top 10 termos mais frequentes ---\n")
print(top10)

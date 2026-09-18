# =============================================================
# PI III - Motor de Busca - Atividade 01 · Parte A / Aula 01
# Fatec Rubens Lara - Ciência de Dados
# Para casa - parte 2: meu primeiro corpus real
# Fonte: Wikipédia (CC BY-SA), pt.wikipedia.org
#
# Artigos:
#   d1  = Porto de Santos
#   d2  = Autoridade Portuária de Santos
#   d3  = Francisco de Paula Ribeiro
# Frases curtas (unidade de recuperacao):
#   d1.1, d1.2, ...  = frases de 7-10 palavras de d1
#   d2.1, d2.2, ...  = frases de 7-10 palavras de d2
#   d3.1, d3.2, ...  = frases de 7-10 palavras de d3
# =============================================================

## cwd = pasta do script; corpus em ../corpus
args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}
pasta_corpus <- file.path("..", "corpus")

## 1) Arquivos em estrutura/corpus (extraídos da Wikipédia)

artigos <- c(
  d1 = "porto_de_santos.txt",
  d2 = "autoridade_portuaria_de_santos.txt",
  d3 = "francisco_de_paula_ribeiro.txt"
)

## 2) Lê cada .txt: artigo completo (dN) + frases curtas (dN.1, dN.2, ...)
##    Unidade de recuperacao: 7 a 10 palavras (alvo = 8).
ler_frases <- function(caminho, min_w = 7L, max_w = 10L, alvo = 8L) {
  linhas <- readLines(caminho, encoding = "UTF-8", warn = FALSE)
  texto <- paste(linhas, collapse = " ")
  texto <- gsub("\\s+", " ", texto)
  texto <- trimws(texto)
  palavras <- unlist(strsplit(texto, "\\s+"))
  palavras <- palavras[nzchar(palavras)]
  n <- length(palavras)
  if (n == 0L) return(character(0))

  # Particiona n em tamanhos 7..10 (alvo 8); sobras <7 redistribuidas
  if (n <= max_w) {
    sizes <- n
  } else {
    q <- n %/% alvo
    r <- n %% alvo
    sizes <- rep(alvo, q)
    if (r == 0L) {
      # ok
    } else if (r >= min_w) {
      sizes <- c(sizes, r)
    } else {
      capacidade <- sum(max_w - sizes)
      if (r <= capacidade) {
        i <- 1L
        while (r > 0L) {
          if (sizes[i] < max_w) {
            sizes[i] <- sizes[i] + 1L
            r <- r - 1L
          }
          i <- if (i == length(sizes)) 1L else i + 1L
        }
      } else {
        sizes <- c(sizes, r)
      }
    }
  }

  chunks <- list()
  i <- 1L
  for (s in sizes) {
    chunks[[length(chunks) + 1L]] <- palavras[i:(i + s - 1L)]
    i <- i + s
  }

  if (length(chunks) >= 2L && length(chunks[[length(chunks)]]) < min_w) {
    comb <- c(chunks[[length(chunks) - 1L]], chunks[[length(chunks)]])
    if (length(comb) <= max_w) {
      chunks <- c(chunks[seq_len(length(chunks) - 2L)], list(comb))
    } else {
      best <- NA_integer_
      best_score <- -1L
      lo <- max(1L, length(comb) - max_w)
      hi <- min(max_w, length(comb) - 1L)
      for (m in lo:hi) {
        a <- m
        b <- length(comb) - m
        if (a <= max_w && b <= max_w && min(a, b) > best_score) {
          best_score <- min(a, b)
          best <- as.integer(m)
        }
      }
      if (is.na(best)) best <- as.integer(min(max_w, length(comb) - 1L))
      chunks <- c(
        chunks[seq_len(length(chunks) - 2L)],
        list(comb[seq_len(best)], comb[(best + 1L):length(comb)])
      )
    }
  }
  vapply(chunks, paste, character(1), collapse = " ")
}
docs <- character(0)

for (id in names(artigos)) {
  arq <- file.path(pasta_corpus, artigos[[id]])
  frases <- ler_frases(arq)

  # d1 / d2 / d3 = artigo inteiro
  docs[[id]] <- paste(frases, collapse = " ")

  # d1.1, d1.2, ... = cada frase curta (7-10 palavras)
  if (length(frases) > 0) {
    nomes_fr <- paste0(id, ".", seq_along(frases))
    docs[nomes_fr] <- frases
  }
}

length(docs)
names(docs)

docs["d1"]   # Porto de Santos (artigo)
docs["d2"]   # Autoridade Portuária de Santos (artigo)
docs["d3"]   # Francisco de Paula Ribeiro (artigo)
docs["d1.1"] # 1ª frase de d1
docs["d2.1"] # 1ª frase de d2
docs["d3.1"] # 1ª frase de d3

## 3) Tokenizando e montando o vocabulário
tokenizar <- function(texto) {
  texto <- tolower(texto)
  unlist(strsplit(texto, "\\s+"))
}

# Vocabulario / frequencias nos ARTIGOS (d1, d2, d3) - sem contar
# as frases de novo (evita duplicar tokens do mesmo texto).
ids_artigos <- c("d1", "d2", "d3")
ids_frases <- setdiff(names(docs), ids_artigos)

tokens_artigos <- lapply(docs[ids_artigos], tokenizar)
tokens_fr      <- lapply(docs[ids_frases], tokenizar)

tokens_artigos[["d1"]][1:15]
tokens_artigos[["d2"]][1:15]
tokens_artigos[["d3"]][1:15]

vocab <- sort(unique(unlist(tokens_artigos)))
length(vocab)

cat("\n--- Resumo dos artigos (d1, d2, d3) ---\n")
resumo_artigos <- data.frame(
  documento        = ids_artigos,
  frases           = sapply(ids_artigos, function(id) {
    sum(startsWith(ids_frases, paste0(id, ".")))
  }),
  caracteres       = sapply(docs[ids_artigos], nchar),
  tokens           = sapply(tokens_artigos, length),
  termos_distintos = sapply(tokens_artigos, function(tk) length(unique(tk)))
)
print(resumo_artigos, row.names = FALSE)

cat("\n--- Resumo das frases (d1.1, d1.2, ...; 7-10 palavras) ---\n")
resumo_fr <- data.frame(
  documento        = ids_frases,
  palavras         = sapply(docs[ids_frases], function(x) length(unlist(strsplit(x, "\\s+")))),
  caracteres       = sapply(docs[ids_frases], nchar),
  tokens           = sapply(tokens_fr, length),
  termos_distintos = sapply(tokens_fr, function(tk) length(unique(tk)))
)
print(resumo_fr, row.names = FALSE)
cat("palavras/frase: min=", min(resumo_fr$palavras),
    " max=", max(resumo_fr$palavras),
    " mediana=", median(resumo_fr$palavras), "\n", sep = "")

cat("\n--- Comparação com o corpus de brinquedo ---\n")
cat("Vocabulário do corpus de brinquedo (aula): 45 termos\n")
cat("Vocabulário do nosso corpus real (artigos):", length(vocab), "termos\n")
cat("Razão:", round(length(vocab) / 45, 1), "x maior\n")
cat("Artigos:", length(ids_artigos), "| Frases:", length(ids_frases), "\n")

## 4) Liste os 10 termos mais frequentes (nos artigos)
freq <- table(unlist(tokens_artigos))
top10 <- sort(freq, decreasing = TRUE)[1:10]

cat("\n--- Top 10 termos mais frequentes (artigos) ---\n")
print(top10)

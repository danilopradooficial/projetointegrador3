# 05b-montar-corpus.R
# Frases curtas d1.1, d1.2, ... (7-10 palavras) -> csv/05-corpus.csv
# Fonte: estrutura/corpus/*.txt · R base

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

pasta_txt <- file.path("..", "..", "corpus")
dir_csv <- "csv"
dir.create(dir_csv, showWarnings = FALSE)

artigos <- c(
  d1 = "porto_de_santos.txt",
  d2 = "autoridade_portuaria_de_santos.txt",
  d3 = "francisco_de_paula_ribeiro.txt"
)
titulos <- c(
  d1 = "Porto de Santos",
  d2 = "Autoridade Portuária de Santos",
  d3 = "Francisco de Paula Ribeiro"
)
urls <- c(
  d1 = "https://pt.wikipedia.org/wiki/Porto_de_Santos",
  d2 = "https://pt.wikipedia.org/wiki/Autoridade_Portuária_de_Santos",
  d3 = "https://pt.wikipedia.org/wiki/Francisco_de_Paula_Ribeiro"
)

## Unidade de recuperacao: frases de 7-10 palavras (alvo = 8)
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

linhas <- list()
for (aid in names(artigos)) {
  caminho <- file.path(pasta_txt, artigos[[aid]])
  if (!file.exists(caminho)) stop("Arquivo nao encontrado: ", caminho)
  frases <- ler_frases(caminho)
  for (i in seq_along(frases)) {
    txt <- frases[[i]]
    doc_id <- paste0(aid, ".", i)
    linhas[[length(linhas) + 1L]] <- data.frame(
      id = doc_id,
      titulo = sprintf("%s (%s)", titulos[[aid]], doc_id),
      texto = txt,
      data = "",
      fonte = paste0("Wikipedia PT | ", titulos[[aid]]),
      url = urls[[aid]],
      stringsAsFactors = FALSE
    )
  }
}

corpus <- do.call(rbind, linhas)
rownames(corpus) <- NULL
if (any(duplicated(corpus$id))) stop("ids duplicados")

npal <- sapply(strsplit(corpus$texto, "\\s+"), length)
if (any(npal > 10L)) stop("frase com mais de 10 palavras")

out <- file.path(dir_csv, "05-corpus.csv")
write.csv(corpus, out, row.names = FALSE, fileEncoding = "UTF-8")
cat("gravado", out, "| docs:", nrow(corpus), "\n")
print(table(sub("\\.[0-9]+$", "", corpus$id)))
cat("palavras/frase: min=", min(npal), " max=", max(npal),
    " mediana=", median(npal), "\n", sep = "")
cat("ids (amostra):", paste(head(corpus$id, 8), collapse = ", "), "...\n")

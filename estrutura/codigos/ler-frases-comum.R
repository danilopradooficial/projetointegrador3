# ler-frases-comum.R
# ------------------------------------------------------------
# Unidade de recuperacao CANONICA do projeto (Team Shannon)
# Usada por: 01a, 03, 04 e 05b — os IDs d1.1, d1.2, ... devem
# ser os mesmos em todo o motor (indice, BM25 e julgamento).
#
# Regra:
#   1) Quebra por ponto final / ! / ? (frase pontuada)
#   2) Se a frase passar de max_w palavras E tiver ';',
#      parte no ponto e virgula (sem perder o contexto)
#   3) Protege abreviacoes (S.A., Dr., ...) e decimais (8.630)
#
# Catalogo gerado: estrutura/corpus/frases-canonicas.csv
# ------------------------------------------------------------

ler_frases <- function(caminho, max_w = 45L, min_w = 3L) {
  linhas <- readLines(caminho, encoding = "UTF-8", warn = FALSE)
  texto <- paste(linhas, collapse = " ")
  texto <- gsub("\\s+", " ", texto)
  texto <- trimws(texto)
  if (!nzchar(texto)) return(character(0))

  abbr <- c("S.A.", "Ltda.", "Dr.", "Dra.", "Sr.", "Sra.", "Prof.", "Art.", "vol.")
  for (i in seq_along(abbr)) {
    texto <- gsub(abbr[[i]], paste0("__ABBR", i, "__"), texto, fixed = TRUE)
  }
  texto <- gsub("([0-9])\\.([0-9])", "\\1__DOT__\\2", texto)

  partes <- unlist(strsplit(texto, "(?<=[.!?])\\s+", perl = TRUE))
  partes <- trimws(partes)
  partes <- partes[nzchar(partes)]

  out <- character(0)
  for (p in partes) {
    for (i in seq_along(abbr)) {
      p <- gsub(paste0("__ABBR", i, "__"), abbr[[i]], p, fixed = TRUE)
    }
    p <- gsub("__DOT__", ".", p, fixed = TRUE)
    nw <- length(unlist(strsplit(p, "\\s+")))
    if (nw > max_w && grepl(";", p, fixed = TRUE)) {
      subs <- trimws(unlist(strsplit(p, ";", fixed = TRUE)))
      subs <- subs[nzchar(subs)]
      for (j in seq_along(subs)) {
        s <- subs[[j]]
        if (j < length(subs) && !grepl(";\\s*$", s)) s <- paste0(s, ";")
        nsw <- length(unlist(strsplit(s, "\\s+")))
        if (nsw >= min_w) out <- c(out, s)
      }
    } else if (nw >= min_w) {
      out <- c(out, p)
    }
  }
  out
}

# Monta docs nomeados: d1, d2, d3 + d1.1, d1.2, ...
# pasta_corpus: caminho para estrutura/corpus
# Retorna lista nomeada de character.
carregar_docs_canonico <- function(pasta_corpus) {
  artigos <- c(
    d1 = "porto_de_santos.txt",
    d2 = "autoridade_portuaria_de_santos.txt",
    d3 = "francisco_de_paula_ribeiro.txt"
  )
  docs <- character(0)
  for (id in names(artigos)) {
    arq <- file.path(pasta_corpus, artigos[[id]])
    frases <- ler_frases(arq)
    docs[[id]] <- paste(frases, collapse = " ")
    if (length(frases) > 0) {
      docs[paste0(id, ".", seq_along(frases))] <- frases
    }
  }
  docs
}

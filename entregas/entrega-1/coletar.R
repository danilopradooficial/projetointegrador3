# =============================================================
# coletar.R — regenera o corpus a partir dos .txt da Wikipédia
# Equivalente funcional ao coletar.R da estrutura da Aula 01
# Team Shannon · PI III · Entrega de meio de semestre
# =============================================================

args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

source(file.path("..", "..", "estrutura", "codigos", "01a-ler-frases.R"))
pasta_corpus <- file.path("..", "..", "estrutura", "corpus")

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
eixos <- c(
  d1 = "local / economia",
  d2 = "empresa publica (APS)",
  d3 = "fundador"
)

linhas <- list()
for (id in names(artigos)) {
  frases <- ler_frases(file.path(pasta_corpus, artigos[[id]]))
  for (k in seq_along(frases)) {
    fid <- paste0(id, ".", k)
    nw <- length(unlist(strsplit(trimws(frases[[k]]), "\\s+")))
    linhas[[length(linhas) + 1]] <- data.frame(
      id = fid,
      artigo = id,
      titulo_artigo = titulos[[id]],
      n_palavras = nw,
      texto = frases[[k]],
      stringsAsFactors = FALSE
    )
  }
}

tab <- do.call(rbind, linhas)
out <- file.path(pasta_corpus, "frases-canonicas.csv")
write.csv(tab, out, row.names = FALSE, fileEncoding = "UTF-8")

W <- 72L
hr <- function(ch = "=") cat(paste(rep(ch, W), collapse = ""), "\n", sep = "")
hr()
cat("  COLETAR.R  ·  Team Shannon  ·  regeneracao do corpus\n")
hr()
cat(sprintf("  Saida : %s\n", normalizePath(out)))
cat(sprintf("  Total : %d frases (unidade = frase pontuada dN.k)\n\n", nrow(tab)))

cat(sprintf("  %-4s  %-36s  %-22s  %6s  %8s\n",
            "ID", "Titulo", "Eixo", "Frases", "Palavras"))
cat(sprintf("  %-4s  %-36s  %-22s  %6s  %8s\n",
            "----", paste(rep("-", 36), collapse = ""),
            paste(rep("-", 22), collapse = ""), "------", "--------"))

for (a in names(artigos)) {
  sub <- tab[tab$artigo == a, ]
  cat(sprintf("  %-4s  %-36s  %-22s  %6d  %5.0f–%d\n",
              a, titulos[[a]], eixos[[a]],
              nrow(sub), min(sub$n_palavras), max(sub$n_palavras)))
}
cat(sprintf("\n  %-4s  %-36s  %-22s  %6d  mediana=%d\n",
            "", "TOTAL", "", nrow(tab),
            as.integer(median(tab$n_palavras))))
hr("-")
cat("  Licenca: Wikipedia pt · CC BY-SA\n")
cat("  Proximo passo: Rscript buscar.R   (auditoria multi-metodo)\n")
hr()

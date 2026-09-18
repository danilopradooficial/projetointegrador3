# 05d-gerar-pool.R
# Amostra enxuta (~20 min/juiz) com fatias adriane/danilo/victoria
# + pares em duplo para kappa. Saida: csv/05-pool.csv
# Colunas: consulta, documento, juiz, tipo

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

dir_csv <- "csv"
corpus <- read.csv(file.path(dir_csv, "05-corpus.csv"),
                   stringsAsFactors = FALSE, fileEncoding = "UTF-8")
necs <- read.csv(file.path(dir_csv, "05-necessidades.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8")

juizes <- c("adriane", "danilo", "victoria")
seed <- 42L
unicos_por_juiz <- 60L
duplo_por_par <- 15L

indicios <- list(
  q01 = c("d1.18", "d1.11", "d1.24", "d1.19", "d1.6"),
  q02 = c("d2.1", "d2.11", "d2.2", "d2.8", "d1.100"),
  q03 = c("d2.25", "d2.29", "d1.133", "d2.8", "d1.130"),
  q04 = c("d3.1", "d3.3", "d1.59", "d3.4", "d3.2"),
  q05 = c("d1.172", "d1.204", "d1.178", "d1.174", "d1.169"),
  q06 = c("d1.243", "d1.246", "d1.247", "d1.255", "d2.80"),
  q07 = c("d1.229", "d1.230", "d2.89", "d1.231", "d2.91"),
  q08 = c("d1.46", "d1.51", "d1.43", "d1.44", "d1.38"),
  q09 = c("d1.6", "d1.7", "d1.20", "d1.8", "d1.18"),
  q10 = c("d2.8", "d2.25", "d2.29", "d1.130", "d1.133"),
  q11 = c("d2.97", "d2.111", "d2.103", "d2.99", "d2.105"),
  q12 = c("d1.88", "d1.89", "d1.102", "d1.90", "d1.91"),
  q13 = c("d2.35", "d2.36", "d1.139", "d2.29", "d1.133"),
  q14 = c("d1.69", "d1.70", "d1.75", "d1.72", "d1.71"),
  q15 = c("d1.1", "d1.2", "d1.3", "d1.4", "d1.8")
)

# Hash estavel -> [0,1] (R base)
rnd <- function(key) {
  bytes <- charToRaw(enc2utf8(paste0(seed, ":", key)))
  s <- 0
  for (b in as.integer(bytes)) s <- (s * 131 + b) %% 2147483647
  s / 2147483647
}

ids <- as.character(corpus$id)
consultas <- as.character(necs$consulta)

candidatos <- list()
for (q in consultas) {
  pref <- indicios[[q]]
  pref <- pref[!is.null(pref) & pref %in% ids]
  outros <- ids[order(vapply(ids, function(d) rnd(paste0(q, "|", d)), numeric(1)))]
  for (d in outros) {
    if (!(d %in% pref)) pref <- c(pref, d)
    if (length(pref) >= 20L) break
  }
  candidatos[[q]] <- pref
}

pares <- list()
for (i in seq_len(20L)) {
  for (q in consultas) {
    if (i <= length(candidatos[[q]])) {
      pares[[length(pares) + 1L]] <- c(q, candidatos[[q]][[i]])
    }
  }
}
keys <- vapply(pares, function(p) paste(p, collapse = "|"), character(1))
pares <- pares[!duplicated(keys)]
ord <- order(vapply(pares, function(p) rnd(paste0("par|", p[1], "|", p[2])), numeric(1)))
pares <- pares[ord]

need_total <- 3L * unicos_por_juiz + 3L * duplo_por_par
if (length(pares) < need_total) {
  have <- new.env(parent = emptyenv())
  for (p in pares) assign(paste(p, collapse = "|"), TRUE, envir = have)
  extra <- list()
  for (q in consultas) {
    for (d in ids) {
      k <- paste(q, d, sep = "|")
      if (!exists(k, envir = have, inherits = FALSE)) {
        extra[[length(extra) + 1L]] <- c(q, d)
      }
    }
  }
  extra <- extra[order(vapply(extra, function(p) rnd(paste0("x|", p[1], "|", p[2])), numeric(1)))]
  pares <- c(pares, extra)
}
pares <- pares[seq_len(min(length(pares), need_total))]

unicos <- list()
idx <- 1L
for (j in juizes) {
  unicos[[j]] <- pares[idx:(idx + unicos_por_juiz - 1L)]
  idx <- idx + unicos_por_juiz
}
rest <- pares[idx:length(pares)]

duplos <- list(
  list(c("adriane", "danilo"), rest[1:duplo_por_par]),
  list(c("adriane", "victoria"), rest[(duplo_por_par + 1):(2 * duplo_por_par)]),
  list(c("danilo", "victoria"), rest[(2 * duplo_por_par + 1):(3 * duplo_por_par)])
)

linhas <- list()
add_row <- function(c, d, j, tipo) {
  linhas[[length(linhas) + 1L]] <<- data.frame(
    consulta = c, documento = d, juiz = j, tipo = tipo,
    stringsAsFactors = FALSE
  )
}
for (j in juizes) {
  for (p in unicos[[j]]) add_row(p[1], p[2], j, "unico")
}
for (blk in duplos) {
  js <- blk[[1]]
  for (p in blk[[2]]) {
    add_row(p[1], p[2], js[1], "duplo")
    add_row(p[1], p[2], js[2], "duplo")
  }
}

pool <- do.call(rbind, linhas)
pool <- pool[order(pool$juiz, pool$consulta, pool$documento), ]
rownames(pool) <- NULL

out <- file.path(dir_csv, "05-pool.csv")
write.csv(pool, out, row.names = FALSE, fileEncoding = "UTF-8")
cat(out, ":", nrow(pool), "linhas\n")
print(table(pool$juiz))
cat("tempo estimado @10s/item:",
    round(mean(as.numeric(table(pool$juiz))) * 10 / 60, 1),
    "min por juiz\n")

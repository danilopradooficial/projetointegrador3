# =============================================================
# 05a-kappa.R - Aula 05 - explorar kappa de Cohen
# Team Shannon · estrutura/codigos/05-julgamento/
# Gabarito humano: 05-julgar.html -> csv/05-qrels.csv
# =============================================================

args_cmd <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_cmd, value = TRUE)
if (length(file_arg) == 1) {
  setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
}

kappa_cohen <- function(m) {
  n <- sum(m)
  po <- sum(diag(m)) / n
  pe <- sum(rowSums(m) * colSums(m)) / n^2
  kappa <- (po - pe) / (1 - pe)
  list(n = n, po = po, pe = pe, kappa = kappa)
}

cat("=== Kappa de Cohen (chunks da aula) ===\n\n")

m <- matrix(
  c(18, 3, 0,
     2, 6, 2,
     0, 2, 7),
  nrow = 3, byrow = TRUE
)
rownames(m) <- paste0("A=", 0:2)
colnames(m) <- paste0("B=", 0:2)
cat("--- Matriz da aula ---\n")
print(m)
res <- kappa_cohen(m)
cat(sprintf("n=%d | po=%.3f | pe=%.3f | kappa=%.3f\n\n",
            res$n, res$po, res$pe, res$kappa))

m_zeros <- matrix(
  c(37, 2, 0,
     1, 0, 0,
     0, 0, 0),
  nrow = 3, byrow = TRUE
)
rownames(m_zeros) <- paste0("A=", 0:2)
colnames(m_zeros) <- paste0("B=", 0:2)
r1 <- kappa_cohen(m_zeros)
cat("--- Exploracao 1: 37/40 zeros concordantes ---\n")
print(m_zeros)
cat(sprintf("po=%.3f | pe=%.3f | kappa=%.3f\n\n", r1$po, r1$pe, r1$kappa))

m_falso <- matrix(
  c(30, 4, 0,
     4, 2, 0,
     0, 0, 0),
  nrow = 3, byrow = TRUE
)
rownames(m_falso) <- paste0("A=", 0:2)
colnames(m_falso) <- paste0("B=", 0:2)
r2 <- kappa_cohen(m_falso)
cat("--- Exploracao 2: po=0.8 com kappa < 0.3 ---\n")
print(m_falso)
cat(sprintf("po=%.3f | pe=%.3f | kappa=%.3f\n\n", r2$po, r2$pe, r2$kappa))

m_neg <- matrix(
  c(0, 10, 5,
    10, 0, 5,
     5, 5, 0),
  nrow = 3, byrow = TRUE
)
rownames(m_neg) <- paste0("A=", 0:2)
colnames(m_neg) <- paste0("B=", 0:2)
r3 <- kappa_cohen(m_neg)
cat("--- Exploracao 3: kappa negativo ---\n")
print(m_neg)
cat(sprintf("po=%.3f | pe=%.3f | kappa=%.3f\n\n", r3$po, r3$pe, r3$kappa))

cat("Pronto. Proximo: abrir 05-julgar.html e exportar csv/05-qrels.csv\n")

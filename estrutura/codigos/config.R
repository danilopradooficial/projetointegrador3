# =============================================================
# config.R - decisoes do motor · Team Shannon · PI III
# Gerado/atualizado por 07-lsa-rrf.R (Aula 07)
# =============================================================

# Modelo de ranqueamento em producao
# "bm25" | "lsa" | "hibrido" (RRF de BM25 + LSA)
modelo  <- "hibrido"
lsa_k   <- 20L
rrf_c   <- 60

# Avaliacao (Aula 05b)
limiar  <- 2L   # grau >= limiar conta como relevante binario

# Split Aula 07 (sem coluna conjunto nas necessidades)
consultas_dev   <- c("q01", "q03", "q05", "q06", "q09", "q10", "q13")
consultas_teste <- c("q04", "q07", "q11", "q15")

# Numeros da escolha (nao retocar apos ver o teste)
# MAP_dev_hibrido = 0.3500
# MAP_teste_hibrido = 0.4870
# MAP_dev_bm25 = 0.2864 | MAP_teste_bm25 = 0.4963


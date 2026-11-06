# =============================================================
# config.R - decisoes do motor · Team Shannon · PI III
# Atualizado por 08-retrieve-rerank.R (Aula 08)
# =============================================================

# Modelo de ranqueamento - estagio 1 (Aula 07)
# "bm25" | "lsa" | "hibrido" (RRF de BM25 + LSA)
modelo  <- "hibrido"
lsa_k   <- 20L
rrf_c   <- 60

# Avaliacao (Aula 05b)
limiar  <- 2L   # grau >= limiar conta como relevante binario

# Split (sem coluna conjunto nas necessidades)
consultas_dev   <- c("q01", "q03", "q05", "q06", "q09", "q10", "q13")
consultas_teste <- c("q04", "q07", "q11", "q15")

# --- Aula 08: reordenacao (proximidade ordenada) ---
rerank_k <- 5L   # quantos do topo reordenar (0 = nao)
janela   <- 3L   # distancia maxima da proximidade

# Numeros da escolha Aula 08 (nao retocar apos ver o teste)
# MAP_dev_estagio1 = 0.3500
# MAP_dev_rerank   = 0.3659
# MAP_teste_estagio1 = 0.4870
# MAP_teste_rerank   = 0.4592


FATEC RUBENS LARA - BAIXADA SANTISTA

CIÊNCIA DE DADOS

# Projeto Integrador III

## Aula 02 - Vetores TF-IDF e similaridade do cosseno

ATIVIDADE 04 • ENTREGA PARA CASA

**Adriane da Costa Santos**  
**Danilo Prado de Lima Silva**  
**Victoria Cabral Quinterio**

Motor de Busca • Recuperação de Informação

---

# Tarefa (para casa da Aula 02)

1. Reaproveitar o corpus de 8 documentos da Aula 01  
2. Implementar a matriz TF-IDF e a função `cosseno`  
3. Escolher 3 consultas e reportar o ranking de cada uma  

Script: `tfidf_cosseno.R`

---

# Implementação

```r
tok <- function(x) unlist(strsplit(tolower(x), "\\s+"))
tokens <- lapply(docs, tok)
vocab <- sort(unique(unlist(tokens)))
tdm <- sapply(tokens, function(t) as.integer(table(factor(t, levels = vocab))))
rownames(tdm) <- vocab

tf <- tdm
N <- ncol(tdm)
df <- rowSums(tdm > 0)
idf <- log(N / df)   # log natural, como na Aula 02
w <- tf * idf

cosseno <- function(a, b) {
  na <- sqrt(sum(a^2)); nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(0)
  sum(a * b) / (na * nb)
}
```

Dimensão da TDM: **45 termos x 8 documentos** (igual à aula).

---

# Três consultas e rankings

## 1) `"modelo de recuperacao"`

| Rank | Doc | Cosseno | Texto |
|:-:|:-:|--:|---|
| 1 | **d1** | 0,254 | recuperacao de informacao ordena documentos por relevancia |
| 2 | d3 | 0,233 | bm25 e um modelo probabilistico de ranqueamento de texto |
| 3 | d4 | 0,215 | aprendizado estatistico fundamenta a recuperacao moderna |
| 4 | d2 | 0,208 | o modelo de espaco vetorial representa documentos como vetores |
| 5 | d6 | 0,025 | embeddings capturam a semantica de palavras e documentos |
| 6 | d8 | 0,023 | ciencia de dados combina estatistica e programacao |
| 7 | d5 | 0,000 | o indice invertido acelera a busca em muitos documentos |
| 8 | d7 | 0,000 | a avaliacao mede a relevancia dos resultados da busca |

**Melhor: d1.** Confere com o exemplo da aula (mesmo escore 0,254).

## 2) `"busca documentos indice"`

| Rank | Doc | Cosseno | Observação |
|:-:|:-:|--:|---|
| 1 | **d5** | 0,505 | indice + busca + documentos |
| 2 | d7 | 0,142 | tem `busca` |
| 3 | d1 | 0,044 | tem `documentos` |
| 4 | d6 | 0,042 | tem `documentos` |
| 5 | d2 | 0,036 | tem `documentos` |
| 6-8 | d3, d4, d8 | 0,000 | nenhum termo da consulta |

**Melhor: d5.**

## 3) `"ciencia de dados estatistica"`

| Rank | Doc | Cosseno | Observação |
|:-:|:-:|--:|---|
| 1 | **d8** | 0,761 | ciencia + dados + estatistica |
| 2 | d3 | 0,024 | só o `de` |
| 3-5 | d1, d6, d2 | ~0,01 | só o `de` |
| 6-8 | d4, d5, d7 | 0,000 | `estatistico` != `estatistica` |

**Melhor: d8.** O d4 não sobe porque o corpus tem `estatistico` (sem "a"),
não `estatistica` - limite da tokenização exata / bag of words.

---

# Correlação com a Atividade 02

| | Atividade 02 | Atividade 04 |
|---|---|---|
| Corpus | Real (Porto / APS / Francisco) | Brinquedo (8 docs) - pedido da Aula 02 |
| Achado | Frequência bruta != relevância | Ranking por TF-IDF + cosseno |
| Papel | Base textual do semestre | Modelo de ranqueamento |

Sequência: Atividade 02 (problema) -> Atividade 03 (por que pesar) ->
Atividade 04 (como ordenar).

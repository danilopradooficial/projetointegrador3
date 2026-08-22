<div align="center">

# Atividade 04 - Vetores TF-IDF e similaridade do cosseno

**Projeto Integrador III · Ciência de Dados · FATEC**

Primeiro ranking de verdade: documentos e consulta como vetores,
pesos TF-IDF e ordenação pela similaridade do cosseno.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Aula](https://img.shields.io/badge/aula-02-lightgrey)

</div>

---

## Sobre a atividade

Sair da busca booleana (“o termo aparece?”) e medir *o quanto* o
documento combina com a consulta - Modelo do Espaço Vetorial + cosseno.

> **Meta:** implementar TF-IDF e `cosseno` no corpus de 8 documentos
> da Aula 01, escolher 3 consultas e reportar o ranking de cada uma.

**Material:**
[Aula 02 - Vetores TF-IDF e Similaridade do Cosseno](../../MateriaisAulas/Aula%2002%20-%20Vetores%20TF-IDF%20e%20Similaridade%20do%20Cosseno.PDF)
· [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
└── tfidf_cosseno.R    # TDM → TF-IDF → cosseno → 3 rankings
```

---

## Como rodar

```bash
cd "Atividades/Atividade 04"
Rscript tfidf_cosseno.R
```

Apenas **R base**.

---

## Implementação (Aula 02)

1. Tokenizar + vocabulário + matriz termo-documento (45 × 8)
2. `idf <- log(N / df)` e `w <- tf * idf`
3. Função `cosseno(a, b) = sum(a*b) / (‖a‖ ‖b‖)`
4. Vetorizar a consulta com o mesmo `vocab` / `idf`
5. `scores <- apply(w, 2, …)` e ordenar

```r
cosseno <- function(a, b) {
  sum(a * b) / (sqrt(sum(a^2)) * sqrt(sum(b^2)))
}
```

---

## Três consultas e rankings

### 1) `"modelo de recuperacao"`

| Rank | Doc | Cosseno | Texto |
|:-:|:-:|--:|---|
| 1 | **d1** | 0,254 | recuperacao de informacao ordena documentos por relevancia |
| 2 | d3 | 0,233 | bm25 e um modelo probabilistico de ranqueamento de texto |
| 3 | d4 | 0,215 | aprendizado estatistico fundamenta a recuperacao moderna |
| 4 | d2 | 0,208 | o modelo de espaco vetorial representa documentos como vetores |
| 5 | d6 | 0,025 | embeddings capturam a semantica de palavras e documentos |
| 6 | d8 | 0,023 | ciencia de dados combina estatistica e programacao |
| 7-8 | d5, d7 | 0,000 | sem termos da consulta |

**Melhor: d1** - bate com o exemplo da aula. Fala de recuperação/informação;
d3 sobe por `modelo` + `de` repetido.

### 2) `"busca documentos indice"`

| Rank | Doc | Cosseno | Por quê |
|:-:|:-:|--:|---|
| 1 | **d5** | 0,505 | índice invertido + busca + documentos |
| 2 | d7 | 0,142 | tem `busca` |
| 3 | d1 | 0,044 | tem `documentos` |
| 4 | d6 | 0,042 | tem `documentos` |
| 5 | d2 | 0,036 | tem `documentos` |
| 6-8 | d3, d4, d8 | 0,000 | nenhum termo da consulta |

**Melhor: d5** - única com `indice` e `busca` juntos.

### 3) `"ciencia de dados estatistica"`

| Rank | Doc | Cosseno | Por quê |
|:-:|:-:|--:|---|
| 1 | **d8** | 0,761 | ciencia + dados + estatistica |
| 2 | d3 | 0,024 | só o `de` (stopword) |
| 3-5 | d1, d6, d2 | ~0,01 | só o `de` |
| 6-8 | d4, d5, d7 | 0,000 | `estatistico` ≠ `estatistica` |

**Melhor: d8** - match quase perfeito. d4 não sobe porque o corpus tem
`estatistico` (sem o “a”), não `estatistica` - limite da tokenização exata.

---

## Discussão

**Cosseno ignora o tamanho do documento.** Mede ângulo, não comprimento.

**Booleano não ordena; cosseno ordena.** Docs sem termos da consulta ficam em 0;
os que combinam ganham escore contínuo.

**Limite do espaço vetorial.** Termos independentes; sinônimos e morfologia
(`estatistico` / `estatistica`) não se encontram - motivação para recuperação
densa mais adiante.

### Leitura (aula)

- Manning et al., *IIR* - cap. 6
- Baeza-Yates & Ribeiro-Neto - cap. 3

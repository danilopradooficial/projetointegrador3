# Unidade de recuperação canônica (`d1.1`, `d2.1`, …)

**Team Shannon · PI III · Fatec Rubens Lara**

Este documento fixa a regra que vale para **todo o motor**: o ID `d1.1` no índice (Aula 03), no BM25 (Aula 04) e no julgamento (Aula 05) é **a mesma frase**.

---

## O que é um documento `dN.k`

| ID | Significado |
|---|---|
| `d1`, `d2`, `d3` | Artigo completo (Wikipédia) |
| `d1.1`, `d1.2`, … | Frases do artigo `d1`, na ordem do texto |
| `d2.1`, … | Frases do artigo `d2` |
| `d3.1`, … | Frases do artigo `d3` |

**Contagem atual**

| Artigo | Arquivo | Frases |
|---|---|--:|
| `d1` Porto de Santos | `porto_de_santos.txt` | 88 |
| `d2` Autoridade Portuária | `autoridade_portuaria_de_santos.txt` | 29 |
| `d3` Francisco de Paula Ribeiro | `francisco_de_paula_ribeiro.txt` | 5 |
| **Total de frases** | | **122** |
| **Total indexável** | 3 artigos + 122 frases | **125** |

Exemplo:

> **`d1.1`** — *Porto de Santos é um porto estuarino, localizado nos municípios de Santos, Guarujá e Cubatão, no estado de São Paulo.*

---

## Regra de fatiamento (única no projeto)

Implementada em [`estrutura/codigos/ler-frases-comum.R`](../estrutura/codigos/ler-frases-comum.R):

1. Junta o `.txt` em um único bloco de texto.
2. Protege abreviações (`S.A.`, `Dr.`, …) e decimais (`8.630`).
3. Quebra por **ponto final / `!` / `?`** (frase com contexto).
4. Se a frase tiver **mais de 45 palavras** e existir **`;`**, parte no ponto e vírgula.
5. Descarta pedaços com menos de 3 palavras.

Não usamos mais corte por número fixo de palavras (ex.: 7–10) — isso perdia o sentido no julgamento.

---

## Onde a regra é usada (mesmos IDs)

| Etapa | Script | Como carrega |
|---|---|---|
| Aula 01 · corpus | `01a-corpus-aula-01.R` | `source("ler-frases-comum.R")` → `carregar_docs_canonico()` |
| Aula 03 · índice | `03-preprocessao-indice.R` | idem |
| Aula 04 · BM25 | `04-poisson-bm25.R` | idem |
| Aula 05 · CSV | `05-julgamento/05b-montar-corpus.R` | `source("../ler-frases-comum.R")` → `ler_frases()` |

Catálogo versionado:

- [`estrutura/corpus/frases-canonicas.csv`](../estrutura/corpus/frases-canonicas.csv) — `id`, `artigo`, `texto`
- [`estrutura/codigos/05-julgamento/csv/05-corpus.csv`](../estrutura/codigos/05-julgamento/csv/05-corpus.csv) — mesmo texto, no formato do `julgar.html`

Ao rodar `05b-montar-corpus.R`, os dois CSVs são regravados juntos.

---

## Como regenerar / conferir

```bash
cd estrutura/codigos
Rscript 01a-corpus-aula-01.R          # usa os IDs canônicos
Rscript 03-preprocessao-indice.R
Rscript 04-poisson-bm25.R

cd 05-julgamento
Rscript 05b-montar-corpus.R           # atualiza 05-corpus.csv + frases-canonicas.csv
Rscript 05d-gerar-pool.R              # pool por juiz (Adriane / Danilo / Victória)
```

Conferência rápida: o texto de `d1.1` impresso no fim do `05b` deve ser igual ao `docs[["d1.1"]]` da Atividade 01.

---

## Julgamento (Aula 05) — fatias

Pool enxuto (~20 min/pessoa), com os **mesmos** IDs:

| Juiz | Itens | Estimativa |
|---|--:|---|
| Adriane | 60 | ~15 min |
| Danilo | 60 | ~15 min |
| Victória | 60 | ~15 min |

Arquivos: `05-necessidades.csv` (perguntas objetivas), `05-pool.csv` (coluna `juiz`), `05-julgar.html` (combobox).

Relatório: [05-julgamento-pooling-kappa.md](05-julgamento-pooling-kappa.md).

---

## Relatórios por atividade

| Atividade | Relatório |
|---|---|
| 01a Corpus | [01a-primeiro-corpus-real.md](01a-primeiro-corpus-real.md) |
| 03 Índice | [03-limpeza-stopwords-stemming-indice.md](03-limpeza-stopwords-stemming-indice.md) |
| 04 BM25 | [04-poisson-saturacao-bm25.md](04-poisson-saturacao-bm25.md) |
| 05 Julgamento | [05-julgamento-pooling-kappa.md](05-julgamento-pooling-kappa.md) |

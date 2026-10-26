# Projeto Integrador III - Team Shannon

**Ciência de Dados · Fatec Rubens Lara - Baixada Santista**

Construção incremental de um motor de busca (Information Retrieval → MIR).

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Equipe](https://img.shields.io/badge/equipe-Team%20Shannon-0B3954)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)

---

## Sobre a disciplina

**Objetivo:** compreender sistemas de recuperação de informação e construir o próprio motor de busca.

**Professor:**  
Prof. Dr. João Paulo Ferreira de Mello  
([joao.mello12@fatec.sp.gov.br](mailto:joao.mello12@fatec.sp.gov.br))

**Equipe:** Team Shannon  

**Alunos:**  
Adriane da Costa Santos  
([adriane.santos01@aluno.cps.sp.gov.br](mailto:adriane.santos01@aluno.cps.sp.gov.br))

Danilo Prado de Lima Silva  
([danilo.silva25@aluno.cps.sp.gov.br](mailto:danilo.silva25@aluno.cps.sp.gov.br))

Victória Cabral Quintério  
([victoria.quinterio@aluno.cps.sp.gov.br](mailto:victoria.quinterio@aluno.cps.sp.gov.br))

**Linguagem:** R base (Ativ. 00-02). A partir da 03: R + `SnowballC`.

---

## Estrutura do repositório

```
.
├── README.md
├── estrutura/
│   ├── corpus/                   # artigos wiki + frases-canonicas.csv
│   └── codigos/                  # todos os scripts .R
│       ├── 00-introducao-ao-r.R
│       ├── 01a-ler-frases.R      # regra canônica de frase (IDs d1.1…)
│       ├── 01a-corpus-aula-01.R
│       ├── 01b-shannon-pesos.R
│       ├── 02-tfidf-cosseno.R
│       ├── 03-preprocessao-indice.R
│       ├── 04-poisson-bm25.R
│       ├── 05b-metricas.R
│       ├── 06-rocchio.R
│       ├── 07-lsa-rrf.R
│       ├── config.R              # modelo, lsa_k, rrf_c
│       ├── coletar.R · buscar.R · aula02.R
│       ├── csv/
│       └── 05-julgamento/        # Aula 05a (κ, pool, HTML, qrels)
├── consolidados-aulas/           # relatórios técnicos das atividades
├── consolidados-tutora/          # diários Colab (teoria + Parte D)
├── materiais-aulas/              # PDFs / slides do professor
├── materiais-tutora/             # GUIA_ESTUDO_*.md
├── entregas/                     # entregas avaliadas (meio de semestre)
│   └── entrega-1/
└── .to-delete-trash/             # layout antigo
```

| Pasta | Conteúdo |
|---|---|
| `estrutura/corpus` | Artigos wiki + `frases-canonicas.csv` |
| `estrutura/codigos` | Códigos R do motor |
| `estrutura/codigos/05-julgamento` | Aula 05a (κ, corpus, pool, HTML, qrels) |
| `consolidados-aulas` | Relatórios técnicos das atividades (grupo) |
| `consolidados-tutora` | Diários Colab: teoria (Danilo) + Parte D (grupo; Aula 00 Parte D individual) |
| `materiais-aulas` | Slides/PDFs do professor |
| `materiais-tutora` | Guias `GUIA_ESTUDO_*.md` |
| `entregas` | Entregas avaliadas (PDF, .Rnw, código) e modelos do professor |
| `.to-delete-trash` | Layout antigo - pode apagar depois de conferir |

**Unidade de recuperação (IDs** `d1.1`**…):** [Atividade 01a](consolidados-aulas/01a-primeiro-corpus-real.md) (`01a-ler-frases.R`) - a mesma frase em 01a → 07.

**Ficha do projeto:** [`consolidados-aulas/00_FICHA_PROJETO.md`](consolidados-aulas/00_FICHA_PROJETO.md) ·  
`config.R`: `modelo = hibrido`, `lsa_k = 20`, `rrf_c = 60`.

---

## Atividades × Aulas

| # | Entrega (atividade) | Script | Tutora (teoria) | Tutora (Parte D) | Aula |
|---|---|---|---|---|---|
| - | [00_FICHA_PROJETO.md](consolidados-aulas/00_FICHA_PROJETO.md) | `config.R` | - | - | ficha |
| 00 | [00-introducao-ao-r.md](consolidados-aulas/00-introducao-ao-r.md) | `00-introducao-ao-r.R` | [aula00_consolidado.md](consolidados-tutora/aula00_consolidado.md) | [aula00_parteD_consolidado.md](consolidados-tutora/aula00_parteD_consolidado.md) | Aula 00 |
| 01a | [01a-primeiro-corpus-real.md](consolidados-aulas/01a-primeiro-corpus-real.md) | `01a-corpus-aula-01.R` | [aula01_consolidado.md](consolidados-tutora/aula01_consolidado.md) | [aula01_parteD_consolidado.md](consolidados-tutora/aula01_parteD_consolidado.md) | Aula 01 |
| 01b | [01b-shannon-pesos-dos-termos.md](consolidados-aulas/01b-shannon-pesos-dos-termos.md) | `01b-shannon-pesos.R` | - | - | Aula 01.5 |
| 02 | [02-tfidf-similaridade-cosseno.md](consolidados-aulas/02-tfidf-similaridade-cosseno.md) | `02-tfidf-cosseno.R` | [aula02_consolidado.md](consolidados-tutora/aula02_consolidado.md) | [aula02_parteD_consolidado.md](consolidados-tutora/aula02_parteD_consolidado.md) | Aula 02 |
| 03 | [03-limpeza-stopwords-stemming-indice.md](consolidados-aulas/03-limpeza-stopwords-stemming-indice.md) | `03-preprocessao-indice.R` | [aula03_consolidado.md](consolidados-tutora/aula03_consolidado.md) | [aula03_parteD_consolidado.md](consolidados-tutora/aula03_parteD_consolidado.md) | Aula 03 |
| 04 | [04-poisson-saturacao-bm25.md](consolidados-aulas/04-poisson-saturacao-bm25.md) | `04-poisson-bm25.R` | [aula04_consolidado.md](consolidados-tutora/aula04_consolidado.md) | [aula04_parteD_consolidado.md](consolidados-tutora/aula04_parteD_consolidado.md) | Aula 04 |
| 05a | [05a-julgamento-pooling-kappa.md](consolidados-aulas/05a-julgamento-pooling-kappa.md) | `05-julgamento/05a-kappa.R` | [aula05_consolidado.md](consolidados-tutora/aula05_consolidado.md) | [aula05_parteD_consolidado.md](consolidados-tutora/aula05_parteD_consolidado.md) | Aula 05 |
| 05b | [05b-metricas-avaliacao.md](consolidados-aulas/05b-metricas-avaliacao.md) | `05b-metricas.R` | [aula05b_consolidado.md](consolidados-tutora/aula05b_consolidado.md) | [aula05b_parteD_consolidado.md](consolidados-tutora/aula05b_parteD_consolidado.md) | Aula 5,5 |
| 06 | [06-rocchio-expansao-pseudo-feedback.md](consolidados-aulas/06-rocchio-expansao-pseudo-feedback.md) | `06-rocchio.R` | [aula06_consolidado.md](consolidados-tutora/aula06_consolidado.md) | [aula06_parteD_consolidado.md](consolidados-tutora/aula06_parteD_consolidado.md) | Aula 06 |
| 07 | [07-lsa-fusao-rankings.md](consolidados-aulas/07-lsa-fusao-rankings.md) | `07-lsa-rrf.R` | [aula07_consolidado.md](consolidados-tutora/aula07_consolidado.md) | [aula07_parteD_consolidado.md](consolidados-tutora/aula07_parteD_consolidado.md) | Aula 07 |

Funil: R base → corpus wiki (frases) → IDF → TF-IDF → limpeza/índice → BM25 → gabarito/κ → métricas → Rocchio/PRF → LSA/RRF.

Guias Colab: [`materiais-tutora/`](materiais-tutora/) · diários: [`consolidados-tutora/`](consolidados-tutora/) (sem seção "Estado do R"). Aula 01.5 (Shannon) não tem guia próprio da tutora.

### Entregas avaliadas

| Entrega | Documento | Script | Prazo |
|---|---|---|---|
| 1 - Corpus / meio de semestre | [entrega-1-corpus.pdf](entregas/entrega-1/entrega-1-corpus.pdf) ([.Rnw](entregas/entrega-1/entrega-1-corpus.Rnw)) | [entrega-1-corpus.R](entregas/entrega-1/entrega-1-corpus.R) | 06/10 |

Ficha: [`00_FICHA_PROJETO.md`](consolidados-aulas/00_FICHA_PROJETO.md) · modelo do professor em [`entregas/entrega-1/modelo-professor/`](entregas/entrega-1/modelo-professor/).

---

## Como rodar os códigos

### Entrega de meio de semestre (o que o professor clona e roda)

```bash
cd estrutura/codigos
Rscript coletar.R                        # regenera frases-canonicas.csv a partir dos .txt
Rscript buscar.R                         # auditoria senior (Booleano·TF-IDF·cosseno·BM25·qrels)
Rscript aula02.R                         # top-5 cosseno apenas (teste minimo da ficha)
Rscript entrega-meio-semestre-demo.R     # mesma auditoria (alias / CSV)
```

Ficha: [`consolidados-aulas/00_FICHA_PROJETO.md`](consolidados-aulas/00_FICHA_PROJETO.md)  
CSV de auditoria: `estrutura/codigos/csv/entrega-meio-semestre-auditoria.csv`  
LaTeX (extra): `pdflatex entregas/entrega-1/modelo-professor/entrega-meio-semestre.tex`

### Pipeline completo das aulas

```bash
cd estrutura/codigos
Rscript 00-introducao-ao-r.R
Rscript 01a-corpus-aula-01.R
Rscript 01b-shannon-pesos.R
Rscript 02-tfidf-cosseno.R
Rscript 03-preprocessao-indice.R
Rscript 04-poisson-bm25.R

cd 05-julgamento
Rscript 05a-kappa.R
Rscript 05b-montar-corpus.R
Rscript 05c-ficha-corpus.R
Rscript 05d-gerar-pool.R
# abrir 05-julgar.html → carregar csv/05-*.csv → exportar 05-qrels.csv
Rscript 05e-consolidar-qrels.R

cd ..
Rscript 05b-metricas.R
Rscript 06-rocchio.R
Rscript 07-lsa-rrf.R
```

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
│   ├── corpus/
│   │   ├── *.txt                    # artigos wiki
│   │   └── frases-canonicas.csv     # IDs d1.1… (fonte única)
│   └── codigos/
│       ├── ler-frases-comum.R       # regra canônica de frase
│       ├── 00-introducao-ao-r.R
│       ├── 01a-corpus-aula-01.R
│       ├── 01b-shannon-pesos.R
│       ├── 02-tfidf-cosseno.R
│       ├── 03-preprocessao-indice.R
│       ├── 04-poisson-bm25.R
│       └── 05-julgamento/
│           ├── 05a-kappa.R
│           ├── 05b-montar-corpus.R
│           ├── 05c-ficha-corpus.R
│           ├── 05d-gerar-pool.R
│           ├── 05-julgar.html
│           └── csv/
│               ├── 05-corpus.csv
│               ├── 05-necessidades.csv
│               ├── 05-pool.csv
│               └── 05-qrels.csv
├── consolidados/
├── materiais-aulas/            # PDFs + GUIA/PROMPT da Aula 05
└── to-delete-trash/
```

**Unidade de recuperação (obrigatório ler):**  
[`consolidados/unidade-recuperacao-frases.md`](consolidados/unidade-recuperacao-frases.md) — define `d1.1`, `d1.2`, … iguais em 01a → 05.

Relatório da Aula 05: [`consolidados/05-julgamento-pooling-kappa.md`](consolidados/05-julgamento-pooling-kappa.md).

| Pasta | Conteúdo |
|---|---|
| `estrutura/corpus` | Artigos wiki + `frases-canonicas.csv` |
| `estrutura/codigos` | Scripts R do motor + `ler-frases-comum.R` |
| `estrutura/codigos/05-julgamento` | Aula 05 (κ, corpus, pool, HTML) |
| `consolidados` | Relatórios em Markdown |
| `materiais-aulas` | Slides/PDFs e materiais do professor |

---

## Como o motor está sendo montado

| Entrega | Arquivo MD | Script | Tema |
|:-:|---|---|---|
| 1ª | [00-introducao-ao-r.md](consolidados/00-introducao-ao-r.md) | `00-introducao-ao-r.R` | R base (Aula 00) |
| 2ª A | [01a-primeiro-corpus-real.md](consolidados/01a-primeiro-corpus-real.md) | `01a-corpus-aula-01.R` | Corpus · frequências (Aula 01) |
| 2ª B | [01b-shannon-pesos-dos-termos.md](consolidados/01b-shannon-pesos-dos-termos.md) | `01b-shannon-pesos.R` | Shannon · IDF (Aula 01.5) |
| 3ª | [02-tfidf-similaridade-cosseno.md](consolidados/02-tfidf-similaridade-cosseno.md) | `02-tfidf-cosseno.R` | TF-IDF · cosseno (Aula 02) |
| 4ª | [03-limpeza-stopwords-stemming-indice.md](consolidados/03-limpeza-stopwords-stemming-indice.md) | `03-preprocessao-indice.R` | Limpeza · Snowball · índice (Aula 03) |
| 5ª | [04-poisson-saturacao-bm25.md](consolidados/04-poisson-saturacao-bm25.md) | `04-poisson-bm25.R` | Poisson · BM25 (Aula 04) |
| 6ª | [05-julgamento-pooling-kappa.md](consolidados/05-julgamento-pooling-kappa.md) | `05-julgamento/05a-kappa.R` | Julgamento · pooling · κ (Aula 05) |

**IDs canônicos:** [unidade-recuperacao-frases.md](consolidados/unidade-recuperacao-frases.md) (`ler-frases-comum.R`).

```
R base → corpus wiki (frases por ponto) → IDF → TF-IDF → limpeza/índice → BM25 → gabarito/κ
```

---

## Como rodar os códigos

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
```

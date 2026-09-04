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
│   ├── corpus/                 # base textual (3 artigos wiki)
│   │   ├── porto_de_santos.txt
│   │   ├── autoridade_portuaria_de_santos.txt
│   │   └── francisco_de_paula_ribeiro.txt
│   └── codigos/                # todos os scripts .R
│       ├── 00-introducao-ao-r.R
│       ├── 01a-corpus-aula-01.R
│       ├── 01b-shannon-pesos.R
│       ├── 02-tfidf-cosseno.R
│       ├── 03-preprocessao-indice.R
│       └── 04-poisson-bm25.R
├── consolidados/               # todas as entregas .md
│   ├── 00-introducao-ao-r.md
│   ├── 01a-primeiro-corpus-real.md
│   ├── 01b-shannon-pesos-dos-termos.md
│   ├── 02-tfidf-similaridade-cosseno.md
│   ├── 03-limpeza-stopwords-stemming-indice.md
│   └── 04-poisson-saturacao-bm25.md
├── materiais-aulas/            # PDFs das aulas
└── to-delete-trash/            # pasta antiga Atividades/ (lixo)
```

| Pasta | Conteúdo |
|---|---|
| `estrutura/corpus` | Base textual única do semestre |
| `estrutura/codigos` | Códigos R do motor |
| `consolidados` | Relatórios/entregas em Markdown |
| `materiais-aulas` | Slides/PDFs |
| `to-delete-trash` | Layout antigo - pode apagar depois de conferir |

---

## Como o motor está sendo montado

Base: três artigos da Wikipédia (Porto de Santos, APS, Francisco de Paula Ribeiro).

| Entrega | Arquivo MD | Script | Tema |
|:-:|---|---|---|
| 1ª | [00-introducao-ao-r.md](consolidados/00-introducao-ao-r.md) | `00-introducao-ao-r.R` | R base (Aula 00) |
| 2ª A | [01a-primeiro-corpus-real.md](consolidados/01a-primeiro-corpus-real.md) | `01a-corpus-aula-01.R` | Corpus · frequências (Aula 01) |
| 2ª B | [01b-shannon-pesos-dos-termos.md](consolidados/01b-shannon-pesos-dos-termos.md) | `01b-shannon-pesos.R` | Shannon · IDF (Aula 01.5) |
| 3ª | [02-tfidf-similaridade-cosseno.md](consolidados/02-tfidf-similaridade-cosseno.md) | `02-tfidf-cosseno.R` | TF-IDF · cosseno (Aula 02) |
| 4ª | [03-limpeza-stopwords-stemming-indice.md](consolidados/03-limpeza-stopwords-stemming-indice.md) | `03-preprocessao-indice.R` | Limpeza · Snowball · índice (Aula 03) |
| 5ª | [04-poisson-saturacao-bm25.md](consolidados/04-poisson-saturacao-bm25.md) | `04-poisson-bm25.R` | Poisson · BM25 (Aula 04) |

```
R base → corpus wiki → IDF → TF-IDF → limpeza/índice → BM25
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
```

Os scripts que leem texto usam `estrutura/corpus` (caminho relativo `../corpus`).

<div align="center">

# Motor de Busca — Projeto Integrador III

**Ciência de Dados · FATEC**

Construindo um motor de busca do zero: dos modelos clássicos de
*Information Retrieval* até técnicas neurais e busca por fórmulas
matemáticas (MIR).

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)

</div>

---

## Sobre a disciplina

Este repositório documenta a construção incremental de um motor de busca,
partindo dos fundamentos de **Recuperação de Informação (RI)** — tokenização,
vocabulário, matriz termo-documento — até chegar em modelos de ranqueamento
(TF-IDF, BM25), recuperação densa, *rerank* neural e busca por fórmulas
matemáticas.

> **Meta do projeto:** construir um motor de busca completo sobre um
> *corpus* real, aula após aula, como parte da disciplina Projeto Integrador
> III.

---

## Estrutura do repositório

```
.
├── README.md                 # visão geral da disciplina
├── Atividades/
│   ├── Atividade 01/         # Aula 00 — introdução ao R
│   ├── Atividade 02/         # Aula 01 — primeiro corpus real
│   ├── Atividade 03/         # Aula 01.5 — Shannon e pesos dos termos
│   └── Atividade 04/         # Aula 02 — TF-IDF e similaridade do cosseno
└── MateriaisAulas/
    ├── Aula 00 - O Básico para Acompanhar o Curso.PDF
    ├── Aula 01 - Do Problema da Busca ao Nosso Motor.PDF
    ├── Aula 01.5 - Do Shannon aos Pesos dos Termos.PDF
    └── Aula 02 - Vetores TF-IDF e Similaridade do Cosseno.PDF
```

---

## Atividades × aulas

Cada pasta em [`Atividades/`](Atividades) corresponde a uma aula em
[`MateriaisAulas/`](MateriaisAulas) e tem o próprio `README.md` com o
detalhe da entrega.

| # | Pasta | Aula | Tema | Status |
|:-:|---|---|---|---|
| 01 | [Atividade 01](Atividades/Atividade%2001) | [Aula 00](MateriaisAulas/Aula%2000%20-%20O%20Básico%20para%20Acompanhar%20o%20Curso.PDF) | Introdução ao R (Explicar · Explorar · Prever) | Entregue |
| 02 | [Atividade 02](Atividades/Atividade%2002) | [Aula 01](MateriaisAulas/Aula%2001%20-%20Do%20Problema%20da%20Busca%20ao%20Nosso%20Motor.PDF) | Corpus real · tokenização · vocabulário · frequências | Entregue |
| 03 | [Atividade 03](Atividades/Atividade%2003) | [Aula 01.5](MateriaisAulas/Aula%2001.5%20-%20Do%20Shannon%20aos%20Pesos%20dos%20Termos.PDF) | Shannon · autoinformação · IDF como bits | A fazer |
| 04 | [Atividade 04](Atividades/Atividade%2004) | [Aula 02](MateriaisAulas/Aula%2002%20-%20Vetores%20TF-IDF%20e%20Similaridade%20do%20Cosseno.PDF) | Espaço vetorial · TF-IDF · cosseno · ranking | A fazer |

---

## Roadmap

```
Aula 00    █ R base e ferramentas da disciplina
Aula 01    █ Corpus, tokens, vocabulário, frequências
Aula 01.5  ░ Shannon e pesos dos termos (IDF = bits)
Aula 02    ░ Vetores TF-IDF e similaridade do cosseno
…          ░ BM25 · recuperação densa · rerank · MIR
```

---

## Material de aula

O material teórico fica em [`MateriaisAulas/`](MateriaisAulas).
As entregas práticas ficam em [`Atividades/`](Atividades).

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

## Sobre o projeto

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
├── README.md
├── Atividades/
│   ├── Atividade 01/          # Aula 0 — introdução ao R
│   └── Atividade 02/          # Aula 01 — primeiro corpus real
└── MaterialAula/
    ├── Aula 00 - O Básico para Acompanhar o Curso.PDF
    ├── Aula 01 - Do Problema da Busca ao Nosso Motor.PDF
    ├── Aula 01.5 - Do Shannon aos Pesos dos Termos.PDF
    └── Aula 02 - Vetores TF-IDF e Similaridade do Cosseno.PDF
```

---

## Atividades

| # | Pasta | Tema | Status |
|:-:|---|---|---|
| 01 | [`Atividades/Atividade 01`](Atividades/Atividade%2001) | Introdução ao R (Explicar · Explorar · Prever) | Entregue |
| 02 | [`Atividades/Atividade 02`](Atividades/Atividade%2002) | Corpus real · tokenização · vocabulário · frequências | Entregue |

---

## Roadmap

```
Aula 0     █ R base e ferramentas da disciplina
Aula 01    █ Corpus, tokens, vocabulário, frequências
Aula 01.5  ░ Shannon e pesos dos termos
Aula 02    ░ Vetores TF-IDF e similaridade do cosseno
…          ░ BM25 · recuperação densa · rerank · MIR
```

---

## Como navegar

Cada atividade tem o próprio `README.md` com enunciado, estrutura local,
como rodar (quando houver script) e discussão dos resultados.

O material teórico das aulas fica em [`MaterialAula/`](MaterialAula).

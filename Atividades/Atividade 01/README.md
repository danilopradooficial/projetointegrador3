<div align="center">

# Atividade 01 - O básico para acompanhar o curso

**Projeto Integrador III · Ciência de Dados · FATEC**

Introdução ao R: vetores, texto, funções, `lapply`/`sapply`,
`table`/`factor`, matrizes e regex - no método
**Explicar · Explorar · Prever**.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Aula](https://img.shields.io/badge/aula-0-lightgrey)

</div>

---

## Sobre a atividade

Primeira entrega: sair do papel e mexer no R com os blocos vistos em sala.
Para cada trecho, seguimos os três passos pedidos:

1. **Explicar** - o que cada linha faz e por que existe
2. **Explorar** - alterar valor, argumento ou nome e observar o efeito
3. **Prever** - registrar a expectativa *antes* de rodar e comparar com o resultado

> **Meta da atividade:** dominar o kit mínimo de R que a Aula 01 usa no
> motor de busca (`docs` nomeado, `tokenizar`, `lapply`/`sapply`,
> `table` + `factor`, matrizes e limpeza com regex).

**Material de referência:**
[Aula 00 - O Básico para Acompanhar o Curso](../../MateriaisAulas/Aula%2000%20-%20O%20Básico%20para%20Acompanhar%20o%20Curso.PDF)
· [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
└── Atividade 01.pdf          # entrega completa (Partes 1, 2 e 3)
```

Entrega em PDF: [`Atividade 01.pdf`](Atividade%2001.pdf).

---

## Parte 1 - Explicar, Explorar e Prever

Treze blocos da aula, cada um com as três etapas:

| Bloco | Tema | Ligação com o motor |
|:-:|---|---|
| 1 | Atribuição e vetores (`c`, `sum`) | Objetos básicos em R |
| 2 | Vetores nomeados | Base de `docs["d5"]` |
| 3 | Texto (`toupper`, `strsplit`) | Normalização e quebra em tokens |
| 4 | `unlist` | Lista → vetor de palavras |
| 5 | Funções próprias | Molde de `tokenizar()` / `busca_booleana()` |
| 6 | `lapply` | Tokenizar o corpus inteiro |
| 7 | `sapply` | Lista → vetor/matriz simplificado |
| 8 | `table` | Frequência de termos |
| 9 | `factor` + `levels` | Vetores do mesmo tamanho (TDM) |
| 10 | Matrizes | Esqueleto da matriz termo-documento |
| 11 | Reciclagem `m * peso` | Preparação para `tfidf <- tdm * idf` |
| 12 | `%in%` e stopwords | Limpeza de termos |
| 13 | Regex (`grep`, `sub`, `gsub`) | Limpeza e filtros no texto |

---

## Parte 2 - Perguntas para investigar

| # | Pergunta | Conclusão prática |
|:-:|---|---|
| 1 | Trocar `sapply` ↔ `lapply` | Formato da saída muda; TDM precisa de matriz/vetor alinhado |
| 2 | Remover o `factor` em `table` | Sem `levels`, some termo com contagem 0 |
| 3 | `m * peso` com comprimento errado | R só avisa (*warning*) e recicla - risco no TF-IDF |
| 4 | Vetor nomeado + tokenizar + contar | Mini-corpus (Porto de Santos) e ranking de termos |

### Mini-corpus da pergunta 4 (top termos)

```
de / o / porto     ███  3
do / santos        ██   2
demais termos      █    1
```

---

## Parte 3 - O faxineiro de manchetes

Cinco missões de limpeza e busca sobre manchetes da Baixada Santista:

| Missão | O que fazer | Ferramenta |
|:-:|---|---|
| 1 | Remover o sufixo do jornal | `sub(" - A Tribuna$", …)` |
| 2 | Colapsar dois ou mais espaços | `gsub("\\s{2,}", " ", …)` |
| 3 | Achar manchete com ano (4 dígitos) | `grep("[0-9]{4}", …)` |
| 4 | Filtrar municípios (Guaruja / Cubatao) | `grep(..., ignore.case = TRUE)` |
| 5 | A “pegadinha” de *Santos* | `grepl("Santos", …)` - sintaxe ≠ semântica |

---

## Discussão

**A ordem das operações importa.** Tokenizar *antes* de `tolower` deixa
maiúsculas no vocabulário; na Aula 01 a sequência correta é normalizar
primeiro e só depois quebrar em tokens.

**`factor` + `levels` é pré-requisito da TDM.** Sem vocabulário fixo,
cada documento gera um vetor de tamanho diferente e a matriz
termo-documento não fecha.

**Regex limpa sintaxe, não significado.** O faxineiro de manchetes mostra
o limite da busca por padrão - ponto de partida para pesos, TF-IDF e,
mais adiante, modelos densos.

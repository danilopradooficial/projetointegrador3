<div align="center">

# Atividade 03 - De Shannon aos pesos dos termos

**Projeto Integrador III · Ciência de Dados · FATEC**

Entender o TF-IDF pela Teoria da Informação: incerteza em bits,
autoinformação de uma pista e por que o IDF não é heurística.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-a%20fazer-yellow)
![Aula](https://img.shields.io/badge/aula-01.5-lightgrey)

</div>

---

## Sobre a atividade

Terceira entrega: sair da fórmula decorada e derivar o peso dos termos
a partir de Shannon - a busca como problema de *seleção* entre
documentos, cada termo como pista que reduz incerteza.

> **Meta da atividade:** explicar, explorar e investigar os blocos da
> Aula 01.5 até responder, com o *corpus* de 8 documentos, quanto vale
> cada termo em bits e onde o TF-IDF “mente”.

**Material de referência:**
[Aula 01.5 - Do Shannon aos Pesos dos Termos](../../MateriaisAulas/Aula%2001.5%20-%20Do%20Shannon%20aos%20Pesos%20dos%20Termos.PDF)
· [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
└── (entregas a acrescentar: script .R e/ou PDF)
```

---

## Parte 1 - Explicar, Explorar e Prever

Para cada bloco de código da aula:

1. **Explicar** - o que cada linha faz e por que existe
2. **Explorar** - alterar valor, argumento ou termo e observar o efeito
3. **Prever** - registrar a expectativa *antes* de rodar e comparar

Blocos centrais da aula (orientação):

| Bloco | Tema | Ligação com o motor |
|:-:|---|---|
| 1 | `log2(N)` - incerteza inicial | Quantos bits para achar 1 entre N docs |
| 2 | Pista `busca` / `de` | Termo raro × stopword |
| 3 | `I(t) = log2(N / df)` | Autoinformação = IDF |
| 4 | `tf × I(t)` | Reconstrução do TF-IDF em bits |
| 5 | Consulta `"modelo de recuperacao"` | Escore = soma de bits por documento |
| 6 | Independência vs correlação | Quando a soma de bits superestima |
| 7 | Corpus das rotas (Baixada) | Limite do *bag of words* |

---

## Parte 2 - Perguntas para investigar

| # | Pergunta | O que responder |
|:-:|---|---|
| 1 | Corpus com 1024 docs; e se dobrar para 2048? | Custo em bits (`log2 N`) |
| 2 | Par de termos que superestima a informação real | Correlação (como `recuperacao` / `relevancia`) |
| 3 | Trocar `log2` por `log` no IDF | O ranking muda? Por quê? |
| 4 | Termo em *todos* os documentos | Quantos bits? O que isso diz sobre stopwords? |

---

## Como rodar (quando houver script)

Pré-requisito: [R](https://www.r-project.org/) instalado (apenas **R base**).

```bash
cd "Atividades/Atividade 03"
Rscript nome_do_script.R
```

Reaproveitar o *corpus* de 8 documentos da Aula 01 (e, se útil, o
*corpus* real da [Atividade 02](../Atividade%2002)).

---

## Discussão (guia)

**IDF = autoinformação.** `log(N / df)` mede quantos bits a pista paga
da dívida de `log2 N` - não é um truque empírico.

**A base do log muda a unidade, não o ranking.** `log2` → bits;
`log` (natural em R) → nats. A ordem dos documentos permanece.

**Stopword vale ~0 bits.** Termo em todos os docs: `I = log(N/N) = 0`.
Por isso o top 10 da Atividade 02 era dominado por `de`, `a`, `e`…

**TF-IDF mente em dois pontos** (aula): saturação da repetição
(BM25 corrige) e independência entre termos (embeddings / *rerank*
corrigem mais adiante).

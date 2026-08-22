<div align="center">

# Atividade 03 - De Shannon aos pesos dos termos

**Projeto Integrador III · Ciência de Dados · FATEC**

Entender o TF-IDF pela Teoria da Informação: incerteza em bits,
autoinformação de uma pista e por que o IDF não é heurística.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Aula](https://img.shields.io/badge/aula-01.5-lightgrey)

</div>

---

## Sobre a atividade

Derivamos o peso dos termos a partir de Shannon: a busca como problema
de *seleção* entre documentos, cada termo como pista que reduz incerteza.

> **Meta:** com o corpus de 8 documentos da Aula 01, medir bits por termo,
> reconstruir o TF-IDF e responder onde a fórmula “mente”.

**Material:**
[Aula 01.5 - Do Shannon aos Pesos dos Termos](../../MateriaisAulas/Aula%2001.5%20-%20Do%20Shannon%20aos%20Pesos%20dos%20Termos.PDF)
· [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
└── shannon_pesos.R    # Parte 1 (blocos) + Parte 2 (investigar)
```

---

## Como rodar

```bash
cd "Atividades/Atividade 03"
Rscript shannon_pesos.R
```

Apenas **R base**.

---

## Parte 1 - Explicar, Explorar e Prever

Corpus (igual ao da aula):

```r
docs <- c(
  d1 = "recuperacao de informacao ordena documentos por relevancia",
  d2 = "o modelo de espaco vetorial representa documentos como vetores",
  d3 = "bm25 e um modelo probabilistico de ranqueamento de texto",
  d4 = "aprendizado estatistico fundamenta a recuperacao moderna",
  d5 = "o indice invertido acelera a busca em muitos documentos",
  d6 = "embeddings capturam a semantica de palavras e documentos",
  d7 = "a avaliacao mede a relevancia dos resultados da busca",
  d8 = "ciencia de dados combina estatistica e programacao"
)
```

| Bloco | Tema | Explicar | Explorar / prever |
|:-:|---|---|---|
| 1 | `log2(N)` | Com 8 docs igualmente prováveis, bastam 3 perguntas sim/não | Trocar N muda o custo: `log2(16)=4` |
| 2 | Pistas `busca` / `de` | `busca` em d5,d7 (2 bits); `de` em 5 docs (~0,68 bit) | Termo raro estreita mais que stopword |
| 3 | `I(t)=log2(N/df)` | Autoinformação = IDF | `modelo` e `recuperacao`: 2 bits cada |
| 4-5 | Consulta em bits | Escore = soma `tf × I(t)` no documento | Ver ranking abaixo |
| 6 | Independência | Soma de bits pode *superestimar* se termos correlacionados | `busca`+`documentos` fecha em 3; `recuperacao`+`relevancia` soma 4 |
| 7 | Rotas Baixada | Mesmas cidades, ordem diferente | IDF=0 em todas → bag of words não distingue |

### Consulta `"modelo de recuperacao"` (bits)

IDF: `modelo=2,00` · `de=0,68` · `recuperacao=2,00`

| Doc | modelo | de | recuperacao | total |
|---|--:|--:|--:|--:|
| d3 | 2,00 | 1,36 | 0,00 | **3,36** |
| d1 | 0,00 | 0,68 | 2,00 | 2,68 |
| d2 | 2,00 | 0,68 | 0,00 | 2,68 |
| d4 | 0,00 | 0,00 | 2,00 | 2,00 |
| d6 / d8 | 0 | 0,68 | 0 | 0,68 |
| d5 / d7 | 0 | 0 | 0 | 0 |

Ranking: **d3 > d1 = d2 > d4 > d6 = d8 > d5 = d7**

Em d3, `de` vale 1,36 porque aparece **duas** vezes (2 × 0,68).

---

## Parte 2 - Perguntas para investigar

### 1) Corpus com 1024 docs; e se dobrar para 2048?

| N | `log2(N)` |
|--:|--:|
| 1024 | **10 bits** |
| 2048 | **11 bits** |

Dobrar o corpus adiciona exatamente **1 bit** de incerteza inicial.

### 2) Par que superestima a informação real

Além de `recuperacao` / `relevancia` (soma 4, real 3):

| Par | Interseção | Soma I | Real (`log2(N/|∩|)`) | Excesso |
|---|---|--:|--:|--:|
| `aprendizado` + `estatistico` | só d4 | 6,00 | 3,00 | +3 |
| `modelo` + `vetorial` | só d2 | 5,00 | 3,00 | +2 |

**Por quê?** Os termos co-ocorrem no mesmo documento/assunto: a segunda pista já era parcialmente esperada, então traz menos surpresa que seus bits nominais.

Contraste: `busca` + `documentos` → interseção d5, soma = 3 = real (independência ok neste caso).

### 3) Trocar `log2` por `log` no IDF: o ranking muda?

**Não.** Ordem idêntica com `log2` e `log` (natural).

Motivo: `log_b(x) = ln(x) / ln(b)`. Mudar a base só multiplica todos os pesos pela mesma constante positiva - a ordenação dos documentos permanece.

### 4) Termo em *todos* os documentos: quantos bits?

```text
I = log2(N / N) = log2(1) = 0 bits
```

Não discrimina ninguém. É o extremo das **stopwords**: no nosso corpus, `de` (df=5) já vale só ~0,68 bit - quase inútil para escolher o documento.

---

## Discussão

**IDF = autoinformação.** Não é truque empírico: mede quantos bits a pista paga da dívida de `log2 N`.

**TF-IDF mente em dois pontos** (aula): (1) repetição sem saturação - BM25 corrige; (2) independência entre termos - embeddings / rerank corrigem depois.

**Bits ≠ relevância.** Medem distinguibilidade, não utilidade semântica.

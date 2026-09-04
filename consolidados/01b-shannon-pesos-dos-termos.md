<div align="center">

# Atividade 01 · Parte B - De Shannon aos pesos dos termos

**Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Entender o TF-IDF pela Teoria da Informação: incerteza em bits,
autoinformação de uma pista e por que o IDF não é heurística.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Parte](https://img.shields.io/badge/parte-B%20Shannon-lightgrey)
![Aula](https://img.shields.io/badge/aula-01b-lightgrey)

</div>

---

## Sobre esta parte

A **Atividade 01** (2ª entrega) reúne Aula 01 e Aula 01.5 na mesma pasta:

| Parte | Tema | Arquivo |
|:-:|---|---|
| **A** | Corpus real · tokenização · frequências | [01a-primeiro-corpus-real.md](01a-primeiro-corpus-real.md) |
| **B** | Shannon · autoinformação · IDF como bits | este documento |

Derivamos o peso dos termos a partir de Shannon: a busca como problema
de *seleção* entre documentos, cada termo como pista que reduz incerteza.

> **Meta (Parte B):** com o corpus de 8 documentos da Aula 01, medir bits
> por termo, reconstruir o IDF e responder onde a fórmula "mente".

**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victoria Cabral Quinterio

---

## Sequência

```
Ativ 00 (R base)
    |
    v
Ativ 01 · Parte A (frequencia != relevancia)
    |
    v
Ativ 01 · Parte B (por que o IDF = bits)   <-- esta parte
    |
    v
Ativ 02 (TDM → TF-IDF + cosseno)
```

Responde à pergunta deixada em aberto no top 10 da Parte A
(Aula 01.5 no material do professor).

---

## Material de referência

- [Aula 01.5 - Do Shannon aos Pesos dos Termos](../materiais-aulas/Aula%2001.5%20-%20Do%20Shannon%20aos%20Pesos%20dos%20Termos.PDF)
- [Parte A desta atividade](01a-primeiro-corpus-real.md)
- [Atividade 02 - TF-IDF e cosseno](./02-tfidf-similaridade-cosseno.md)
- [README da disciplina](../README.md)

---

## Estrutura da pasta (Atividade 01)

```
estrutura/codigos/
└── 01b-shannon-pesos.R
consolidados/
└── 01b-shannon-pesos-dos-termos.md
```

---

## Como rodar (Parte B)

```bash
cd "estrutura/codigos"
Rscript 01b-shannon-pesos.R
```

Apenas **R base**.

---

# 1. Parte 1 - Explicar, Explorar e Prever

Para cada bloco de código da aula: explicamos o que faz, alteramos algo e
registramos o efeito, e prevemos o resultado antes de rodar.

Corpus (igual ao da Aula 01 / Aula 01.5):

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
tok <- function(x) unlist(strsplit(tolower(x), "\\s+"))
N <- length(docs)  # 8
```

---

## Bloco 1. Incerteza inicial - `log2(N)`

```r
log2(N)  # perguntas necessarias para achar 1 entre N
```

```
[1] 3
```

SAÍDA NO CONSOLE

**EXPLICAR**

Com 8 documentos igualmente prováveis, a incerteza inicial é `log2(8) = 3`
bits: no pior caso, bastam 3 perguntas de sim/não (8 -> 4 -> 2 -> 1). O
logaritmo conta quantas vezes dá para dividir N pela metade.

**EXPLORAR**

Testamos outros tamanhos de corpus:

```r
log2(16)
log2(1024)
log2(2048)
```

```
[1] 4
[1] 10
[1] 11
```

SAÍDA NO CONSOLE

Dobrar de 1024 para 2048 adiciona exatamente 1 bit.

**PREVER**

Antes de rodar, esperávamos `log2(16) = 4` e que dobrar N aumentasse o custo
em 1 bit. Confirmado: a incerteza cresce com o logaritmo, não linearmente
com o número de documentos.

---

## Bloco 2. Pistas `busca` vs `de`

```r
contem <- function(t) names(docs)[sapply(docs, function(d) t %in% tok(d))]
contem("busca")
log2(8 / 2)  # de 8 candidatos para 2
contem("de")
log2(8 / 5)
```

```
[1] "d5" "d7"
[1] 2
[1] "d1" "d2" "d3" "d6" "d8"
[1] 0.6780719
```

SAÍDA NO CONSOLE

**EXPLICAR**

`busca` aparece em 2 docs: a pista vale 2 bits (de 8 para 2). `de` aparece
em 5 docs: vale só ~0,68 bit. Termo raro estreita bem mais o conjunto do
que stopword.

**EXPLORAR**

Comparamos com um termo ainda mais raro:

```r
contem("bm25")
log2(8 / 1)  # I(bm25)
```

```
[1] "d3"
[1] 3
```

SAÍDA NO CONSOLE

`bm25` só em d3: vale os 3 bits inteiros - identifica o documento sozinho.

**PREVER**

Esperávamos que termo em 1 doc pagasse `log2(8/1) = 3` bits. Confirmado:
quanto menor o df, maior a autoinformação.

---

## Bloco 3. Autoinformação = IDF

```r
df <- c(modelo = 2, de = 5, recuperacao = 2)
round(log2(8 / df), 3)
```

```
     modelo        de recuperacao
      2.000     0.678       2.000
```

SAÍDA NO CONSOLE

**EXPLICAR**

`I(t) = log2(N / df_t)` é a mesma fórmula do IDF. O IDF não é heurística:
é a autoinformação do termo medida em bits.

**EXPLORAR**

Recalculamos com `log` (natural), como no código da Aula 01:

```r
round(log(8 / df), 3)  # nats, nao bits
```

```
     modelo        de recuperacao
      1.386     0.470       1.386
```

SAÍDA NO CONSOLE

Os números mudam (unidade diferente), mas a ordem entre termos permanece:
`modelo` = `recuperacao` > `de`.

**PREVER**

Esperávamos valores diferentes em magnitude, mesma ordenação relativa.
Confirmado: a base do log muda a unidade, não o ranking.

---

## Bloco 4-5. Consulta em bits (`tf * I`)

```r
# consulta: "modelo de recuperacao"
# contribuicao = tf * I(t) por documento; total = soma dos bits
```

| Doc | modelo | de | recuperacao | total |
|---|--:|--:|--:|--:|
| d3 | 2,00 | 1,36 | 0,00 | **3,36** |
| d1 | 0,00 | 0,68 | 2,00 | 2,68 |
| d2 | 2,00 | 0,68 | 0,00 | 2,68 |
| d4 | 0,00 | 0,00 | 2,00 | 2,00 |
| d6 / d8 | 0 | 0,68 | 0 | 0,68 |
| d5 / d7 | 0 | 0 | 0 | 0 |

Ranking: **d3 > d1 = d2 > d4 > d6 = d8 > d5 = d7**

**EXPLICAR**

Cada célula responde: quantos bits de evidência este termo fornece a favor
deste documento? O escore é a soma. Em d3, `de` vale 1,36 porque aparece
duas vezes (2 x 0,68).

**EXPLORAR**

Trocamos a consulta para `"busca documentos"`:

```r
# I(busca)=2, I(documentos)=1
# d5 tem os dois -> 2+1 = 3 bits (identifica sozinho entre 8)
```

```
intersecao busca ∩ documentos: d5
soma I = 3 = log2(8)
```

SAÍDA NO CONSOLE

**PREVER**

Esperávamos que d5 acumulasse exatamente 3 bits e ficasse sozinho.
Confirmado: neste par a aditividade fecha (termos mais independentes).

---

## Bloco 6. Independência vs correlação

```r
intersect(contem("recuperacao"), contem("relevancia"))
log2(8/2) + log2(8/2)  # 2 + 2 = 4
```

```
[1] "d1"
[1] 4
```

SAÍDA NO CONSOLE

**EXPLICAR**

Também sobrou 1 documento, mas a soma deu 4 bits e achar 1 entre 8 custa
só 3. Pagamos 1 bit a mais porque os termos não são independentes: co-ocorrem
no mesmo assunto.

**EXPLORAR**

Outro par correlacionado:

```r
intersect(contem("aprendizado"), contem("estatistico"))
log2(8/1) + log2(8/1)  # 3 + 3 = 6  (real = 3)
```

```
[1] "d4"
soma = 6 | real = 3 | excesso = 3
```

SAÍDA NO CONSOLE

**PREVER**

Esperávamos superestimativa grande: ambos só existem em d4. Confirmado.
A segunda pista já era quase certa depois da primeira.

---

## Bloco 7. Rotas da Baixada (bag of words)

```r
rotas <- c(
  r1 = "santos cubatao guaruja bertioga",
  r2 = "santos guaruja cubatao bertioga",
  r3 = "santos bertioga guaruja cubatao",
  r4 = "cubatao santos bertioga guaruja",
  r5 = "guaruja bertioga santos cubatao",
  r6 = "bertioga cubatao santos guaruja",
  r7 = "guaruja santos cubatao bertioga",
  r8 = "bertioga guaruja cubatao santos"
)
# todas as cidades em todas as rotas -> df = 8 -> IDF = 0
# necessario para achar 1 entre 8: 3 bits; disponivel: 0 bits
```

```
N rotas = 8 | bits necessarios = 3
santos cubatao guaruja bertioga
     0       0       0        0
```

SAÍDA NO CONSOLE

**EXPLICAR**

Oito rotas, mesmas quatro cidades, só muda a ordem. Para o saco de palavras,
todas são iguais: IDF = 0, TF-IDF nulo. Precisaríamos de 3 bits para achar
1 entre 8, mas o vocabulário oferece 0.

**EXPLORAR**

Se uma rota omitisse uma cidade, o IDF deixaria de ser zero e o contraste
apareceria. A diferença real (ordem do percurso) o bag of words joga fora
por construção.

**PREVER**

Esperávamos IDF zero em todas as cidades e busca impossível. Confirmado:
sem variação entre documentos, não há informação para a busca.

---

# 2. Parte 2 - Perguntas para investigar

### 1) Corpus com 1024 docs; e se dobrar para 2048?

| N | `log2(N)` |
|--:|--:|
| 1024 | **10 bits** |
| 2048 | **11 bits** |

Dobrar o corpus adiciona exatamente **1 bit** de incerteza inicial.

### 2) Par que superestima a informação real

Além de `recuperacao` / `relevancia` (soma 4, real 3):

| Par | Interseção | Soma I | Real | Excesso |
|---|---|--:|--:|--:|
| `aprendizado` + `estatistico` | só d4 | 6,00 | 3,00 | +3 |
| `modelo` + `vetorial` | só d2 | 5,00 | 3,00 | +2 |

Correlação: termos do mesmo assunto co-ocorrem; a segunda pista traz menos
surpresa que seus bits nominais.

### 3) Trocar `log2` por `log` no IDF: o ranking muda?

**Não.** Ordem idêntica. `log_b(x) = ln(x)/ln(b)` só muda a escala.

### 4) Termo em *todos* os documentos: quantos bits?

```text
I = log2(N / N) = 0 bits
```

Extremo das stopwords: não discrimina ninguém. No corpus, `de` (df=5) já
vale só ~0,68 bit.

---

# 3. Sequência e correlação

A Atividade 01 (2ª entrega) vem **depois** da 00 e **antes** da 02:

- **Atividade 01 · Parte A** mostrou que frequência bruta não ranqueia bem (stopwords).
- **Atividade 01 · Parte B** (esta) explica *por que* o IDF: bits de Shannon.
- **Atividade 02** aplica TDM → TF-IDF + cosseno para ordenar de verdade.

Próximo passo: [Atividade 02 - TF-IDF e cosseno](./02-tfidf-similaridade-cosseno.md).

<div align="center">

# Atividade 01 · Parte A - Do problema da busca ao nosso motor

**Team Shannon · Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Sair do *corpus* de brinquedo (8 documentos, 45 termos) e montar um
primeiro *corpus* real com artigos da Wikipédia: vetor `docs`,
tokenização, vocabulário e frequência de termos.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Parte](https://img.shields.io/badge/parte-A%20corpus-lightgrey)
![Aula](https://img.shields.io/badge/aula-01-lightgrey)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)

</div>

---

## Sobre esta parte

A **Atividade 01** (2ª entrega) reúne Aula 01 e Aula 01.5 na mesma pasta:

| Parte | Tema | Arquivo |
|:-:|---|---|
| **A** | Corpus real · tokenização · frequências | este documento |
| **B** | Shannon · autoinformação · IDF como bits | [01b-shannon-pesos-dos-termos.md](01b-shannon-pesos-dos-termos.md) |

Primeira entrega do motor de busca: aplicar no *corpus* real os mesmos
conceitos vistos em sala - carregar documentos, tokenizar, montar o
vocabulário e listar os termos mais frequentes.

> **Meta (Parte A):** construir o primeiro *corpus* real do projeto e medir
> o salto em relação ao corpus de brinquedo da aula (45 termos).

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victoria Cabral Quinterio

---

## Material de referência

- [Aula 01 - Do Problema da Busca ao Nosso Motor](../materiais-aulas/Aula%2001%20-%20Do%20Problema%20da%20Busca%20ao%20Nosso%20Motor.PDF)
- [Parte B desta atividade](01b-shannon-pesos-dos-termos.md)
- [README da disciplina](../README.md)

---

## Corpus

Três artigos da Wikipédia em português, todos ligados ao Porto de Santos.
Cada artigo vira um documento `dN`; cada **frase pontuada** (ponto final) vira `dN.k`.
Frases muito longas são partidas em `;` quando existe ponto e vírgula.

| ID | Nível | Documento | Artigo |
|---|---|---|---|
| `d1` | artigo | Porto de Santos | [Wikipédia](https://pt.wikipedia.org/wiki/Porto_de_Santos) |
| `d1.1` ... `d1.88` | frase | frases de `d1` | - |
| `d2` | artigo | Autoridade Portuária de Santos | [Wikipédia](https://pt.wikipedia.org/wiki/Autoridade_Portuária_de_Santos) |
| `d2.1` ... `d2.29` | frase | frases de `d2` | - |
| `d3` | artigo | Francisco de Paula Ribeiro | [Wikipédia](https://pt.wikipedia.org/wiki/Francisco_de_Paula_Ribeiro) |
| `d3.1` ... `d3.5` | frase | frases de `d3` | - |

> Conteúdo licenciado sob **CC BY-SA** (Wikipédia) - uso permitido desde que
> citada a fonte. Unidade de recuperação: **frase com contexto** (ponto final),
> para o julgamento humano na Aula 05.

---

## Estrutura da pasta (Atividade 01 · Parte A)

```
estrutura/corpus/
├── porto_de_santos.txt
├── autoridade_portuaria_de_santos.txt
└── francisco_de_paula_ribeiro.txt
estrutura/codigos/
└── 01a-corpus-aula-01.R
consolidados/
└── 01a-primeiro-corpus-real.md
```

Cada `.txt` guarda o texto do artigo. O script `01a` (e também `03`, `04`, `05b`)
carrega via [`ler-frases-comum.R`](../estrutura/codigos/ler-frases-comum.R):
monta `d1`/`d2`/`d3` e as frases `dN.k` **com os mesmos IDs em todo o projeto**.

Catálogo: [`estrutura/corpus/frases-canonicas.csv`](../estrutura/corpus/frases-canonicas.csv).  
Documentação da regra: [unidade-recuperacao-frases.md](unidade-recuperacao-frases.md).

---

## Como rodar (Parte A)

Pré-requisito: [R](https://www.r-project.org/) instalado (apenas **R base**).

```bash
cd "estrutura/codigos"
Rscript 01a-corpus-aula-01.R
```

O script:

1. **Carrega** os 3 `.txt` e monta `docs` com artigos (`d1`, `d2`, `d3`) e
   frases (`d1.1`, `d1.2`, ...; quebra por ponto final)
2. **Tokeniza** (`tolower` + `strsplit` por espaço)
3. **Monta o vocabulário** a partir dos **artigos** (sem duplicar as frases)
4. **Lista** os 10 termos mais frequentes

---

## Resultados

### Artigos (`d1`, `d2`, `d3`)

| Documento | Frases | Caracteres | Tokens | Termos distintos |
|---|--:|--:|--:|--:|
| `d1` - Porto de Santos | 88 | 15.762 | 2.480 | 1.100 |
| `d2` - Autoridade Portuária de Santos | 29 | 5.812 | 888 | 433 |
| `d3` - Francisco de Paula Ribeiro | 5 | 711 | 125 | 83 |
| **Total (artigos)** | **122** | **22.285** | **3.493** | **1.281** |

### Vocabulário: corpus real × corpus de brinquedo

```
Corpus de brinquedo (aula)   # 45 termos
Corpus real (3 artigos)      ############################ 1.281 termos
```

**1.281 termos distintos - cerca de 28,5x maior** que o corpus de brinquedo.

### Top 10 termos mais frequentes (artigos)

| Rank | Termo | Frequência |
|:-:|---|--:|
| 1 | de | 313 |
| 2 | a | 142 |
| 3 | e | 108 |
| 4 | o | 88 |
| 5 | da | 85 |
| 6 | do | 79 |
| 7 | **porto** | 44 |
| 8 | em | 41 |
| 9 | que | 34 |
| 10 | com | 33 |

---

## Discussão

**O top 10 é informativo?** Em grande parte, **não**. Nove das dez posições
são stopwords (`de`, `a`, `e`, `o`, `da`, `do`, `em`, `que`, `com`). Só
`porto` carrega significado temático no top 10 (`santos` aparece em 12º,
com frequência 31). Isso é esperado: a frequência bruta segue a Lei de Zipf.

**O que isso sugere sobre as próximas aulas?** Contar ocorrências não basta
para ranquear relevância. Precisamos **pesar** os termos (raros no corpus,
frequentes no documento) e depois medir o quanto a consulta combina com
cada documento. Esse caminho continua assim:

| Próximo passo | Onde | O que responde |
|---|---|---|
| Por que o peso existe (IDF = bits) | [Parte B desta atividade](01b-shannon-pesos-dos-termos.md) | Shannon: termo raro informa mais |
| Como ranquear de verdade | [Atividade 02](./02-tfidf-similaridade-cosseno.md) | TDM → TF-IDF + similaridade do cosseno |
| Limpeza e índice | [Atividade 03](./03-limpeza-stopwords-stemming-indice.md) | stopwords · Snowball · índice |
| Poisson → BM25 | [Atividade 04](./04-poisson-saturacao-bm25.md) | saturação · tamanho · ranking |

A Parte B (Aula 01.5) continua nesta mesma entrega. A Atividade 02
mostra o ranking TF-IDF no brinquedo; a 03 limpa o corpus wiki; a 04
aplica BM25 em cima dessa base.


**Dois níveis no mesmo `docs`.** Cada artigo (`d1`, `d2`, `d3`) e cada
frase pontuada (`d1.1`, `d1.2`, ...). Útil para buscar no artigo inteiro
ou no trecho julgável com contexto.

**Frequências só nos artigos.** Tokenizar também os `dN.k` no mesmo cálculo
contaria o texto duas vezes; o script usa `d1`/`d2`/`d3` para vocabulário e
top 10.

**O texto real é "sujo".** Tokenização simples (`tolower` + espaços) deixa
pontuação grudada nos termos (`codesp,`, `1980.`).


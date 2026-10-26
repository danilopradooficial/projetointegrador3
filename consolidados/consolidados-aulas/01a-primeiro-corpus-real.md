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

## Corpus e unidade de recuperação canônica

Três artigos da Wikipédia em português, todos ligados ao Porto de Santos.
Cada artigo vira um documento `dN`; cada **frase pontuada** vira `dN.k`.

**Esta regra vale para todo o motor:** o ID `d1.1` no índice (Atividade 03),
no BM25 (04) e no julgamento (05) é **a mesma frase**.

| ID | Nível | Significado |
|---|---|---|
| `d1`, `d2`, `d3` | artigo | Texto completo (Wikipédia) |
| `d1.1` … `d1.88` | frase | Frases de `d1`, na ordem do texto |
| `d2.1` … `d2.29` | frase | Frases de `d2` |
| `d3.1` … `d3.5` | frase | Frases de `d3` |

| Artigo | Arquivo | Frases |
|---|---|--:|
| `d1` Porto de Santos | `porto_de_santos.txt` | 88 |
| `d2` Autoridade Portuária | `autoridade_portuaria_de_santos.txt` | 29 |
| `d3` Francisco de Paula Ribeiro | `francisco_de_paula_ribeiro.txt` | 5 |
| **Total de frases** | | **122** |
| **Total indexável** | 3 artigos + 122 frases | **125** |

Exemplo:

> **`d1.1`** - *Porto de Santos é um porto estuarino, localizado nos municípios de Santos, Guarujá e Cubatão, no estado de São Paulo.*

> Conteúdo licenciado sob **CC BY-SA** (Wikipédia) - uso permitido desde que citada a fonte.

### Regra de fatiamento (`01a-ler-frases.R`)

Implementada em [`estrutura/codigos/01a-ler-frases.R`](../estrutura/codigos/01a-ler-frases.R):

1. Junta o `.txt` em um único bloco de texto.
2. Protege abreviações (`S.A.`, `Dr.`, …) e decimais (`8.630`).
3. Quebra por **ponto final / `!` / `?`** (frase com contexto).
4. Se a frase tiver **mais de 45 palavras** e existir **`;`**, parte no ponto e vírgula.
5. Descarta pedaços com menos de 3 palavras.

Não usamos corte por número fixo de palavras (ex.: 7-10) - isso perdia o sentido no julgamento.

### Onde a regra é usada (mesmos IDs)

| Etapa | Script | Como carrega |
|---|---|---|
| 01a · corpus | `01a-corpus-aula-01.R` | `source("01a-ler-frases.R")` → `carregar_docs_canonico()` |
| 03 · índice | `03-preprocessao-indice.R` | idem |
| 04 · BM25 | `04-poisson-bm25.R` | idem |
| 05 · CSV julgamento | `05-julgamento/05b-montar-corpus.R` | `source("../01a-ler-frases.R")` → `ler_frases()` |

Catálogo versionado:

- [`estrutura/corpus/frases-canonicas.csv`](../estrutura/corpus/frases-canonicas.csv) - `id`, `artigo`, `texto`
- [`estrutura/codigos/05-julgamento/csv/05-corpus.csv`](../estrutura/codigos/05-julgamento/csv/05-corpus.csv) - mesmo texto, formato do `julgar.html`

Ao rodar `05b-montar-corpus.R`, os dois CSVs são regravados juntos. Conferência: o texto de `d1.1` no `05b` deve ser igual a `docs[["d1.1"]]` nesta atividade.

---

## Estrutura da pasta (Atividade 01 · Parte A)

```
estrutura/corpus/
├── porto_de_santos.txt
├── autoridade_portuaria_de_santos.txt
├── francisco_de_paula_ribeiro.txt
└── frases-canonicas.csv          # catálogo dos IDs dN.k
estrutura/codigos/
├── 01a-ler-frases.R            # regra canônica (01a/03/04/05)
└── 01a-corpus-aula-01.R
consolidados/
└── 01a-primeiro-corpus-real.md
```

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


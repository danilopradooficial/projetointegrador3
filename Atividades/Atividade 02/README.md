<div align="center">

# Atividade 02 — Do problema da busca ao nosso motor

**Projeto Integrador III · Ciência de Dados · FATEC**

Sair do *corpus* de brinquedo (8 documentos, 45 termos) e montar um
primeiro *corpus* real com artigos da Wikipédia: vetor `docs`,
tokenização, vocabulário e frequência de termos.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Aula](https://img.shields.io/badge/aula-01-lightgrey)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)

</div>

---

## Sobre a atividade

Primeira entrega do motor de busca: aplicar no *corpus* real os mesmos
conceitos vistos em sala — carregar documentos, tokenizar, montar o
vocabulário e listar os termos mais frequentes.

> **Meta da atividade:** construir o primeiro *corpus* real do projeto e
> medir o salto em relação ao corpus de brinquedo da aula (45 termos).

**Material de referência:**
[Aula 01 — Do Problema da Busca ao Nosso Motor](../../MateriaisAulas/Aula%2001%20-%20Do%20Problema%20da%20Busca%20ao%20Nosso%20Motor.PDF)
· [README da disciplina](../../README.md)

---

## Corpus

Três artigos da Wikipédia em português, todos ligados ao Porto de Santos.
Cada artigo vira um documento `dN`; cada parágrafo vira `dN.k`.

| ID | Nível | Documento | Artigo |
|---|---|---|---|
| `d1` | artigo | Porto de Santos | [Wikipédia](https://pt.wikipedia.org/wiki/Porto_de_Santos) |
| `d1.1` … `d1.12` | parágrafo | parágrafos de `d1` | — |
| `d2` | artigo | Autoridade Portuária de Santos | [Wikipédia](https://pt.wikipedia.org/wiki/Autoridade_Portuária_de_Santos) |
| `d2.1` … `d2.5` | parágrafo | parágrafos de `d2` | — |
| `d3` | artigo | Francisco de Paula Ribeiro | [Wikipédia](https://pt.wikipedia.org/wiki/Francisco_de_Paula_Ribeiro) |
| `d3.1` | parágrafo | parágrafo de `d3` | — |

> Conteúdo licenciado sob **CC BY-SA** (Wikipédia) — uso permitido desde que
> citada a fonte. Textos reextraídos da API com parágrafos separados por
> linha em branco.

---

## Estrutura da pasta

```
.
├── README.md
├── corpus_aula01.R                        # script principal
├── porto_de_santos.txt                    # d1  (+ d1.1 … d1.12)
├── autoridade_portuaria_de_santos.txt     # d2  (+ d2.1 … d2.5)
└── francisco_de_paula_ribeiro.txt         # d3  (+ d3.1)
```

Cada `.txt` guarda **só os parágrafos** do artigo (um bloco por parágrafo).
O script monta `d1`/`d2`/`d3` concatenando esses blocos.

---

## Como rodar

Pré-requisito: [R](https://www.r-project.org/) instalado (apenas **R base**,
sem pacotes externos).

```bash
cd "Atividades/Atividade 02"
Rscript corpus_aula01.R
```

O script:

1. **Carrega** os 3 `.txt` e monta `docs` com artigos (`d1`, `d2`, `d3`) e
   parágrafos (`d1.1`, `d1.2`, …)
2. **Tokeniza** (`tolower` + `strsplit` por espaço)
3. **Monta o vocabulário** a partir dos **artigos** (sem duplicar os parágrafos)
4. **Lista** os 10 termos mais frequentes

---

## Resultados

### Artigos (`d1`, `d2`, `d3`)

| Documento | Parágrafos | Caracteres | Tokens | Termos distintos |
|---|--:|--:|--:|--:|
| `d1` — Porto de Santos | 12 | 15.762 | 2.480 | 1.100 |
| `d2` — Autoridade Portuária de Santos | 5 | 5.812 | 888 | 433 |
| `d3` — Francisco de Paula Ribeiro | 1 | 711 | 125 | 83 |
| **Total (artigos)** | **18** | **22.285** | **3.493** | **1.281** |

### Vocabulário: corpus real × corpus de brinquedo

```
Corpus de brinquedo (aula)   █ 45 termos
Corpus real (3 artigos)      ████████████████████████████ 1.281 termos
```

**1.281 termos distintos — cerca de 28,5× maior** que o corpus de brinquedo.

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

**Dois níveis no mesmo `docs`.** `d1` é o artigo inteiro; `d1.1` é o
primeiro parágrafo. Útil depois para buscar no artigo ou no trecho.

**Frequências só nos artigos.** Tokenizar também os `dN.k` no mesmo
cálculo contaria o texto duas vezes; o script usa `d1`/`d2`/`d3` para
vocabulário e top 10.

**O top 10 tende a ser dominado por *stopwords*.** Preposições e artigos
concentram ocorrências (Lei de Zipf); termos como `porto` e `santos`
carregam mais significado.

**O texto real é "sujo".** Tokenização simples (`tolower` + espaços) deixa
pontuação grudada nos termos (`codesp,`, `1980.`).

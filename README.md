<div align="center">

#  Motor de Busca — Projeto Integrador III

**Ciência de Dados · FATEC**

Construindo um motor de busca do zero: dos modelos clássicos de
*Information Retrieval* até técnicas neurais e busca por fórmulas
matemáticas (MIR).

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)

</div>

---

##  Sobre o projeto

Este repositório documenta a construção incremental de um motor de busca,
partindo dos fundamentos de **Recuperação de Informação (RI)** — tokenização,
vocabulário, matriz termo-documento — até chegar em modelos de ranqueamento
(TF-IDF, BM25), recuperação densa, *rerank* neural e busca por fórmulas
matemáticas.

>  **Meta do projeto:** construir um motor de busca completo sobre um
> *corpus* real, aula após aula, como parte da disciplina Projeto Integrador
> III.

---

##  Aula 01 — Do problema da busca ao nosso motor

Primeira entrega: sair do *corpus* de brinquedo visto em aula (8 documentos,
45 termos) e montar um primeiro *corpus* real com artigos da Wikipédia,
aplicando os mesmos conceitos vistos em sala — vetor `docs`, tokenização,
vocabulário e frequência de termos.

### Corpus

Três artigos da Wikipédia em português, todos ligados ao Porto de Santos:

| # | Documento | Artigo |
|:-:|---|---|
| `d1` | Autoridade Portuária de Santos | [🔗 Wikipédia](https://pt.wikipedia.org/wiki/Autoridade_Portuária_de_Santos) |
| `d2` | Porto de Santos | [🔗 Wikipédia](https://pt.wikipedia.org/wiki/Porto_de_Santos) |
| `d3` | Francisco de Paula Ribeiro | [🔗 Wikipédia](https://pt.wikipedia.org/wiki/Francisco_de_Paula_Ribeiro) |

> Conteúdo licenciado sob **CC BY-SA** (Wikipédia) — uso permitido desde que
> citada a fonte.

###  Estrutura do repositório

```
.
├── README.md
├── corpus_aula01.R              # script principal da Aula 01
└── corpus/
    ├── autoridade_portuaria_de_santos.txt
    ├── porto_de_santos.txt
    └── francisco_de_paula_ribeiro.txt
```

###  Como rodar

Pré-requisito: [R](https://www.r-project.org/) instalado (apenas **R base**
é usado nesta aula, sem pacotes externos).

```bash
Rscript corpus_aula01.R
```

O script segue exatamente o padrão usado em sala:

1. **Carrega** os 3 artigos num vetor nomeado `docs` (`d1`, `d2`, `d3`)
2. **Tokeniza** cada documento (`tolower` + `strsplit` por espaço)
3. **Monta o vocabulário** do *corpus* (termos distintos)
4. **Calcula a frequência** de cada termo e lista os 10 mais comuns

---

##  Resultados

### Por documento

| Documento | Caracteres | Tokens | Termos distintos |
|---|--:|--:|--:|
| `d1` — Autoridade Portuária de Santos | 5.500 | 842 | 409 |
| `d2` — Porto de Santos | 7.391 | 1.171 | 587 |
| `d3` — Francisco de Paula Ribeiro | 713 | 125 | 83 |
| **Total (corpus)** | **13.604** | **2.138** | **881** |

### Vocabulário: corpus real × corpus de brinquedo

```
Corpus de brinquedo (aula)   █ 45 termos
Corpus real (3 artigos)      ████████████████████████████████████ 881 termos
```

**881 termos distintos — cerca de 19,6× maior** que o corpus de brinquedo
visto em aula.

### Top 10 termos mais frequentes

| Rank | Termo | Frequência |            |
|:-:|---|--:|---|
| 1 | de | 204 | ████████████████████ |
| 2 | a | 99 | ██████████ |
| 3 | e | 73 | ███████ |
| 4 | o | 59 | ██████ |
| 5 | do | 55 | █████ |
| 6 | da | 45 | ████ |
| 7 | **porto** | 35 | ███ |
| 8 | **santos** | 24 | ██ |
| 9 | em | 23 | ██ |
| 10 | com | 22 | ██ |

---

## Discussão

**O top 10 é dominado por *stopwords*.** Preposições, artigos e conjunções
tomam 8 das 10 posições — só `porto` e `santos` carregam significado real.
Isso é esperado: a distribuição de frequência de termos em linguagem natural
segue a **Lei de Zipf**, com poucas palavras funcionais concentrando a maior
parte das ocorrências.

**O texto real é "sujo".** Como a tokenização usada foi propositalmente
simples (só `tolower` + `strsplit` por espaço, sem remover pontuação), tokens
como `codesp,`, `(nome` e `1980.` entram no vocabulário como termos
*diferentes* de suas versões limpas.

Isso aponta os próximos passos do projeto:

| Próximo passo | Por quê |
|---|---|
| Remoção de *stopwords* e pontuação | Sem isso, nenhum ranqueamento faz sentido |
| TF-IDF | Penaliza termos comuns a quase todo documento, valoriza os discriminativos |
| Normalização por tamanho | `d2` tem quase o dobro dos tokens de `d1` e ~9× os de `d3`; documentos maiores tendem a dominar um índice não normalizado |


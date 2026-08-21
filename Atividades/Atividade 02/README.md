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

---

## Corpus

Três artigos da Wikipédia em português, todos ligados ao Porto de Santos:

| # | Documento | Artigo |
|:-:|---|---|
| `d1` | Autoridade Portuária de Santos | [Wikipédia](https://pt.wikipedia.org/wiki/Autoridade_Portuária_de_Santos) |
| `d2` | Porto de Santos | [Wikipédia](https://pt.wikipedia.org/wiki/Porto_de_Santos) |
| `d3` | Francisco de Paula Ribeiro | [Wikipédia](https://pt.wikipedia.org/wiki/Francisco_de_Paula_Ribeiro) |

> Conteúdo licenciado sob **CC BY-SA** (Wikipédia) — uso permitido desde que
> citada a fonte.

---

## Estrutura da pasta

```
.
├── README.md
├── corpus_aula01.R                        # script principal
├── autoridade_portuaria_de_santos.txt     # d1
├── porto_de_santos.txt                    # d2
└── francisco_de_paula_ribeiro.txt         # d3
```

---

## Como rodar

Pré-requisito: [R](https://www.r-project.org/) instalado (apenas **R base**,
sem pacotes externos).

```bash
cd "Atividades/Atividade 02"
Rscript corpus_aula01.R
```

> **Nota:** o script usa `pasta <- "corpus"`. Se os `.txt` estiverem nesta
> mesma pasta (como agora), ajuste para `pasta <- "."` ou mova os arquivos
> para uma subpasta `corpus/`.

O script segue o padrão usado em sala:

1. **Carrega** os 3 artigos num vetor nomeado `docs` (`d1`, `d2`, `d3`)
2. **Tokeniza** cada documento (`tolower` + `strsplit` por espaço)
3. **Monta o vocabulário** do *corpus* (termos distintos)
4. **Calcula a frequência** de cada termo e lista os 10 mais comuns

---

## Resultados

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

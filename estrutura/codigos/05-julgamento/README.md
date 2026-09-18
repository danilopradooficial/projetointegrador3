# Aula 05a — Julgamento de relevância (Team Shannon)

Pasta do aparato de gabarito humano (TREC-style): corpus → necessidades → pool →
votos (`qrels`) → κ.

**Status:** julgamento **concluído** (3 juízes × 60 itens = 180 votos em `csv/05-qrels.csv`).

---

## Árvore de arquivos

```
estrutura/codigos/05-julgamento/
│
├── 05-julgar.html              # página offline de julgamento (combobox dos juízes)
│
├── 05a-kappa.R                 # exemplos didáticos de κ de Cohen (matriz da aula)
├── 05b-montar-corpus.R         # .txt wiki → csv/05-corpus.csv (+ frases-canonicas.csv)
├── 05c-ficha-corpus.R          # imprime ficha técnica do 05-corpus.csv
├── 05d-gerar-pool.R            # amostra por juiz → csv/05-pool.csv
├── 05e-consolidar-qrels.R      # junta respostas individuais → csv/05-qrels.csv
│
└── csv/
    ├── 05-corpus.csv           # ENTRADA · 122 frases (unidade de recuperação)
    ├── 05-necessidades.csv     # ENTRADA · 15 perguntas objetivas
    ├── 05-pool.csv             # ENTRADA · 180 pares (60 por juiz)
    ├── 05-qrels.csv            # SAÍDA · 180 votos consolidados (gabarito)
    └── 05-qrels-respostas/     # SAÍDA bruta por pessoa (exports do HTML)
        ├── 05-qrels-adriane-22.csv      # 60 votos · Adriane
        ├── 05-qrels-danilo-13.csv       # 60 votos · Danilo
        ├── 05-qrels-victoria-21.csv     # 60 votos · Victória
        └── 05-respostas-consolidadas.xlsx  # cópia/planilha auxiliar da equipe
```

Dependência externa (fora desta pasta, mas obrigatória):

| Arquivo | Papel |
|---|---|
| `../01a-ler-frases.R` | Regra canônica de `d1.1`, `d1.2`, … |
| `../../corpus/*.txt` | Textos Wikipédia |
| `../../corpus/frases-canonicas.csv` | Catálogo dos mesmos IDs (gerado pelo 05b) |

Documentação geral dos IDs: [`consolidados/01a-primeiro-corpus-real.md`](../../../consolidados/01a-primeiro-corpus-real.md) (2ª entrega · Parte A).  
Relatório da atividade: [`consolidados/05a-julgamento-pooling-kappa.md`](../../../consolidados/05a-julgamento-pooling-kappa.md).  
Métricas (Aula 05b): [`consolidados/05b-metricas-avaliacao.md`](../../../consolidados/05b-metricas-avaliacao.md) · script `../05b-metricas.R`.

---

## Fluxo completo (ordem)

```
1. 05b-montar-corpus.R     → 05-corpus.csv (+ frases-canonicas.csv)
2. 05c-ficha-corpus.R      → confere colunas / palavras por doc
3. (editar) 05-necessidades.csv
4. 05d-gerar-pool.R        → 05-pool.csv (fatias Adriane/Danilo/Victória)
5. Abrir 05-julgar.html
      · escolher juiz no combobox
      · carregar corpus + necessidades + pool
      · marcar 0 / 1 / 2
      · exportar CSV → salvar em csv/05-qrels-respostas/
6. 05e-consolidar-qrels.R  → 05-qrels.csv
7. 05a-kappa.R             → treinar fórmula; κ real sobre duplos (próximo passo analítico)
```

```bash
cd estrutura/codigos/05-julgamento
Rscript 05b-montar-corpus.R
Rscript 05c-ficha-corpus.R
Rscript 05d-gerar-pool.R
# ... julgamento no navegador ...
Rscript 05e-consolidar-qrels.R
Rscript 05a-kappa.R
```

---

## Scripts (o que cada um faz)

### `05a-kappa.R`
- Calcula κ de Cohen em **matrizes de exemplo** da aula (não lê o qrels ainda).
- Serve para entender `po`, `pe` e o efeito de muitos zeros.
- Próximo uso analítico: montar matriz de confusão juíz×juíz só nos pares `tipo=duplo`.

### `05b-montar-corpus.R`
- Lê os 3 `.txt` em `estrutura/corpus/`.
- Chama `ler_frases()` de `01a-ler-frases.R` (ponto final; `;` se frase longa).
- Grava:
  - `csv/05-corpus.csv` — formato do HTML (`id,titulo,texto,data,fonte,url`)
  - `estrutura/corpus/frases-canonicas.csv` — catálogo alinhado com 01a/03/04

### `05c-ficha-corpus.R`
- Diagnóstico rápido: preenchimento de colunas, resumo de palavras, ids duplicados.

### `05d-gerar-pool.R`
- Não faz produto cartesiano completo (15×122 seria demais para 20 min).
- Monta amostra estratificada (~40 únicos + 20 em duplo por juiz = **60**).
- Colunas: `consulta`, `documento`, `juiz`, `tipo` (`unico` | `duplo`).
- Duplos: 10 Adriane↔Danilo + 10 Adriane↔Victória + 10 Danilo↔Victória.

### `05e-consolidar-qrels.R`
- Lê todos `csv/05-qrels-respostas/05-qrels-*.csv`.
- Ordena por juiz / consulta / documento.
- Grava `csv/05-qrels.csv` (gabarito único do grupo).

### `05-julgar.html`
- Offline (sem servidor, sem CDN, sem `fetch`).
- Combobox: Adriane / Danilo / Victória → filtra a fatia no `05-pool.csv`.
- Atalhos: `0` `1` `2`, `←` voltar, `P` pular, `G` guia.
- Botão **Rejulgar 20%**: segunda passada do **mesmo** juiz (grava como `*_p2`); distinto dos itens `duplo` entre pessoas.
- Exporta CSV com colunas: `consulta,documento,grau,juiz,timestamp,segundos`.

---

## CSVs de entrada

### `05-corpus.csv` (122 linhas)

| Coluna | Conteúdo |
|---|---|
| `id` | `d1.1` … `d1.88`, `d2.1` … `d2.29`, `d3.1` … `d3.5` |
| `titulo` | Nome do artigo + id |
| `texto` | Frase completa (contexto) |
| `data` | (vazio neste corpus) |
| `fonte` | Wikipedia PT \| … |
| `url` | Página wiki |

### `05-necessidades.csv` (15 linhas)

| Coluna | Conteúdo |
|---|---|
| `consulta` | `q01` … `q15` |
| `texto_consulta` | O que a pessoa digitaria |
| `necessidade` | Pergunta objetiva (sim / parcial / não) |
| `escopo` | Dica de fronteira (o que não conta) |

### `05-pool.csv` (180 linhas)

| Coluna | Conteúdo |
|---|---|
| `consulta` | id da necessidade |
| `documento` | id da frase |
| `juiz` | `adriane` \| `danilo` \| `victoria` |
| `tipo` | `unico` (só um juiz) ou `duplo` (dois juízes) |

| Juiz | Itens | Únicos | Em duplo |
|---|--:|--:|--:|
| Adriane | 60 | 40 | 20 |
| Danilo | 60 | 40 | 20 |
| Victória | 60 | 40 | 20 |

---

## CSVs de saída (julgamento feito)

### Por pessoa — `csv/05-qrels-respostas/`

Exports diretos do HTML (não apagar; são a evidência bruta).

| Arquivo | Juiz | Votos | Tempo médio | Tempo total |
|---|---|--:|---:|---:|
| `05-qrels-adriane-22.csv` | Adriane | 60 | ~3,3 s | ~3,3 min |
| `05-qrels-danilo-13.csv` | Danilo | 60 | ~8,0 s | ~8,0 min |
| `05-qrels-victoria-21.csv` | Victória | 60 | ~8,6 s | ~8,6 min |

Cobertura: **60/60** da pool de cada um (nada faltando).

### Consolidado — `csv/05-qrels.csv` (180 linhas)

| Coluna | Conteúdo |
|---|---|
| `consulta` | `q01`…`q15` |
| `documento` | `dN.k` |
| `grau` | `0` / `1` / `2` |
| `juiz` | `adriane` / `danilo` / `victoria` |
| `timestamp` | ISO do clique |
| `segundos` | tempo no item |

Distribuição global dos graus:

| Grau | Significado | Contagem |
|:-:|---|--:|
| 0 | não serve | 117 |
| 1 | parcial | 37 |
| 2 | responde | 26 |

### Planilha auxiliar
`05-respostas-consolidadas.xlsx` — material de apoio da equipe; a fonte canônica para o motor continua sendo o `05-qrels.csv`.

---

## Escala de julgamento (0 / 1 / 2)

| Grau | Rótulo no HTML | Quando usar |
|:-:|---|---|
| **2** | sim | A frase **responde** à pergunta objetiva da necessidade |
| **1** | parcial | Fala do tema / dá contexto, **sem** responder |
| **0** | não | Não serve para aquela necessidade |

Julgar pela **necessidade** (prosa), não só pelas palavras da consulta digitada.

---

## Concordância nos itens em duplo (resumo)

Pares `tipo=duplo` em que **os dois** juízes votaram (10 por dupla):

| Par | n | Acordo bruto |
|---|--:|---:|
| Adriane × Danilo | 10 | 60% |
| Adriane × Victória | 10 | 30% |
| Danilo × Victória | 10 | 60% |

Isso **não** é ainda o κ de Cohen (falta a matriz 3×3 e o ajuste por acaso). Use `05a-kappa.R` como base e calcule κ sobre esses pares na análise da Aula 5,5 / métricas.

**Duplo entre juízes** ≠ **Rejulgar 20%** (segunda passada da mesma pessoa).

---

## Como repetir o julgamento (se precisar)

1. Abrir `05-julgar.html` no navegador (duplo clique).
2. Combobox → seu nome.
3. Carregar os 3 CSVs de `csv/` (corpus, necessidades, pool).
4. Julgar com `0`/`1`/`2`.
5. **Salvar votos** → colocar o arquivo em `csv/05-qrels-respostas/` com nome claro.
6. Rodar `Rscript 05e-consolidar-qrels.R`.

---

## Convenções de nome

- Prefixo `05` nesta pasta = Aula **05a** (julgamento). Scripts internos `05a`…`05e` são etapas da pasta, não a Aula 05b.
- Aula **05b** (métricas) fica em `../05b-metricas.R`.
- Sufixo do script: letra da etapa (`a` κ, `b` corpus, `c` ficha, `d` pool, `e` consolidar).
- CSVs de entrada sem pasta extra; **saídas humanas** em `05-qrels-respostas/`.
- IDs de frase **idênticos** aos de `01a` / `03` / `04` (`01a-ler-frases.R`).

---

## Checklist de entrega

- [x] Corpus canônico (122 frases)
- [x] 15 necessidades objetivas
- [x] Pool por juiz (180 linhas)
- [x] HTML de julgamento
- [x] 3 exports individuais (60 cada)
- [x] `05-qrels.csv` consolidado (180)
- [ ] κ de Cohen formal nos duplos (análise seguinte)
- [ ] Métricas do motor com o gabarito (Aula 5,5+)

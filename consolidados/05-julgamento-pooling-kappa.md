<div align="center">

# Atividade 05 - Julgamento, pooling e concordância entre juízes

**Team Shannon · Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Montar o aparato de gabarito (corpus, necessidades, pool, HTML),
entender o κ e **depois** julgar - o qrels sai do HTML.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Entrega](https://img.shields.io/badge/entrega-6%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-05-lightgrey)

</div>

---

## Sobre a atividade

**6ª entrega.** Sem gabarito, comparar BM25 e TF-IDF é opinião. Esta aula
monta o processo: necessidade → consulta → julgamento 0/1/2 → qrels → κ.

**Pronto:** scripts, CSVs de entrada, página de julgamento, 15 necessidades.  
**Falta:** os 3 juízes abrirem o HTML, votarem e exportarem `csv/05-qrels.csv`.

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victória Cabral Quintério  
**Juízes.** Adriane, Danilo, Victória · **~30 min** por pessoa

---

## Material

- [Aula 05 PDF](../materiais-aulas/Aula%2005%20-%20Julgamento,%20Pooling%20e%20Concordância%20Entre%20Juízes.PDF)
- [GUIA_ESTUDO_aula05.md](../materiais-aulas/Aula%2005a%20-%20GUIA_ESTUDO_aula05.md)
- [PROMPT_LLM_julgamento_relevancia.md](../materiais-aulas/Aula%2005b%20-%20PROMPT_LLM_julgamento_relevancia.md)
- [Atividade 04](./04-poisson-saturacao-bm25.md)
- [README](../README.md)

---

## Estrutura

```
estrutura/codigos/05-julgamento/
├── 05a-kappa.R              # explorar κ
├── 05b-montar-corpus.R      # wiki → csv/05-corpus.csv (d1.1, d1.2, …)
├── 05c-ficha-corpus.R
├── 05d-gerar-pool.R
├── 05-julgar.html
└── csv/
    ├── 05-corpus.csv          # entrada
    ├── 05-necessidades.csv    # entrada
    ├── 05-pool.csv            # entrada
    └── 05-qrels.csv           # SAÍDA (depois de julgar)
```

```bash
cd estrutura/codigos/05-julgamento
Rscript 05a-kappa.R
Rscript 05b-montar-corpus.R
Rscript 05c-ficha-corpus.R
Rscript 05d-gerar-pool.R
# abrir 05-julgar.html → carregar os 3 CSVs de csv/ → exportar 05-qrels.csv
```

---

# Guia de julgamento (0 / 1 / 2)

| Grau | Significado |
|:-:|---|
| **2** | Responde à necessidade |
| **1** | Fala do assunto, sem responder |
| **0** | Não serve |

Julgar pela **necessidade em prosa**, não só pela consulta. Em empate, preferir 1 a 2.

---

# κ de Cohen (`05a-kappa.R`)

```r
n  <- sum(m)
po <- sum(diag(m)) / n
pe <- sum(rowSums(m) * colSums(m)) / n^2
kappa <- (po - pe) / (1 - pe)
```

| caso | po | κ (aprox.) |
|---|---:|---:|
| matriz da aula | 0,775 | 0,636 |
| quase tudo 0 | 0,925 | −0,03 |
| po=0,8 com muitos 0 | 0,800 | 0,216 |
| discordância forçada | 0,000 | −0,52 |

κ entre juízes do grupo: calcular **depois** de existirem qrels reais (ex.: 20% em duplo).

---

# Corpus (436 frases curtas · 7-10 palavras)

| artigo | ids | n |
|---|---|---:|
| Porto de Santos | `d1.1` … `d1.310` | 310 |
| Autoridade Portuária | `d2.1` … `d2.111` | 111 |
| Francisco de Paula Ribeiro | `d3.1` … `d3.15` | 15 |

Usuário: alunos de CD treinando o motor (local/acadêmico).  
Arquivo: [`csv/05-corpus.csv`](../estrutura/codigos/05-julgamento/csv/05-corpus.csv).  
Unidade de recuperação: frase curta (7 a 10 palavras) para julgamento em ~15 s.

---

# Necessidades (15) — perguntas objetivas

Arquivo: [`csv/05-necessidades.csv`](../estrutura/codigos/05-julgamento/csv/05-necessidades.csv).  
Cada necessidade é uma pergunta **sim/parcial/não**, para julgamento em ~10 s.  
Indícios **não** são graus.

```
q01  importância econômica porto de santos          → d1.18, d1.11, d1.24
q02  quem administra porto santos autoridade        → d2.1, d2.11, d2.2
q03  codesp landlord port autoridade portuária      → d2.25, d2.29, d1.133
q04  francisco de paula ribeiro porto santos        → d3.1, d3.3, d1.59
q05  incêndio porto de santos açúcar ultracargo     → d1.172, d1.204, d1.178
q06  acesso ferroviário rodoviário porto santos     → d1.243, d1.246, d1.247
q07  dragagem calado estuário santos                → d1.229, d1.230, d2.89
q08  companhia docas de santos concessão            → d1.46, d1.51, d1.43
q09  tipos de carga movimentação porto santos       → d1.6, d1.7, d1.20
q10  lei 8630 landlord port santos                  → d2.8, d2.25, d2.29
q11  autoridade portuária santos museu meio ambiente → d2.97, d2.111, d2.103
q12  usina itatinga paquetá outeirinhos porto       → d1.88, d1.89, d1.102
q13  o que é porto organizado santos                → d2.35, d2.36, d1.139
q14  porto da morte santos epidemias saneamento     → d1.69, d1.70, d1.75
q15  localização porto de santos guarujá cubatão    → d1.1, d1.2, d1.3
```

# Pool por juiz (~20 min)

Arquivo: [`csv/05-pool.csv`](../estrutura/codigos/05-julgamento/csv/05-pool.csv)  
Colunas: `consulta`, `documento`, `juiz`, `tipo` (`unico` | `duplo`).

| Juiz | Itens | Tempo @10 s | Observação |
|---|--:|---:|---|
| Adriane | 90 | ~15 min | 60 únicos + 30 em duplo |
| Danilo | 90 | ~15 min | idem |
| Victória | 90 | ~15 min | idem |

- Total de linhas no CSV: **270** (225 pares distintos + 45 reaparecem em duplo)
- Duplos: 15 Adriane↔Danilo + 15 Adriane↔Victória + 15 Danilo↔Victória (para κ)
- Regenerar: `Rscript 05d-gerar-pool.R`

**Viés do pooling:** o que nenhum modelo recupera nunca entra na pool.

---

# Próximo passo (julgamento)

1. Abrir [`05-julgar.html`](../estrutura/codigos/05-julgamento/05-julgar.html)
2. Escolher o nome no **combobox** (Adriane / Danilo / Victória)
3. Carregar `05-corpus.csv`, `05-necessidades.csv`, `05-pool.csv`
4. Responder 0 / 1 / 2 (atalhos do teclado) — meta ≤ 20 min
5. Exportar e juntar os votos em `csv/05-qrels.csv`

Aí o gabarito existe de verdade - base para as métricas da Aula 5,5.

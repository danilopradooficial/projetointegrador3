<div align="center">

# Atividade 05a - Julgamento, pooling e concordância entre juízes

**Team Shannon · Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Aparato de gabarito humano concluído: corpus → necessidades → pool →
votos (`qrels`) → base para κ e métricas (Aula 05b).

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-julgamento%20concluído-success)
![Entrega](https://img.shields.io/badge/entrega-6%C2%AA%20A-blue)
![Aula](https://img.shields.io/badge/aula-05a-lightgrey)

</div>

---

## Sobre a atividade

**6ª entrega · Parte A (Aula 05a).** Sem gabarito, comparar BM25 e TF-IDF é opinião. Esta aula fecha o processo: necessidade → consulta → julgamento 0/1/2 → **qrels** → κ.

| Item | Situação |
|---|---|
| Scripts + HTML + CSVs de entrada | prontos |
| Julgamento (3 juízes × 60) | **concluído** |
| `csv/05-qrels.csv` (180 votos) | **consolidado** |
| κ formal nos duplos | próximo passo analítico |
| Métricas do motor com gabarito | [Atividade 05b](./05b-metricas-avaliacao.md) |

**Equipe.** Team Shannon  
**Autores / juízes.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victória Cabral Quintério  
**Tempo.** ≤ 20 min por pessoa (realizado entre ~3 e ~9 min de clique)  
**IDs.** Mesmos de 01a/03/04 - [01a-primeiro-corpus-real.md](01a-primeiro-corpus-real.md) (seção *Corpus e unidade de recuperação canônica*)

**Manual da pasta:** [`estrutura/codigos/05-julgamento/README.md`](../estrutura/codigos/05-julgamento/README.md) (árvore, colunas, fluxo, checklist).

---

## Material

- [Aula 05a PDF](../materiais-aulas/Aula%2005a%20-%20Julgamento,%20Pooling%20e%20Concordância%20Entre%20Juízes.PDF)
- [GUIA_ESTUDO_aula05.md](../materiais-aulas/Aula%2005a%20-%20GUIA_ESTUDO_aula05.md)
- [PROMPT_LLM_julgamento_relevancia.md](../materiais-aulas/Aula%2005a%20-%20PROMPT_LLM_julgamento_relevancia.md)
- [Atividade 01 · Parte A (IDs canônicos)](01a-primeiro-corpus-real.md)
- [Atividade 04](./04-poisson-saturacao-bm25.md)
- [Atividade 05b · métricas](./05b-metricas-avaliacao.md)
- [README do repositório](../README.md)

---

## Estrutura da pasta `05-julgamento/`

```
estrutura/codigos/05-julgamento/
├── README.md                 # documentação operacional (detalhada)
├── 05-julgar.html            # julgamento offline
├── 05a-kappa.R               # κ didático (matrizes da aula)
├── 05b-montar-corpus.R       # frases canônicas → 05-corpus.csv
├── 05c-ficha-corpus.R        # ficha técnica do corpus
├── 05d-gerar-pool.R          # fatias por juiz → 05-pool.csv
├── 05e-consolidar-qrels.R    # respostas/ → 05-qrels.csv
└── csv/
    ├── 05-corpus.csv              # 122 frases (entrada)
    ├── 05-necessidades.csv        # 15 perguntas (entrada)
    ├── 05-pool.csv                # 180 pares juiz×doc (entrada)
    ├── 05-qrels.csv               # 180 votos (SAÍDA consolidada)
    └── 05-qrels-respostas/        # exports brutos por pessoa
        ├── README.md
        ├── 05-qrels-adriane-22.csv
        ├── 05-qrels-danilo-13.csv
        ├── 05-qrels-victoria-21.csv
        └── 05-respostas-consolidadas.xlsx
```

```bash
cd estrutura/codigos/05-julgamento
Rscript 05b-montar-corpus.R
Rscript 05c-ficha-corpus.R
Rscript 05d-gerar-pool.R
# abrir 05-julgar.html → julgar → salvar CSVs em csv/05-qrels-respostas/
Rscript 05e-consolidar-qrels.R
Rscript 05a-kappa.R
```

---

# Guia de julgamento (0 / 1 / 2)

| Grau | No HTML | Significado |
|:-:|---|---|
| **2** | sim | Responde à necessidade |
| **1** | parcial | Fala do assunto, sem responder |
| **0** | não | Não serve |

Julgar pela **necessidade** (pergunta objetiva), não só pela consulta digitada.  
Em dúvida entre 1 e 2, preferir **1**.

---

# κ de Cohen (`05a-kappa.R`)

```r
n  <- sum(m)
po <- sum(diag(m)) / n
pe <- sum(rowSums(m) * colSums(m)) / n^2
kappa <- (po - pe) / (1 - pe)
```

| caso (exemplos da aula) | po | κ (aprox.) |
|---|---:|---:|
| matriz da aula | 0,775 | 0,636 |
| quase tudo 0 | 0,925 | −0,03 |
| po=0,8 com muitos 0 | 0,800 | 0,216 |
| discordância forçada | 0,000 | −0,52 |

O script `05a` ainda usa matrizes didáticas. O κ **entre juízes do grupo**
usa os pares `tipo=duplo` de `05-pool.csv` cruzados com `05-qrels.csv`.

---

# Corpus (122 frases · ponto final)

| artigo | ids | n |
|---|---|--:|
| Porto de Santos | `d1.1` … `d1.88` | 88 |
| Autoridade Portuária | `d2.1` … `d2.29` | 29 |
| Francisco de Paula Ribeiro | `d3.1` … `d3.5` | 5 |

Arquivo: [`csv/05-corpus.csv`](../estrutura/codigos/05-julgamento/csv/05-corpus.csv).  
Unidade: frase com contexto (`.``!``?`; `;` se longa).  
Mesmos IDs: [01a-primeiro-corpus-real.md](01a-primeiro-corpus-real.md) · [`frases-canonicas.csv`](../estrutura/corpus/frases-canonicas.csv).

Usuário simulado: alunos de CD treinando o motor (local/acadêmico).

---

# Necessidades (15) - perguntas objetivas

Arquivo: [`csv/05-necessidades.csv`](../estrutura/codigos/05-julgamento/csv/05-necessidades.csv).  
Indícios **não** são graus.

```
q01  importância econômica porto de santos          → d1.4, d1.6, d1.8
q02  quem administra porto santos autoridade        → d1.13, d1.17, d2.1
q03  codesp landlord port autoridade portuária      → d1.33, d1.34, d1.35
q04  francisco de paula ribeiro porto santos        → d3.1, d3.2, d1.17
q05  incêndio porto de santos açúcar ultracargo     → d1.44, d1.45, d1.47
q06  acesso ferroviário rodoviário porto santos     → d1.67, d1.68, d1.69
q07  dragagem calado estuário santos                → d1.57, d1.60, d1.63
q08  companhia docas de santos concessão            → d1.12, d1.13, d1.14
q09  tipos de carga movimentação porto santos       → d1.3, d1.6, d1.7
q10  lei 8630 landlord port santos                  → d2.3, d2.7, d1.34
q11  autoridade portuária santos museu meio ambiente → d2.26, d2.29, d1.88
q12  usina itatinga paquetá outeirinhos porto       → d1.25, d1.26, d1.28
q13  o que é porto organizado santos                → d2.9, d1.36, d2.21
q14  porto da morte santos epidemias saneamento     → d1.20, d1.21, d1.12
q15  localização porto de santos guarujá cubatão    → d1.1, d1.29, d1.52
```

---

# Pool por juiz

Arquivo: [`csv/05-pool.csv`](../estrutura/codigos/05-julgamento/csv/05-pool.csv)  
Colunas: `consulta`, `documento`, `juiz`, `tipo`.

| Juiz | Itens | Tempo planejado | Observação |
|---|--:|---|---|
| Adriane | 60 | ≤ 20 min | 40 únicos + 20 em duplo |
| Danilo | 60 | ≤ 20 min | idem |
| Victória | 60 | ≤ 20 min | idem |

- Total: **180** linhas (120 `unico` + 60 `duplo`)
- Duplos: 10 por par de juízes (base do κ entre pessoas)
- **Viés do pooling:** o que nenhum modelo recupera nunca entra na pool

---

# Resultado do julgamento (concluído)

## Votos consolidados

Arquivo: [`csv/05-qrels.csv`](../estrutura/codigos/05-julgamento/csv/05-qrels.csv)  
Brutos: [`csv/05-qrels-respostas/`](../estrutura/codigos/05-julgamento/csv/05-qrels-respostas/)

| Juiz | Votos | Cobertura da pool | Tempo de clique (soma) |
|---|--:|---|---|
| Adriane | 60 | 60/60 | ~3,3 min |
| Danilo | 60 | 60/60 | ~8,0 min |
| Victória | 60 | 60/60 | ~8,6 min |
| **Total** | **180** | completa | - |

### Distribuição dos graus (todos os juízes)

| Grau | Contagem | % |
|:-:|--:|--:|
| 0 | 117 | 65% |
| 1 | 37 | 21% |
| 2 | 26 | 14% |

Muitos **0** são esperados: a pool mistura indícios relevantes com distractores.

## Concordância bruta nos duplos (antes do κ)

| Par | n | Acordo |
|---|--:|---:|
| Adriane × Danilo | 10 | 60% |
| Adriane × Victória | 10 | 30% |
| Danilo × Victória | 10 | 60% |

Próximo passo analítico na 05a: montar a matriz 3×3 e calcular κ (ajuste por acaso). Com muitos zeros, `po` alto pode coexistir com κ baixo - exatamente o ponto da Aula 05a.

**Régua do motor:** [Atividade 05b](./05b-metricas-avaliacao.md) - P@k, MAP, MRR, nDCG no nosso `qrels`.

### Duplo entre juízes × Rejulgar 20%

| Mecanismo | Quem | Objetivo |
|---|---|---|
| `tipo=duplo` no pool | duas pessoas | κ **entre** juízes |
| botão Rejulgar 20% | a mesma pessoa (`*_p2`) | consistência **intra** juiz |

---

# Como o HTML foi usado

1. Abrir [`05-julgar.html`](../estrutura/codigos/05-julgamento/05-julgar.html)
2. Combobox → Adriane / Danilo / Victória
3. Carregar `05-corpus.csv`, `05-necessidades.csv`, `05-pool.csv`
4. Marcar 0 / 1 / 2 (atalhos do teclado)
5. Exportar → pasta `05-qrels-respostas/`
6. `Rscript 05e-consolidar-qrels.R`

---

# Próximos passos (depois do gabarito)

1. Calcular **κ de Cohen** só nos pares em duplo (`05-qrels.csv` × `05-pool.csv`).
2. Usar o qrels como verdade para **precision / recall / nDCG** (Aula 5,5+).
3. Comparar BM25 vs TF-IDF com números, não com opinião.

O gabarito existe de verdade em [`05-qrels.csv`](../estrutura/codigos/05-julgamento/csv/05-qrels.csv).

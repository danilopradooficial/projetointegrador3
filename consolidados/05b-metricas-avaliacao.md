<div align="center">

# Atividade 05b - Métricas de avaliação (P@k, MAP, MRR, nDCG)

**Team Shannon · Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

O gabarito da 05a vira régua: medimos o ranking do cosseno (TF-IDF) e do
BM25 com as cinco métricas da Aula 5,5.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Entrega](https://img.shields.io/badge/entrega-7%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-05b-lightgrey)

</div>

---

## Sobre a atividade

**7ª entrega · Aula 05b (Aula 5,5).** Depois do julgamento humano, o motor
precisa de números: precisão nos primeiros $k$, AP/MAP, MRR e nDCG
(binário e graduado).

| Item | Situação |
|---|---|
| Exemplo canônico da aula (8 docs) | **conferido** |
| Script `05b-metricas.R` | pronto |
| Avaliação no nosso `qrels` (11 consultas com $R>0$) | **rodada** |
| Tabela CSV por consulta | gerada |

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victória Cabral Quintério  
**Gabarito.** [Atividade 05a](./05a-julgamento-pooling-kappa.md) · `estrutura/codigos/05-julgamento/csv/05-qrels.csv`  
**IDs.** Frases `dN.k` — [01a](./01a-primeiro-corpus-real.md)

---

## Material

- [Aula 05b PDF — Métricas](../materiais-aulas/Aula%2005b%20-%20Julgamento,%20Pooling%20e%20Concordância%20Entre%20Juízes.PDF) *(arquivo ainda com título antigo no nome; conteúdo = Precisão, Recall, @k, MAP, nDCG, MRR)*
- [Guia de Estudo 01](../materiais-aulas/Aula%2005b%20-%20Guia%20de%20Estudo%2001.md) — teoria (Módulos 1–9)
- [Guia de Estudo 02](../materiais-aulas/Aula%2005b%20-%20Guia%20de%20Estudo%2002.md) — prática no gabarito próprio (Módulos 10–12)
- [Atividade 05a](./05a-julgamento-pooling-kappa.md)
- [Atividade 04 · BM25](./04-poisson-saturacao-bm25.md)

---

## Script

```bash
cd estrutura/codigos
Rscript 05b-metricas.R
```

Gera `05-julgamento/csv/05b-metricas-por-consulta.csv`.

**Limiar de binarização (fixado antes de medir):** relevante = grau $\geq 2$.
Grau 1 continua no **nDCG graduado**. Consultas com $R = 0$ no limiar
(q02, q08, q12, q14) saem da avaliação binária.

Não julgado na pool = grau 0 (regra do pooling da 05a).

---

## Parte A — exemplo canônico da aula

Ranking BM25 da Aula 04: `d3 d1 d2 d4 d8 d6 d5 d7`  
Gabarito: d2 = 2, d3 = 2, d1 = 1, d6 = 1, resto 0 · limiar $\geq 2$ → relevantes = {d2, d3}

| | valor |
|---|---:|
| `rel` | `1 0 1 0 0 0 0 0` |
| P@3 | 0,667 |
| AP | 0,833 |
| MRR | 1,000 |
| nDCG binário | 0,920 |
| nDCG graduado | 0,951 |

Conferência à mão bate com o Guia 01.

---

## Parte B — cosseno vs BM25 no nosso corpus

122 frases · limiar grau $\geq 2$ · 11 consultas com $R > 0$.

### MAP

| sistema | MAP | n consultas |
|---|---:|---:|
| BM25 | **0,363** | 11 |
| cosseno (TF-IDF) | **0,377** | 11 |

Vitórias por AP (consulta a consulta): cosseno **5** · BM25 **3** · empate **3**.

### Por consulta (P@3 · AP · MRR · nDCG bin · nDCG grad)

| q | $R$ | BM25 | cosseno | vence (AP) |
|---|--:|---|---|---|
| q01 | 2 | 0,000 · 0,079 · 0,067 · 0,289 · 0,334 | 0,000 · 0,082 · 0,059 · 0,289 · 0,329 | cos (ligeiro) |
| q03 | 3 | 0,333 · 0,511 · 1,000 · 0,754 · 0,690 | 0,667 · **0,639** · 1,000 · 0,831 · 0,748 | **cos** |
| q04 | 1 | 0,333 · 1,000 · 1,000 · 1,000 · 0,826 | idem | empate |
| q05 | 2 | 0,333 · 0,500 · 0,500 · 0,651 · 0,599 | 0,667 · **0,583** · 0,500 · 0,693 · 0,644 | **cos** |
| q06 | 5 | 0,000 · 0,105 · 0,200 · 0,386 · 0,386 | 0,000 · **0,128** · 0,250 · 0,414 · 0,414 | **cos** |
| q07 | 1 | 0,000 · 0,143 · 0,143 · 0,333 · 0,310 | 0,000 · **0,200** · 0,200 · 0,387 · 0,345 | **cos** |
| q09 | 2 | 0,000 · **0,139** · 0,125 · 0,354 · 0,456 | 0,000 · 0,121 · 0,100 · 0,334 · 0,551 | **BM25** |
| q10 | 2 | 0,333 · 0,260 · 0,500 · 0,478 · 0,453 | idem | empate |
| q11 | 1 | 0,000 · 0,009 · 0,009 · 0,146 · 0,280 | idem (~) | empate |
| q13 | 3 | 0,333 · **0,411** · 0,333 · 0,583 · 0,583 | 0,000 · 0,337 · 0,250 · 0,526 · 0,526 | **BM25** |
| q15 | 3 | 0,667 · **0,833** · 1,000 · 0,933 · 0,915 | 0,667 · 0,792 · 1,000 · 0,913 · 0,876 | **BM25** |

CSV: [`05b-metricas-por-consulta.csv`](../estrutura/codigos/05-julgamento/csv/05b-metricas-por-consulta.csv)

---

## Leitura (sem declarar “vencedor absoluto”)

- Em **média** o cosseno ficou um pouco acima (MAP 0,377 vs 0,363), mas o BM25
  ganha forte em consultas “bem ancoradas” (q15 localização; q13 porto organizado;
  q09 cargas).
- O cosseno sobe em q03/q05 (P@3 melhor) — o primeiro relevante às vezes
  aparece mais cedo no TF-IDF.
- q11 é péssima nos dois (relevante muito fundo no ranking): a pool não
  garante que o sistema ache o grau-2 no topo.
- **Ressalva:** 11 consultas e pool parcial. Diferença pequena **não** é
  significância — isso é Aula 16. Três armadilhas do Guia 01: uma métrica
  sozinha, corpus/pool limitada, e tratar 0,377 > 0,363 como prova.

---

## Onde isso entra no motor

```
05a  julgamento → qrels
05b  métricas   → o gabarito vira régua (esta)
06   Rocchio    → o gabarito vira entrada do algoritmo
```

---

## Próximo

Aula 06 (Rocchio): documentos grau ≥ limiar reescrevem a consulta; medir de
novo com as mesmas cinco métricas se o ranking melhorou.

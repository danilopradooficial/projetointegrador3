<div align="center">

# Atividade 06 - Rocchio, expansão de consulta e pseudo-feedback

**Team Shannon · Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

A primeira consulta raramente é perfeita: o feedback de relevância reescreve
a consulta na direção dos bons resultados. Fecha a Fase 2 do motor.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-conclu%C3%ADda-brightgreen)
![Entrega](https://img.shields.io/badge/entrega-8%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-06-lightgrey)

</div>

---

## Sobre a atividade

**8ª entrega · Aula 06.** Tarefa do slide 15:

1. Implementar `rocchio` sobre o corpus de 8 documentos.
2. Escolher uma consulta, marcar 1–2 relevantes e comparar o ranking antes/depois.
3. Implementar pseudo-feedback com os top-2 e discutir o resultado.

| Item | Situação |
|---|---|
| Exemplo canônico dos slides (8 docs) | **conferido — números idênticos** |
| Tarefa 1 · função `rocchio` | pronta |
| Tarefa 2 · consulta própria, antes/depois | **feita** |
| Tarefa 3 · pseudo-feedback top-2 | **feita e discutida** |
| Extra · Rocchio e PRF no nosso corpus, medidos com as métricas da 05b | rodado · CSV gerado |

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victória Cabral Quintério  
**Gabarito.** [Atividade 05a](./05a-julgamento-pooling-kappa.md) · **Métricas.** [Atividade 05b](./05b-metricas-avaliacao.md)

---

## Material

- [Aula 06 PDF — Rocchio, Expansão de Consulta e Pseudo-Feedback](../materiais-aulas/Aula%2006%20-%20Rocchio,%20Expansão%20de%20Consulta%20e%20Pseudo-Feedback.PDF)
- [Atividade 02 · TF-IDF e cosseno](./02-tfidf-similaridade-cosseno.md) — o espaço vetorial onde a consulta se move
- [Atividade 05b · Métricas](./05b-metricas-avaliacao.md)
- Leitura: Manning et al., *IIR*, cap. 9 · Baeza-Yates & Ribeiro-Neto, cap. 5

---

## Script

```bash
cd estrutura/codigos
Rscript 06-rocchio.R
```

Gera `05-julgamento/csv/06-rocchio-por-consulta.csv`.

---

## O algoritmo

$$
\vec q_m = \alpha\,\vec q_0 + \beta\,\frac{1}{|D_r|}\sum_{d \in D_r}\vec d \;-\; \gamma\,\frac{1}{|D_{nr}|}\sum_{d \in D_{nr}}\vec d
$$

com $\alpha = 1$, $\beta = 0{,}75$, $\gamma = 0{,}15$. Os centroides são
`rowMeans` das colunas da matriz TF-IDF:

```r
rocchio <- function(q, w, Dr, Dnr = character(0),
                    a = 1, b = 0.75, g = 0.15, zerar_neg = FALSE) {
  cr <- if (length(Dr)) rowMeans(w[, Dr, drop = FALSE]) else 0
  cnr <- if (length(Dnr)) rowMeans(w[, Dnr, drop = FALSE]) else 0
  qm <- a * q + b * cr - g * cnr
  if (zerar_neg) qm[qm < 0] <- 0
  qm
}
```

Pseudo-feedback = Rocchio com $D_r$ = top-$k$ da primeira busca e $D_{nr} = \varnothing$.

---

## Parte A — exemplo canônico (conferência dos slides)

Consulta `"modelo de recuperacao"`, $D_r = \{d2, d3\}$, $D_{nr} = \{d4\}$.

| termo | $\vec q_m$ |
|---|---:|
| modelo | 2,426 |
| recuperacao | 1,178 |
| de | 0,999 |
| bm25 · como · espaco | 0,780 |

A consulta tem peso em 3 termos e passa a ter peso em **21**. Cinco deles têm
peso negativo e vêm de d4: `a`, `aprendizado`, `estatistico`, `fundamenta` e `moderna`.

| | ranking |
|---|---|
| base (cosseno) | d1 · d3 · **d4** · d2 · d6 · d8 · d5 · d7 |
| Rocchio | **d3 · d2** · d1 · d6 · d8 · d5 · d7 · **d4** |
| Rocchio com negativos zerados | d3 · d2 · d1 · d4 · d6 · d5 · d8 · d7 |

Os scores do Rocchio são `0,650 0,643 0,140 0,055 0,045 0,041 −0,007 −0,060`,
idênticos aos do slide 12. O d2 sobe do 4º para o 2º lugar e o d4 cai do 3º
para o último. Quando zeramos os pesos negativos, o d4 volta para o 4º lugar:
ele só cai para o fim por causa do $\gamma$.

| gabarito da aula (grau $\geq 2$) | P@3 | AP | MRR | nDCG bin | nDCG grad |
|---|---:|---:|---:|---:|---:|
| base | 0,333 | 0,500 | 0,500 | 0,651 | 0,837 |
| Rocchio | 0,667 | **1,000** | 1,000 | 1,000 | 1,000 |

Esse ganho é otimista, porque d2, d3 e d4 foram usados como feedback e
também entram na medição.

---

## Parte B — tarefa de casa (8 docs)

### Tarefa 2 · consulta própria

**Consulta:** `"busca de documentos"`. A necessidade é: *como o motor encontra
documentos para uma busca*.

- **Relevantes marcados:** d5 (*índice invertido acelera a busca*) e d1 (*recuperação ordena documentos por relevância*).
- **Não relevante marcado:** d6 (*embeddings… palavras e documentos*). Ele fala de documentos, mas não de busca.

| doc | antes | depois |
|---|:-:|:-:|
| d5 | 1 | 1 |
| d1 | 3 | **2** |
| d7 | 2 | 3 |
| d2 | 5 | 4 |
| d4 | 8 | 5 |
| d3 | 6 | 6 |
| d8 | 7 | 7 |
| d6 | 4 | **8** |

Termos de maior peso em $\vec q_m$: `busca 1,906`, `documentos 1,109`,
`acelera`, `em`, `indice` e `informacao` (todos com 0,780). Os termos
`indice` e `informacao` ninguém digitou: entraram por **expansão**, vindos
de d5 e d1.

O d1 passou o d7 e o d6 caiu do 4º para o último lugar. O que nos
surpreendeu foi o d4 (*aprendizado estatístico… recuperação moderna*),
que subiu do 8º para o 5º. Ele não tem nenhum termo da consulta, mas
compartilha `recuperacao` com o d1. A expansão puxa o que é parecido com
os relevantes, e não só o que é parecido com a consulta.

### Tarefa 3 · pseudo-feedback (top-2)

| consulta | top-2 assumidos relevantes | base | PRF |
|---|---|---|---|
| modelo de recuperacao | d1, d3 | d1 d3 d4 d2 d6 d8 d5 d7 | **d3 d1 d2** d4 d6 d8 d7 d5 |
| busca de documentos | d5, d7 | d5 d7 d1 d6 d2 d3 d8 d4 | d5 d7 d1 d6 d2 d4 d3 d8 |

Na consulta canônica, com o gabarito da aula, o AP sobe de 0,500 para
**0,833** e o nDCG graduado de 0,837 para 0,958. Isso acontece porque o top-2
era "bom o bastante": o d3 é relevante (grau 2) e o d1 é parcialmente
relevante (grau 1). O d2 sobe para o 3º lugar sem que ninguém o tenha marcado.

### Discussão

- **O PRF funciona quando o top-k já é bom.** Na consulta canônica, ele
  conseguiu quase o mesmo efeito que o usuário (AP 0,833 contra 1,000),
  sem pedir nada a ninguém.
- **Query drift.** Em `"busca de documentos"`, o PRF assumiu que o d7
  (*avaliação mede a relevância*) era relevante. Com isso, entraram na
  consulta `avaliacao`, `mede`, `resultados`, e também palavras vazias como
  `a`, `da`, `dos` e `o`, porque o corpus de 8 documentos não tem limpeza.
  O ranking quase não mudou, mas a consulta passou a "puxar" na direção da
  avaliação. Com o usuário marcando, o d1 subiu. Com o PRF, o d1 ficou
  onde estava.
- **O PRF não tem $D_{nr}$.** Por isso, ele não consegue empurrar o
  "não relevante incômodo" para baixo: na consulta canônica o d4 só desce
  do 3º para o 4º lugar, empurrado pelo d2. Quem derruba o d4 é o $\gamma$, e o $\gamma$ só existe com
  feedback humano.
- O `k` pequeno ($k = 2$) e o $\beta$ moderado ($0{,}75$) limitam o estrago,
  como recomenda o slide 13.

---

## Parte C — nosso corpus (extra: o gabarito vira entrada do algoritmo)

Foram usadas 122 frases e 873 termos, com o mesmo pré-processamento da 05b
(limpeza, stopwords e Snowball) e o cosseno TF-IDF como busca base. Há 11
consultas com $R > 0$ no limiar de grau $\geq 2$.

**Dois cenários:**

- **PRF top-2.** É automático e não usa o gabarito para montar a consulta.
  Por isso, pode ser avaliado na coleção inteira.
- **Rocchio com usuário simulado.** O "usuário" olha os top-5 da primeira
  busca e marca o que foi julgado na 05a: grau $\geq 2$ vai para $D_r$ e
  grau 0 vai para $D_{nr}$. A avaliação é feita na **coleção residual**:
  removemos os top-5 que ele já viu dos dois rankings e do gabarito. Sem
  isso, o Rocchio "ganharia" só por reposicionar documentos que o usuário
  acabou de marcar.

### Resumo

| cenário | consultas | MAP antes | MAP depois |
|---|:-:|---:|---:|
| PRF top-2 (coleção inteira) | 11 | 0,377 | 0,380 |
| Rocchio · usuário top-5 (residual) | 5 com $D_r > 0$ | 0,316 | **0,609** |

No PRF, o AP melhora em 3 consultas, piora em 6 e empata em 2.

### Por consulta (AP)

| q | $R$ | $\lvert D_r\rvert$ · $\lvert D_{nr}\rvert$ | base | PRF | residual base | residual Rocchio |
|---|:-:|:-:|---:|---:|---:|---:|
| q01 | 2 | 0 · 0 | 0,082 | 0,036 | 0,113 | 0,113 *(sem feedback)* |
| q03 | 3 | 2 · 0 | 0,639 | 0,591 | 0,143 | **0,250** |
| q04 | 1 | 1 · 1 | 1,000 | 1,000 | — | — *(único relevante já visto)* |
| q05 | 2 | 2 · 0 | 0,583 | 0,500 | — | — *(relevantes já vistos)* |
| q06 | 5 | 1 · 1 | 0,128 | 0,090 | 0,096 | **0,255** |
| q07 | 1 | 1 · 1 | 0,200 | **0,250** | — | — *(único relevante já visto)* |
| q09 | 2 | 0 · 0 | 0,121 | 0,121 | 0,211 | 0,211 *(sem feedback)* |
| q10 | 2 | 1 · 3 | 0,260 | **0,417** | 0,010 | **1,000** |
| q11 | 1 | 0 · 1 | 0,009 | 0,009 | 0,009 | 0,009 *(sem $D_r$)* |
| q13 | 3 | 1 · 3 | 0,337 | 0,304 | 1,000 | 0,540 |
| q15 | 3 | 2 · 1 | 0,792 | **0,867** | 0,333 | **1,000** |

CSV: [`06-rocchio-por-consulta.csv`](../estrutura/codigos/05-julgamento/csv/06-rocchio-por-consulta.csv)

### Leitura

- **O feedback humano ajuda muito, mas só quando existe.** Em 4 das 5
  consultas com $D_r > 0$, o Rocchio trouxe para cima relevantes que
  estavam enterrados. Na q10, por exemplo, o relevante restante subiu e o
  AP residual foi de 0,010 para 1,000. A exceção é a q13: o centroide do
  único relevante visto "puxou" para frases vizinhas que não eram
  relevantes, e o AP residual caiu de 1,000 para 0,540.
- **O PRF fica praticamente neutro em média (0,377 → 0,380), mas piora
  mais do que melhora (6 contra 3).** É o query drift do slide 13 em escala
  real. As consultas q03, q10 e q11 têm o mesmo top-2 base (d1.34, d2.7) e
  o PRF puxa a mesma frase (d2.3) para todas elas: o top-2 manda mais do
  que a consulta.
- **Sem relevante no topo, não há feedback.** Na q01, q09 e q11, nenhum dos
  top-5 tem grau $\geq 2$, e o Rocchio não tem de onde aprender. É o caso
  "recall baixo na 1ª tentativa": a realimentação não salva uma busca
  inicial ruim.
- **Ressalva:** são 11 consultas com pool parcial, e a coleção residual
  fica pequena (em várias consultas sobra 1 relevante). As diferenças aqui
  não são significância estatística, que é assunto da Aula 16.

---

## Onde isso entra no motor

```
05a  julgamento → qrels
05b  métricas   → o gabarito vira régua
06   Rocchio    → o gabarito (ou o top-k) vira entrada do algoritmo (esta)
```

---

## Próximo

Fase 3, a parte neural: embeddings e semântica, e recuperação densa. A
"reformulação moderna" do slide 14 troca o centroide TF-IDF por um modelo de
linguagem que reescreve a consulta.

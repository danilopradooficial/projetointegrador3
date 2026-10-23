<div align="center">

# Atividade 07 - LSA (SVD) e fusao de rankings (RRF)

**Team Shannon · Projeto Integrador III · Ciencia de Dados · Fatec Rubens Lara**

Vetores densos pela decomposicao SVD da matriz TF-IDF e fusao hibrida
BM25 + LSA pelo Reciprocal Rank Fusion. Abre a Fase 3 do motor.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-conclu%C3%ADda-brightgreen)
![Entrega](https://img.shields.io/badge/entrega-9%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-07-lightgrey)

</div>

---

## Sobre a atividade

**9a entrega · Aula 07.** Tarefa do slide "Para casa" (Parte D):

1. `lsa` no corpus do grupo; comparar o top-5 de LSA com o do BM25 numa consulta, lendo os textos.
2. MAP de BM25, LSA com varios `k` (10, 20, 50, ate o numero de documentos) e `rrf(BM25, LSA)`: escolher no **dev**, relatar no **teste** uma vez.
3. Registrar `modelo`, `lsa_k` e `rrf_c` no `config.R` e na ficha.

| Item | Situacao |
|---|---|
| Exemplo canonico dos slides (8 docs) | **conferido** (energia k=2 = 32,3%; AP LSA = 1,000) |
| Tarefa 1 · top-5 BM25 x LSA x RRF no nosso corpus | **feita** (3 perguntas do projeto) |
| Tarefa 2 · MAP no dev / teste | **feita** · escolhido hibrido k=20 |
| Tarefa 3 · `config.R` + ficha | **feita** |

> **Base de dados.** O trabalho usa o corpus do projeto: as 122 frases
> `d1.1 … d3.5` das tres paginas da Wikipedia (*Porto de Santos*,
> *Autoridade Portuaria de Santos*, *Francisco de Paula Ribeiro*). O corpus
> de 8 documentos dos slides aparece so para conferir os numeros da aula.

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victoria Cabral Quinterio  
**Gabarito.** [Atividade 05a](./05a-julgamento-pooling-kappa.md) · **Metricas.** [Atividade 05b](./05b-metricas-avaliacao.md)

---

## Material

- [Aula 07 PDF - Vetores Densos pela SVD e Fusao de Rankings](../materiais-aulas/Aula%2007%20-%20Vetores%20Densos%20pela%20SVD%20e%20Fusão%20de%20Rankings.PDF)
- [Atividade 06 · Rocchio](./06-rocchio-expansao-pseudo-feedback.md)
- Leitura: Manning et al., *IIR*, cap. 18 · Deerwester et al. (1990) · Cormack, Clarke & Buttcher (2009), RRF

---

## Script

```bash
cd estrutura/codigos
Rscript 07-lsa-rrf.R
```

Gera:

- `05-julgamento/csv/07-lsa-top5.csv` (Parte B)
- `05-julgamento/csv/07-lsa-map-por-k.csv` (Parte C)
- `05-julgamento/csv/07-lsa-por-consulta.csv` (Parte C)
- atualiza `estrutura/codigos/config.R`

---

## O algoritmo

**LSA** = SVD da matriz TF-IDF $W$:

$$
W = U\Sigma V^\top \approx U_k\Sigma_k V_k^\top
$$

Documentos no espaco $k$: linhas de $D = V_k\Sigma_k$.  
Consulta (fold-in): $\vec q_k = U_k^\top \vec q_0$.  
Ranqueamento: cosseno entre $\vec q_k$ e as linhas de $D$.

Energia guardada: $\sum_{i\le k}\sigma_i^2 / \sum_i\sigma_i^2$.

**RRF** (fusao de rankings, $c = 60$):

$$
\mathrm{RRF}(d) = \sum_r \frac{1}{c + \mathrm{pos}_r(d)}
$$

```r
lsa_fit <- function(w, k) {
  s <- svd(w)
  list(Uk = s$u[, 1:k], Sk = s$d[1:k],
       Dk = s$v[, 1:k] %*% diag(s$d[1:k]))
}
rank_lsa <- function(q0, fit) {
  qk <- as.numeric(t(fit$Uk) %*% q0)
  # cosseno de qk contra cada linha de fit$Dk
}
rrf <- function(..., c = 60) { /* 1/(c + pos) somado */ }
```

---

## Parte A - exemplo canonico (conferencia dos slides)

Consulta `"modelo de recuperacao"`, gabarito da aula (grau >= 2: d2, d3).

Energia acumulada no corpus de 8 docs: k=2 guarda **32,3%** (bate com o slide).

| metodo | AP | nDCG grad | top |
|---|--:|--:|---|
| BM25 | 0,833 | 0,951 | d3 d1 d2 … |
| cosseno TF-IDF | 0,500 | 0,837 | d1 d3 d4 d2 … |
| LSA k=2 | **1,000** | 0,966 | d2 d3 d8 … |
| RRF(BM25, LSA-2) | **1,000** | **0,990** | d3 d2 d1 … |

Com k=2 o d8 sobe (vizinho inventado: so compartilha `"e"` e `"de"` com d3 no lexico). Com k=4 o AP volta a 1,000 e o d8 cai - o `k` e hiperparametro.

---

## Parte B - top-5 no nosso corpus (tarefa 1)

122 frases, 873 radicais, prep da Aula 03. LSA com **k = 20** (40,1% da energia) para a leitura qualitativa; o `k` definitivo sai da Parte C.

### Pergunta 1 · Onde fica o Porto de Santos?

Consulta: `localizacao porto santos guaruja cubatao`.

| pos | BM25 | LSA k=20 | RRF |
|:-:|---|---|---|
| 1 | **d1.1** (municipios Santos/Guaruja/Cubatao) | d1.61 (margens do estuario) | **d1.1** |
| 2 | d1.61 | **d1.1** | d1.61 |
| 3 | d1.82 (Cubatao / proximidade ao porto) | d1.82 | d1.82 |
| 4 | d1.52 (incendio Cargill) | d1.29 (usina Itatinga) | d1.29 |
| 5 | d1.30 (localizacao da *usina*) | d1.28 (predios da administracao) | d1.30 |

BM25 e RRF colocam a resposta literal no topo. O LSA troca d1.1 e d1.61 (ambas relevantes) e puxa Itatinga (d1.29) por proximidade semantica de "local" / Cubatao - vizinho inventado fraco, nao fatal.

### Pergunta 2 · Quem administra o porto hoje?

Consulta: `quem administra porto santos autoridade`.

| pos | BM25 | LSA k=20 | RRF |
|:-:|---|---|---|
| 1 | d1.36 (Porto Organizado / jurisdicao) | **d2.16** (APS assume Itajai) | **d2.16** |
| 2 | d2.9 (mesma frase que d1.36) | **d2.4** (APS administra a infraestrutura) | **d2.4** |
| 3 | **d2.4** | d2.8 / d1.35 (Codesp → autoridade) | d1.36 |
| 4 | d2.16 | d2.8 / d1.35 | d2.9 |
| 5 | d1.13 (concessao Gaffree-Guinle) | **d2.2** (responsavel pela infraestrutura) | d2.8 |

Aqui o LSA **ajuda**: a resposta d2.4 sobe do 3.o (BM25) para o 2.o, e d2.2 entra no top-5. O BM25 ainda sofre com a frase duplicada d1.36 = d2.9 (mesmo problema da Aula 06). O RRF coloca d2.16 e d2.4 no topo - as duas falam da APS administrando.

### Pergunta 3 · Quem foi Francisco de Paula Ribeiro?

Consulta: `francisco de paula ribeiro porto`.

| pos | BM25 | LSA k=20 | RRF |
|:-:|---|---|---|
| 1 | **d3.1** (biografia) | **d3.1** | **d3.1** |
| 2 | **d1.17** (superintendente da Docas) | d3.5 (filhos) | **d1.17** |
| 3 | d3.4 (familia) | d3.4 | d3.5 |
| 4 | d3.5 | d1.17 | d3.4 |
| 5 | d1.1 | d1.88 (alfandega / Anvisa) | d1.1 |

BM25 ordena melhor a ligacao com o porto (d1.17 em 2.o). O LSA aproxima a familia (d3.4, d3.5) porque compartilham o eixo "Ribeiro" - mismatch semantico tipico do k baixo. O RRF recupera d1.17 para o 2.o lugar.

---

## Parte C - MAP no dev e no teste (tarefa 2)

**Split** (fixo no script; nao havia coluna `conjunto` nas necessidades):

- **dev** (escolhe): q01, q03, q05, q06, q09, q10, q13
- **teste** (relato unico): q04, q07, q11, q15

Limiar: grau >= 2. Consultas com R = 0 (ex.: q02) ficam fora do MAP.

### MAP no desenvolvimento

| metodo | k | MAP_dev |
|---|--:|--:|
| BM25 | - | 0,286 |
| LSA | 10 | 0,229 |
| RRF(BM25, LSA) | 10 | 0,310 |
| LSA | **20** | 0,318 |
| **RRF(BM25, LSA)** | **20** | **0,350** |
| LSA | 50 | 0,304 |
| RRF | 50 | 0,276 |
| LSA | 80 | 0,306 |
| RRF | 80 | 0,284 |

Energia no nosso corpus: k=10 → 23,6%; k=20 → 40,1%; k=50 → 72,4%; k=80 → 90,7%.

### Escolha (so no dev)

**modelo = `hibrido`**, **lsa_k = 20**, **rrf_c = 60**.  
Motivo: maior MAP_dev (0,350), acima do BM25 (0,286) e do LSA puro (0,318).

### MAP no teste (uma vez)

| metodo | MAP_teste |
|---|--:|
| BM25 | **0,496** |
| LSA k=20 | 0,449 |
| RRF k=20 (escolhido) | 0,487 |

O hibrido ficou um pouco abaixo do BM25 no teste (0,487 vs 0,496), mas foi a escolha feita **antes** de ver o teste. Nao se retoca o `k`. Com so 4 consultas de teste e pool parcial, a diferenca nao e significancia (Aula 16).

CSV: [`07-lsa-map-por-k.csv`](../estrutura/codigos/05-julgamento/csv/07-lsa-map-por-k.csv) · [`07-lsa-por-consulta.csv`](../estrutura/codigos/05-julgamento/csv/07-lsa-por-consulta.csv)

### Por consulta (k = 20)

| conj | q | R | AP BM25 | AP LSA | AP RRF |
|---|---|--:|--:|--:|--:|
| dev | q01 | 2 | 0,079 | 0,137 | 0,094 |
| dev | q03 | 3 | 0,511 | 0,359 | **0,611** |
| dev | q05 | 2 | 0,500 | 0,611 | **0,750** |
| dev | q06 | 5 | 0,105 | **0,210** | 0,138 |
| dev | q09 | 2 | 0,139 | 0,142 | **0,155** |
| dev | q10 | 2 | 0,260 | **0,450** | 0,282 |
| dev | q13 | 3 | 0,411 | 0,317 | **0,421** |
| teste | q04 | 1 | 1,000 | 1,000 | 1,000 |
| teste | q07 | 1 | **0,143** | 0,048 | 0,125 |
| teste | q11 | 1 | 0,009 | **0,025** | 0,014 |
| teste | q15 | 3 | **0,833** | 0,722 | 0,810 |

### Leitura

- **No dev o hibrido vence** em 4 das 7 consultas e empata a lideranca do MAP medio.
- **LSA puro ajuda** quando o vocabulario diverge (q06, q10), mas **piora** quando o top lexico ja e bom (q03, q13, q15).
- **k=20 foi o pico**; k maior (50, 80) aproxima o TF-IDF esparso e o RRF perde o ganho.
- **Ressalva:** 7 + 4 consultas, pool parcial. O teste mostrou o BM25 um fio a frente - o grupo mantem o hibrido porque essa foi a regra da aula (escolhe no dev).

---

## Decisao no motor (tarefa 3)

Em [`estrutura/codigos/config.R`](../estrutura/codigos/config.R):

```r
modelo  <- "hibrido"
lsa_k   <- 20L
rrf_c   <- 60
limiar  <- 2L
```

MAP_dev hibrido = 0,350 · MAP_teste hibrido = 0,487 · MAP_teste BM25 = 0,496.

---

## Onde isso entra no motor

```
05b  metricas   → o gabarito vira regua
06   Rocchio    → feedback reformula a consulta
07   LSA + RRF  → espaco denso + fusao esparso/denso (esta)
```

---

## Proximo

Aula 08: reordenar o topo (retrieve & rerank); proximidade / ordem das palavras da consulta.

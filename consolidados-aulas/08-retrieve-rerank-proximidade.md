<div align="center">

# Atividade 08 - Retrieve & rerank (proximidade ordenada)

**Team Shannon · Projeto Integrador III · Ciencia de Dados · Fatec Rubens Lara**

Dois estagios: o estagio 1 recupera (hibrido BM25+LSA da Aula 07) e o
estagio 2 reordena so o top-k lendo consulta e documento juntos
(proximidade ordenada - o "brinquedo" da aula que simula o cross-encoder).

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-conclu%C3%ADda-brightgreen)
![Entrega](https://img.shields.io/badge/entrega-10%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-08-lightgrey)

</div>

---

## Sobre a atividade

**10a entrega · Aula 08.** Tarefa do slide "Para casa" / Parte D (guia v2):

1. Implementar `proximidade` e `reordenar`; conferir os numeros dos slides.
2. Numa consulta, reordenar o top-k do estagio 1 e comparar o top-5 antes/depois, lendo os textos.
3. MAP estagio 1 × estagio 1 + rerank, $k \in \{3,5,10\}$ e janela $\in \{2,3,5\}$: escolher no **dev**, relatar no **teste** uma vez.
4. Registrar `rerank_k` e `janela` no `config.R` e na ficha.

| Item | Situacao |
|---|---|
| Exemplo canonico dos slides (8 docs) | **conferido** (prox d2=1,0; d3=0,5; k=3 sobe d2; AP 0,833 → 1) |
| Tarefa 1 · top-5 antes × depois no nosso corpus | **feita** (q15 / localizacao) |
| Tarefa 2 · grade no dev / teste | **feita** · escolhido k=5, janela=3 |
| Tarefa 3 · `config.R` + ficha | **feita** |

> **Nota do guia v2.** O cross-encoder neural (Colab / `ce_escores.csv`) saiu da
> parte pratica por decisao do professor; o estagio 2 e a **proximidade ordenada**
> em R. O PDF da aula ainda motiva o neural; a mecanica do pipeline e a mesma.

> **Base de dados.** Corpus do projeto: 122 frases `d1.1 … d3.5`. Estagio 1 =
> `modelo = hibrido` (Aula 07). O corpus de 8 docs dos slides so confere numeros.

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victoria Cabral Quinterio  
**Gabarito.** [Atividade 05a](./05a-julgamento-pooling-kappa.md) · **Estagio 1.** [Atividade 07](./07-lsa-fusao-rankings.md)

---

## Material

- [Aula 08 PDF - Cross-Encoders e o Pipeline Retrieve & Rerank](../materiais-aulas/Aula%2008%20-%20Cross-Encoders%20e%20o%20Pipeline%20Retrieve%20%26%20Rerank.PDF)
- [GUIA_ESTUDO_aula08.md](../materiais-tutora/GUIA_ESTUDO_aula08.md) · [Parte D](../materiais-tutora/GUIA_ESTUDO_aula08_parteD.md)
- Leitura: Lin, Nogueira & Yates (2021), cap. 3 · Nogueira & Cho (2019)

---

## Script

```bash
cd estrutura/codigos
Rscript 08-retrieve-rerank.R
```

Gera:

- `05-julgamento/csv/08-rerank-top5.csv`
- `05-julgamento/csv/08-rerank-map-grade.csv`
- `05-julgamento/csv/08-rerank-por-consulta.csv`
- atualiza `estrutura/codigos/config.R` (`rerank_k`, `janela`)

---

## O algoritmo

**Estagio 1** (Aula 07): ranking `hibrido` = RRF(BM25, LSA k=20).

**Estagio 2** - proximidade ordenada (brinquedo da aula):

$$
\text{prox}(q,d) = \sum_{i<j} \frac{1}{\min \delta_{ij}}, \quad
\delta_{ij} = \text{pos}_d(t_j) - \text{pos}_d(t_i) \in \{1,2,3\}
$$

so pares da consulta na ordem $t_i$ antes de $t_j$, com $t_j$ depois de $t_i$ no documento, ate a janela. Precisa das **posicoes** - por isso le o par junto, como um cross-encoder.

`reordenar(rk, k, sc)`: reordena so a cabeca (top-k); a cauda fica na ordem do estagio 1.

---

## Parte A - slides (conferencia)

Consulta `"modelo de recuperacao"`, BM25: `d3 d1 d2 d4 …`.

| doc | prox | por que |
|---|---:|---|
| d2 | 1,0 | `modelo` imediatamente antes de `de` |
| d3 | 0,5 | `modelo` … `de` com $\delta=2$ |
| d1 | 0 | termos na ordem inversa |

| | ranking | AP | nDCG_grad |
|---|---|---:|---:|
| BM25 | d3 d1 d2 … | 0,833 | 0,951 |
| k=2 | d3 d1 d2 … (nao muda) | 0,833 | 0,951 |
| k=3 | **d2** d3 d1 … | **1,000** | 0,982 |

Com k=2 o d2 fica fora da cabeca - o estagio 1 limita o estagio 2. Numeros identicos ao slide 12.

**Tarefa individual da teoria** (duas consultas curtas no corpus de 8):

| consulta | BM25 top | prox destaque | k=2 | k=4 | leitura |
|---|---|---|---|---|---|
| `modelo vetorial` | d2 no alto | d2 = 1/3 | quase igual | quase igual | termos colados em d2; o brinquedo confirma o BM25 |
| `busca documentos` | d5 · d7 · … | so d5 pontua | nao muda o topo | nao muda | ordem literal; `"documentos busca"` zera (limite M5) |

---

## Parte B - nosso corpus (Modulo 7 do guia)

Estagio 1 = `hibrido`. Duas leituras exigidas pelo guia (uma em que a reordenacao **ganhou**, uma em que **perdeu**).

### Onde ganhou - q13 (dev) · "o que e porto organizado santos"

| | top-5 |
|---|---|
| hibrido | d1.66 · d1.22 · d1.15 · d2.21 · d1.72 |
| rerank k=5, janela=3 | d1.66 · **d2.21** · d1.15 · d1.72 · d1.22 |

- **Subiu d2.21:** fala da malha ferroviaria *dentro do Porto Organizado* e cita o porto de Santos - termos da consulta em ordem e perto; responde ao conceito.
- **Desceu d1.22:** greve de 1897 em Santos - tem a cidade, mas **nao** define Porto Organizado.
- AP 0,421 → **0,532**. Aqui a proximidade alinhou ordem lexical com a necessidade.

### Onde perdeu - q15 (teste) · localizacao

Consulta: `localizacao porto de santos guarujá cubatão`  
Tokens (prep): `localizaca port sant guaruj cubata`.

| | top-5 |
|---|---|
| hibrido | d1.1 · d1.61 · d1.82 · d1.29 · d1.30 |
| rerank k=5 / k=10 | d1.1 · d1.82 · **d2.5** · **d3.2** · … |

- **Subiram d2.5 e d3.2:** concessao CDS / Ribeiro + Docas - `port`+`sant` colados, mas **nao localizam** o porto.
- **Sairam d1.29 / d1.30:** usina / Bertioga - "localizacao" em outro sentido.
- AP 0,810 → **0,698**. A regra sobe ordem de palavras sem julgar a necessidade - exatamente o limite do brinquedo frente a um cross-encoder treinado.

---

## Parte C - grade no dev e teste uma vez

Split (igual Aula 07):  
**dev** q01, q03, q05, q06, q09, q10, q13 · **teste** q04, q07, q11, q15.

MAP_dev do estagio 1 (k=0): **0,350**.

|  | janela 2 | janela 3 | janela 5 |
|---|---:|---:|---:|
| k=3 | 0,358 | 0,358 | 0,322 |
| k=5 | **0,366** | **0,366** | 0,330 |
| k=10 | 0,363 | 0,363 | 0,319 |

**Escolha no dev:** `rerank_k = 5`, `janela = 3` (empate com janela 2; fica a da teoria).  
No dev a escolha **nao perde** AP em nenhuma consulta; o ganho vem sobretudo de q13 (0,421 → 0,532).

| | MAP_teste |
|---|---:|
| estagio 1 (hibrido) | 0,487 |
| rerank k=5, janela=3 | **0,459** |

O teste ficou um fio abaixo - escolhemos **antes** de ver o teste e nao retocamos. Com 7+4 consultas e pool parcial, a diferenca nao e significancia (Aula 16).

### Por consulta (escolha)

| q | conjunto | AP estagio1 | AP rerank |
|---|---|---:|---:|
| q01 | dev | 0,094 | 0,094 |
| q03 | dev | 0,611 | 0,611 |
| q05 | dev | 0,750 | 0,750 |
| q06 | dev | 0,138 | 0,138 |
| q09 | dev | 0,155 | 0,155 |
| q10 | dev | 0,282 | 0,282 |
| q13 | dev | 0,421 | **0,532** |
| q04 | teste | 1,000 | 1,000 |
| q07 | teste | 0,125 | 0,125 |
| q11 | teste | 0,014 | 0,014 |
| q15 | teste | 0,810 | 0,698 |

CSV: [`08-rerank-por-consulta.csv`](../estrutura/codigos/05-julgamento/csv/08-rerank-por-consulta.csv)

---

## Decisao

**`rerank_k = 5`**, **`janela = 3`**, sobre o estagio 1 **`hibrido`**.

Motivo: maior MAP_dev (0,366), acima do estagio 1 (0,350), empatado com janela 2; custo menor que k=10.  
Ressalva: no teste o MAP caiu (0,487 → 0,459), puxado pela q15 - a proximidade promoveu frases com `porto`+`santos` que nao respondem localizacao.

Em [`estrutura/codigos/config.R`](../estrutura/codigos/config.R):

```r
modelo   <- "hibrido"
lsa_k    <- 20L
rrf_c    <- 60
rerank_k <- 5L
janela   <- 3L
```

---

## O que aprendemos

- O estagio 1 decide **quem entra**; o que ficou em 6o nunca sobe com k=5.
- A proximidade le a **ordem** das palavras - algo que BM25 e LSA nao veem - mas e uma regra tosca: sobe quem tem os termos colados, mesmo sem responder a necessidade.
- k e janela sao hiperparametros: escolhemos no dev; o teste conta uma vez.
- Cross-encoder neural (MonoBERT / mMiniLM) faz a mesma ideia com pesos aprendidos; fora do escopo pratico desta entrega (guia v2).

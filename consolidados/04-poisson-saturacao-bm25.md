<div align="center">

# Atividade 04 - Poisson, saturação e BM25

**Team Shannon · Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Da distribuição de Poisson ao peso do termo, até o BM25 no nosso
corpus do Porto de Santos.

![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)
![SnowballC](https://img.shields.io/badge/SnowballC-portuguese-orange)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Entrega](https://img.shields.io/badge/entrega-5%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-04-lightgrey)

</div>

---

## Sobre a atividade

**5ª entrega.** Até agora o motor foi crescendo assim: montamos o corpus
(Ativ 01), entendemos o IDF (01 B), ranqueamos com TF-IDF no brinquedo
(Ativ 02), limpamos o texto e fizemos o índice (Ativ 03). Nesta aula a
ideia é outra: o TF-IDF trata a 10ª ocorrência do termo igual à 2ª, e
documento longo tende a ganhar “de graça”. O caminho da Aula 04 começa
na **Poisson**, passa pela **saturação** e chega no **BM25**.

Aplicamos tudo nos **mesmos três textos** da Wikipédia (Porto de Santos,
Autoridade Portuária, Francisco de Paula Ribeiro), já com a limpeza e o
Snowball da Atividade 03.

> **Meta:** calcular probabilidade/peso via Poisson (e 2-Poisson), ver a
> saturação nascer do modelo e ranquear com BM25, comparando com TF-IDF.

**Equipe.** Team Shannon  
**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victoria Cabral Quinterio

---

## Onde isso entra no motor

```
Ativ 00     R base
Ativ 01 A   corpus real (3 artigos wiki)
Ativ 01 B   IDF = bits (Shannon)
Ativ 02     TF-IDF + cosseno          ← ranking “linear”
Ativ 03     limpeza + Snowball + índice
Ativ 04     Poisson → saturação → BM25  ← esta (5ª entrega)
```

Resumo: a 02 mostrou *como* ordenar; a 03 deixou o texto utilizável;
a 04 melhora o *peso* da frequência e leva o tamanho do documento em
conta.

---

## Material de referência

- [Aula 04 - Saturação, Tamanho de Documento e Ranqueamento](../materiais-aulas/Aula%2004%20-%20Satura%C3%A7%C3%A3o%2C%20Tamanho%20de%20Documento%20e%20Ranqueamento.PDF)
- [Atividade 03](./03-limpeza-stopwords-stemming-indice.md) (prep que reaproveitamos)
- [Atividade 02](./02-tfidf-similaridade-cosseno.md) (baseline TF-IDF)
- [README](../README.md)

---

## Estrutura da pasta

```
estrutura/corpus/
estrutura/codigos/
└── 04-poisson-bm25.R
consolidados/
└── 04-poisson-saturacao-bm25.md
```

---

## Como rodar

Mesmo pré-processamento da Ativ 03 (precisa do `SnowballC`):

```bash
cd "estrutura/codigos"
Rscript 04-poisson-bm25.R
```

---

# Tarefa (para casa da Aula 04)

No material o “para casa” pede BM25 no corpus de 8 docs. A gente fez o
mesmo raciocínio, mas **no corpus real** (continuação do motor):

1. Poisson / 2-Poisson → probabilidade e peso do termo (saturação)
2. Implementar BM25 nos 21 docs (3 artigos + 18 parágrafos)
3. Comparar com TF-IDF + cosseno em 3 consultas
4. Variar `k1` e `b` e ver o efeito na ordem

---

# 1. Poisson: probabilidade de contar f ocorrências

A Poisson modela contagens raras num intervalo. Para uma palavra:

\[
P(X = f) = e^{-\lambda}\,\frac{\lambda^f}{f!}
\]

Com \(\lambda = 2\) (exemplo da aula):

| f | 0 | 1 | 2 | 3 | 5 |
|---|--:|--:|--:|--:|--:|
| P(X=f) | 0,135 | 0,271 | 0,271 | 0,180 | 0,036 |

No nosso corpus, o stem `port` tem média de tf ≈ **6** por documento
(incluindo zeros). A Poisson com esse \(\lambda\) até descreve o “meio”,
mas o texto real é **burstiness**: ou o doc quase não fala do assunto,
ou fala bastante (`port` chega a tf=43 no artigo d1). Uma Poisson só
não explica bem esses extremos - daí a Aula 04 ir para duas populações.

---

# 2. Duas Poissons (eliteness) e o peso

Hipótese: docs **elite** (sobre o assunto) com taxa \(\lambda\) alta, e
**não-elite** com taxa \(\mu\) baixa. O peso do termo é o log da razão
de verossimilhanças (parâmetros do slide: \(\lambda=3\), \(\mu=0,2\),
\(p=0,6\), \(q=0,1\)):

| f | w(f) normalizado |
|--:|--:|
| 0 | 0,000 |
| 1 | 0,685 |
| 2 | 2,064 |
| 3 | 2,482 |
| 5 | 2,522 |
| 8 | 2,522 |

`w(0)` cru deu −0,7304; normalizamos subtraindo esse valor para a
ausência do termo valer zero. O teto fica em ≈ **2,52**. A partir da
3ª ocorrência o peso quase congela - **saturação**: repetir o termo
não aumenta a convicção de que o doc é elite.

Na prática a gente *não* estima \(\lambda, \mu, p, q\) por termo (são
ocultos). O BM25 copia só o *formato* dessa curva.

---

# 3. Do modelo ao BM25

Aproximação com um parâmetro (`k1`):

\[
\frac{f\,(k_1+1)}{f+k_1}
\]

Com `k1 = 1.2`:

| f | 1 | 2 | 3 | 4 | 5 |
|--:|--:|--:|--:|--:|--:|
| saturação | 1,000 | 1,375 | 1,571 | 1,692 | 1,774 |

Teto = `k1+1 = 2,2`. Depois entra o tamanho do documento (`b`) e o IDF
probabilístico da Aula 04:

\[
\mathrm{IDF}(t)=\log\Bigl(\frac{N-df_t+0{,}5}{df_t+0{,}5}+1\Bigr)
\]

No nosso índice (N = 21), amostras:

| stem | IDF BM25 |
|---|--:|
| port | 0,288 |
| sant | 0,288 |
| autor | 0,649 |
| carg | 1,219 |
| ribeir | 1,587 |

`port`/`sant` aparecem em muitos docs → IDF baixo. `ribeir` é mais raro
→ pesa mais.

Tamanhos após o prep da Ativ 03:

| doc | \|d\| (stems) |
|---|--:|
| d1 Porto de Santos | 1.526 |
| d2 Autoridade Portuária | 527 |
| d3 Francisco de Paula Ribeiro | 73 |
| média (21 docs) | 202,5 |

d1 é bem mais longo que d2/d3 - o parâmetro `b` existe justamente por
isso.

---

# 4. Ranking no corpus real

Pré-processamento = o da Atividade 03 (`limpar` + stopwords + Snowball).
Parâmetros padrão: `k1 = 1.2`, `b = 0.75`.

## Comparação nos artigos (d1, d2, d3)

### Consulta `"porto de santos"` → stems `port | sant`

| Modelo | 1º | 2º | 3º |
|---|---|---|---|
| **BM25** | d2 (1,074) | d1 (1,072) | d3 (0,913) |
| **TF-IDF** | d1 (0,145) | d2 (0,130) | d3 (0,040) |

Aqui aparece o efeito do tamanho: o TF-IDF (com cosseno) prefere o
artigo longo d1; o BM25, com `b = 0,75`, aproxima d2 de d1 (d2 é mais
curto e também fala muito de porto/Santos). Nos parágrafos, o BM25
ainda sobe trechos bem focados (`d1.2`, `d2.2`…).

### Consulta `"autoridade portuaria"` → `autor | portu`

| Modelo | 1º | 2º | 3º |
|---|---|---|---|
| **BM25** | **d2** (1,758) | d1 (1,208) | d3 (0) |
| **TF-IDF** | **d2** (0,164) | d1 (0,058) | d3 (0) |

Os dois modelos batem: o artigo da APS (d2) é o certo.

### Consulta `"francisco ribeiro"` → `francisc | ribeir`

| Modelo | 1º | 2º | 3º |
|---|---|---|---|
| **BM25** | **d3** (5,680) | d1 (0,864) | d2 (0) |
| **TF-IDF** | **d3** (0,363) | d1 (0,022) | d2 (0) |

De novo alinhados. d3 é curto e específico - BM25 e TF-IDF colocam ele
na frente. (d3.1 tem o mesmo texto do artigo d3, por isso empata com
d3 no ranking por parágrafo.)

---

# 5. Variando k1 e b

Consulta `"porto autoridade"`, top 3:

| k1 | b | top 3 |
|--:|--:|---|
| 0,5 / 1,2 / 2,0 | 0 | d2, d1, d2.2 |
| 0,5 / 1,2 / 2,0 | 0,75 | d2, d2.2, d1.5 |
| 0,5 / 1,2 / 2,0 | 1 | d2.5, d2.2, d2 |

No nosso corpus pequeno, mudar `k1` quase não alterou a ordem; já o
`b` sim: com `b = 0` o artigo longo d1 sobe; com `b = 1` ganham
parágrafos mais curtos da APS (`d2.5`, `d2.2`). Faz sentido com o que
a aula descreve (verbosidade vs escopo).

---

# Discussão (o que a gente entendeu)

1. **Poisson** dá a probabilidade de ver o termo *f* vezes; sozinha não
   segura o “estouro” de palavras de conteúdo no texto real.
2. Com **duas Poissons** (elite / não-elite) o peso **satura** - e isso
   não foi imposto na mão, saiu do modelo.
3. O **BM25** é a versão prática: mesma ideia de saturação (`k1`) +
   correção de tamanho (`b`) + IDF robusto.
4. No Porto de Santos, BM25 e TF-IDF concordam nas consultas claras
   (APS, Francisco); na consulta genérica “porto de santos” o BM25
   freia um pouco o artigo enorme (d1) - exatamente o problema que a
   Aula 04 queria atacar.

Próximo no material: avaliação de ranking (P@k, MAP, nDCG).

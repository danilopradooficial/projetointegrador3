# Aula 5,5 — Parte D: as métricas no seu gabarito

## Guia de estudo autônomo, com uma LLM como tutora — sessão prática

*versão 1 — 2026-09-13 — Projeto Integrador III — Motor de Busca*

---

## Para o aluno: como usar

Este é o **segundo arquivo** da Aula 5,5. Vem depois de `GUIA_ESTUDO_aula05b.md` (a teoria, Módulos 1–9 e o teste).

1. Abra a LLM que você usa. Cole **este arquivo inteiro** e, junto, **o consolidado** da sessão teórica.
2. Escreva: *"Vamos para a prática."*
3. **R aberto**, com três coisas: o `qrels.csv` exportado pelo `julgar.html` (Parte D da Aula 05), e os rankings do **cosseno** e do **BM25** sobre o seu corpus (Partes D das Aulas 02 e 04).
4. Se ela despejar texto, entregar código sem comentário, escolher o limiar por você, ou declarar o vencedor por você, diga **"mais curto"**, **"comente"** ou **"isso é comigo"**.

**Tempo:** 40 a 50 minutos. **Depois:** Aula 06.

**No fim você terá:** cosseno e BM25 medidos contra o **seu** gabarito, consulta a consulta, com as cinco métricas — e a sua resposta a "qual venceu, e dá para afirmar isso?".

---
---

# Instruções para a LLM

Valem **todas** as regras da Parte A do arquivo anterior — tamanho (teto 360, flexível a 540), uma ideia por mensagem, código comentado, previsão antes da saída, "só o que foi apresentado", LaTeX, tom. Se ele não colou o consolidado, peça; se não tiver, calibre: *"por que o AP divide por $R$?"*

Avise no início: blocos curtos; consolidado no fim.

**A divisão de trabalho:**

| você (LLM) faz | o aluno faz |
|---|---|
| lembra as funções da teoria | **escolhe o limiar** de binarização e diz por quê |
| apresenta as duas funções novas de R | **monta** `rel` e `g` para cada consulta e cada sistema |
| confere as contas | **declara** o vencedor — e a ressalva |

**Você não escolhe o limiar nem declara o vencedor.** Se ele perguntar "qual é melhor?", devolva: *"olhe a tabela; em quantas consultas cada um ganhou?"*

**Só o que foi apresentado.** As cinco métricas e `cumsum`, `which`, `dcg` — da teoria. **Duas funções novas**, apresentadas no Módulo 10 antes de usar: `read.csv` e `setNames`.

**Não adiante a Aula 16.** "A diferença é significativa?" — a resposta honesta aqui é "com 3 consultas, não dá para saber"; o teste é a Aula 16. Guarde.

**Rota:** Módulos 10, 11 e 12 de 12.

---

## Módulo 10 — Do `qrels.csv` ao vetor `rel`
*trabalho 10 min · conversa 4 min · lembrete: duas funções novas; ele escolhe o limiar*

**Duas funções novas.** `read.csv("arquivo.csv")` lê um CSV e devolve uma tabela (um *data frame*: colunas com nome, acessadas com `$`). `setNames(valores, nomes)` cria um vetor nomeado a partir de dois vetores — é o `c(d1 = 1, d2 = 2)` construído por código.

```r
q <- read.csv("qrels.csv")                          # o gabarito exportado pelo julgar.html
head(q)                                             # as primeiras linhas: consulta, documento, grau, ...
```

Ele olha: quais consultas há? quantos documentos por consulta?

Para **uma** consulta — a `q01` dele:

```r
linhas <- q[q$consulta == "q01", ]                  # só as linhas dessa consulta
grau   <- setNames(linhas$grau, linhas$documento)   # vetor nomeado: documento -> grau
grau
```

**Ele escolhe o limiar** — grau $\geq 2$ ou $\geq 1$? — e diz por quê. Então, para o ranking do **BM25** dele nessa consulta (o vetor de nomes de documento na ordem que saiu):

```r
relevantes <- names(grau)[grau >= 2]                # o limiar DELE
rel_bm25   <- as.integer(ranking_bm25 %in% relevantes)
rel_bm25
```

E o mesmo para `ranking_cos`.

> **Erro previsto:** documentos no ranking que **não estão** no gabarito — o `julgar.html` julgou a *pool*, e o ranking pode conter documentos fora dela. Sinal: `rel` tem zeros para documentos que ele nunca julgou. Reação: pela regra do *pooling* (Aula 05), não julgado = irrelevante. É o viés dito com todas as letras, acontecendo no corpus dele.

> **Erro previsto:** escolher o limiar olhando qual dá o resultado mais bonito. Sinal: ele testa os dois e fica com o que favorece um sistema. Reação: o limiar é decidido **antes** e vale para os dois. Ele escreve a justificativa — uma frase — antes de calcular qualquer métrica.

> **Checkpoint 10.** *Com o seu limiar, quantos relevantes ($R$) tem a `q01`? E quantos deles o BM25 pôs nas três primeiras posições?*
> Esperado: `length(relevantes)` e `sum(rel_bm25[1:3])`. Dois números que ele lê.

> **Ponte:** `rel` pronto para os dois sistemas. As cinco métricas são as funções da teoria.

---

## Módulo 11 — As cinco métricas, dois sistemas, uma consulta
*trabalho 14 min · conversa 4 min · lembrete: previsão antes; uma tabela no fim*

Para `q01`, ele roda a cadeia da teoria **duas vezes** — uma com `rel_bm25`, outra com `rel_cos`:

```r
R        <- length(relevantes)
precisao <- cumsum(rel_bm25) / seq_along(rel_bm25)
ap       <- sum(precisao[rel_bm25 == 1]) / R
mrr      <- 1 / which(rel_bm25 == 1)[1]
ndcg     <- dcg(rel_bm25) / dcg(sort(rel_bm25, decreasing = TRUE))
g        <- grau[ranking_bm25]                       # graus na ordem do ranking
g[is.na(g)] <- 0                                     # documento não julgado: grau 0 (pooling)
ndcg_g   <- dcg(g) / dcg(sort(g, decreasing = TRUE))
```

A linha `g[is.na(g)] <- 0` é nova: `grau[ranking]` devolve `NA` para documento fora do gabarito; convertemos em 0. `is.na` testa "é NA?". Apresente antes de usar.

**Antes de rodar cada métrica, ele prevê** — olhando `rel_bm25` — se vai ser alta ou baixa. Depois monta a tabela:

| métrica | cosseno | BM25 |
|---|---|---|
| P@3 | | |
| AP | | |
| MRR | | |
| nDCG bin | | |
| nDCG grad | | |

> **Erro previsto:** `R = 0` — a consulta não tem relevante com o limiar escolhido, e o AP divide por zero. Sinal: `NaN`. Reação: é a regra "nenhuma consulta sem resposta" da Aula 05. Ou ele baixa o limiar (para os dois sistemas!), ou a consulta sai da avaliação.

> **Erro previsto:** todas as métricas iguais nos dois sistemas. Sinal: ele acha que errou. Reação: com poucos documentos, dois rankings podem ter os mesmos relevantes nas mesmas posições. Não é erro — é a armadilha 2 da teoria: corpus pequeno não discrimina.

> **Checkpoint 11.** *Em qual das cinco métricas os dois sistemas mais diferem nessa consulta — e o que essa métrica está vendo que as outras não veem?*
> Esperado: ele aponta a linha da tabela e liga à definição — se é MRR, a posição do primeiro; se é nDCG graduado, os grau-1; se é AP, um relevante tardio.

> **Ponte:** uma consulta não decide nada. Agora as outras.

---

## Módulo 12 — Todas as consultas, e o vencedor
*trabalho 12 min · conversa 4 min · lembrete: ele declara; você pergunta "em quantas?"*

Ele repete o Módulo 11 para cada consulta que julgou — três, se seguiu a Parte D da Aula 05. Uma tabela por consulta, e no fim uma tabela-resumo: **quem venceu em cada consulta, por métrica**.

```r
# para cada consulta, os APs dos dois sistemas lado a lado
# (ele monta à mão ou com um vetor: ap_bm25 <- c(q01 = ..., q02 = ..., q03 = ...))
mean(ap_bm25)   # o MAP do BM25
mean(ap_cos)    # o MAP do cosseno
```

**A pergunta final, dele:** *qual venceu?* E a segunda, que é a que importa: *dá para afirmar isso?* Três consultas; se um sistema ganhou em duas e perdeu em uma, o MAP diz uma coisa e a consulta perdida diz outra.

> **Erro previsto:** declarar vencedor pelo MAP e parar. Sinal: "BM25 venceu, MAP 0,72 contra 0,65". Reação: *"em quantas consultas? na que ele perdeu, por quê?"* Uma consulta em que o vencedor vai mal ensina mais que a média — é a seção 7 do relatório do projeto.

> **Erro previsto:** perguntar se a diferença é significativa. Reação honesta: com três consultas, **não dá para saber** — e dizer isso é a resposta certa. O teste que responde é a Aula 16. **Guarde.**

> **Checkpoint 12.** *O vencedor é o mesmo em todas as consultas? Se não, o que você escreveria no relatório?*
> Esperado: ele olha a tabela-resumo. Se não é unânime: "o BM25 vence em média, mas perde em `q02` porque …" — a explicação vem do Módulo 11 da Parte D da Aula 04 (tamanho ou repetição). E a ressalva: três consultas é pouco para afirmar.

> **Ponte:** ele mediu os dois modelos contra o próprio gabarito e sabe o que a medida vale — e o que não vale.

---

## Fechamento

Ordem: **perguntas guardadas → tarefa → o que vem → consolidado.** (O teste já foi na sessão teórica.)

1. **Perguntas guardadas:** responda as curtas; encaminhe as outras — significância é a Aula 16; "e se eu tivesse 20 consultas?" é o `PROMPT_LLM_julgamento_relevancia.md` do projeto.
2. **A tarefa:** está feita no corpus dele. Falta fazer no corpus de 8 com o gabarito de 3 consultas da Aula 05, e escrever. Não escreva por ele.
3. **O que vem:** *"Hoje o seu gabarito foi régua. Na Aula 06 ele vira entrada: o Rocchio pega os documentos que você marcou como relevantes e reescreve a consulta com as palavras deles — e você mede, com estas mesmas cinco métricas, se a consulta reescrita ranqueia melhor que a original. É a primeira vez que o gabarito melhora o motor em vez de só medi-lo."*
4. **Gere o consolidado** — avise que está gerando. Mesmo formato de três partes (`.md` em bloco de código, nunca PDF, sem código, sem reexplicação, LaTeX). Parte 1: Módulos 10–12. Parte 2: ele escolheu o limiar antes de calcular, com justificativa? Tratou os não julgados como zero sem reclamar? Declarou o vencedor com ressalva ou sem? Parte 3, "Produzido": o limiar e o motivo; a tabela-resumo (quem venceu em cada consulta); o MAP dos dois; a ressalva que ele escreveu.

Salvar como `consolidados/aula05b_parteD_consolidado.md`.

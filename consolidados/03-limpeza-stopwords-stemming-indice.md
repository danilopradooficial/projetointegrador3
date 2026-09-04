

# Atividade 03 - Limpeza, stopwords, stemming e o índice

**Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Pré-processar o *corpus* real, reduzir ao radical com Snowball e
montar um índice invertido com busca booleana (AND / OR).

![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)
![SnowballC](https://img.shields.io/badge/SnowballC-portuguese-orange)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Entrega](https://img.shields.io/badge/entrega-4%C2%AA-blue)
![Aula](https://img.shields.io/badge/aula-03-lightgrey)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)



---



## Sobre a atividade

**4ª entrega.** Na Atividade 01 o top 10 era quase só stopword; na 02 a
gente ranqueou com TF-IDF (ainda com tokenização simples, no brinquedo).
Aqui fechamos a Aula 03 no **mesmo corpus wiki** do Porto de Santos:
limpar, tirar stopword, stemmar com Snowball e montar o índice.

### O que a Aula 03 pedia (e a gente cobriu)

| Tópico | Onde |
|---|---|
| Pré-processamento | pipeline `prep` |
| Padronização do texto | `limpar()` |
| Remover stopwords | `sem_stop()` |
| Reduzir ao radical (stemming) | `wordStem` |
| Biblioteca Snowball | pacote `SnowballC` |

Também: índice invertido + `busca_AND` / `busca_OR`.

> **Meta:** vocabulário menor, índice utilizável e busca booleana nos
> artigos/parágrafos do corpus real.

**Autores.** Adriane da Costa Santos · Danilo Prado de Lima Silva · Victoria Cabral Quinterio

---



## Sequência

```
Ativ 00              R base                         ← 1ª entrega
   |
   v
Ativ 01 · Parte A    corpus real + top 10           ← 2ª entrega
   |
   v
Ativ 01 · Parte B    IDF = bits
   |
   v
Ativ 02              TF-IDF + cosseno               ← 3ª entrega
   |
   v
Ativ 03              limpeza · Snowball · índice    ← 4ª entrega (esta)
```


|             | Atividade 01 · Parte A         | Atividade 03                    |
| ----------- | ------------------------------ | ------------------------------- |
| Corpus      | Real (Porto / APS / Francisco) | O mesmo                         |
| Tokenização | `tolower` + espaços (suja)     | limpar + stop + Snowball        |
| Estrutura   | frequências / Zipf             | índice invertido + AND/OR       |
| Achado      | stopwords dominam o top 10     | após prep, top 10 fica temático |


---



## Material de referência

- [Aula 03 - Limpeza de Texto, Stopwords, Stemming e o Indice](../materiais-aulas/Aula%2003%20-%20Limpeza%20de%20Texto%2C%20Stopwords%2C%20Stemming%20e%20o%20Indice.PDF)
- [Atividade 01 · Parte A](./01a-primeiro-corpus-real.md)
- [README da disciplina](../README.md)

---



## Estrutura da pasta

```
estrutura/corpus/                 # base textual unica
estrutura/codigos/
└── 03-preprocessao-indice.R
consolidados/
└── 03-limpeza-stopwords-stemming-indice.md
```

---



## Como rodar

Pré-requisito: R + pacote **SnowballC** (pedido na Aula 03).

```bash
cd "estrutura/codigos"
Rscript 03-preprocessao-indice.R
```

Na primeira execução o script tenta instalar o `SnowballC` na biblioteca
do usuário, se ainda não estiver disponível.

---



# Tarefa Aula 03

Adaptamos o “para casa” da aula ao **corpus real**, cobrindo:

1. **Pré-processamento** completo do texto
2. **Padronização** (caixa, acentos, pontuação, espaços)
3. **Remoção de stopwords**
4. **Stemming** (redução ao radical)
5. Biblioteca **SnowballC** (`wordStem`, `portuguese`)
6. Índice invertido + `busca_AND` / `busca_OR` e comparação

Script: `03-preprocessao-indice.R`

---



# Implementação — pré-processamento passo a passo

O pré-processamento desta atividade é o pipeline completo abaixo.
Cada etapa alimenta a seguinte; a busca usa o **mesmo** `prep` da
indexação.

```
texto bruto
    │
    ▼
[1] padronização  →  limpar()     (caixa, acentos, pontuação, espaços)
    │
    ▼
[2] tokenização   →  strsplit
    │
    ▼
[3] stopwords     →  sem_stop()   (remove termos pouco informativos)
    │
    ▼
[4] stemming      →  wordStem()   (SnowballC, português)
    │
    ▼
índice invertido  →  postings[[termo]]
```

---

## 1) Pré-processamento (visão geral)

Função que concentra todo o pipeline usado na indexação e na consulta:

```r
prep <- function(x) {
  t <- sem_stop(x)   # já inclui padronização + tokenização + stopwords
  if (length(t) == 0) return(character(0))
  SnowballC::wordStem(t, language = "portuguese")  # stemming (Snowball)
}
```

---

## 2) Padronização do texto

Objetivo: formas diferentes do “mesmo” termo colapsarem numa única chave
(Aula 03 — Normalização).

```r
limpar <- function(x) {
  x <- tolower(x)                                      # 1) caixa baixa
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT") # 2) acentos → ASCII
  x <- gsub("[^a-z0-9 ]", " ", x)                      # 3) tira pontuação
  x <- gsub("\\s+", " ", x)                            # 4) colapsa espaços
  trimws(x)                                            # 5) bordas
}
```

| Passo | O que faz | Exemplo |
|---|---|---|
| Caixa | `Porto` = `porto` | minúsculas |
| Acentos | `portuária` → `portuaria` | `iconv` / TRANSLIT |
| Pontuação | `!`, `(`, `-`, `:` → espaço | regex `[^a-z0-9 ]` |
| Espaços | `"  "` → `" "` | `\\s+` |

No corpus de brinquedo da aula não havia acentos. No texto da Wikipédia
há (`portuária`, `municípios`): por isso usamos `iconv`, como a Aula 03
sugere.

**Amostra (`d1.1`):**

```
Bruto: Porto de Santos é um porto estuarino, localizado nos municípios...
Limpo: porto de santos e um porto estuarino localizado nos municipios...
```

---

## 3) Remover stopwords

Stopwords = palavras muito frequentes e pouco discriminativas
(`de`, `o`, `a`, `e`… — o problema do top 10 da Atividade 01).

```r
stopwords <- c(
  "de", "o", "a", "e", "um", "uma", "por", "como", "que",
  "da", "do", "em", "no", "na", "com", "para", ...
)

sem_stop <- function(x) {
  t <- unlist(strsplit(limpar(x), " "))  # padroniza + tokeniza
  t <- t[nzchar(t)]
  t[!t %in% stopwords]                  # remove stopwords
}
```

Na amostra `d1.1`: **214** tokens após padronizar → **132** sem stopwords.

---

## 4) Reduzir ao radical (stemming)

Stemming aproxima flexões da mesma palavra a um radical comum, para
casarem na busca (`documentos` / `documento` → `document`).

Na Aula 03 há uma versão *ilustrativa* com `sub("(cao|mento|...)$", "")`.
Em produção (e nesta entrega) usamos o algoritmo de verdade: **Snowball**.

---

## 5) Biblioteca Snowball (`SnowballC`)

Pacote externo pedido na Aula 03 (não vem no R base):

```r
install.packages("SnowballC")   # uma vez
library(SnowballC)

wordStem(c("documentos", "documento", "documentacao"),
         language = "portuguese")
#> [1] "document" "document" "document"
```

No nosso pipeline:

```r
SnowballC::wordStem(t, language = "portuguese")
```

Atenção (Aula 03): stemming é **destrutivo** — o radical nem sempre é
palavra real; ganha-se recall, perde-se um pouco de precisão.

---

## 6) Índice invertido (após o pré-processamento)

Com o texto já padronizado, sem stopwords e stemmed:

```r
postings <- list()
for (d in names(docs)) {
  for (termo in unique(prep(docs[[d]]))) {
    postings[[termo]] <- c(postings[[termo]], d)
  }
}
```

## 7) Busca booleana

```r
busca_AND <- function(consulta) {
  termos <- prep(consulta)   # mesmo prep da indexação!
  Reduce(intersect, postings[termos])
}

busca_OR <- function(consulta) {
  unique(unlist(postings[prep(consulta)], use.names = FALSE))
}
```

---



# Resultados no corpus real

**21 documentos** indexados: 3 artigos (`d1`, `d2`, `d3`) + 18 parágrafos.

## Efeito no vocabulário (só artigos)


| Etapa          | Termos distintos | vs limpeza |
| -------------- | ---------------- | ---------- |
| Após limpeza   | 1.104            | —          |
| Após stopwords | 1.054            | −4,5%      |
| Após Snowball  | **873**          | **−20,9%** |


Remover stopwords corta poucas *formas* (são sempre as mesmas), mas
muda muito a **frequência**. O stemming é o que realmente comprime o
dicionário.

### Top 10 antes (limpo, ainda com stopwords)


| Rank | Termo  | Freq |
| ---- | ------ | ---- |
| 1    | de     | 313  |
| 2    | a      | 154  |
| 3    | e      | 131  |
| 4    | o      | 90   |
| 5    | da     | 85   |
| 6    | do     | 79   |
| 7    | porto  | 50   |
| 8    | santos | 50   |
| 9    | em     | 42   |
| 10   | que    | 36   |




### Top 10 depois (sem stop + Snowball)


| Rank | Stem      | Freq |
| ---- | --------- | ---- |
| 1    | **port**  | 63   |
| 2    | **sant**  | 51   |
| 3    | **portu** | 28   |
| 4    | codesp    | 18   |
| 5    | autor     | 16   |
| 6    | termin    | 16   |
| 7    | acess     | 15   |
| 8    | complex   | 15   |
| 9    | empres    | 15   |
| 10   | are       | 14   |


O top 10 deixa de ser Zipf de stopwords e passa a refletir o tema do
corpus (porto, Santos, autoridade, CODESP…).

## Índice

- Dicionário: **873** stems
- Exemplos de postagens:
  - `port` → d1, d1.1–d1.10, d2, d2.1–d2.3, d2.5, d3, d3.1 (16 docs)
  - `sant` → 16 docs
  - `carg` → d1, d1.1, d1.2, d1.8–d1.10
  - `ribeir` → d1, d1.2, d3, d3.1



## AND vs OR


| Consulta               | Stems             | |AND| | |OR| | Observação                                             |
| ---------------------- | ----------------- | ----- | ---- | ------------------------------------------------------ |
| `porto de santos`      | port · sant       | 16    | 16   | `de` some na stop list; AND = OR                       |
| `autoridade portuaria` | autor · portu     | 11    | 15   | OR mais largo                                          |
| `francisco ribeiro`    | francisc · ribeir | 4     | 4    | concentra em d1/d3                                     |
| `carga container`      | carg · contain    | 0     | 6    | `contain` não está no índice (texto usa outras formas) |
| `porto autoridade`     | port · autor      | 10    | 17   | AND exige os dois stems                                |


**AND** restringe (interseção); **OR** amplia (união). Sem ler nenhum
documento na hora da busca — só cruzamos listas de postagens.

## Stemming é destrutivo


| Forma                  | Stem     |
| ---------------------- | -------- |
| documentos / documento | document |
| cargas / carga         | carg     |
| navios / navio         | navi     |
| portuaria              | portu    |
| portuario              | portuari |


Ganha-se *recall* (formas diferentes casam), perde-se um pouco de
*precisão* (radicais que não são palavras reais; `portuaria` e
`portuario` não colapsam no mesmo stem). Trade-off da Aula 03.

---



# Discussão

1. **Por que o vocabulário cai ~21%?** Stemming funde flexões
  (`porto`/`portos` → `port`, `santos` → `sant`).
2. **Por que stopwords mudam pouco o tamanho do vocab, mas mudam o top 10?**
  Poucas formas, muitas ocorrências — exatamente o problema da Atividade 01.
3. **Índice invertido** transforma busca de O(N docs) em consulta ao
  dicionário + interseção/união de listas curtas.
4. **Mesmo** `prep` **na consulta e na indexação** — sem isso, `Santos` não
  acharia `sant`.

Próximo passo: saturação e BM25 na
[Atividade 04](./04-poisson-saturacao-bm25.md)
([Aula 04](../materiais-aulas/Aula%2004%20-%20Satura%C3%A7%C3%A3o%2C%20Tamanho%20de%20Documento%20e%20Ranqueamento.PDF)).
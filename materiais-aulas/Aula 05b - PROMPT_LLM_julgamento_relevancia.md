# Montando o experimento de julgamento de relevância com apoio de uma LLM

**Projeto Integrador III — Motor de Busca — Aula 05**

---

## Para o aluno: como usar este arquivo

1. Prepare o corpus e o pacote de entrada (seção seguinte). **Não pule esta parte.**
2. Abra a LLM que você usa (ChatGPT, Claude, Gemini, o que for).
3. Cole **tudo o que está abaixo da linha "INÍCIO DO BRIEFING"**, junto com o pacote de entrada.
4. Ela vai analisar o corpus e fazer perguntas antes de produzir qualquer coisa. Responda com calma.
5. No fim você terá uma **página HTML** para julgar (abre com dois cliques, funciona sem internet) e os scripts em R que leem o resultado dela.

**O ponto central, e leia duas vezes:** a LLM **olha para o corpus e monta o experimento**. **Vocês fazem o julgamento.** Se ela decidir o que é relevante, vocês estarão medindo a opinião dela sobre o resultado dela — a avaliação vira circular e não vale nada. O gabarito é o dado mais caro do projeto justamente por ser humano.

---

# Parte 0 — O que preparar antes

## A estrutura que o corpus precisa ter

Cinco requisitos. Os três primeiros não são negociáveis: sem eles nada do resto funciona.

**1. Uma linha = um documento.** Parece óbvio e é onde mais gente tropeça. Vocês precisam decidir qual é a **unidade de recuperação**: uma notícia inteira? um parágrafo? um PDF? uma página do PDF? Se a coleta trouxe um artigo repartido em quatro linhas, ou tudo concatenado num arquivo só, o corpus ainda não existe.

**2. Um identificador único e estável.** É a chave que amarra `pool.csv` → `julgar.html` → `qrels.csv` → rankings dos modelos. Se ele mudar quando vocês reordenarem as linhas ou refizerem a coleta, o gabarito inteiro vira lixo. **Não use o número da linha.** Use algo derivado do conteúdo: a URL, um hash do texto, uma *citekey*.

**3. Um campo com o texto a indexar** — pode ser a concatenação de vários (título + resumo + palavras-chave, por exemplo).

**4. Conteúdo suficiente para alguém julgar.** Se o documento for só um título, o julgamento é rápido mas raso. Se for um PDF de 300 páginas, ninguém julga 380 itens. O ponto ideal é algo que se lê em **15 a 20 segundos**: título mais resumo, ou os primeiros parágrafos.

**5. Nenhuma informação de relevância.** Nenhuma coluna de categoria, tag ou nota pré-existente pode chegar ao juiz durante o julgamento.

### Esquema mínimo

```csv
id,titulo,texto,data,fonte,url
```

| coluna | obrigatória? | observação |
|---|---|---|
| `id` | **sim** | único e estável; é a chave de tudo |
| `titulo` | recomendada | é o que o juiz lê primeiro |
| `texto` | **sim** | o que vai para o índice e para a tela de julgamento |
| `data` | opcional | útil para facetar e para explicar resultados |
| `fonte` | opcional | veículo, autor, seção |
| `url` | opcional | permite ao juiz conferir o original em caso de dúvida |

> **Se o corpus for PDFs**, o passo zero é extrair o texto. Não existe corpus antes disso.

### Se vocês ainda não têm o corpus

Use o `coletar_corpus.R` da disciplina. Ele traz quatro fontes prontas — feed RSS, Wikipedia em
português, pasta de `.txt`, e CSV que vocês já tenham — e entrega um `corpus.csv` já no formato
acima, com limpeza, **id estável derivado do conteúdo** e uma ficha técnica que acusa id
duplicado, texto vazio e documentos curtos ou longos demais.

Rodem o script **antes** de abrir a conversa com a LLM, e colem a ficha técnica que ele imprime
como parte do pacote de entrada (item (a) abaixo).

---

## O pacote de entrada para a LLM

Três coisas, nesta ordem.

### (a) A ficha técnica

Números que a LLM não pode inventar. Rodem o script abaixo e colem a saída.

```r
# ficha_corpus.R -- resumo e amostra do corpus para dar a LLM
# no Windows, se a primeira coluna vier como "i..id", troque para "UTF-8-BOM"
corpus <- read.csv("corpus.csv", stringsAsFactors = FALSE,
                   fileEncoding = "UTF-8")

cat("linhas :", nrow(corpus), "\n")
cat("colunas:", paste(names(corpus), collapse = ", "), "\n\n")

# cobertura: quanto de cada coluna esta de fato preenchido
for (col in names(corpus)) {
  v     <- as.character(corpus[[col]])
  cheio <- sum(!is.na(v) & trimws(v) != "")
  cat(sprintf("%-14s %5.1f%% preenchido\n", col, 100 * cheio / nrow(corpus)))
}

# tamanho dos documentos, em palavras
palavras <- sapply(strsplit(corpus$texto, "\\s+"), length)
cat("\npalavras por documento:\n")
print(summary(palavras))

# tem que dar zero: id duplicado quebra o pareamento com o gabarito
cat("\nids duplicados:", sum(duplicated(corpus$id)), "\n")
```

### (b) Uma amostra aleatória de 50 a 200 linhas

**Aleatória, não as primeiras.** As primeiras linhas de uma coleta costumam ser todas do mesmo dia e da mesma editoria — a LLM vai concluir que o corpus só fala daquilo.

```r
set.seed(42)                                   # amostra reproduzivel
n <- min(100, nrow(corpus))
amostra <- corpus[sample(nrow(corpus), n), ]

# truncar: melhor a LLM ver 100 documentos pela metade que 8 inteiros
amostra$texto <- substr(amostra$texto, 1, 1500)

write.csv(amostra, "amostra_para_llm.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
```

### (c) Três linhas completas, sem truncar

Para a LLM ver o formato **bruto**: acentuação, marcação sobrando, aspas, quebras de linha, o que houver. Copiem e colem literalmente, sem limpar.

### (d) Uma frase sobre o usuário

Quem vai usar esse motor de busca e que tipo de pergunta faria. Duas linhas bastam — mas sem isso as consultas que ela propuser serão genéricas.

---

## Armadilhas de formato (todas comuns, todas chatas)

- **O Excel em português salva CSV com `;` e em Latin-1.** É o erro número um. Salvem como "CSV UTF-8" ou gerem pelo R com `write.csv(..., fileEncoding = "UTF-8")`.
- **Quebra de linha dentro de um campo** parte o CSV em dois. Ou o campo está entre aspas corretamente, ou troquem `\n` por espaço antes de exportar: `gsub("[\r\n]+", " ", texto)`.
- **BOM no início do arquivo** faz a primeira coluna virar `ï»¿id` ou `i..id`. Leiam com `fileEncoding = "UTF-8-BOM"`.
- **Vírgula dentro do texto** sem aspas destrói o alinhamento das colunas. O `write.csv` do R já resolve isso sozinho; um `paste` feito à mão, não.
- **Não colem dado pessoal nem texto integral de obra protegida** num chat. Metadados bibliográficos, títulos e resumos podem; PDFs completos de livros, não.

---

## INÍCIO DO BRIEFING

Você vai me ajudar a montar um experimento de julgamento de relevância para avaliar um motor de busca. Leia tudo antes de responder.

### Contexto

Estou na disciplina Projeto Integrador III (Tecnologia em Ciência de Dados, FATEC). O projeto é construir um motor de busca em **R base**. Vamos comparar: modelo booleano, TF-IDF com similaridade de cosseno, e BM25.

Para comparar esses modelos preciso de um **gabarito** (*qrels*, no jargão do TREC): para cada consulta, quais documentos são relevantes e em que grau. Sem gabarito não existe avaliação objetiva — "esse modelo parece melhor" não é resultado.

### Seu papel, em uma frase

**Você examina o corpus e constrói todo o aparato e a organização do experimento. Eu e meu grupo fazemos os julgamentos.**

### Regras invioláveis

1. **Você não julga relevância.** Em nenhum momento você decide, sugere ou "pré-preenche" se um documento é relevante. Se eu pedir, recuse e me lembre do porquê. (Há uma exceção controlada na Parte 2, no fim.)
2. **Você não inventa documentos, consultas ou números.** Tudo que você afirmar sobre o corpus tem que vir de entradas que eu te mostrei — cite o identificador delas.
3. **O gabarito é fechado antes de rodar qualquer sistema.** Não me mostre nem discuta rankings enquanto estivermos julgando.
4. **Scripts de análise em R base.** Sem `tidyverse`, sem pacotes externos, salvo autorização minha. Precisa rodar em qualquer máquina do laboratório.
5. **A interface de julgamento é uma página HTML** — arquivo único, sem internet, sem servidor, sem CDN. Especificação no Entregável 5.
6. **Todo número que você produzir tem que ser conferível à mão.** Código comentado linha a linha.

---

## Os entregáveis

Produza **um por vez**, esperando meu OK antes do próximo.

---

### Entregável 1 — Análise do corpus

Antes de qualquer outra coisa, olhe para os dados que eu anexei e me diga o que você vê. Não descreva o que "normalmente" tem num corpus — descreva **o meu**.

O que deve constar:

- **Estrutura**: quais campos existem, quais estão sempre preenchidos e quais são esparsos. Se algum campo tiver cobertura baixa, diga o número.
- **Tamanho e forma dos textos**: quantas palavras tem um documento típico? Há muita variação? Documentos curtíssimos ou longuíssimos que vão se comportar mal na normalização do BM25?
- **Idioma**: um só, ou misturado? Se misturado, em que proporção?
- **Sujeira**: codificação estranha, marcação sobrando, títulos derivados de nome de arquivo, campos duplicados, entradas vazias. Aponte com exemplos concretos.
- **Do que o corpus trata**: quais são os 6 a 10 assuntos que aparecem com força suficiente para sustentar uma consulta.
- **O que o corpus NÃO cobre**: assuntos que alguém tentaria buscar e não acharia. Isso importa: consulta sem resposta quebra o cálculo do AP.

Termine com **três perguntas para mim**, escolhidas por você, sobre o que você não conseguiu deduzir olhando os dados.

Depois pergunte também:

1. Quem é o usuário imaginado desse motor de busca? Que tipo de pergunta ele faria?
2. Quantas pessoas do grupo vão julgar? (decide se dá para medir concordância)
3. Quanto tempo total vocês têm para julgar? (dimensiona a amostra)

---

### Entregável 2 — Necessidades de informação

**15 a 25** necessidades, derivadas dos assuntos que *você encontrou* no Entregável 1. Cada uma tem:

- um **identificador** (`q01`, `q02`, …);
- a **necessidade em prosa**, uma ou duas frases, no estilo de um tópico do TREC: o que a pessoa quer saber, não as palavras que digitaria;
- a **consulta**: as palavras que alguém realmente digitaria;
- uma **nota de escopo** dizendo o que não conta como resposta;
- os **documentos do corpus que te fizeram achar que essa consulta tem resposta** — só os identificadores, sem julgar o grau deles. Isso é para eu conferir que a consulta não é fabricada; não é gabarito.

Formato:

```
q07
Necessidade: O usuário quer entender que técnicas existem para reduzir o
             tamanho de um índice invertido sem perder resultados.
Consulta:    compressao indice invertido
Escopo:      Textos sobre compressão de dados em geral não contam; precisa
             tratar de índices de busca.
Indícios:    d0142, d0891, d1330  (encontrados na amostra; NÃO são julgamentos)
```

Regras para o conjunto:

- **Variedade de dificuldade.** Algumas fáceis (uma palavra-chave resolve), outras difíceis (a resposta usa vocabulário diferente da consulta). Se todas forem fáceis, todos os modelos empatam em 1,0 e a avaliação não discrimina nada.
- **Variedade no número provável de relevantes.** Algumas com poucos, outras com muitos.
- **Nenhuma consulta sem resposta.** Zero relevantes quebra recall e AP (divisão por zero).
- Plausíveis para o usuário que eu descrevi — não fabricadas para favorecer um modelo.

---

### Entregável 3 — Guia de julgamento

Um documento de **uma página** que define a escala e, principalmente, resolve os casos de fronteira. É o que faz duas pessoas do grupo julgarem parecido.

Escala de três níveis:

| grau | significado |
|---|---|
| **2** | responde à necessidade |
| **1** | fala do assunto sem responder |
| **0** | não serve |

Precisa conter:

- uma frase operacional por grau, **específica para o meu corpus** — usando o vocabulário e os tipos de documento que você viu no Entregável 1;
- **pelo menos 5 casos de fronteira decididos de antemão**, no formato "documento assim → grau tal, porque…". Tire os exemplos do corpus real. Tipos de dúvida que precisam estar resolvidos: documento correto mas superficial; correto no idioma errado; responde só a uma parte; excelente mas que o usuário certamente já conhece; cita a resposta sem explicá-la;
- a regra de ouro: **julgar contra a necessidade em prosa, nunca contra as palavras da consulta**.

---

### Entregável 4 — Desenho da amostra (*pooling*)

Não vou julgar o corpus inteiro. Desenhe a *pool* pelo método do TREC:

1. Rodar cada modelo para cada consulta.
2. Pegar o **top-k** de cada modelo (sugira um k e justifique).
3. Unir e deduplicar por consulta.
4. **Embaralhar a ordem** dentro da pool. Se eu vir os documentos na ordem do BM25, julgo com viés de posição e o gabarito passa a favorecer o BM25.
5. Tudo fora da pool é assumido irrelevante.

Me diga, com números: quantos julgamentos dá no total; quanto tempo isso leva a 20 segundos por julgamento; e, se passar do tempo que eu informei, reduza k ou o número de consultas e explique o que se perde.

Diga explicitamente **qual é o viés do pooling**: documento que nenhum modelo recuperou nunca entra na pool, logo nunca é descoberto, logo o recall real é superestimado. É conhecido e aceito na literatura, mas tem que estar no relatório.

Separe **20% da pool para julgamento duplo** — duas pessoas julgam os mesmos itens, sem se consultar. É o que permite medir concordância no Entregável 7.

Saída deste entregável: um `pool.csv` com este formato, e o script R que o gera a partir dos rankings dos modelos.

```csv
consulta,documento,ordem_exibicao
q01,d0891,1
q01,d0142,2
```

> A coluna `ordem_exibicao` já vem embaralhada. Ela **não** revela de qual modelo o documento veio — essa informação não pode chegar ao juiz.

---

### Entregável 5 — Adaptar o corpus à ferramenta de julgamento

**A ferramenta de julgamento já existe.** A disciplina distribui o arquivo `julgar.html`: página
única, abre com dois cliques, funciona offline, sem servidor e **sem nenhuma requisição de rede**.
Ela já faz um documento por vez com a necessidade fixa no topo, atalhos de teclado, correção do
item anterior, ordem embaralhada com semente, gravação a cada julgamento com retomada,
tempo por item, modo de segunda passada e exportação em CSV.

**Não reescreva essa página.** Sua tarefa aqui é fazer o meu corpus caber nela:

**1. Converter o corpus para o formato que ela lê.**

```csv
id,titulo,texto,data,fonte,url
```

Só `id` e `texto` são obrigatórios. Escreva o script R que faz essa conversão a partir do meu
formato original, e confira: ids únicos, sem quebra de linha solta, UTF-8, nada de `;` como
separador vindo do Excel.

**2. Gerar o `necessidades.csv`** a partir do Entregável 2:

```csv
consulta,texto_consulta,necessidade,escopo
```

**3. Gerar o `pool.csv`** conforme o Entregável 4:

```csv
consulta,documento
```

A página embaralha sozinha com a semente informada na tela — você não precisa embaralhar no
script, mas **precisa** garantir que a pool não carregue nenhuma coluna que revele de qual
modelo ou de qual posição o documento veio.

**4. Só então, se faltar alguma coisa**, modifique o HTML. Antes de propor qualquer alteração,
diga em uma frase o que ela já faz e por que não basta. Alterações plausíveis: mostrar um campo
específico do meu corpus na tela do documento, ou mudar a escala de 0–2 para 0–3.

**Verificação que você deve me pedir para fazer**, antes de eu confiar horas de trabalho à
ferramenta: abrir offline, carregar os três CSVs, julgar 3 itens, voltar com `←` e mudar uma
nota, fechar o navegador, reabrir e confirmar que retomou, exportar e conferir as 6 colunas do
CSV (`consulta,documento,grau,juiz,timestamp,segundos`).

---

### Entregável 6 — Script R das métricas

Lê o `qrels.csv` exportado pela página e o ranking de cada modelo, e calcula:

- **P@k** e **R@k** para k = 1, 3, 5, 10
- **AP** por consulta e **MAP** sobre todas
- **MRR**
- **nDCG** binário e **nDCG graduado**

Requisitos:

- comentado linha a linha, explicando qual pedaço da fórmula cada linha é;
- o AP divide pelo número de relevantes **no corpus**, não pelo número de parcelas da soma (relevante não recuperado entra valendo zero);
- para binarizar o gabarito graduado, limiar **grau ≥ 2**, deixado como parâmetro;
- tratar explicitamente: consulta sem relevantes, ranking mais curto que k, empates de escore;
- devolver também os **APs individuais** por consulta, não só a média — preciso deles para o teste estatístico.

**Teste obrigatório antes de me entregar.** Valide contra este cenário trabalhado em aula. Se não bater, o código está errado:

```r
ranking <- c("d3","d1","d2","d4","d8","d6","d5","d7")
grau    <- c(d1=1, d2=2, d3=2, d4=0, d5=0, d6=1, d7=0, d8=0)
# binario com limiar grau >= 2  ->  relevantes = d2, d3
```

| métrica | valor esperado |
|---|---|
| P@3 | 0,667 |
| AP | 0,833 |
| MRR | 1,000 |
| nDCG binário | 0,920 |
| nDCG graduado | 0,951 |

Rode o teste e **me mostre a saída** junto com o código.

---

### Entregável 7 — Concordância entre juízes

Script R que calcula o **κ de Cohen** sobre os 20% julgados em duplicata:

$$\kappa = \frac{p_o - p_e}{1 - p_e}$$

onde $p_o$ é a concordância observada e $p_e$ a esperada por acaso.

Deve produzir a matriz de confusão 3×3 entre os dois juízes, o valor de κ, e a **lista dos itens em que discordaram** para o grupo discutir.

Interprete para mim:

- **κ < 0,4** → o guia de julgamento está ambíguo. Reescrever e rejulgar. Não seguir adiante.
- **0,4 ≤ κ < 0,6** → aceitável num trabalho de disciplina, mas registrar a limitação.
- **κ ≥ 0,6** → bom.

E explique por que κ imperfeito **não invalida a comparação entre modelos**: o ruído do gabarito atinge todos igualmente, então ele atrapalha a leitura do valor absoluto do MAP, mas não a resposta a "o BM25 é melhor que o TF-IDF?".

---

### Entregável 8 — Esqueleto do relatório

Um `.md` com a estrutura e, em cada seção, uma frase dizendo o que entra:

1. Corpus e usuário imaginado
2. Necessidades de informação (conjunto completo em anexo)
3. Guia de julgamento e escala
4. Desenho da amostra e viés do pooling
5. Concordância entre juízes (κ e discussão)
6. Resultados por métrica, tabela modelo × métrica
7. Análise por consulta: onde cada modelo ganha e onde perde, com exemplos
8. Limitações
9. Conclusão

Na seção 7, insista que a análise não pode ser só a tabela. Uma consulta em que o BM25 vai muito mal ensina mais que a média de todas.

---

## Parte 2 (opcional) — a LLM como segundo juiz

Experimento **à parte**. Não substitui o julgamento humano em nenhuma hipótese.

Depois que o gabarito humano estiver **fechado e exportado**, dá para pedir à LLM que julgue a mesma pool com o mesmo guia, e comparar os dois com o mesmo κ.

O que isso mede — e o que não mede:

- **Mede** o quanto a LLM concorda com humanos numa tarefa de julgamento com critérios escritos. Pergunta legítima e atual: boa parte da avaliação de sistemas de RAG hoje é feita assim.
- **Não mede** se a LLM está certa. Se ela discorda de vocês, o padrão continua sendo vocês.
- **Cuidado sério:** se o motor usa embeddings de um modelo e o juiz é outro da mesma família, vocês estão medindo a coerência de uma tecnologia consigo mesma, não a qualidade da busca. Tem que estar escrito no relatório.

Guardem `qrels_humano.csv` e `qrels_llm.csv` separados, e **nunca misturem**.

---

## FIM DO BRIEFING

---

## Para o aluno: como saber se a LLM fez um bom trabalho

Seis verificações. Se qualquer uma falhar, peça para refazer.

1. **A análise do corpus é sobre o SEU corpus?** Se ela descreveu genericamente "um corpus de textos" sem citar identificadores e exemplos reais, ela não olhou os dados.
2. **Ela fez as perguntas antes de produzir?** Se já veio com 20 consultas prontas antes de saber quem é o usuário, ela inventou.
3. **O teste do Entregável 6 bateu?** Peça a saída. "Deve dar aproximadamente" sem rodar não vale.
4. **Rode uma consulta à mão.** Escreva o vetor `rel` no papel, calcule P@3 e AP na calculadora, compare. Cinco minutos.
5. **Ela recusou julgar?** Peça "diga quais são relevantes". Se ela responder, o briefing não pegou — recole as regras invioláveis.
6. **Ela tentou reescrever o `julgar.html`?** Não precisava. A página já existe e já foi testada — a tarefa dela era converter o seu corpus para o formato que a página lê. Se ela propôs alterações, exija a justificativa de uma frase.
7. **Os três CSVs carregam?** Desconecte a internet, dê dois cliques no `julgar.html`, carregue `corpus.csv`, `necessidades.csv` e `pool.csv`, julgue três itens, feche, reabra e confirme que retomou.

## O que entregar no repositório

```
estrutura/codigos/05-julgamento/
├── 05a-kappa.R … 05d-gerar-pool.R
├── 05-julgar.html
└── csv/
    ├── 05-corpus.csv
    ├── 05-necessidades.csv
    ├── 05-pool.csv
    └── 05-qrels.csv

Relatório: consolidados/05-julgamento-pooling-kappa.md
```

E em `consolidados/`, um `.md` dizendo o que cada membro julgou e as decisões de fronteira que vocês tomaram durante o processo — inclusive as que contrariaram o guia.

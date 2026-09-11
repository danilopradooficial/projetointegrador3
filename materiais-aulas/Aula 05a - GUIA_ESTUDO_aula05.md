# Aula 05 — Relevância e o Gabarito

## Guia de estudo autônomo, com uma LLM como tutora

**Projeto Integrador III — Motor de Busca — Tecnologia em Ciência de Dados**

---

## Para o aluno: como usar

1. Abra a LLM que você usa (ChatGPT, Claude, Gemini, o que for).
2. Cole **este arquivo inteiro**, e escreva: *"Seja meu tutor nesta aula."*
3. Ela vai fazer três perguntas rápidas para saber de onde você parte, e então começar.
4. **Responda às perguntas dela.** O guia foi feito para uma conversa, não para leitura passiva. Se você só ler, vai achar que entendeu — e não vai.
5. São duas etapas, e **podem ser em sessões diferentes**:
   - **Parte conceitual** (Módulos 1–8 + autoavaliação): 60 a 90 minutos.
   - **Construção do seu sistema** (Módulos 9–13): mais 60 a 90 minutos.

   Para parar no meio, peça a ela que diga em que módulo vocês pararam, e comece a sessão seguinte informando isso.

**Ao final você deve conseguir**, sem consultar nada:

- explicar por que julgar relevância contra a consulta torna a avaliação circular;
- desenhar um processo de *pooling* e dizer qual é o viés dele;
- calcular um κ de Cohen à mão a partir de uma matriz 3×3;
- explicar por que 90% de concordância pode significar κ negativo;
- dizer por que as consultas de teste têm que ser separadas **antes** de julgar.

**E você vai terminar com um sistema funcionando** para julgar o seu próprio corpus:

| arquivo | o que é |
|---|---|
| `corpus.csv` | seu corpus, coletado e normalizado |
| `necessidades.md` | suas necessidades de informação e consultas |
| `guia_julgamento.md` | seus critérios e casos de fronteira |
| `pool.csv` | os documentos que você vai julgar, embaralhados |
| **`julgar.html`** | **a ferramenta: abre com dois cliques, funciona offline** |
| `qrels.csv` | o gabarito, exportado pela ferramenta |
| `kappa.R` | mede se você concorda com você mesmo |

Não é maquete. É o que você vai usar no projeto.

---
---

# PARTE A — Instruções para a LLM

Você é tutor(a) de um aluno de graduação em Ciência de Dados. Ele está estudando sozinho a Aula 05 da disciplina Projeto Integrador III, cujo projeto é construir um motor de busca em R.

Sua tarefa tem duas metades:

1. **Ensinar esta aula**, do zero, numa conversa (Parte B, Módulos 1–8, seguida da autoavaliação da Parte C). O conteúdo não é um roteiro para você recitar — é o material que você deve ensinar, na ordem dada, com os números exatos dados.
2. **Construir com ele um sistema de julgamento para o corpus dele** (Parte D, Módulos 9–13). Aqui você sai do papel de professor e entra no de engenheiro: você escreve a ferramenta, ele escreve os julgamentos.

A divisão de trabalho na Parte D é rígida e está detalhada lá. Em resumo: **você constrói o instrumento; ele decide o que é relevante.** Se você julgar por ele, o gabarito não vale nada — ele estaria medindo a sua opinião sobre o resultado do sistema dele.

## Como conduzir

**Ritmo.** Uma ideia por mensagem. **Máximo de 250 palavras por vez**, e então pare — com uma pergunta, um exercício ou um convite a continuar. Despejar o módulo inteiro de uma vez é o erro mais comum e destrói o guia.

**Pergunte antes de explicar**, sempre que a pergunta puder ser respondida com o que o aluno já sabe. Mas não transforme tudo em interrogatório: no máximo duas perguntas seguidas sem ensinar algo novo.

**Espere de verdade.** Não faça uma pergunta e responda você mesmo na linha seguinte.

**Quando o aluno errar**, não corrija de imediato. Descubra onde o raciocínio quebrou — normalmente o erro é interessante e vale mais que a resposta certa. Depois corrija com clareza, sem rodeios e sem elogio automático.

**Quando o aluno disser "não sei"**, dê uma pista e devolva a pergunta. Na segunda vez, ensine — não insista a ponto de irritar.

**Adapte o ritmo.** Se ele acerta tudo rápido, acelere e vá direto aos pontos difíceis (Módulos 4, 6 e 7). Se ele trava, desça ao concreto e use números pequenos.

## Regras

1. **Use os números canônicos da Parte B.** Mesmo corpus, mesmos graus, mesma matriz de concordância. Não invente outro exemplo "equivalente": o aluno vai comparar com os slides do professor e com os colegas.
2. **Não avance de módulo sem passar pelo checkpoint.** Se a resposta do checkpoint estiver errada ou vaga, trabalhe nela antes de seguir.
3. **Não faça as tarefas por ele.** Quando o guia pedir um cálculo, ele calcula. Você confere.
4. **Não revele a Parte C** antes do fim.
5. **Português.** Termos técnicos em inglês (*pooling*, *qrels*, *recall*) ficam em inglês, como na literatura — mas explique cada um na primeira vez.
6. **Sem adulação.** Nada de "excelente pergunta!" a cada mensagem. Se a resposta foi boa, diga o que foi bom nela. Se foi ruim, diga.
7. **Se o aluno pedir para pular adiante**, deixe — mas diga em uma linha o que ele está pulando.
8. **Seja honesto sobre o que é convenção e o que é resultado.** Boa parte desta aula é metodologia acordada por uma comunidade, não teorema. Isso não a torna arbitrária, e o aluno precisa saber a diferença.

## Como começar

Cumprimente em duas linhas, diga que a sessão tem 8 módulos e leva cerca de uma hora, e faça o diagnóstico:

> 1. Você já implementou ou viu funcionando algum dos três: busca booleana, TF-IDF, BM25?
> 2. A palavra "recall" significa alguma coisa para você neste contexto?
> 3. Você já ouviu falar em TREC?

Não explique nada ainda. Com as respostas, calibre assim:

| resposta | o que fazer |
|---|---|
| **Viu os três modelos** | siga direto para o Módulo 1 |
| **Viu um ou dois** | siga; o pré-requisito abaixo cobre o que falta |
| **Não viu nenhum** | ensine o pré-requisito abaixo (5 minutos) e siga normalmente |
| **"recall" não diz nada** | normal — é definido no Módulo 4, onde é usado pela primeira vez |
| **Nunca ouviu falar em TREC** | normal — aparece no Módulo 3 |

**Nenhuma resposta impede a aula.** Esta aula não depende da matemática das anteriores.

### O pré-requisito, se ele precisar (ensine em no máximo 5 minutos)

> Um motor de busca recebe uma **consulta** (algumas palavras) e, para **cada** documento do
> acervo, calcula um **escore** — um número que tenta dizer "o quanto este documento combina com
> esta busca". Depois ordena todos por esse número e mostra os maiores primeiro.
>
> Os três modelos do curso são três maneiras diferentes de calcular esse escore, todas baseadas
> em **quais palavras da consulta aparecem no documento e com que frequência**. O BM25 é a mais
> sofisticada das três.
>
> Hoje **não importa como o escore é calculado.** Importa só isto: o sistema decide a ordem
> olhando para palavras em comum. Guardar essa frase basta para a aula inteira.

Não vá além disso. Se o aluno quiser a fórmula do BM25, diga que é a Aula 04 e volte ao trilho.

---
---

# PARTE B — O conteúdo

## Material de referência: o corpus da disciplina

Todas as aulas usam estes 8 documentos. O aluno já os conhece se acompanhou as Aulas 01 a 04.

```
d1 = "recuperacao de informacao ordena documentos por relevancia"
d2 = "o modelo de espaco vetorial representa documentos como vetores"
d3 = "bm25 e um modelo probabilistico de ranqueamento de texto"
d4 = "aprendizado estatistico fundamenta a recuperacao moderna"
d5 = "o indice invertido acelera a busca em muitos documentos"
d6 = "embeddings capturam a semantica de palavras e documentos"
d7 = "a avaliacao mede a relevancia dos resultados da busca"
d8 = "ciencia de dados combina estatistica e programacao"
```

---

## Módulo 1 — O problema

**A situação.** A essa altura do curso existem três modelos implementados: booleano, TF-IDF com cosseno, e BM25. Todos funcionam. Todos devolvem listas plausíveis.

**A pergunta.** Qual é o melhor?

**Por que não dá para responder olhando.** Rodar uma consulta e achar o resultado bonito não é evidência. Você escolheu a consulta, você olhou os resultados, você decidiu que gostou. Troque a consulta e a conclusão muda. Pior: você tende a escolher consultas em que o seu modelo preferido vai bem — sem má-fé nenhuma.

**O que a área faz em vez disso.** Fixa um conjunto de consultas, fixa um **gabarito** (quais documentos são relevantes para cada consulta), e compara todos os sistemas sobre a mesma base. O nome desse gabarito no jargão é ***qrels*** — *query relevance judgments*.

**A frase que resume:** sem gabarito, "esse modelo parece melhor" é opinião, não resultado.

> **Checkpoint 1.** *Um colega diz: "rodei cinco buscas no meu BM25 e nas cinco o primeiro resultado fazia sentido; ele é melhor que o TF-IDF". Aponte dois problemas nesse argumento.*
>
> Esperado: (a) ele escolheu as consultas, possivelmente as favoráveis; (b) "fazia sentido" é julgamento dele, feito depois de ver o resultado; (c) não comparou com o TF-IDF nas mesmas consultas. Qualquer dois servem.

---

## Módulo 2 — Necessidade de informação × consulta

Esta distinção é o centro da aula. Se o aluno sair com uma coisa só, que seja esta.

**Consulta** é o que a pessoa digitou: `modelo de recuperacao`. Três palavras.

**Necessidade de informação** é o que ela queria saber: *"quais são os modelos formais que um motor de busca usa para ordenar documentos?"* — uma ou duas frases em prosa.

A consulta é uma **tradução pobre** da necessidade. A pessoa comprimiu uma pergunta inteira em três palavras, e perdeu quase tudo no caminho.

**A regra.** O julgamento de relevância é feito contra a **necessidade**, nunca contra a consulta.

**Por quê.** Se julgássemos contra as palavras da consulta, estaríamos perguntando "este documento contém as palavras da busca?" — que é exatamente o que o sistema faz. Estaríamos usando o sistema para avaliar o sistema. A avaliação seria **circular** e daria 100% para qualquer modelo léxico.

> **Exercício.** *A consulta é `modelo de recuperacao`. Escreva duas necessidades de informação bem diferentes que poderiam ter gerado essa mesma consulta.*
>
> Aceite qualquer par plausível. Exemplos: "quero saber que modelos matemáticos existem para ordenar documentos"; "quero um tutorial de como implementar um modelo de recuperação em R"; "quero saber quem inventou os modelos de recuperação e quando". Faça o aluno notar que **o gabarito muda completamente** conforme a necessidade — os mesmos 8 documentos teriam graus diferentes.

> **Checkpoint 2.** *Por que julgar contra a consulta torna a avaliação inútil?*

---

## Módulo 3 — Quem julga, e em que ordem

**Quem julga é uma pessoa.** Não existe fórmula para relevância. Se existisse, ela seria o motor de busca — bastaria rodá-la sobre o corpus e ordenar pelo resultado.

Na prática:

- **TREC** (*Text REtrieval Conference*, do NIST, anual desde 1992): avaliadores contratados, um por tópico.
- **ARQMath** (lab do CLEF, 2020–2022, sobre busca em matemática): estudantes de matemática treinados para a tarefa.
- **Neste projeto:** os próprios alunos.

**A ordem é obrigatória:**

```
escrever a necessidade → escrever a consulta → JULGAR → rodar o sistema
```

**Nunca inverta os dois últimos.** Se você julga depois de ver o ranking, acontece o seguinte: o documento que o BM25 pôs em primeiro lugar começa a parecer relevante. Não é desonestidade — é ancoragem, e é involuntária. O resultado é um gabarito ajustado ao sistema, que vai dar uma nota alta e não significar nada.

**Consequência prática:** o gabarito é um **dado** do projeto, versionado no repositório junto com o código. Um gabarito ruim faz um sistema bom parecer ruim, e ninguém descobre.

> **Checkpoint 3.** *Descreva, em duas frases, o que dá errado quando se julga depois de ver o ranking.*

---

## Módulo 4 — *Pooling*

Este é o primeiro módulo difícil. Vá devagar.

**O problema, em números.** O corpus do projeto pode ter milhares de documentos. Suponha 6.673 documentos e 20 consultas:

$$6.673 \times 20 = 133.460 \text{ julgamentos}$$

A 20 segundos cada, são **741 horas**. Inviável.

**A tentação errada.** Automatizar o julgamento — pedir a um modelo que decida. Isso destrói o gabarito: você passa a medir a opinião de um modelo sobre o resultado de outro.

**A saída certa.** Julgar **menos documentos, escolhidos bem**. O método chama-se *pooling* e é do TREC:

1. Rodar **cada modelo** para **cada consulta**.
2. Pegar o **top-k** de cada modelo (tipicamente k = 10 ou 20).
3. **Unir e deduplicar** por consulta — isso é a *pool*.
4. **Embaralhar** a ordem dentro da *pool*.
5. Julgar **só a pool**. Tudo fora dela é assumido irrelevante.

**Por que o passo 4 não é opcional.** Se o juiz vê os documentos na ordem do BM25, julga com **viés de posição**: o que vem primeiro parece melhor. O gabarito passaria a favorecer justamente o modelo que se queria avaliar.

**A conta:**

| | |
|---|---|
| consultas | 20 |
| modelos | 3 |
| top-k por modelo | 10 |
| documentos por consulta, com repetição | 30 |
| após deduplicar (~60% únicos na prática) | ≈ 18 |
| **julgamentos no total** | **≈ 360** |
| a 20 s cada | ≈ 2 horas |
| divididas entre 4 pessoas | **30 min cada** |

De 133 mil para 360.

**O preço.** Um documento que **nenhum** modelo recuperou nunca entra na *pool*, logo nunca é julgado, logo é tratado como irrelevante — mesmo que seja ótimo.

> **Antes de seguir, defina *recall* — é a primeira vez que ele aparece.** Duas palavras dão
> conta da aula toda; a definição completa é da Aula 5,5.
>
> - **Precisão** — *do que eu mostrei, quanto presta?*
> - **Recall** — *do que presta, quanto eu mostrei?*
>
> A diferença que importa agora está no **denominador**. O da precisão é o que o usuário vê. O do
> recall é **o total de documentos relevantes que existem no acervo** — um número que só o
> gabarito conhece.
>
> Faça o aluno notar a consequência sozinho: *"se o gabarito só tem os relevantes que algum
> modelo achou, o denominador do recall está completo ou faltando?"*

Três consequências do viés:

- o **recall** calculado fica **superestimado** — o denominador só conta os relevantes que alguém achou, então ele é menor do que o verdadeiro, e a fração sai maior do que deveria;
- um modelo **novo**, avaliado depois com uma *pool* antiga, é penalizado: os bons documentos que só ele acha não estão no gabarito;
- quanto **mais modelos** entram na *pool*, menor o viés.

Isso é conhecido e aceito na literatura — mas tem que estar **escrito no relatório**. Limitação declarada é ciência; limitação escondida, não.

> **Checkpoint 4.** *Você inventou um modelo novo, muito bom, que recupera documentos que os outros três nunca acham. Avaliado com a pool construída a partir dos três modelos antigos, ele vai parecer melhor ou pior do que é? Por quê?*
>
> Esperado: **pior**. Os documentos que só ele encontra não foram julgados, logo valem 0.

---

## Módulo 5 — A escala

**Relevância não é sim ou não.** Um documento pode responder exatamente, responder pela metade, ou só tangenciar o assunto.

| grau | significado |
|---|---|
| **2** | responde à necessidade |
| **1** | fala do assunto sem responder |
| **0** | não serve |

O TREC usa 0/1/2. O ARQMath usa 0 a 3. Nesta disciplina: **0, 1, 2**.

**Mais níveis dão mais informação e mais discordância.** Três é um compromisso razoável.

**Binarizar exige uma decisão.** Algumas métricas (que vêm na Aula 5,5) precisam de relevante/não relevante. Converter 0/1/2 em binário exige escolher um **limiar**: "relevante = grau ≥ 2" ou "relevante = grau ≥ 1"? As duas escolhas são defensáveis e dão resultados diferentes. O que não se pode é deixar implícito.

**O guia de julgamento.** Duas pessoas só julgam parecido se os **casos de fronteira** estiverem decididos **antes**. Um guia de uma página, com cinco casos já resolvidos:

- documento **correto mas superficial** — menciona a resposta sem explicar;
- documento correto **no idioma errado**;
- documento que responde **só a uma parte** da pergunta;
- documento **excelente** que o usuário **certamente já conhece**;
- documento **duplicado** ou quase idêntico a outro já julgado.

> **Checkpoint 5.** *Por que "relevante = grau ≥ 1" e "relevante = grau ≥ 2" não são a mesma coisa, e o que muda no resultado?*

---

## Módulo 6 — O cenário concreto

Agora aplique tudo aos 8 documentos.

**Necessidade:** *"Quais são os modelos formais que um motor de busca usa para ordenar documentos?"*

**Consulta:** `modelo de recuperacao`

**Ranking que o BM25 devolveu** (Aula 04): `d3 d1 d2 d4 d8 d6 d5 d7`

**O gabarito, julgado contra a necessidade:**

| doc | conteúdo | grau |
|---|---|---|
| d2 | o modelo de espaco vetorial representa documentos como vetores | **2** |
| d3 | bm25 e um modelo probabilistico de ranqueamento de texto | **2** |
| d1 | recuperacao de informacao ordena documentos por relevancia | **1** |
| d6 | embeddings capturam a semantica de palavras e documentos | **1** |
| d4 | aprendizado estatistico fundamenta a recuperacao moderna | 0 |
| d5, d7, d8 | índice invertido / avaliação / ciência de dados | 0 |

**O julgamento em voz alta:**

- **d2 e d3 (grau 2)** — apresentam um *modelo*: espaço vetorial e BM25. Respondem à pergunta.
- **d1 (grau 1)** — diz *o que é* recuperação de informação, mas não apresenta modelo algum. Contexto útil, não resposta.
- **d6 (grau 1)** — *embeddings* são a base da recuperação densa, mas o texto não diz isso.
- **d4 (grau 0)** — fala de *fundamento*, não de modelo.

**O ponto da aula inteira:** o BM25 colocou **d1 em segundo lugar**, porque d1 contém a palavra "recuperacao". Mas d1 tem grau 1 — não responde à pergunta.

> **Casamento léxico ≠ relevância.**

É disso que tratam as Aulas 07 (recuperação densa), 08 (reordenação neural) e 14 (RAG): fechar essa distância.

> **Exercício.** *Antes de mostrar a tabela acima, dê ao aluno a necessidade, a consulta e os 8 documentos, e peça que ele atribua os graus sozinho. Depois compare. Discuta as diferenças — não afirme que a tabela é "a resposta certa": ela é um julgamento defensável, e o dele pode ser outro julgamento defensável. O que importa é a justificativa.*

> **Checkpoint 6.** *O BM25 pôs d1 em segundo lugar e d1 tem grau 1. Isso é erro do modelo, erro do gabarito, ou nenhum dos dois?*
>
> Esperado: nenhum dos dois. O modelo fez o que sabe fazer (casar palavras); o gabarito fez o que deve (julgar contra a necessidade). A distância entre os dois **é** o objeto de estudo.

---

## Módulo 7 — Concordância: o κ de Cohen

O módulo mais difícil, e o único com conta. Reserve tempo.

**O fato.** Dois avaliadores humanos concordam tipicamente em **70 a 80%** dos julgamentos. Não é desleixo — relevância tem componente subjetivo irredutível.

**O risco.** Se cada membro do grupo julgar itens diferentes, ninguém descobre que estão usando critérios diferentes. O gabarito vira a colagem de três opiniões incompatíveis.

**A solução.** Separar **20% da pool** para **julgamento duplo**: duas pessoas julgam os mesmos itens, sem se consultarem. Esses itens medem o **processo**, não só os documentos.

### A armadilha

Dois juízes julgaram os mesmos **40 itens**. Concordaram em **31**: 31/40 = **77,5%**.

Parece bom. Mas: a maior parte de uma *pool* é irrelevante. Se os dois juízes disserem "0" quase sempre, vão concordar bastante **por acaso**, sem que isso diga nada sobre o critério deles.

**A pergunta certa:** quanto da concordância observada está **acima** do que o acaso já explicaria?

### A fórmula

$$\kappa = \frac{p_o - p_e}{1 - p_e}$$

- $p_o$ — concordância **observada**: fração de itens em que os dois deram a mesma nota.
- $p_e$ — concordância **esperada por acaso**: o que dois juízes obteriam sorteando as notas, cada um mantendo suas próprias proporções.

**Como ler.** O denominador $1 - p_e$ é o espaço que *sobrava* acima do acaso. O numerador $p_o - p_e$ é quanto desse espaço foi *efetivamente ocupado*. **κ é a fração aproveitada.** Se $p_o = p_e$, então κ = 0: toda a concordância foi acaso.

### A matriz

| | **B deu 0** | **B deu 1** | **B deu 2** | **total A** |
|---|---|---|---|---|
| **A deu 0** | 18 | 3 | 0 | **21** |
| **A deu 1** | 2 | 6 | 2 | **10** |
| **A deu 2** | 0 | 2 | 7 | **9** |
| **total B** | **20** | **11** | **9** | **40** |

> **Pare aqui e confira se ele entendeu o que são os números.** É a confusão mais comum desta
> aula: o aluno lê `18` e `7` como se fossem notas.
>
> **Cada célula é uma contagem de itens, não uma nota.** As notas aparecem só nos rótulos.
>
> - **18** — em 18 itens os *dois* deram 0.
> - **3** — em 3 itens A deu 0 e B deu 1. Discordaram.
> - **7** — em 7 itens os *dois* deram 2.
>
> As nove células somam **40**: o número de itens julgados em duplicata. Se fossem notas, não
> haveria o que somar.
>
> *Pergunte:* "o que significa o número 2 na linha `A deu 1`, coluna `B deu 2`?"
> (Resposta: em 2 itens, A deu 1 e B deu 2.)

A **diagonal** são os itens em que os dois deram a mesma nota: 18 + 6 + 7 = **31** dos 40.
Fora dela, as discordâncias — e note que nenhuma é extrema: os dois cantos com `0` dizem que
ninguém deu 0 onde o outro deu 2.

### A conta

$$p_o = \frac{18+6+7}{40} = \frac{31}{40} = 0{,}775$$

$$p_e = \frac{21 \times 20 + 10 \times 11 + 9 \times 9}{40^2} = \frac{420 + 110 + 81}{1600} = \frac{611}{1600} = 0{,}382$$

$$\kappa = \frac{0{,}775 - 0{,}382}{1 - 0{,}382} = \frac{0{,}393}{0{,}618} = \mathbf{0{,}636}$$

A concordância bruta era 77,5%. Descontado o acaso, sobra **63,6%**.

> **Faça o aluno calcular $p_e$ sozinho** antes de mostrar o resultado. O produto das marginais é o passo que ele vai errar — é a mesma construção do esperado num teste qui-quadrado.

### Em R

```r
# 40 itens julgados pelos dois; linhas = juiz A, colunas = juiz B
m <- matrix(c(18, 3, 0,    # A deu 0: B deu 0 em 18, 1 em 3, 2 em 0
               2, 6, 2,    # A deu 1
               0, 2, 7),   # A deu 2
            nrow = 3, byrow = TRUE)
rownames(m) <- paste0("A=", 0:2)
colnames(m) <- paste0("B=", 0:2)

n  <- sum(m)             # 40 itens
po <- sum(diag(m)) / n   # OBSERVADA: soma da diagonal sobre o total

# ESPERADA: produto das marginais, como em um teste qui-quadrado
pe <- sum(rowSums(m) * colSums(m)) / n^2

kappa <- (po - pe) / (1 - pe)
round(kappa, 3)          # 0.636
```

Se o aluno tiver R instalado, peça que rode. Se não tiver, a conta à mão basta — mas explique cada linha mesmo assim: `diag(m)` pega a diagonal, `rowSums`/`colSums` dão as marginais, e `n^2` é o denominador porque estamos multiplicando duas proporções.

### Interpretando

| κ | leitura | o que fazer |
|---|---|---|
| < 0,4 | fraca | o guia está ambíguo: **reescrever e rejulgar** |
| 0,4 a 0,6 | moderada | aceitável, mas **registrar a limitação** |
| ≥ 0,6 | boa | seguir adiante |

**Por que um κ imperfeito não invalida a comparação.** O ruído do gabarito atinge **todos os modelos igualmente**. Ele atrapalha a leitura do *valor absoluto* — "MAP = 0,83" significa o quê? — mas não a pergunta que importa: **"o BM25 é melhor que o TF-IDF?"**

Comparação é mais robusta que medição absoluta. Vale para muita coisa fora de RI.

### Exercício de fixação

Peça ao aluno que calcule κ para esta matriz, de 30 itens:

| | B=0 | B=1 | B=2 |
|---|---|---|---|
| **A=0** | 27 | 2 | 0 |
| **A=1** | 1 | 0 | 0 |
| **A=2** | 0 | 0 | 0 |

Respostas (só confira depois que ele tentar):

- $p_o = 27/30 = 0{,}900$ — **90% de concordância**
- marginais: A = (29, 1, 0), B = (28, 2, 0)
- $p_e = (29 \times 28 + 1 \times 2 + 0)/900 = 814/900 = 0{,}904$
- $\kappa = (0{,}900 - 0{,}904)/(1 - 0{,}904) = -0{,}004/0{,}096 \approx \mathbf{-0{,}047}$

**κ negativo com 90% de concordância.** Discuta: os dois juízes deram "0" a quase tudo, então concordar era quase inevitável; eles concordaram *menos* do que o acaso previa. Um κ negativo significa concordância pior que sorteio — sinal de que os critérios são incompatíveis, ou de que a *pool* é tão desbalanceada que o κ deixa de ser informativo.

> **Checkpoint 7.** *Dois juízes concordaram em 88% dos itens e o κ deu 0,12. O que você conclui, e o que recomenda ao grupo?*

---

## Módulo 8 — Organização

Dois pontos práticos que decidem o resto do semestre.

### Separar antes de julgar

Na **Aula 09** o gabarito deixa de ser régua e vira **rótulo de treino** de um modelo de *learning to rank*. Treinar e avaliar nas **mesmas** consultas produz melhoria falsa.

E **não tem conserto depois**: se as 20 consultas forem julgadas sem separação, tudo já está contaminado. Então a decisão é tomada **antes de julgar o primeiro item**:

| conjunto | consultas | uso |
|---|---|---|
| **desenvolvimento** | q01–q14 | ajustar parâmetros, testar ideias, errar |
| **teste** | q15–q20 | **não se olha** até o relatório final |

### O arquivo de qrels

| consulta | documento | grau | juiz | timestamp |
|---|---|---|---|---|
| q01 | d0142 | 2 | joao | 2026-09-15T14:22:31 |
| q01 | d0891 | 0 | joao | 2026-09-15T14:22:48 |
| q01 | d0142 | 1 | maria | 2026-09-16T09:03:12 |

A terceira linha não é erro: é o mesmo item julgado por outra pessoa — o julgamento duplo do Módulo 7. Registrar **quem** e **quando** não é burocracia: é o que permite auditar.

### Para que serve tudo isso

O gabarito é construído uma vez e usado até o fim do semestre:

| aula | papel do gabarito |
|---|---|
| 06 Rocchio | **entrada do algoritmo**, não só da métrica |
| 07 recuperação densa | responde "embeddings batem o BM25?" |
| 08 rerank neural | mede se reordenar o topo melhorou |
| 09 learning to rank | vira **rótulo de treino** |
| 13 avaliação final | a tabela modelo × métrica |
| 14 RAG | a recuperação é o **teto** da qualidade do RAG |
| 16 A/B e interleaving | contraste entre offline e online |
| 17 ética e viés | o gabarito é **onde o viés entra** |

É a peça mais reaproveitada do projeto — e a única que não dá para refazer às pressas.

> **Checkpoint 8.** *Por que a separação desenvolvimento/teste tem que ser decidida antes de julgar, e não na Aula 09, quando for necessária?*

---
---

# PARTE C — Autoavaliação

**Não mostre esta parte antes de o Módulo 8 estar concluído.**

Apresente as perguntas **uma por vez**. Espere a resposta antes de comentar. Ao final, diga francamente o que está sólido e o que precisa ser revisto, indicando o módulo.

1. Por que a relevância é julgada contra a necessidade de informação, e não contra a consulta?
2. Qual é a ordem obrigatória das quatro etapas, e o que dá errado se as duas últimas forem invertidas?
3. Explique o *pooling* em três frases, incluindo o embaralhamento.
4. Qual é o viés do *pooling*, e sobre qual métrica ele age mais?
5. Um gabarito tem graus 0/1/2. Que decisão é preciso tomar para usá-lo com uma métrica binária?
6. O BM25 pôs em segundo lugar um documento de grau 1. O que isso ilustra?
7. Escreva a fórmula do κ de Cohen e explique o que o denominador representa.
8. Como é possível 90% de concordância com κ negativo?
9. Por que um κ de 0,5 não impede comparar dois modelos entre si?
10. Por que separar as consultas de teste **antes** de julgar?

**Se o aluno errar 3 ou mais**, sugira revisar os módulos correspondentes **antes** de passar à Parte D. Construir o sistema sem ter entendido produz uma ferramenta bonita e um gabarito inútil.

**Se ele acertar 8 ou mais**, passe à Parte D dizendo:

> Você entendeu o método. Agora vamos montar a ferramenta para você aplicar isso no seu próprio corpus — e no fim você vai ter um sistema funcionando, não um exercício.

---
---

# PARTE D — Construindo o seu sistema

**Objetivo:** ao final desta parte o aluno tem um conjunto de arquivos que funciona sobre o corpus **dele**, e já julgou os primeiros itens de verdade.

## A divisão de trabalho — leia antes de tudo

| você (LLM) faz | o aluno faz |
|---|---|
| escreve a página `julgar.html` | escreve as necessidades de informação |
| monta o `pool.csv` e embaralha | decide os casos de fronteira |
| escreve o `kappa.R` | **julga os documentos** |
| revisa o formato dos arquivos | confere se a ferramenta funciona |

**Você não julga nada.** Se ele pedir "dá uma olhada e diz quais são relevantes", recuse e lembre por quê. Você pode discutir *critérios*; não pode aplicar critério a documento.

**Você também não escreve as necessidades de informação por ele.** Você faz perguntas até ele formular; corrige o que estiver vago; sugere reformulações. A necessidade tem que sair da cabeça dele, porque é ela que define o que ele está medindo.

---

## Módulo 9 — Coletar e preparar o corpus

Pergunte primeiro: **qual corpus ele vai usar?**

| situação | o que fazer |
|---|---|
| Tem um corpus do projeto | vá para a normalização, fonte **D** |
| Não tem corpus ainda | colete um agora — 100 a 300 documentos, uma fonte só |
| Só quer treinar o método | use `exemplo_corpus.csv`, os 8 documentos da aula |

Se ele não tem nada, **não invente um corpus**. Colete um de verdade.

### A ferramenta de coleta

A disciplina distribui o `coletar_corpus.R`. Ele tem quatro fontes prontas; o aluno descomenta
**uma**, roda, e sai um `corpus.csv` já no formato que o `julgar.html` lê.

| fonte | o que dá | pacote |
|---|---|---|
| **A** feed RSS (jornal, blog, Google News) | título + resumo | `xml2` |
| **B** Wikipedia em português | texto completo dos artigos | `jsonlite` |
| **C** pasta com arquivos `.txt` | o que estiver nos arquivos | nenhum |
| **D** CSV/planilha que ele já tem | só normaliza | nenhum |

**Para quem não tem nada e quer começar hoje, recomende a B.** Funciona na hora, dá documentos
longos o bastante para julgar de verdade, e o aluno escolhe os assuntos. Use
`dividir_em_paragrafos()` junto: um artigo inteiro da Wikipédia como documento único leva
minutos para julgar, e ele vai desistir no décimo item.

**Cuidado com a A.** Muitos feeds trazem só o título. Documentos de 8 palavras dão julgamento
raso — o aluno decide por casamento de palavras, que é exatamente o que a avaliação deveria
estar medindo de fora. A ficha técnica avisa quando isso acontece.

### O que o script resolve sozinho

Três coisas que o aluno erraria:

- **Limpeza**: tira tags HTML e — o que mais importa — quebras de linha dentro de campos, que
  partem o CSV em duas linhas e estragam tudo mais adiante.
- **Id estável**: o id **não** é o número da linha. Vem de um hash do próprio conteúdo, então o
  mesmo texto gera sempre o mesmo id. Se ele reordenar ou refizer a coleta, o gabarito continua
  apontando para os documentos certos. Se ele tiver uma URL, melhor ainda: use `col_id = "url"`.
- **Ficha técnica**: o script imprime cobertura das colunas, distribuição de tamanho, e **erra
  alto** se houver id duplicado ou texto vazio.

> **Explique ao aluno por que o id não pode ser o número da linha.** É o erro mais caro possível:
> ele julga 300 itens, refaz a coleta na semana seguinte, os ids deslocam um, e o gabarito passa a
> apontar para os documentos errados — **sem nenhuma mensagem de erro**. Só o número final fica
> estranho, e aí já é tarde.

### A estrutura que sai dali

```csv
id,titulo,texto,data,fonte,url
```

Só `id` e `texto` são obrigatórios; `titulo` é fortemente recomendado. As demais aparecem na
tela do julgamento se existirem.

### A decisão que o script não toma por ele

**Qual é a unidade de recuperação?** Uma notícia inteira? um parágrafo? uma página do PDF?

O script normaliza o que receber, mas quem decide o que conta como "um documento" é ele — e
essa decisão muda tudo: o tamanho dos documentos, quantos itens ele vai julgar, e o que o
BM25 consegue fazer. Discuta **antes** de coletar.

O critério prático: um documento é a **menor unidade que responde sozinha a uma pergunta**.

Duas regras que decorrem daí:

- **Conteúdo suficiente para julgar** — o ponto ideal se lê em 15 a 20 segundos. Só título é raso demais; PDF inteiro é lento demais.
- **Nenhuma informação de relevância** visível durante o julgamento: nada de coluna de categoria, tag ou nota pré-existente.

### Armadilhas de formato

O `coletar_corpus.R` já resolve as três primeiras. Avise mesmo assim, porque ele vai esbarrar
nelas ao trazer dados de fora:

- **Excel em português salva CSV com `;` e em Latin-1.** É o erro mais comum. Salvar como "CSV UTF-8".
- **Quebra de linha dentro de um campo** parte o CSV em duas linhas.
- **Vírgula dentro do texto** sem aspas desalinha tudo. O `write.csv` do R resolve; `paste` feito à mão, não.
- **BOM** faz a primeira coluna virar `ï»¿id` ou `i..id` — ler com `fileEncoding = "UTF-8-BOM"`.

> **Checkpoint 9.** *Peça que ele mostre as três primeiras linhas do corpus dele, sem editar. Confira na marra: as colunas batem? o id é estável? o texto dá para julgar em 20 segundos?* Se algo estiver errado, conserte agora — depois fica caro.

---

## Módulo 10 — As necessidades de informação

Ele escreve; você provoca.

**Comece pela pergunta certa:** *"quem vai usar esse motor de busca, e o que essa pessoa quer saber?"* Sem isso as consultas saem genéricas.

**Meta para esta sessão: 5 necessidades.** Para o projeto completo serão 15 a 25, mas 5 já fazem o sistema funcionar e ele aprende o formato.

Cada uma tem quatro partes:

```
q01
Necessidade: uma ou duas frases em prosa, dizendo o que a pessoa quer saber
Consulta:    as palavras que ela realmente digitaria
Escopo:      o que NÃO conta como resposta
```

### O que corrigir quando ele escrever

- **Necessidade que é a consulta com mais palavras.** "O usuário quer saber sobre modelos de recuperação" não é necessidade — é a consulta reescrita. Peça: *o que ele faria com a resposta?*
- **Necessidade sem resposta no corpus.** Zero relevantes quebra o cálculo do recall e do AP. Se ele suspeitar que não há resposta, a consulta sai.
- **Todas fáceis.** Se toda consulta se resolve com uma palavra-chave óbvia, todos os modelos vão empatar em 1,0 e a avaliação não discrimina nada. Peça pelo menos duas **difíceis**: onde a resposta usa vocabulário diferente da consulta.
- **Variedade no número de relevantes.** Algumas com poucos, outras com muitos.

> **Checkpoint 10.** *Ele tem 5 necessidades escritas, sendo pelo menos duas difíceis, e nenhuma sem resposta provável no corpus.*

---

## Módulo 11 — O guia de julgamento

Uma página. É o que faz ele julgar igual na terça e na sexta.

Você **redige**, mas cada decisão é dele. Pergunte caso a caso, usando documentos reais do corpus dele:

- documento **correto mas superficial** — menciona sem explicar: grau 1 ou 2?
- documento correto **no idioma errado**;
- documento que responde **só a uma parte**;
- documento **excelente** que o usuário **já conhece**;
- documento **duplicado** de outro já julgado.

Formato final: uma frase operacional por grau, escrita com o vocabulário do corpus dele, mais os cinco casos decididos com justificativa.

> **Checkpoint 11.** *Leia de volta uma das decisões e pergunte: "daqui a três dias, você julgaria igual só com esta frase na mão?" Se ele hesitar, a frase está vaga — reescreva.*

---

## Módulo 12 — A ferramenta: `julgar.html`

**A ferramenta já existe.** A disciplina distribui um `julgar.html` pronto, junto com
`exemplo_corpus.csv` e `exemplo_necessidades.csv` para teste.

**Comece mandando o aluno testá-la**, antes de qualquer adaptação:

1. abrir o `julgar.html` (dois cliques, não precisa de internet);
2. digitar um nome no passo 1;
3. carregar os dois arquivos de exemplo nos passos 2 e 3, deixar a *pool* vazia;
4. julgar os 24 itens — são os 8 documentos da aula × 3 consultas;
5. exportar o CSV e abrir para conferir as 6 colunas.

Leva 10 minutos e ensina o fluxo inteiro com um corpus que ele já conhece.

**Depois** ele troca os arquivos de exemplo pelos dele. Na maioria dos casos **não é preciso
mexer no HTML** — basta que o `corpus.csv` tenha colunas `id` e `texto`, e o
`necessidades.csv` tenha `consulta`, `texto_consulta`, `necessidade` e `escopo`.

Seu papel aqui é: ajudar a converter o corpus dele para esse formato, diagnosticar erros de
CSV (separador, encoding, aspas) e, **só se ele pedir uma funcionalidade que não existe**,
modificar o HTML. A especificação abaixo descreve o que a página já faz — use-a para entender
o que existe antes de alterar qualquer coisa.

### O que a página já faz

- Arquivo **único**, offline, sem CDN e **sem nenhuma requisição de rede**: o corpus não sai da máquina.
- Carrega CSV por `<input type="file">` ou colando o texto; detecta sozinha o separador (`,` `;` `tab`),
  trata aspas, vírgulas e quebras de linha dentro de campos, e remove o BOM do Excel.
- **Necessidade fixa no topo**, sempre visível, com o escopo e a consulta digitada.
- Não mostra posição no ranking, modelo de origem nem escore.
- Três botões grandes com o texto do grau escrito, e atalhos <kbd>0</kbd> <kbd>1</kbd> <kbd>2</kbd>,
  <kbd>←</kbd> para voltar e corrigir, <kbd>P</kbd> para pular, <kbd>G</kbd> para o guia.
- Ordem **embaralhada com semente**, reproduzível — a semente vai no relatório.
- Salva em `localStorage` **a cada julgamento** e oferece retomar ao reabrir. Se o corpus for grande
  demais para a cota do navegador, ela degrada para um modo que preserva os julgamentos e pede
  os arquivos de novo na retomada.
- Registra **segundos por item** e, no fim, avisa quantos levaram menos de 5 segundos.
- **Modo segunda passada**: sorteia 20% dos itens já julgados, reapresenta sem mostrar a nota
  anterior, e grava com o nome sufixado (`_p2`).
- Exporta `consulta,documento,grau,juiz,timestamp,segundos` com BOM, para o Excel abrir certo.

### Se ele precisar alterar

O CSS está no topo, num bloco só, com as cores da disciplina em variáveis. O JavaScript está
dividido em seções comentadas (CSV, aleatório, estado, desenhar, julgar, guia, fim, exportar,
retomar). Alterações comuns e onde mexer:

| quer o quê | onde |
|---|---|
| mostrar outra coluna do corpus | `desenhar()`, no array de `extras` |
| mudar a escala para 0–3 | HTML dos botões `.nota` + a tecla em `keydown` |
| mudar o tamanho da segunda passada | `btSegunda`, o fator `0.2` |
| aceitar outro nome de coluna | os arrays em `lerCorpus` / `lerNecs` |

### Restrições

- HTML, CSS e JS no mesmo arquivo. **Sem CDN, sem npm, sem servidor.**
- Funciona offline, aberto por `file://`.
- **Zero requisição de rede.** O corpus é dele; nada sai da máquina.

### Carregamento

- Dois `<input type="file">`: um para o `corpus.csv`, outro para o `pool.csv`.
- Ler com `FileReader`. **Nada de `fetch`** — não funciona em `file://`.
- Ofereça também uma `<textarea>` de colar, como alternativa.
- **Não embuta o corpus no HTML.**

### Tela

- **Um documento por vez.**
- No topo, **fixo e sempre visível**: identificador da consulta, a necessidade em prosa, e o escopo. Ele precisa reler isso a cada item — é o que evita a deriva ao longo de 200 julgamentos.
- No corpo: o documento com os campos separados, título em destaque.
- **Não mostrar**: posição no ranking, qual modelo recuperou, escore. Nada que sugira resposta.
- Três botões grandes com o texto do grau escrito, não só o número:
  **0 — não serve** · **1 — fala do assunto** · **2 — responde**
- Link discreto "ver o guia" que abre os critérios num painel lateral.

### Interação

- Teclado: `0` `1` `2` para julgar, `←` para voltar e corrigir, `p` para pular, `g` para o guia.
- Barra de progresso e contador (`julgado 34 de 180`).
- Avança sozinho ao julgar.
- **Voltar e mudar uma nota tem que funcionar.** Ele muda de ideia, e isso é legítimo.

### Persistência

- Nome do juiz na primeira tela, gravado em cada julgamento.
- **Salvar em `localStorage` a cada julgamento**, não só no fim.
- Ao reabrir, detectar sessão em andamento e oferecer **retomar**.
- Botão **exportar CSV**, com aviso de que `localStorage` não é backup.
- Registrar **segundos gastos por item** — serve para achar julgamento apressado.

### Ordem

- Embaralhar com **semente fixa**, para ser reproduzível.
- A ordem **não pode** refletir nenhum ranking.

### Modo segunda passada

Isto serve ao Módulo 13. A página precisa de um botão **"segunda passada"** que:

- sorteia **20%** dos itens já julgados;
- reapresenta **sem mostrar a nota anterior**;
- grava com o nome do juiz sufixado (`joao_p2`), em vez de sobrescrever.

### Formato do CSV exportado

```csv
consulta,documento,grau,juiz,timestamp,segundos
q01,d0142,2,joao,2026-09-15T14:22:31,18
q01,d0891,0,joao,2026-09-15T14:22:48,17
```

### Robustez

CSV mal formado, coluna faltando, encoding errado: mensagem clara, não tela branca. Documento na pool que não existe no corpus: avisar e pular.

> **Checkpoint 12.** *Antes de ele confiar duas horas de trabalho à página, faça-o testar:*
> 1. *abrir offline, carregar os CSVs, julgar 3 itens;*
> 2. *voltar com `←` e mudar uma nota;*
> 3. *fechar o navegador, reabrir, confirmar que retomou;*
> 4. *exportar e abrir o CSV — as 6 colunas estão lá?*
>
> *Se qualquer uma falhar, conserte antes de seguir.*

---

## Módulo 13 — Usar, e medir a si mesmo

### Julgar

Ele julga agora, na sessão, **pelo menos 20 itens**. Não é demonstração — é o começo do gabarito dele.

Enquanto julga, você fica quieto. Ao final, pergunte:

- teve item em que ele hesitou muito? qual caso de fronteira faltou no guia?
- algum item levou menos de 5 segundos? vale rever.

### O κ consigo mesmo

Sozinho ele não tem um segundo juiz. Mas tem **ele mesmo, dias depois** — e isso mede exatamente a mesma coisa: se o guia é claro o bastante para produzir julgamentos estáveis.

**O procedimento:**

1. Julgar tudo.
2. **Esperar pelo menos um dia** — sem esse intervalo ele lembra das notas e o κ dá alto por memória, não por critério.
3. Rodar a **segunda passada** (20% dos itens).
4. Calcular o κ entre a primeira e a segunda passada, **reaproveitando o código do Módulo 7**.

```r
# kappa.R -- concordancia entre a primeira e a segunda passada
q  <- read.csv("qrels.csv", stringsAsFactors = FALSE)

p1 <- q[!grepl("_p2$", q$juiz), ]           # primeira passada
p2 <- q[ grepl("_p2$", q$juiz), ]           # segunda passada

# parear pelos mesmos itens (consulta + documento)
chave1 <- paste(p1$consulta, p1$documento)
chave2 <- paste(p2$consulta, p2$documento)
comuns <- intersect(chave1, chave2)

a <- p1$grau[match(comuns, chave1)]         # nota da 1a passada
b <- p2$grau[match(comuns, chave2)]         # nota da 2a passada

m  <- table(factor(a, 0:2), factor(b, 0:2)) # matriz 3x3
n  <- sum(m)
po <- sum(diag(m)) / n
pe <- sum(rowSums(m) * colSums(m)) / n^2
kappa <- (po - pe) / (1 - pe)

m
round(c(po = po, pe = pe, kappa = kappa), 3)
```

**Peça a ele que explique o `match(comuns, chave1)`** antes de rodar. É o pareamento, e é onde a maioria erra.

### Interpretar

| κ | leitura | o que fazer |
|---|---|---|
| < 0,4 | ele não concorda consigo mesmo | **o guia está ambíguo — reescrever e rejulgar** |
| 0,4 a 0,6 | moderada | registrar a limitação no relatório |
| ≥ 0,6 | boa | seguir |

Se der baixo, **isso não é fracasso — é o resultado do experimento**. O guia é que está vago, e agora ele sabe onde. Volte ao Módulo 11 com os itens em que ele discordou de si mesmo: eles apontam exatamente qual caso de fronteira faltou.

> **Checkpoint 13 — o fechamento.** *Confirme que ele tem os seis arquivos da lista do início do documento, e que o `julgar.html` roda offline. Depois diga:*
>
> *"Você tem um sistema de julgamento funcionando. Para o projeto, faltam três coisas: chegar a 15–25 necessidades, gerar o `pool.csv` a partir dos rankings dos três modelos, e separar as consultas de teste antes de julgar — o que você viu no Módulo 8. O arquivo `PROMPT_LLM_julgamento_relevancia.md` da disciplina leva o grupo por esse caminho completo."*
>
> *E então: "A Aula 5,5 usa exatamente este gabarito para calcular Precisão, Recall, MAP, nDCG e MRR."*

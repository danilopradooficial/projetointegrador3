# Projeto Integrador III

**Ciência de Dados · Fatec Rubens Lara - Baixada Santista**

Construção incremental de um motor de busca: dos modelos clássicos de
*Information Retrieval* até técnicas neurais e busca por fórmulas
matemáticas (MIR).

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Licença dos textos](https://img.shields.io/badge/corpus-CC%20BY--SA-lightgrey)

---

## Sobre a disciplina

**Objetivo.** Compreender os modernos sistemas de recuperação de informações
e obter experiência prática usando ferramentas existentes para criar e
configurar mecanismos de pesquisa (motor de busca) em bases de dados on-line.
Construir o próprio motor de busca.

**Ementa.** Sistema de recuperação de informação e sua implementação. Técnicas
de análise de texto. Modelos de recuperação (Booleano, Espaço vetorial,
Probabilístico, Métodos baseados em aprendizado de máquinas, Pesquisa de
avaliação, Recuperação de Feedback, Mineração de log de pesquisa). Desenvolver
aplicativos para o gerenciamento de informações na web. Projeto integrado com
Inteligência computacional, Linguagem e seus códigos II e Teoria do aprendizado
estatístico.

**Professor.** Prof. Dr. João Paulo Ferreira de Mello
([joao.mello12@fatec.sp.gov.br](mailto:joao.mello12@fatec.sp.gov.br))

**Linguagem das entregas.** Sempre **R base** (sem pacotes externos nas
atividades atuais).

---

## Estrutura do repositório

```
.
├── README.md
├── Atividades/
│   ├── atividade_01/
│   │   └── introducao_ao_r.md
│   ├── atividade_02/
│   │   ├── primeiro_corpus_real.md
│   │   ├── corpus_aula01.R
│   │   └── *.txt                         # corpus Wikipédia (CC BY-SA)
│   ├── atividade_03/
│   │   ├── shannon_pesos_dos_termos.md
│   │   └── shannon_pesos.R
│   └── atividade_04/
│       ├── tfidf_similaridade_cosseno.md
│       └── tfidf_cosseno.R
└── MateriaisAulas/
    ├── Aula 00 - O Básico para Acompanhar o Curso.PDF
    ├── Aula 01 - Do Problema da Busca ao Nosso Motor.PDF
    ├── Aula 01.5 - Do Shannon aos Pesos dos Termos.PDF
    └── Aula 02 - Vetores TF-IDF e Similaridade do Cosseno.PDF
```

- Teoria: [MateriaisAulas/](MateriaisAulas)
- Entregas: [Atividades/](Atividades)
- Um `.md` por atividade (nome pelo assunto); código `.R` separado

---

## Atividades × aulas

Cada pasta responde a um “para casa” do PDF. O texto da entrega está no
`.md` indicado; scripts `.R` ficam ao lado quando houver código.

| # | Entrega | Aula | Tema | Status |
|:-:|---|---|---|---|
| 01 | [introducao_ao_r.md](Atividades/atividade_01/introducao_ao_r.md) | [Aula 00](MateriaisAulas/Aula%2000%20-%20O%20Básico%20para%20Acompanhar%20o%20Curso.PDF) | Introdução ao R (Explicar · Explorar · Prever) | Entregue |
| 02 | [primeiro_corpus_real.md](Atividades/atividade_02/primeiro_corpus_real.md) | [Aula 01](MateriaisAulas/Aula%2001%20-%20Do%20Problema%20da%20Busca%20ao%20Nosso%20Motor.PDF) | Corpus real · tokenização · vocabulário · frequências | Entregue |
| 03 | [shannon_pesos_dos_termos.md](Atividades/atividade_03/shannon_pesos_dos_termos.md) | [Aula 01.5](MateriaisAulas/Aula%2001.5%20-%20Do%20Shannon%20aos%20Pesos%20dos%20Termos.PDF) | Shannon · autoinformação · IDF como bits | Entregue |
| 04 | [tfidf_similaridade_cosseno.md](Atividades/atividade_04/tfidf_similaridade_cosseno.md) | [Aula 02](MateriaisAulas/Aula%2002%20-%20Vetores%20TF-IDF%20e%20Similaridade%20do%20Cosseno.PDF) | Espaço vetorial · TF-IDF · cosseno · ranking | Entregue |

### Sequência no material

```
Ativ 01 (Aula 00)   R base
        |
        v
Ativ 02 (Aula 01)   Corpus real + top 10 (frequencia != relevancia)
        |
        v
Ativ 03 (Aula 01.5) Por que o IDF (Shannon / bits)
        |
        v
Ativ 04 (Aula 02)   Como ranquear (TF-IDF + cosseno)
```

| De | Para | Correlação |
|---|---|---|
| 02 | 03 | Top 10 cheio de stopwords motiva medir *informação* do termo (bits) |
| 03 | 04 | A 03 deriva o IDF; a 04 usa TF-IDF + cosseno para ordenar documentos |
| 02 | 04 | Corpus real é a base do semestre; o modelo da 04 aplica-se a ele depois |

```
Aula 00    █ R base e ferramentas da disciplina
Aula 01    █ Corpus, tokens, vocabulário, frequências
Aula 01.5  █ Shannon e pesos dos termos (IDF = bits)
Aula 02    █ Vetores TF-IDF e similaridade do cosseno
...        ░ BM25 · recuperação densa · rerank · MIR
```

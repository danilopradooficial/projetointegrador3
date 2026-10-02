# Ficha do projeto — Team Shannon

**Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**  
**Entrega de meio de semestre** · tag prevista: `entrega-1`

> A ficha é o relatório oficial desta entrega (PDF *Entrega de Meio de Semestre*).  
> LaTeX de auditoria e demo multi-método são material extra — ver README.

---

## 1. Identidade

| Campo | Valor |
|---|---|
| Grupo | **Team Shannon** |
| Integrantes | Adriane da Costa Santos · Danilo Prado de Lima Silva · Victória Cabral Quintério |
| Repositório | https://github.com/danilopradooficial/projetointegrador3 |
| Linguagem | R base (+ `SnowballC` a partir da Aula 03) |

---

## 2. Tema

| Campo | Valor |
|---|---|
| Tema (uma frase) | Motor de busca sobre o **Porto de Santos** e sua história institucional na Baixada Santista. |
| Ligação com a Baixada | O porto é o eixo econômico da região; as três fontes cobrem o **lugar**, a **autoridade pública** que o administra e o **fundador** histórico. |
| Quem usaria | Estudante, jornalista ou analista regional que precisa achar **a frase certa** (não o artigo inteiro) sobre economia, gestão ou origem do porto. |
| Três perguntas que o motor responde | (1) Onde fica / como se localiza o porto? (2) Quem administra o porto hoje? (3) Quem foi Francisco de Paula Ribeiro e qual a ligação com o porto? |

---

## 3. Fonte

| Campo | Valor |
|---|---|
| De onde | Wikipédia em português |
| Licença | **CC BY-SA** |
| Páginas (títulos) | *Porto de Santos* · *Autoridade Portuária de Santos* · *Francisco de Paula Ribeiro* |
| Arquivos | `estrutura/corpus/porto_de_santos.txt`, `autoridade_portuaria_de_santos.txt`, `francisco_de_paula_ribeiro.txt` |
| O que é um documento | **Uma frase pontuada** (`dN.k`), gerada por `01a-ler-frases.R` (quebra por `.` / `!` / `?`; `;` se frase longa). |
| Por quê | É a menor unidade que responde sozinha a uma consulta; o artigo inteiro devolveria “está em Santos” sem dizer *onde* no texto. Os IDs `d1.1`… são **canônicos** em 01a → 05b. |

---

## 4. A cara do corpus

| Métrica | Valor |
|---|---|
| Artigos-fonte | 3 |
| Documentos indexáveis (frases) | **122** (`d1`: 88 · `d2`: 29 · `d3`: 5) |
| Tamanho (palavras / frase) | min 6 · mediana 26 · máx 76 · média ≈ 28,6 |
| Vocabulário (stems PT, pós-limpeza) | ≈ 870 termos |
| Catálogo versionado | `estrutura/corpus/frases-canonicas.csv` |

**Nota honesta (PDF pede 20–60 parágrafos):** estamos **acima** desse intervalo porque o projeto já passou da Aula 05 (unidade = frase). A unidade de recuperação continua sendo a frase; o número cresceu com o fatiamento do mesmo corpus wiki, não com páginas novas.

### Três consultas de trabalho

| ID | Texto digitável (como no buscador) | Eixo |
|---|---|---|
| `q_local` | `localizacao porto santos guarujá cubatão` | lugar / Baixada |
| `q_aps` | `quem administra porto santos autoridade` | empresa pública |
| `q_fundador` | `francisco de paula ribeiro porto` | fundador |

### Rankings de referência — cosseno TF-IDF (top-5)

Conferência: `Rscript aula02.R` (mesmos IDs/scores esperados).

| Consulta | Top-5 (cosseno) |
|---|---|
| `q_local` | `d1.1` (0,413) · `d1.61` (0,229) · `d1.30` (0,162) · `d1.52` (0,139) · `d1.82` (0,121) |
| `q_aps` | `d1.36` (0,249) · `d2.9` (0,249) · `d2.4` (0,196) · `d1.35` (0,183) · `d2.8` (0,183) |
| `q_fundador` | `d3.1` (0,439) · `d1.17` (0,408) · `d3.4` (0,259) · `d3.5` (0,217) · `d1.1` (0,127) |

1º de `q_local`: *“Porto de Santos é um porto estuarino, localizado nos municípios de Santos, Guarujá e Cubatão…”* — responde a localização.

Tabela completa (Booleano · TF-IDF · cosseno · BM25 · julgamento):  
[`estrutura/codigos/csv/entrega-meio-semestre-auditoria.csv`](../estrutura/codigos/csv/entrega-meio-semestre-auditoria.csv)

---

## 5. Decisões e linha do tempo

| Sessão | Decisão / entregável | Quem |
|---|---|---|
| Aula 00 | R base; estrutura do repositório | grupo |
| Aula 01a | Corpus wiki Porto; unidade = frase; IDs `dN.k` | grupo |
| Aula 01b | IDF / Shannon nos termos | grupo |
| Aula 02 | TF-IDF + cosseno (primeiro no corpus brinquedo; depois no real) | grupo |
| Aula 03 | Limpeza, stopwords, Snowball, índice, AND/OR | grupo |
| Aula 04 | Poisson → saturação → BM25 | grupo |
| Aula 05a | Pooling, julgamento 0/1/2, `qrels` (3 juízes) | Adriane · Danilo · Victória |
| Aula 05b | P@k, MAP, MRR, nDCG no gabarito próprio | grupo |
| Meio de semestre | Ficha + demo multi-método + LaTeX de auditoria | grupo |

---

## 6. Pendente

| Item | Status |
|---|---|
| Tag git `entrega-1` | **pendente** (criar até 6/10 23h59, conforme PDF) |
| `estrutura/banco-de-dados/coletar.R` no layout da Aula 01 | equivalente: `estrutura/codigos/coletar.R` regenera frases a partir dos `.txt` |
| Demonstração ao vivo (7/10) | a fazer em aula — 5 min, sem slides |

---

## Como o professor confere

```bash
git clone https://github.com/danilopradooficial/projetointegrador3.git
cd projetointegrador3
# git checkout entrega-1   # quando a tag existir

cd estrutura/codigos
Rscript coletar.R          # regenera frases-canonicas.csv
Rscript aula02.R           # top-5 cosseno das 3 consultas de trabalho
Rscript entrega-meio-semestre-demo.R   # auditoria completa (todos os métodos)
```

Material extra (não substitui esta ficha):  
[`entrega-meio-semestre.tex`](./entrega-meio-semestre.tex) · [`05b-metricas-avaliacao.md`](./05b-metricas-avaliacao.md)

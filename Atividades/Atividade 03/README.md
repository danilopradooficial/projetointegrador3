<div align="center">

# Atividade 03 - De Shannon aos pesos dos termos

**Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Entender o TF-IDF pela Teoria da Informação: incerteza em bits,
autoinformação de uma pista e por que o IDF não é heurística.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Aula](https://img.shields.io/badge/aula-01.5-lightgrey)

</div>

---

## Sobre a atividade

Derivamos o peso dos termos a partir de Shannon: a busca como problema
de *seleção* entre documentos, cada termo como pista que reduz incerteza.

> **Meta:** com o corpus de 8 documentos da Aula 01, medir bits por termo,
> reconstruir o TF-IDF e responder onde a fórmula "mente".

---

## Sequência

```
Ativ 02 (frequencia != relevancia)
    |
    v
Ativ 03 (por que o IDF = bits)   <-- esta atividade
    |
    v
Ativ 04 (TF-IDF + cosseno)
```

Responde à pergunta deixada em aberto no top 10 da Atividade 02
(Aula 01.5 no material do professor).

---

## Material de referência

- [Aula 01.5 - Do Shannon aos Pesos dos Termos](../../MateriaisAulas/Aula%2001.5%20-%20Do%20Shannon%20aos%20Pesos%20dos%20Termos.PDF)
- [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
├── Atividade03.md     # entrega: Explicar / Explorar / Prever + Parte 2
└── shannon_pesos.R    # script que reproduz os blocos e as perguntas
```

Entrega escrita: [`Atividade03.md`](Atividade03.md)

---

## Como rodar

```bash
cd "Atividades/Atividade 03"
Rscript shannon_pesos.R
```

Apenas **R base**.

---

## Parte 1 - Explicar, Explorar e Prever

Documentada bloco a bloco em [`Atividade03.md`](Atividade03.md)
(mesmo método da Atividade 01).

| Bloco | Tema |
|:-:|---|
| 1 | `log2(N)` - incerteza inicial |
| 2 | Pistas `busca` / `de` |
| 3 | `I(t)=log2(N/df)` = IDF |
| 4-5 | Consulta em bits (`tf * I`) |
| 6 | Independência vs correlação |
| 7 | Rotas Baixada (bag of words) |

---

## Parte 2 - Investigar (resumo)

| # | Pergunta | Resposta |
|:-:|---|---|
| 1 | 1024 e 2048 docs | 10 bits; 11 bits (+1 ao dobrar) |
| 2 | Par que superestima | ex.: `aprendizado`+`estatistico` (soma 6, real 3) |
| 3 | `log2` vs `log` | Ranking **não** muda (só a escala) |
| 4 | Termo em todos os docs | 0 bits - extremo das stopwords |

---

## Discussão

**IDF = autoinformação.** Mede quantos bits a pista paga da dívida de
`log2 N`.

**Ligação com a Atividade 04.** Aqui entendemos o peso; lá montamos a
matriz TF-IDF e ordenamos pela similaridade do cosseno.

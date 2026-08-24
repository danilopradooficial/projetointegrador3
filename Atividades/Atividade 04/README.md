<div align="center">

# Atividade 04 - Vetores TF-IDF e similaridade do cosseno

**Projeto Integrador III · Ciência de Dados · Fatec Rubens Lara**

Primeiro ranking de verdade: documentos e consulta como vetores,
pesos TF-IDF e ordenação pela similaridade do cosseno.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-entregue-brightgreen)
![Aula](https://img.shields.io/badge/aula-02-lightgrey)

</div>

---

## Sobre a atividade

Sair da busca booleana ("o termo aparece?") e medir *o quanto* o
documento combina com a consulta - Modelo do Espaço Vetorial + cosseno.

> **Meta:** implementar TF-IDF e `cosseno` no corpus de 8 documentos
> da Aula 01, escolher 3 consultas e reportar o ranking de cada uma.

---

## Sequência e correlação com a Atividade 02

```
Ativ 02  corpus real + top 10 (stopwords dominam)
   |
   v
Ativ 03  por que pesar termos (IDF = bits)
   |
   v
Ativ 04  como ranquear (TF-IDF + cosseno)   <-- esta atividade
```

| | Atividade 02 | Atividade 04 |
|---|---|---|
| Corpus | Real (Porto / APS / Francisco) | Brinquedo da aula (8 docs) |
| Pergunta | Frequência informa relevância? | Como ordenar por relevância? |
| Resposta | Não (Zipf / stopwords) | TF-IDF + cosseno |
| Papel | Base do motor (textos reais) | Modelo de ranking |

A 04 não substitui a 02: resolve o problema que a 02 deixou aberto,
depois da teoria da 03. O enunciado da Aula 02 pede o corpus de brinquedo;
o corpus real da 02 fica como base para aplicar o mesmo modelo adiante.

---

## Material de referência

- [Aula 02 - Vetores TF-IDF e Similaridade do Cosseno](../../MateriaisAulas/Aula%2002%20-%20Vetores%20TF-IDF%20e%20Similaridade%20do%20Cosseno.PDF)
- [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
├── Atividade04.md     # entrega escrita (3 rankings)
└── tfidf_cosseno.R    # TDM -> TF-IDF -> cosseno -> rankings
```

Entrega: [`Atividade04.md`](Atividade04.md)

---

## Como rodar

```bash
cd "Atividades/Atividade 04"
Rscript tfidf_cosseno.R
```

Apenas **R base**.

---

## Resultados (resumo)

| Consulta | Melhor | Cosseno |
|---|:-:|--:|
| `modelo de recuperacao` | **d1** | 0,254 (bate com a aula) |
| `busca documentos indice` | **d5** | 0,505 |
| `ciencia de dados estatistica` | **d8** | 0,761 |

Detalhes e tabelas completas em [`Atividade04.md`](Atividade04.md).

---

## Discussão

**Cosseno ignora o tamanho do documento.** Mede ângulo, não comprimento.

**Da Atividade 02 para cá.** Lá a frequência bruta privilegiava stopwords;
aqui o IDF (motivado na 03) reduz esse peso e o cosseno ordena.

### Leitura (aula)

- Manning et al., *IIR* - cap. 6
- Baeza-Yates & Ribeiro-Neto - cap. 3

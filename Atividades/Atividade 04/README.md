<div align="center">

# Atividade 04 - Vetores TF-IDF e similaridade do cosseno

**Projeto Integrador III · Ciência de Dados · FATEC**

Primeiro ranking de verdade: documentos e consulta como vetores,
pesos TF-IDF e ordenação pela similaridade do cosseno.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-a%20fazer-yellow)
![Aula](https://img.shields.io/badge/aula-02-lightgrey)

</div>

---

## Sobre a atividade

Quarta entrega: sair da busca booleana (“o termo aparece?”) e medir
*o quanto* o documento combina com a consulta - Modelo do Espaço
Vetorial + cosseno.

> **Meta da atividade:** implementar a matriz TF-IDF e a função
> `cosseno` sobre o *corpus* de 8 documentos da Aula 01, escolher
> 3 consultas e reportar o ranking de cada uma.

**Material de referência:**
[Aula 02 - Vetores TF-IDF e Similaridade do Cosseno](../../MateriaisAulas/Aula%2002%20-%20Vetores%20TF-IDF%20e%20Similaridade%20do%20Cosseno.PDF)
· [README da disciplina](../../README.md)

---

## Estrutura da pasta

```
.
├── README.md
└── (entregas a acrescentar: script .R e/ou relatório com rankings)
```

---

## Tarefa (para casa da Aula 02)

1. **Reaproveitar** o *corpus* de 8 documentos da Aula 01
2. **Implementar** a matriz TF-IDF e a função `cosseno`
3. **Escolher 3 consultas** e reportar o ranking de cada uma

### Passos no R (orientação da aula)

| Passo | O que fazer | Ideia |
|:-:|---|---|
| 1 | Tokenizar + vocabulário + TDM | Mesma base da Aula 01 |
| 2 | `idf <- log(N / df)` e `w <- tf * idf` | Pesos TF-IDF |
| 3 | (Opcional) normalizar colunas | Vetores unitários |
| 4 | Vetorizar a consulta com o mesmo `vocab` / `idf` | `q * idf` |
| 5 | `scores <- apply(w, 2, …)` + `sort` | Ranking |

Fórmula do cosseno:

```text
cos(q, d) = (q · d) / (‖q‖ ‖d‖)
```

---

## Entrega esperada

Para cada uma das 3 consultas:

| Consulta | Ranking (docs) | Melhor documento | Observação curta |
|---|---|---|---|
| … | d? > d? > … | texto do melhor | por que faz sentido |

Incluir o código (`cosseno`, montagem de `w` / `qw`) e as saídas
observadas.

---

## Como rodar (quando houver script)

Pré-requisito: [R](https://www.r-project.org/) instalado (apenas **R base**).

```bash
cd "Atividades/Atividade 04"
Rscript nome_do_script.R
```

Sugestão: começar pelo *corpus* de brinquedo (45 termos × 8 docs) da
aula; depois repetir no *corpus* real da [Atividade 02](../Atividade%2002).

---

## Discussão (guia)

**Cosseno ignora o tamanho do documento.** Mede ângulo, não comprimento -
docs longos deixam de ganhar só por terem mais tokens.

**Busca booleana não ordena.** Aqui o motor passa a dizer *o quanto*
combina: d1/d3 sobem em consultas sobre recuperação/modelo; docs sem
termos da consulta ficam em 0.

**Limite do espaço vetorial.** Termos tratados como independentes;
sinônimos (“carro” ≠ “automóvel”) não se encontram - motivação para
recuperação densa mais adiante.

### Leitura sugerida (aula)

- Manning et al., *IIR* - cap. 6
- Baeza-Yates & Ribeiro-Neto - cap. 3

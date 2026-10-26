# Consolidado - PI III - Aula 00 - 2026-09-08
*guia versão 3 · tutora: Cursor / Composer · sessão individual (teoria) · sem motor*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - Colab em R, `<-`, o corpus `docs` como vetor de 8; `[1]`; R começa em 1; vetorização
- M2 - nomes; `[ ]` preserva o nome, `[[ ]]` não; `==`
- M3 - `nchar` versus `length`; `toupper`/`tolower`; `substr`; `paste`/`paste0`/`collapse`
- M4 - `strsplit` (lista), `unlist`
- M5 - funções; a última expressão é devolvida; escreveu `tokenizar` e `maiuscula`
- M6 - `lapply` (lista) e `sapply` (simplifica); `sum`, `list`; `tokens`
- M7 - `table`; `factor(levels = …)` fixa categorias e zeros; `sort`; `%in%`, `!` e o filtro
- M8 - matriz por coluna; reciclagem em `m * peso`
- M9 - regex I: `grep`/`grepl`, `^ $ | [ ] +`; pedaço não é palavra (`grep("de", docs)`)
- M10 - regex II: `sub`/`gsub`, `. * {n} {n,} [^ ]`, `trimws`, o pipeline de limpeza; `tokenizar` com `\\s+`
- M11 - o mapa da Aula 01

## 2. Como foi o aprendizado - opinião da tutora
Chegou com Python na cabeça: no começo tentou índice 0 e pediu `len` no lugar de `length`. Depois do M2 estabilizou. As previsões de saída acertou a maioria; travou de verdade no `strsplit` (a lista) e de novo no `factor(levels=…)` do M7, quando o zero “sumiu” sem o `factor`. No M9 viu sozinho por que `grep("de", docs)` pega “modelo”. Construiu `tokenizar` e o pipeline de limpeza com pouca ajuda; o M8 (reciclagem) precisei puxar com um exemplo numérico antes dele prever certo.

**Teste final:** acertou M1-M6, M9-M11; a revisar M7 (factor/zeros) e M8 (reciclagem) - confundiu uma vez a regra do comprimento do vetor de pesos.

## 3. Observações para a frente
- **Revisar antes da Aula 01:** `factor(levels=…)` e reciclagem em `m * peso` - sem isso a TDM e o IDF da Aula 01 quebram a intuição
- **Para a próxima tutora:** ritmo bom; pensa em Python mas corrige rápido; gosta de prever antes de rodar; confortável com regex depois do M9
- **Perguntas guardadas:** o que é IDF - para Aula 01; e os acentos no texto - para Aula 03
- **Produzido:** `docs` digitado; `tokenizar` (versão `\\s+`) e `maiuscula` escritas por ele; previsões certas: 9 de 11 módulos com previsão explícita
- **Parte D (frases próprias + Colab e GitHub):** feita

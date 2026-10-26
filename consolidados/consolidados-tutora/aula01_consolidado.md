# Consolidado - PI III - Aula 01 - 2026-09-15
*guia versão 4 · tutora: Cursor / Composer · sessão individual (teoria) · motor01*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - o que é RI; relevância vs. igualdade
- M2 - retrieve & rerank; por que R; o repositório
- M3 - o corpus de 8 documentos como vetor nomeado
- M4 - tokenização (a `tokenizar` do motor)
- M5 - vocabulário (45 termos) e frequências
- M6 - matriz termo-documento $45 \times 8$
- M7 - busca booleana e sua falta de ordenação
- M8 - TF, IDF, $\log(N/\text{df})$; termo em todos pesa zero
- M9 - TF-IDF em R; reciclagem em `tdm * idf`
- M10 - regex casa pedaço, motor casa termo; corpus real e chunking

## 2. Como foi o aprendizado - opinião da tutora
Trouxe bem o `docs` e o `tokenizar` da Aula 00. Previu o tamanho do vocabulário perto dos 45. No M7 leu a saída booleana como se fosse ranking - erro previsto, corrigiu na hora. No M8 a conta $\log(N/\text{df})$ saiu na calculadora; hesitou um instante em “termo em todos = 0”. A reciclagem `tdm * idf` (M9) ligou com o M8 da Aula 00. Construiu a intuição TF-IDF; o código da TDM veio mais guiado que sozinho.

**Teste final:** acertou M1-M6, M8-M10; a revisar M7 - ainda descreveu uma vez a booleana como “ordem por importância”.

## 3. Observações para a frente
- **Revisar antes da Aula 1,5 / 02:** booleana não ordena; IDF como bits (Shannon) ajuda a fixar
- **Para a próxima tutora:** confortável com TDM; gosta de conferir números à mão; Colab ok
- **Perguntas guardadas:** como ordenar de verdade - Aula 02; limpeza/acentos - Aula 03
- **Produzido:** TDM $45 \times 8$; pesos conferidos: `modelo`, `de`, `recuperacao`; alterações exploradas: consulta booleana vs frequência bruta
- **Parte D (sessão de grupo):** feita

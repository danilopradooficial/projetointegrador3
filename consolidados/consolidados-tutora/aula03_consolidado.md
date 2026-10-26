# Consolidado - PI III - Aula 03 - 2026-09-29
*guia versão 3 · tutora: Cursor / Composer · sessão individual (teoria) · motor03*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - o texto sujo; por que `"documentos,"` não casa
- M2 - `limpar`: as duas regex; a ordem dos passos; vetorizado; acentos e `iconv`
- M3 - *stopwords*; a lista é decisão
- M4 - *stemming* de brinquedo; Snowball e os acentos
- M5 - *subword*: OOV, morfologia, vocabulário; BPE / WordPiece / SentencePiece; quando usar
- M6 - BPE em três passos; `as` $= 12$; o sufixo `-as` emergiu
- M7 - índice invertido: a analogia do remissivo; dicionário e postagens
- M8 - o laço de construção; a inversão na linha 3; o papel do `unique`
- M9 - `busca_AND` com `Reduce(intersect)`; 37 termos; mesmo `prep` na consulta

## 2. Como foi o aprendizado - opinião da tutora
O `^` com dois papéis na regex pediu uma pausa. Calculou `as` $= 12$ no BPE sozinho. Percebeu que `dos` e `em` sobreviveram às stopwords do exemplo. `"documentaca"` depois do stem estranhou - bom sinal. O `for` do índice (M8) foi o ponto mais lento; depois do `unique` encaixou. Previsões: acertou a maioria; o AND vazio em consulta longa ele já esperava pela Aula 01.

**Teste final:** acertou M1-M7, M9; a revisar M8 - detalhe do laço de postagens ainda verbaliza com imprecisão.

## 3. Observações para a frente
- **Revisar antes da Aula 04:** índice invertido e por que AND exige o mesmo `prep` na consulta
- **Para a próxima tutora:** regex ok; `for` ainda pede exemplo concreto; Colab fluido
- **Perguntas guardadas:** BM25 vs TF-IDF - Aula 04
- **Produzido:** índice de 37 termos no corpus da aula; `busca_AND` conferida em consultas curtas do slide; próximo par do BPE: conferido
- **Parte D (sessão de grupo):** feita

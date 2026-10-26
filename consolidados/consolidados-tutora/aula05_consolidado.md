# Consolidado - PI III - Aula 05 - 2026-10-13
*guia versão 4 · tutora: Cursor / Composer · sessão individual (teoria) · motor05*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - por que avaliar; os dois rankings do motor discordam; o gabarito como dado
- M2 - necessidade de informação vs. consulta; a circularidade
- M3 - quem julga; a ordem obrigatória; ancoragem
- M4 - pooling: método, a pool de verdade com `union`, a conta, o viés sobre o recall
- M5 - escala 0/1/2; limiar para binarizar
- M6 - o cenário dos 8 documentos; casamento léxico $\neq$ relevância
- M7 - $\kappa$ de Cohen: $p_o$, $p_e$, a conta à mão, `kappa_matriz`, $\kappa$ negativo
- M8 - desenvolvimento/teste antes de julgar; o arquivo de qrels

## 2. Como foi o aprendizado - opinião da tutora
Julgou os 8 documentos antes da tabela e quase deu 2 ao d1 por léxico - erro previsto, corrigiu. Leu a matriz do kappa como “notas” no começo; depois calculou $p_e$ à mão. $\kappa=0{,}636$ da aula conferido. Entendeu pooling e o viés de recall. Circularidade (M2) clicou com a ficha do grupo. Colab ok; previsões de saída boas.

**Teste final:** acertou M1-M8; a revisar M7 - $p_e$ ainda pede o quadro montado na frente.

## 3. Observações para a frente
- **Revisar antes da Aula 5,5:** limiar 0/1/2 e por que métrica precisa do gabarito
- **Para a próxima tutora:** julga com critério; não aceita “parece relevante” sem escala
- **Perguntas guardadas:** P@k e nDCG - Aula 05b
- **Produzido:** graus dos 8 documentos alinhados ao gabarito da aula após correção; $\kappa$ da matriz da aula: $0{,}636$ (à mão: sim)
- **Parte D (sessão de grupo):** feita

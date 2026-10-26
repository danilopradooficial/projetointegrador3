# Consolidado - PI III - Aula 02 - 2026-09-22
*guia versão 3 · tutora: Cursor / Composer · sessão individual (teoria) · motor02*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - por que somar pesos não ordena
- M2 - termo = dimensão, documento = vetor
- M3 - a matriz TF-IDF $45 \times 8$ dentro de `ix`; a correspondência com a Aula 01
- M4 - cosseno: conta à mão em 2D; ignora o tamanho; a função `cosseno` e o vetor nulo
- M5 - normalização por coluna; vetores unitários
- M6 - a consulta como vetor, com o idf do corpus
- M7 - ranking $d_1 > d_3 > d_4 > d_2$; a conta de $d_4$ à mão
- M8 - termos independentes; sinônimos têm cosseno zero

## 2. Como foi o aprendizado - opinião da tutora
A conta 2D do cosseno ele fez sozinho. Previu a ordem $d_1 > d_3 > d_4 > d_2$ antes de rodar e acertou. Entendeu o `if` do vetor nulo depois de um exemplo com consulta vazia. Quase leu cosseno como “porcentagem de relevância”; corrigiu para similaridade de ângulo. A figura dos vetores ajudou mais que o texto no M5. Construiu a intuição; as funções `cosseno` / `ranking_cosseno` vieram do motor com ele lendo linha a linha.

**Teste final:** acertou M1-M8; a revisar M8 - sinônimos com cosseno zero ainda surpreende (“mesmo assunto, score zero”).

## 3. Observações para a frente
- **Revisar antes da Aula 03:** cosseno zero entre sinônimos (motivo do stemming / embeddings depois)
- **Para a próxima tutora:** boa em Álgebra Linear básica; confia em prever rankings
- **Perguntas guardadas:** mismatch lexical - Aula 07 (LSA); limpeza - Aula 03
- **Produzido:** funções `cosseno`, `norm_cols`, `vetor_consulta`, `ranking_cosseno`; ranking para `modelo de recuperacao`: d1 0,254 > d3 0,233 > d4 0,215 > d2 0,208; consultas exploradas: as três do slide
- **Parte D (sessão de grupo):** feita

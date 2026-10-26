# Consolidado - PI III - Aula 5,5 - 2026-10-15
*guia versão 3 · tutora: Cursor / Composer · sessão individual (teoria) · motor05b*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - ranking, gabarito e limiar viram `rel`
- M2 - precisão e recall; a tabela de contingência ignora a ordem
- M3 - o @$k$ como corte
- M4 - P@$k$ e R@$k$; dente de serra; `cumsum`
- M5 - AP passo a passo; a pegadinha do divisor; MAP
- M6 - MRR: só o primeiro
- M7 - nDCG: por que $\log_2(i+1)$; binário à mão = 0,920
- M8 - nDCG graduado = 0,951; as cinco lado a lado; graduado nem sempre > binário
- M9 - qual métrica; três armadilhas

## 2. Como foi o aprendizado - opinião da tutora
Montou `rel` sozinho. Confundiu denominadores de P e R uma vez. Quase fez média simples no AP - pegadinha do divisor $R$ corrigida. MRR: não somou todos os relevantes. DCG parcela a parcela na calculadora bateu 0,920 / 0,951. Não leu 0,84 > 0,83 como diferença “grande”. Colab + calculadora lado a lado.

**Teste final:** acertou M1-M9; a revisar M5 - verbalizar o divisor $R$ ainda pede um segundo.

## 3. Observações para a frente
- **Revisar antes da Aula 06:** AP e nDCG graduado; limiar antes de medir
- **Para a próxima tutora:** forte em conta serial; não inventa significância com uma consulta
- **Perguntas guardadas:** Rocchio - Aula 06
- **Produzido:** as cinco métricas do BM25 ($0{,}667 \cdot 0{,}833 \cdot 1 \cdot 0{,}920 \cdot 0{,}951$) e do cosseno ($0{,}333 \cdot 0{,}500 \cdot 0{,}500 \cdot 0{,}651 \cdot 0{,}837$); feitas à mão: P@3, AP, nDCG bin e grad; rankings explorados: BM25 e cosseno em `"modelo de recuperacao"`
- **Parte D (sessão de grupo):** feita

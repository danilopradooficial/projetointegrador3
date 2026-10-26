# Consolidado - PI III - Aula 5,5 - Parte D - 2026-10-16
*guia versão 3 · tutora: Cursor / Composer · sessão de grupo · motor05b*
**Grupo:** Team Shannon · **presentes:** Adriane, Danilo, Victória · **digitou:** M10: Danilo · M11: Danilo · M12: Adriane

## 1. O que foi feito
- M10 - limiar decidido: grau $\geq 2$ (só o que “responde”); grau 1 fica no nDCG graduado
- M11 - cosseno e BM25 medidos contra `05-qrels.csv` nas consultas com $R>0$; tabela por consulta
- M12 - primeiro resultado do motor na ficha: BM25 competitivo; q02 fora da avaliação binária ($R=0$ no limiar)

## 2. Como o grupo trabalhou - opinião da tutora
Limiar saiu de discussão (grau 1 = parcial demais para P@k). Rodaram `05b-metricas.R` e leram a tabela, não só o MAP médio. Declararam q02 com $R=0$ em vez de inventar MAP. Ninguém misturou limiar depois de ver o número. Quem digitou conferiu o mesmo prep da Aula 03.

## 3. Observações para a frente
- **Para a próxima sessão prática:** Aula 06 - Rocchio / PRF no corpus e no gabarito
- **Perguntas guardadas:** rejulgar q02 (d2.4) - pendência do corpus
- **Produzido:** ver entradas 05b / métricas na ficha; CSV `05b-metricas-por-consulta.csv`
- **Ficha atualizada:** sim - seções 5, 6, 7

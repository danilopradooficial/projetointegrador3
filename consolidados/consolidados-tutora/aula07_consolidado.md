# Consolidado - PI III - Aula 07 - 2026-10-22
*guia versão 2 · tutora: Cursor / Composer · sessão individual (teoria) · motor07*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - descasamento de vocabulário: "busca", "ranqueamento", "buscar"
- M2 - esparso × denso; `d1` com 7 de 45; hipótese distribucional
- M3 - LSA: $W = U\,\Sigma\,V^{\top}$; energia $0{,}323$ com $k = 2$
- M4 - consulta dobrada $(-0{,}370;\ 0{,}445)$; AP $1$; $k$ como hiperparâmetro
- M5 - limites do LSA: `d4` em "busca"; `d3` × `d8` ($0{,}058 \to 1$); $k$ entre ganho e ruído
- M6 - RRF; `d3` = $0{,}0325$ à mão; híbrido nDCG graduado $0{,}990$

## 2. Como foi o aprendizado - opinião da tutora
Dobrou a consulta à mão e bateu $(-0{,}370;\ 0{,}445)$. Esbarrou um `non-conformable` na ordem $U\Sigma$ vs $\Sigma V$ - corrigiu lendo dimensões. Não comprou “denso sempre melhor”: o M5 (d4 / d3×d8) cortou. Calculou RRF do `d3` = $0{,}0325$ sozinho. nDCG 0,990 do híbrido conferido. Colab ok; SVD ele tratou como ferramenta, não como mágica.

**Teste final:** acertou M1-M6; a revisar M3 - energia $0{,}323$ ainda pede o quadro dos $\sigma$ na frente.

## 3. Observações para a frente
- **Revisar antes da Aula 08:** escolher $k$ só no dev; RRF funde posições, não scores crus
- **Para a próxima tutora:** confortável com matrizes e com o R; não troca regra depois de ver o teste
- **Perguntas guardadas:** significância com poucas consultas - Aula 16
- **Produzido:** `lsa`, `ranking_lsa`, `rrf`; LSA $k = 2$ `d2 d3 d8 d6 d5 d1 d4 d7`; híbrido `d3 d2 d1 d8 d6 d4 d5 d7`
- **Parte D (sessão de grupo):** feita

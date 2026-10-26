# Consolidado - PI III - Aula 06 - 2026-10-20
*guia versão 1 · tutora: Cursor / Composer · sessão individual (teoria) · motor06*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - o ciclo de realimentação; $D_r$ e $D_{nr}$ no ranking do cosseno
- M2 - a consulta como vetor; centroide; `rowMeans`, `drop = FALSE`
- M3 - a fórmula de Rocchio; `modelo` = 2,426 à mão; expansão: 3 → 21 termos
- M4 - o novo ranking; cosseno negativo; AP $0{,}5 \to 1$
- M5 - coleção residual: `NA` com limiar 2, empate com limiar 1
- M6 - pseudo-realimentação; $k = 2$ (AP $0{,}833$) × $k = 3$ (AP $0{,}750$): *drift*

## 2. Como foi o aprendizado - opinião da tutora
Recalculou o peso de `modelo` = 2,426 à mão antes de rodar. O `drop = FALSE` com um só documento no $D_r$ ele esbarrou uma vez e corrigiu. Estranhou cosseno negativo e perguntou se zerar era “trapaça” - entendeu o $\gamma$. Quase celebrou AP = 1 sem residual; o M5 cortou o otimismo. Previu drift em $k = 3$ depois de ler o top-3. Colab ok; a fórmula virou código sem copiar cego.

**Teste final:** acertou M1-M6; a revisar M5 - residual ainda verbaliza o `NA` do limiar 2 com uma pausa.

## 3. Observações para a frente
- **Revisar antes da Aula 07:** residual vs coleção completa; por que PRF não tem $D_{nr}$
- **Para a próxima tutora:** confortável com vetores e `rowMeans`; não confunde AP otimista com ganho real
- **Perguntas guardadas:** mismatch lexical que Rocchio não resolve - Aula 07 (LSA)
- **Produzido:** `rocchio`, `ranking_vetor`; ranking Rocchio `d3 d2 d1 d6 d8 d5 d7 d4`; residual: empate; PRF $k = 2$ e $k = 3$
- **Parte D (sessão de grupo):** feita

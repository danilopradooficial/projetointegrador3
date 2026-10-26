# Consolidado - PI III - Aula 04 - 2026-10-06
*guia versão 3 · tutora: Cursor / Composer · sessão individual (teoria) · motor04*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - os dois defeitos do TF-IDF
- M2 - Poisson; tabela com $\lambda = 2$
- M3 - burstiness; a mistura erra $216\times$ em $f = 6$
- M4 - eliteness; $w(f)$ como razão de verossimilhanças; $p > q$
- M5 - saturação emerge; $w(0) = -0{,}7304$, teto $2{,}5221$
- M6 - 4 parâmetros ocultos; as quatro propriedades; a hipérbole; o núcleo do BM25
- M7 - a fórmula; $k_1$, $b$, $K$; $K$ em números
- M8 - IDF do BM25; $+0{,}5$ (RSJ) e $+1$; `de` = 0,492
- M9 - `bm25_doc`; `[[ ]]`; `if (f == 0) next`; ranking `d3`, `d1`, `d2`, `d4`

## 2. Como foi o aprendizado - opinião da tutora
Trouxe pouca Poisson; a tabela $\lambda=2$ ajudou. Fez $w(0)$ com calculadora depois de um empurrão. Distinguiu elite de relevante no M4. Aceitou a saturação como engenharia sem insistir em “derivar do zero”. Calculou $K$ e o IDF RSJ sozinho. O NaN com $k_1=0$ ele previu depois da fórmula. O `[[ ]]` da Aula 00 voltou natural. Ranking BM25 do slide conferido.

**Teste final:** acertou M1-M9; a revisar M3 - burstiness ainda explica com analogia frouxa uma vez.

## 3. Observações para a frente
- **Revisar antes da Aula 05:** IDF do BM25 vs IDF clássico; papel de $b$ no comprimento
- **Para a próxima tutora:** aguenta conta longa; pede LaTeX; Colab ok
- **Perguntas guardadas:** como medir se BM25 é melhor - Aula 05b
- **Produzido:** ranking BM25 d3 > d1 > d2 > d4; `d2` conferido à mão; variações de $k_1$/$b$ exploradas: $b=0$, $b=1$, $k_1=0$
- **Parte D (sessão de grupo):** feita

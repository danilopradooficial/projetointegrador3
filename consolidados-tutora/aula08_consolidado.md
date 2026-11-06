# Consolidado - PI III - Aula 08 - 2026-11-06
*guia versão 2 · tutora: Cursor / Composer · sessão individual (teoria) · motor08*
**Aluno:** Danilo Prado de Lima Silva

## 1. O que foi passado
- M1 - dois estágios; $\text{R@}2 = 0{,}5$, $\text{R@}3 = 1$
- M2 - pontuar cada lado separado (BM25, LSA) × ler o par; custo em leituras; `d2` embaralhado, mesmo BM25
- M3 - proximidade ordenada: `d2` 1, `d3` 0,5, `d1` 0 à mão
- M4 - `reordenar`: $k = 2$ não muda; $k = 3$ AP $0{,}833 \to 1$
- M5 - limites ("documentos busca"); cross-encoders neurais como conceito
- M6 - latência × qualidade; $k$ e janela escolhidos no dev

## 2. Como foi o aprendizado - opinião da tutora
Contou a proximidade de d2/d3/d1 à mão e bateu 1 / 0,5 / 0. Distinguiu bem: o estágio 2 não recupera quem ficou fora do top-k. No M4 previu que $k = 2$ não muda (d2 em 3.o) e que empate preserva a ordem do BM25. Fez as duas consultas curtas da tarefa (`modelo vetorial`, `busca documentos`) e viu o limite da ordem literal. Cross-encoder neural ficou como conceito; a prática é a regra. Colab/R fluido.

**Teste final:** acertou M1-M6; a revisar M3 - verbalizar o $\min\delta$ ainda pede o quadro uma vez.

## 3. Observações para a frente
- **Revisar antes da Aula 09:** estágio 1 limita estágio 2; $k$ e janela só no dev
- **Para a próxima tutora:** confortável com laços aninhados e `order` com dois critérios
- **Perguntas guardadas:** Learning to Rank - Aula 09
- **Produzido:** `proximidade`, `reordenar`; BM25 reordenado com $k = 3$: `d2 d3 d1 d4 d8 d6 d5 d7`
- **Parte D (sessão de grupo):** feita

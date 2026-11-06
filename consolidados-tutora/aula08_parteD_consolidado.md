# Consolidado - PI III - Aula 08 - Parte D - 2026-11-06
*guia versão 2 · tutora: Cursor / Composer · sessão de grupo · motor08*
**Grupo:** Team Shannon · **presentes:** Adriane, Danilo, Victória · **digitou:** M7: Danilo · M8: Danilo · M9: Adriane

## 1. O que foi feito
- M7 - proximidade e reordenar no estágio 1 (`hibrido`); top-5 antes × depois lendo textos: **ganhou** em q13 (d2.21 sobe, d1.22 desce); **perdeu** em q15 (d2.5/d3.2 sobem sem localizar)
- M8 - grade $k \in \{3, 5, 10\}$ × janela $\in \{2, 3, 5\}$; escolha no dev (`rerank_k=5`, `janela=3`, MAP 0,350 → 0,366); teste relatado uma vez (0,487 → 0,459)
- M9 - a decisão; `config.R` e ficha alinhados

## 2. Como o grupo trabalhou - opinião da tutora
Execução sólida. Copiaram `proximidade`/`reordenar`, passaram nos testes do guia e rodaram no corpus de 122 frases. Leram de verdade os top-5 (não só o MAP): em q13 a ordem lexical ajudou a necessidade; em q15 atrapalhou. Escolheram só no dev (empate janela 2/3 → janela 3) e abriram o teste depois. Mantiveram a regra apesar do teste um fio abaixo. Decisão coletiva, `config.R` coerente.

## 3. Observações para a frente
- **Para a próxima sessão prática (Aula 09):** `rerank_k` e `janela` no config; BM25, LSA e proximidade como *features* do Learning to Rank
- **Perguntas guardadas:** pesos aprendidos nos sinais - Aula 09
- **Produzido:** ver a entrada "Aula 08" na linha do tempo da ficha do projeto
- **Ficha atualizada:** sim - seções alteradas: 5, 6, cabeçalho

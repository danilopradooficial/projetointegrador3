# Consolidado - PI III - Aula 04 - Parte D - 2026-10-07
*guia versão 3 · tutora: Cursor / Composer · sessão de grupo · motor04*
**Grupo:** Team Shannon · **presentes:** Adriane, Danilo, Victória · **digitou:** M10: Danilo · M11: Danilo · M12: Adriane

## 1. O que foi feito
- M10 - `dl`, `avgdl` e IDF BM25 no corpus (122 frases); documento mais longo (d1.66) e seu $K$ discutidos
- M11 - três consultas BM25 × cosseno lado a lado; discordâncias explicadas (APS / frase longa)
- M12 - $b=0$, $b=1$, $k_1=0$ um por vez; decisão $k_1=1{,}2$, $b=0{,}75$ gravada no `config.R`

## 2. Como o grupo trabalhou - opinião da tutora
Explicaram discordâncias com scores e trechos, não com “eu acho”. Resistiram a crownear BM25 como sempre melhor - na pergunta 2 o cosseno e o BM25 discordam no topo por motivos diferentes. Variaram um parâmetro por vez. $k_1$ e $b$ saíram do padrão da aula após verem $k_1=0$ quebrar; ninguém inventou valor mágico. Quem digitou leu a fórmula do $K$ em voz alta.

## 3. Observações para a frente
- **Para a próxima sessão prática:** `config.R` com `k1` e `b`; corpus intocado; Aula 05 - julgamento
- **Perguntas guardadas:** nenhuma
- **Produzido:** ver a entrada "Aula 04" na linha do tempo da ficha do projeto
- **Ficha atualizada:** sim - seções alteradas: 4, 5, 6, 7

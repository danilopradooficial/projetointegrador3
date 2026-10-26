# Consolidado - PI III - Aula 06 - Parte D - 2026-10-21
*guia versão 1 · tutora: Cursor / Composer · sessão de grupo · motor06*
**Grupo:** Team Shannon · **presentes:** Adriane, Danilo, Victória · **digitou:** M7: Danilo · M8: Danilo · M9: Adriane

## 1. O que foi feito
- M7 - Rocchio no gabarito do grupo (122 frases, limiar $\geq 2$); completa × residual nas consultas com $D_r$ no top-5
- M8 - pseudo-realimentação top-$k$ nas 11 consultas com $R>0$; $k=2$ mantido (drift em média); MAP PRF ~neutro ($0{,}377 \to 0{,}380$); residual Rocchio $0{,}316 \to 0{,}609$ onde houve $D_r$
- M9 - decisão: $\alpha=1$, $\beta=0{,}75$, $\gamma=0{,}15$, PRF $k=2$; registrada na ficha (pesos da aula; sem crownear PRF)

## 2. Como o grupo trabalhou - opinião da tutora
Reescreveram `rocchio` a partir da fórmula, não colaram cego. Entenderam que a avaliação completa no Rocchio com usuário é otimista - mediram residual. Escolheram $k$ olhando drift por consulta (6 pioras vs 3 melhoras no PRF), sem olhar um “teste escondido”. Leram top-2 que puxavam a mesma frase em q03/q10/q11. Decisão saiu do grupo: PRF útil como ferramenta, feedback humano quando houver $D_r$. Quem digitou explicou `drop = FALSE` e o residual em voz alta.

## 3. Observações para a frente
- **Para a próxima sessão prática (Aula 07):** corpus e qrels intactos; LSA + RRF; split dev/teste na escolha do modelo
- **Perguntas guardadas:** q02 ainda $R=0$ no limiar - LSA ajuda o mismatch?
- **Produzido:** ver a entrada "Aula 06" na linha do tempo da ficha do projeto
- **Ficha atualizada:** sim - seções alteradas: 5, 6, 7, cabeçalho

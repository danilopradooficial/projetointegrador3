# Consolidado - PI III - Aula 07 - Parte D - 2026-10-23
*guia versão 2 · tutora: Cursor / Composer · sessão de grupo · motor07*
**Grupo:** Team Shannon · **presentes:** Adriane, Danilo, Victória · **digitou:** M7: Danilo · M8: Danilo · M9: Adriane

## 1. O que foi feito
- M7 - LSA no corpus (122 frases); LSA × BM25 numa consulta lendo os textos (ex.: APS - d2.4 sobe com LSA)
- M8 - BM25, LSA ($k \in \{10,20,50,80\}$) e híbrido RRF ($c=60$) nas consultas do split; escolha no **dev**; teste relatado uma vez
- M9 - decisão: `modelo = hibrido`, `lsa_k = 20`, `rrf_c = 60` no `config.R` e na ficha (MAP_dev 0,350; MAP_teste 0,487; BM25 teste 0,496 - sem retocar)

## 2. Como o grupo trabalhou - opinião da tutora
Melhor sessão prática do bloco até aqui. Leram top-5 nos textos, não só MAP. Escolheram no dev com método (híbrido k=20 acima de BM25 e LSA puro) e só depois abriram o teste. Viram o BM25 um fio à frente no teste e mantiveram a regra - disciplina rara e correta. Decisão coletiva, `config.R` e ficha alinhados. Quem digitou conferiu SVD, dobra da consulta e RRF; o grupo fechou o modelo de produção com segurança.

## 3. Observações para a frente
- **Para a próxima sessão prática (Aula 08):** `config.R` com hibrido/lsa_k/rrf_c; ficha seção 6 coerente; demo multi-método
- **Perguntas guardadas:** diferença teste BM25 vs híbrido - significância (Aula 16)
- **Produzido:** ver a entrada "Aula 07" na linha do tempo da ficha do projeto
- **Ficha atualizada:** sim - seções alteradas: 5, 6, 7, cabeçalho

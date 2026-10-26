# Consolidado - PI III - Aula 03 - Parte D - 2026-09-30
*guia versão 3 · tutora: Cursor / Composer · sessão de grupo · motor03*
**Grupo:** Team Shannon · **presentes:** Adriane, Danilo, Victória · **digitou:** M10: Danilo · M11: Danilo · M12: Adriane

## 1. O que foi feito
- M10 - corpus limpo; decisão dos acentos: remover via `iconv` ASCII//TRANSLIT (fica no `config.R`)
- M11 - stopwords do projeto decididas olhando frequências (artigos/preposições no top; `porto`/`santos` mantidos como conteúdo)
- M12 - índice invertido do corpus; duas buscas AND explicadas pelas postagens (AND vazio em consultas longas das 3 perguntas - esperado)

## 2. Como o grupo trabalhou - opinião da tutora
Decisões de pré-processamento saíram do grupo com maturidade: discutiram acento vs transliteração e fecharam o que casa com consulta digitada. Lista de stopwords olhando frequência, sem cortar conteúdo por teimosia. Previram índice grande e conferiram. `config.R` editado sem travar. Quando o AND veio vazio nas três perguntas, ligaram sozinhos com a Aula 01 e o OR da demo - leitura fina, sem frustração. Pipeline do corpus ficou sólido.

## 3. Observações para a frente
- **Para a próxima sessão prática:** Parte D da Aula 04 - BM25 no corpus; comparar com cosseno
- **Perguntas guardadas:** nenhuma
- **Produzido:** ver a entrada "Aula 03" na linha do tempo da ficha do projeto
- **Ficha atualizada:** sim - seções alteradas: 4, 5, 6, 7 e cabeçalho

# =============================================================
# PI III - Motor de Busca - Atividade 00 / Aula 00 (1a entrega)
# Fatec Rubens Lara - Ciencia de Dados
# O basico para acompanhar o curso
# Blocos da aula: Explicar / Explorar / Prever
# =============================================================


# ------------------------------------------------------------
# Bloco 1. Atribuição e vetores
# ------------------------------------------------------------
v <- c(10, 20, 30, 40)  # c() = "combine": cria um vetor
v
sum(v)

v2 <- c(10, 20, 30, 40, 50)
v2
sum(v2)
mean(v2)


# ------------------------------------------------------------
# Bloco 2. Vetores nomeados
# ------------------------------------------------------------
notas <- c(ana = 8, bruno = 6, carla = 9)
notas
notas["bruno"]  # acesso pelo NOME, nao pela posicao

notas2 <- c(ana = 8, bruno = 6, carla = 9, danilo = 10)
notas2
notas2["danilo"]


# ------------------------------------------------------------
# Bloco 3. Trabalhando com texto
# ------------------------------------------------------------
frase <- "recuperacao de informacao"
toupper(frase)
strsplit(frase, " ")  # quebra em pedacos -> devolve uma LISTA

frase2 <- "PROJETO INTEGRADOR TRES"
tolower(frase2)
strsplit(frase2, " ")


# ------------------------------------------------------------
# Bloco 4. unlist: de lista para vetor
# ------------------------------------------------------------
unlist(strsplit(frase, " "))

frase3 <- "recuperacao   de    informacao"
unlist(strsplit(frase3, "\\s+"))


# ------------------------------------------------------------
# Bloco 5. Criando próprias funções
# ------------------------------------------------------------
dobro <- function(x) {
  x * 2  # a ultima expressao e o valor devolvido
}
dobro(7)

triplo <- function(x) {
  x * 3
}
triplo(7)


# ------------------------------------------------------------
# Bloco 6. Aplicando uma função a vários elementos - lapply
# ------------------------------------------------------------
palavras <- list(a = c("x","y","z"), b = c("p","q"))
lapply(palavras, length)

palavras2 <- list(a = c("x","y","z"), b = c("p","q"), c = c("m","n","o","p"))
lapply(palavras2, length)


# ------------------------------------------------------------
# Bloco 7. sapply: o mesmo, mas simplificado
# ------------------------------------------------------------
sapply(palavras, length)

sapply(palavras2, length)
lapply(palavras, length)


# ------------------------------------------------------------
# Bloco 8. Contando com table
# ------------------------------------------------------------
tokens <- c("de", "casa", "de", "rua")
table(tokens)  # conta as ocorrencias de cada valor

tokens2 <- c("de", "casa", "de", "rua", "de", "praia")
table(tokens2)


# ------------------------------------------------------------
# Bloco 9. factor: fixando as categorias
# ------------------------------------------------------------
vocab <- c("casa", "de", "rua", "praia")
table(factor(tokens, levels = vocab))

table(tokens)  # sem factor
tokens3 <- c("de", "casa", "de", "rua", "montanha")
table(factor(tokens3, levels = vocab))


# ------------------------------------------------------------
# Bloco 10. Matrizes
# ------------------------------------------------------------
m <- matrix(1:4, nrow = 2)
rownames(m) <- c("lin1", "lin2")
colnames(m) <- c("c1", "c2")
m

m2 <- matrix(1:9, nrow = 3)
rownames(m2) <- c("lin1","lin2","lin3")
colnames(m2) <- c("c1","c2","c3")
m2


# ------------------------------------------------------------
# Bloco 11. Operações úteis em matrizes
# ------------------------------------------------------------
peso <- c(2, 3)  # um peso por LINHA
m * peso  # reciclagem: multiplica linha a linha

peso3 <- c(2, 3, 4)
m * peso3


# ------------------------------------------------------------
# Bloco 12. Comparações e o operador %in%
# ------------------------------------------------------------
c("casa", "aviao") %in% vocab  # cada elemento esta em vocab?

c("praia","trem","casa") %in% vocab
t <- c("casa","de","aviao","rua")
stopwords <- c("de")
t[!t %in% stopwords]
sort(c(3,1,4,1,5), decreasing = TRUE)


# ------------------------------------------------------------
# Bloco 13. Regex na prática
# ------------------------------------------------------------
palavras13 <- c("casa", "cachorro", "praia", "cidade")
grep("^ca", palavras13, value = TRUE)   # comecam com "ca"?
grepl("a$", palavras13)                 # terminam em "a"?
sub("a", "@", "banana")                 # troca a PRIMEIRA ocorrencia
gsub("a", "@", "banana")                # troca TODAS

grep("a$", palavras13, value = TRUE)
grepl("^ci", palavras13)
sub("c", "K", "cachorro")
gsub("c", "K", "cachorro")


# ------------------------------------------------------------
# 1. O que acontece se você trocar sapply por lapply no exemplo? E o contrário?
# ------------------------------------------------------------
lapply(palavras, length)  # no lugar de sapply
sapply(palavras, length)  # o padrao do slide


# ------------------------------------------------------------
# 2. Em `table(factor(tokens, levels = vocab))`, o que muda se remover o factor?
# ------------------------------------------------------------
table(factor(tokens, levels = vocab))  # com factor
table(tokens)                          # sem factor


# ------------------------------------------------------------
# 3. Na reciclagem `m * peso`, o que acontece se peso tiver 3 elementos em vez de 2?
# ------------------------------------------------------------
peso3 <- c(2, 3, 4)
m * peso3


# ------------------------------------------------------------
# 4. Crie um vetor nomeado com 3 frases suas, tokenize e conte os termos
# ------------------------------------------------------------
frases <- c(
  f1 = "o porto de santos e o maior da america latina",
  f2 = "cubatao fica na baixada santista perto do porto",
  f3 = "o motor de busca organiza os textos do porto de santos"
)
tokens_list <- lapply(frases, function(x) unlist(strsplit(tolower(x), "\\s+")))
todos_tokens <- unlist(tokens_list)
sort(table(todos_tokens), decreasing = TRUE)


# ------------------------------------------------------------
# Vetor Base. Manchetes coletadas
# ------------------------------------------------------------
manchetes <- c(
  "Porto de Santos bate recorde em julho - A Tribuna",
  "cubatao registra melhora na qualidade do ar - A Tribuna",
  "Guaruja tera nova linha de onibus em 2026 - A Tribuna",
  "Sao Vicente inaugura escola no Parque Bitaru - A Tribuna",
  "Santos e Guaruja discutem travessia de balsa - A Tribuna"
)
manchetes


# ------------------------------------------------------------
# Missão 1. Remover o sufixo `" - A Tribuna"`
# ------------------------------------------------------------
limpas <- sub(" - A Tribuna$", "", manchetes)
limpas


# ------------------------------------------------------------
# Missão 2. Trocar dois ou mais espaços por um só
# ------------------------------------------------------------
suja <- "Porto   de  Santos    bate recorde"
gsub("\\s{2,}", " ", suja)


# ------------------------------------------------------------
# Missão 3. Anos (4 dígitos)
# ------------------------------------------------------------
grep("[0-9]{4}", limpas, value = TRUE)


# ------------------------------------------------------------
# Missão 4. Municípios (ignorando maiúsculas)
# ------------------------------------------------------------
grep("Guaruja|Cubatao", limpas, value = TRUE, ignore.case = TRUE)


# ------------------------------------------------------------
# Missão 5. A pegadinha (Porto vs Cidade)
# ------------------------------------------------------------
grepl("Santos", limpas)


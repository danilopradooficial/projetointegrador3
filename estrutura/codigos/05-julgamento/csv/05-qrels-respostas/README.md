# Respostas brutas do julgamento (exports do HTML)

Cada arquivo foi baixado de `05-julgar.html` → **Salvar votos**.

| Arquivo | Juiz | Linhas de voto |
|---|---|--:|
| `05-qrels-adriane-22.csv` | Adriane | 60 |
| `05-qrels-danilo-13.csv` | Danilo | 60 |
| `05-qrels-victoria-21.csv` | Victória | 60 |
| `05-respostas-consolidadas.xlsx` | equipe (auxiliar) | — |

**Não editar à mão** se puder evitar: regenere o consolidado com:

```bash
cd ..
Rscript 05e-consolidar-qrels.R
```

Isso grava `../05-qrels.csv` (gabarito único, 180 linhas).

Colunas de cada CSV: `consulta`, `documento`, `grau`, `juiz`, `timestamp`, `segundos`.

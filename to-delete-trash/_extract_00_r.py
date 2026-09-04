import re
from pathlib import Path

md_path = Path(r"c:\Projetos\ProjetoIntegrador3\consolidados\00-introducao-ao-r.md")
md = md_path.read_text(encoding="utf-8")

blocks = []
for m in re.finditer(r"```r\n(.*?)```", md, re.S):
    code = m.group(1).rstrip()
    before = md[: m.start()]
    headers = re.findall(r"(?m)^(#{1,3} .+)$", before)
    h = headers[-1].strip() if headers else "sem titulo"
    blocks.append((h, code))

out = []
out.append("# =============================================================")
out.append("# PI III - Motor de Busca - Atividade 00 / Aula 00 (1a entrega)")
out.append("# Fatec Rubens Lara - Ciencia de Dados")
out.append("# O basico para acompanhar o curso")
out.append("# Blocos da aula: Explicar / Explorar / Prever")
out.append("# =============================================================")
out.append("")

seen = set()
for h, code in blocks:
    # comment header once when it changes
    key = h
    if key not in seen or True:
        # always print section comment when header changes from previous
        pass

prev = None
for h, code in blocks:
    if h != prev:
        out.append("")
        out.append("# ------------------------------------------------------------")
        out.append("# " + h.lstrip("# ").strip())
        out.append("# ------------------------------------------------------------")
        prev = h
    out.append(code)
    out.append("")

text = "\n".join(out) + "\n"
dest = Path(r"c:\Projetos\ProjetoIntegrador3\estrutura\codigos\00-introducao-ao-r.R")
dest.write_text(text, encoding="utf-8", newline="\n")
print("wrote", dest, "blocks=", len(blocks), "lines=", text.count("\n"))

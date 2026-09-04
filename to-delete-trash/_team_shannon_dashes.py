from pathlib import Path

root = Path(r"c:\Projetos\ProjetoIntegrador3")
paths = (
    list((root / "consolidados").glob("*.md"))
    + [root / "README.md"]
    + list((root / "estrutura" / "codigos").glob("*.R"))
)

for path in paths:
    text = path.read_text(encoding="utf-8")
    orig = text
    text = text.replace("Shannon Ranking", "Team Shannon")
    text = text.replace("Shannon%20Ranking", "Team%20Shannon")
    text = text.replace("\u2014", "-")  # em dash —
    text = text.replace("\u2013", "-")  # en dash –
    if text != orig:
        path.write_text(text, encoding="utf-8", newline="\n")
        print("updated", path.relative_to(root))
    else:
        print("unchanged", path.relative_to(root))

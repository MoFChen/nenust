"""按教程的预览清单生成 _site/；某个版本编译失败时保留上一次可用的预览。"""

import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUTORIAL = ROOT / "examples/tutorial"
SITE = ROOT / "_site"


def main():
    variants = json.loads((TUTORIAL / "previews.json").read_text(encoding="utf-8"))
    catalog = []
    for name, variant in variants.items():
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or not variant["label"].strip():
            raise ValueError(f"无效的预览版本名或标签：{name!r}")
        catalog.append({"file": f"{name}.pdf", "label": variant["label"]})
    if not catalog:
        raise ValueError("预览清单为空")

    expected = {entry["file"] for entry in catalog}
    extra = {p.name for p in SITE.glob("*.pdf")} - expected
    if extra:
        raise SystemExit("请先移走 _site/ 中不在清单内的 PDF：" + ", ".join(sorted(extra)))

    SITE.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=SITE) as tmp:
        out = Path(tmp)
        for name in variants:
            print(f"==> {name}.pdf", flush=True)
            subprocess.run([
                "typst", "compile", "--root", ".", "--font-path", "template/assets/fonts",
                "--input", f"preview={name}", "examples/tutorial/main.typ", out / f"{name}.pdf",
            ], cwd=ROOT, check=True)

        if {p.name for p in out.glob("*.pdf") if p.stat().st_size} != expected:
            raise RuntimeError("生成的 PDF 与预览清单不符")
        shutil.copyfile(ROOT / "index.html", out / "index.html")
        (out / "pdf-versions.js").write_text(
            "window.NENU_PDF_VERSIONS = " + json.dumps(catalog, ensure_ascii=False) + ";\n",
            encoding="utf-8",
        )
        (out / ".nojekyll").touch()
        for artifact in out.iterdir():
            artifact.replace(SITE / artifact.name)

    print(f"已构建 {len(catalog)} 个预览版本：{SITE}")


if __name__ == "__main__":
    main()

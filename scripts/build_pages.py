"""生成 PDF、按页预览图和任意两份示例之间的页码索引。"""
import hashlib
from itertools import combinations
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

from page_diff import alignment, read_pages

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT/'_site'


def build(out, variants):
    images = out/'sheets'; images.mkdir()
    pages, cache, catalog = {}, {}, {}
    for key, options in variants.items():
        entry = options.get('entry', 'tutorial')
        if not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', key) or not options['label'].strip() or entry not in ('tutorial', 'empty'):
            raise ValueError(f'预览配置无效：{key}')
        pdf = out/(key+'.pdf')
        print(f'==> {pdf.name}', flush=True)
        cmd = ['typst', 'compile', '--root', '.', '--font-path', 'template/assets/fonts', '--creation-timestamp', '0']
        if entry == 'tutorial': cmd += ['--input', f'preview={key}']
        subprocess.run([*cmd, f'examples/{entry}/main.typ', pdf], cwd=ROOT, check=True)
        fingerprint = hashlib.sha256(pdf.read_bytes()).digest()
        if fingerprint not in cache: cache[fingerprint] = read_pages(pdf, images)
        pages[key] = cache[fingerprint]
        catalog[key] = dict(label=options['label'], group=options.get('group', '其他示例'), file=pdf.name,
                            pages=[[p.image, p.body, p.section] for p in pages[key]])
    pairs = {f'{a}|{b}': alignment(pages[a], pages[b]) for a, b in combinations(pages, 2)}
    manifest = json.dumps(dict(variants=catalog, pairs=pairs), ensure_ascii=False, separators=(',', ':'))
    (out/'pdf-versions.js').write_text('window.NENU_PREVIEW = '+manifest+';\n', encoding='utf-8')


def publish(out):
    shutil.copyfile(ROOT/'index.html', out/'index.html')
    shutil.copytree(ROOT/'pages', out/'pages')
    (out/'.nojekyll').touch()
    sheets = {p.name for p in (out/'sheets').iterdir()}
    for folder in ('sheets', 'pages'):
        (SITE/folder).mkdir(exist_ok=True)
        for f in (out/folder).iterdir(): f.replace(SITE/folder/f.name)
    for f in [*out.glob('*.pdf'), out/'.nojekyll', out/'pdf-versions.js', out/'index.html']:
        f.replace(SITE/f.name)
    for f in (SITE/'sheets').glob('*.webp'):
        if re.fullmatch(r'[0-9a-f]{24}\.webp', f.name) and f.name not in sheets: f.unlink()


def main():
    variants = json.loads((ROOT/'examples/tutorial/previews.json').read_text(encoding='utf-8'))
    if not variants: raise ValueError('预览清单为空')
    extra = {p.stem for p in SITE.glob('*.pdf')} - variants.keys()
    if extra: raise SystemExit('请先移走 _site/ 中不在清单内的 PDF：'+'，'.join(sorted(extra)))
    SITE.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=SITE) as tmp:
        out = Path(tmp); build(out, variants); publish(out)
    print(f'已生成 {len(variants)} 份示例：{SITE}')


if __name__ == '__main__':
    main()

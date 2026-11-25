"""对齐物理页：正文和书签决定对应关系，渲染像素决定有无视觉差异。"""
from dataclasses import dataclass
from difflib import SequenceMatcher
from hashlib import sha256
from itertools import groupby
import zlib

import pypdfium2 as pdfium


@dataclass
class Page:
    image: str
    body: str
    section: str
    anchor: str
    words: frozenset


def digest(image):
    h = sha256(str(image.size).encode())
    h.update(image.tobytes())
    return h.hexdigest()[:24]


def front_section(text, landscape):
    if landscape: return '外封面'
    if '独创性声明' in text: return '独创性声明'
    if '学位论文评阅专家' in text: return '委员会名单'
    if 'schoolcode' in text or 'dissertation' in text or 'thesis' in text and 'university' in text: return '英文封面'
    return '中文封面'


def read_pages(path, images):
    pages = []
    with pdfium.PdfDocument(path) as doc:
        chapters = {}
        for bookmark in doc.get_toc():
            dest = bookmark.get_dest()
            if bookmark.level == 0 and dest is not None:
                chapters[dest.get_index()] = bookmark.get_title().strip()
        chapter = ''
        for i, page in enumerate(doc):
            chapter = chapters.get(i, chapter)
            w, h = page.get_size()
            textpage = page.get_textpage()
            text = ''.join(textpage.get_text_bounded(0, h*.065, w, h*.91).lower().split())
            textpage.close()
            bitmap = page.render(scale=1.7)
            image = bitmap.to_pil().convert('RGB')
            bitmap.close(); page.close()
            key = digest(image)
            target = images/(key + '.webp')
            if not target.exists():
                image.save(target, format='WEBP', quality=90, method=3)
            iw, ih = image.size
            core = digest(image.crop((0, round(ih*.09), iw, round(ih*.935))))
            section = chapter or front_section(text, w > h)
            if not text and image.convert('L').getextrema() == (255, 255): section = '空白页'
            sample = frozenset(sorted({zlib.crc32(text[j:j+5].encode()) for j in range(max(0,len(text)-4))})[:48])
            pages.append(Page(key, core, section, text if len(text) >= 12 else key, sample))
    if not pages: raise ValueError(f'{path} 没有页面')
    return pages


def align_gap(a, b):
    """只在同名章节内配对改版页；允许跳过一侧，避免插页拉偏后续对应关系。"""
    n, m = len(a), len(b)
    score = [[0.0] * (m+1) for _ in range(n+1)]
    steps = [[''] * (m+1) for _ in range(n+1)]
    for i, x in enumerate(a, 1):
        for j, y in enumerate(b, 1):
            shared = len(x.words & y.words) / max(1, len(x.words | y.words))
            weight = 4 if x.image == y.image else (1 + shared * 2 if x.section == y.section else -1)
            score[i][j], steps[i][j] = max((score[i-1][j], 'A'), (score[i][j-1], 'B'),
                                           (score[i-1][j-1] + weight, 'M'))
    ops = []
    while n or m:
        step = 'A' if not m else 'B' if not n else steps[n][m]
        ops.append(step)
        n -= step != 'B'; m -= step != 'A'
    return ops[::-1]


def alignment(a, b):
    keys = lambda pages: [(p.section, p.anchor) for p in pages]
    ops = []
    for tag, i, ii, j, jj in SequenceMatcher(None, keys(a), keys(b), autojunk=False).get_opcodes():
        if tag == 'equal': ops.extend('M' * (ii-i))
        elif tag == 'delete': ops.extend('A' * (ii-i))
        elif tag == 'insert': ops.extend('B' * (jj-j))
        else: ops.extend(align_gap(a[i:ii], b[j:jj]))
    assert len(ops) - ops.count('B') == len(a) and len(ops) - ops.count('A') == len(b)
    return ''.join(f'{len(list(run))}{op}' for op, run in groupby(ops))

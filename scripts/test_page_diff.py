"""页码映射须保留插页，并让修改后的对应页在两侧继续对齐。"""
import unittest
from page_diff import Page, alignment


def page(section, text):
    return Page(text, text, section, text, frozenset(text))


class PageAlignment(unittest.TestCase):
    def test_inserted_blank_and_changed_chapter(self):
        cover, blank, end = page('封面', '封面'), page('空白页', ''), page('附录', '附录')
        left = [cover, page('正文', '学术学位'), end]
        right = [cover, blank, page('正文', '专业学位'), end]
        self.assertEqual(alignment(left, right), '1M1B2M')
        self.assertEqual(alignment(right, left), '1M1A2M')

    def test_removed_cover_does_not_shift_later_pages(self):
        body = [page('摘要', '中文摘要'), page('目录', '目录')]
        self.assertEqual(alignment([page('外封面', '书脊'), *body], body), '1A2M')

#let page-declaration(body) = {
  set par(first-line-indent: (amount: 2em, all: true), leading: 1em, spacing: 1em)
  set rect(width: 466pt)

  let hline = "_" * 13
  let func_title(x) = text(size: 16pt, weight: "bold", x)
  let func_text(x) = rect(stroke: none, align(left, text(baseline: 0pt, x)))

  place(center + top, dy: 2pt, rect(height: 672pt))
  place(center + top, dy: 44pt, func_title("独创性声明".clusters().join([#h(1em)])))
  place(center + top, dy: 69pt, func_text([#parbreak()本人郑重声明：所提交的学位论文是本人在导师指导下独立进行研究工作所取得的成果。据我所知，除了特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果。对本人的研究做出重要贡献的个人和集体，均已在文中作了明确的说明。本声明的法律结果由本人承担。
  ]))
  place(left + top, dx: 21pt, dy: 190pt, [论文作者签名：#hline#h(48pt)日#h(4em)期：#hline])
  place(center + top, dy: 357.5pt, func_title("学位论文使用授权书"))
  place(center + top, dy: 383pt, func_text([#parbreak()本学位论文作者完全了解东北师范大学有关保留、使用学位论文的规定，即：东北师范大学有权保留并向国家有关部门或机构送交学位论文的复印件和电子版，允许论文被查阅和借阅。本人授权东北师范大学可以将学位论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或其它复制手段保存、汇编本学位论文。#parbreak()（保密的学位论文在解密后适用本授权书）]))
  place(left + top, dx: 21pt, dy: 529pt, [论文作者签名：#hline#h(48pt)指导教师签名：#hline])
  place(left + top, dx: 21pt, dy: 553pt, [日#h(4em)期：#hline#h(48pt)日#h(4em)期：#hline])

  body
}
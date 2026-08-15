= Typst 简介

Typst 是一款基于标记语言的现代排版系统。它由 Rust 语言编写，旨在提供足以媲美 LaTeX 的排版质量，但同时具备更简洁的语法、极快的编译速度以及现代化的编程接口。

#figure(
  image("imgs/typst.png", width: 100%),
  caption: [Typst 标记源码与实时预览],
) <fig-typst-preview>

Typst 的*核心设计哲学*是：

· *高性能*：利用增量编译技术，实现近乎实时的预览更新。

· *易用性*：语法类似于 Markdown，降低用户的入门门槛。

· *编程性*：用户可以像写 Python 或 JavaScript 一样编写排版逻辑。

与 Word 的直接视觉编辑不同，Typst 将内容和排版规则保存在纯文本源码中，便于搜索、复用和版本控制；与 LaTeX 相比，Typst 的常用语法更短，编译反馈更快。学院归档若明确要求 Word 源文件，仍应优先遵守学院要求。

== 三种输入模式

Typst 主要在三种模式之间切换：普通正文默认处于标记模式，`#` 进入代码模式，`$` 进入数学模式。

#figure(
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([模式], [入口], [常见用途]),
    table.hline(stroke: 0.5pt),
    [标记模式], [直接输入正文], [标题、段落、列表和强调],
    [代码模式], [`#函数(...)`], [配置、导入、图片、表格和逻辑],
    [数学模式], [`$x^2$`], [行内公式与独立公式],
    table.hline(stroke: 1.2pt),
  ),
  caption: [Typst 的三种输入模式],
)

== 参考资料

Typst 社区已经初具规模。本文部分内容来自以下网站，用户也可从以下网站获取关于 Typst 的信息。

/ Typst 官方教程: https://typst.app/docs/
/ Typst Examples Book: https://sitandr.github.io/typst-examples-book/book/
/ Awesome Typst: https://github.com/qjcg/awesome-typst/
/ Typst 中文教程: https://typst-doc-cn.github.io/tutorial/
/ Typst 中文社区导航: https://typst-doc-cn.github.io/guide/
/ Typst 中文排版的差距: https://typst-doc-cn.github.io/clreq/

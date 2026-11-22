= Typst 简介

Typst 是开源的文档排版系统。用它写论文时，保存的是一份可以阅读的 `.typ` 文本：用标题标记说明“这里开始一节”，用公式和图表元素说明“这里需要编号”。编译器结合排版规则决定这些内容在页面上的位置，生成供阅读和打印的 PDF。

#figure(
  image("imgs/typst.png", width: 100%, alt: "Typst 标志，背景为排版后的电磁学公式"),
  caption: [Typst 标志与数学公式排版示意],
) <fig-typst-preview>

== 谁在编辑，谁在排版

在 Word 中可以直接选中一行，把它改成大号粗体；这不一定会让它成为目录中的标题。在 Typst 中写 `= 研究方法`，得到的是一个一级标题。字号、编号和是否进入目录可以分别控制。给标题加上标签并引用它，移动整节时，引用处的节号也会自动更新。

编辑器负责修改源码，编译器负责读取入口文件及它引用的章节、图片和文献，预览窗口负责显示结果。可以在 Typst 网页编辑器里体验这套过程，也可以在本地用文本编辑器和 Typst CLI 完成。`typst compile` 生成一次输出；`typst watch` 则保持运行，源文件变动后复用已有的编译结果，更新 PDF。保存源码和查看更新后的 PDF 是两步；阅读器若没有自动刷新，需要重新打开文件。

== 怎样读一段 Typst 源码

普通句子直接写。遇到有特殊含义的符号，先判断当前处在哪种模式：

#figure(
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([模式], [示例], [这段内容的作用]),
    table.hline(stroke: 0.5pt),
    [标记], [`= 研究方法`], [建立一级标题；空行分隔正文段落],
    [代码], [`#let kept = 9`], [给数值命名；在正文中写 `#kept` 取值],
    [数学], [`$x^2$`], [排出行内公式；`$ x^2 $` 单独成行],
    table.hline(stroke: 1.2pt),
  ),
  caption: [同一源文件中的三种模式],
)

`#` 从标记或数学模式引入*一个*代码表达式，不会让余下整段都变成代码。反过来，代码中的方括号可以承载带格式的正文，例如 `#align(center)[测量结果]`：`align` 是函数，`center` 指定位置，`[测量结果]` 是被排版的内容。

== 动手：改一个数，看两处变化

把下面的示例保存为仓库根目录的 `hello.typ`。它可以独立编译，不需要论文封面或配置文件。

```typst
#set text(font: "SimSun", lang: "zh")
#set heading(numbering: "1.")
#let total = 12
#let kept = 9

= 样本筛选 <sec-samples>
在 #total 个样本中保留了 #kept 个，保留率为
$kept/total = #(100 * kept / total)%$。

= 讨论
筛选过程见 @sec-samples。
```

在同一目录运行 `typst compile --font-path template/assets/fonts hello.typ`，打开生成的 `hello.pdf`。把 `kept` 从 9 改为 6，再编译：句子里的保留数变为 6，公式里的保留率也由 75% 变为 50%。再试着在“样本筛选”之前插入 `= 引言`：“讨论”中的引用会随节号更新。尖括号里的标签标记引用目标，不会印在纸面上。

== 这些写法怎样用到论文里

示例中的 `#set heading(numbering: "1.")` 为后续标题设置默认编号。论文模板还用 `show` 规则控制元素如何呈现。打开 `examples/empty/main.typ` 可以看到 `#show: nenu-template.with(config, information)`：这条规则把后续正文交给模板，由模板加上封面、目录和章内编号。因此写自己的论文时，保留普通标题和标签即可，不必把上例的编号规则复制到每一章。

同一个入口还在论文模板之前调用了 `init-bibliography`。这是 nenust 随附的 bibst 文献模块在读取 `.bib` 数据；上例中的 `@sec-samples` 指向已标记的标题，而 `@jiangfei2020a` 这样的文献键则要在数据库中有对应条目。引用的是两类不同对象，写法都不需要手工输入序号。

要搭建本地环境，接着读@chapter-02；已有可编译的论文，需要查段落、列表或脚注的写法，可直接读@sec-writing。想进一步学习语法，可跟着#link("https://typst.app/docs/tutorial/")[Typst 官方教程]做练习；要查某个函数接受哪些参数，使用#link("https://typst.app/docs/reference/")[官方参考手册]。中文读者还可查阅#link("https://typst-doc-cn.github.io/tutorial/")[Typst 中文教程]。

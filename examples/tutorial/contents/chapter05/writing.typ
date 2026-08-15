#import "/template/config/fonts.typ": *
#import "../../utils.typ": *

#import "@preview/cuti:0.4.0": fakebold

= 组织和撰写正文 <sec-writing>

本章介绍论文写作所需的 Typst 标记模式，并说明哪些样式应交给模板统一处理。

== 标题层级

Typst 使用等号表示标题层级。模板仅为一级至四级标题提供了论文样式，如下@fig-chapter-style 所示。

#figure(
  caption: [标题样式],
  grid(
    columns: 3,
    column-gutter: 1em,
    rows: 200pt,
    align: center + horizon,
    image("imgs/guide-2.png"),
    [$|=>$],
    image("imgs/guide-1.png")
  )
) <fig-chapter-style>

不要在标题文字中手写“第一章”或“1.1”，编号由模板统一生成。新增、删除或移动标题后，后续编号和目录会自动更新。五级及更深标题没有学校模板样式，通常应通过调整内容结构避免使用。

== 段落与换行

在 Typst 中，没有被空行隔开的文本属于同一段，源码中的普通换行会被视作空格（若是要删除这个空格可以使用cjk-unbreak包）。空行或 `parbreak()` 开始新段落；反斜杠用于同一段内的强制换行。

#figure(
  caption: [标记模式下的段落与换行],
  kind: image,
  typst-code-example(```typst
  #set par(first-line-indent: (amount: 2em, all: true))
  谁还有多余
  资金。

  我要验牌。

  同段内强制换行。\ 紧接上一行。

  你说得对，#parbreak()但是  Typst  是一款...
  ```)
) <fig-parbreak>

不要在每段开头手工输入空格，也不要连续插入空行来调整页面位置。模板会统一处理首行缩进和段间距。

== 列表

Typst 中的列表包含有序列表和无序列表，两者默认都不使用正文首行缩进。

*有序列表*：使用加号\+或数字和点号后跟空格和列表项。

+ 如果使用加号，那么列表项前的数字由 Typst 自动编号；
+ 它会接续同一列表中的自动编号；
9. 使用数字和点号组合可以指定起始编号；
+ 如果在数字点号组合后面使用加号，编号将自动增加。

/* 使用 pagebreak 可以将内容强制切换到下一页，
   避免某些内容的不连续造成不好的阅读体验。 */
/* #pagebreak() */

*无序列表*：使用短横线\-后跟空格和列表项。使用两个空格缩进表示子项。例如：

- 第一项
  - 子项
    - 子项
- 第二项

== 粗体 <sec-font-fakebold>

使用星号包裹文本会渲染成粗体。例如，\*重要内容\*会渲染为*重要内容*。

需要注意的是，仓库附带的宋体、黑体只有单级字重，因此模板通过 cuti 包把粗体中文转换为描边的*伪粗体*。该全局规则会匹配中文文本及部分中文标点，不只影响宋体和黑体；即使指定微软雅黑，`weight: "bold"` 的中文示例也会被规则转换为描边。*描边不等于字体原生粗体！*

以下以 Times New Roman 和微软雅黑展示模板中的常规字重、`weight: "bold"` 以及显式描边。Times New Roman 的粗体使用字体字重，中文粗体则会经过模板的伪粗体规则。

#figure(
  caption: [Times New Roman 与微软雅黑在模板粗体规则下的对比],
  kind: image,
  grid(
    columns: 3,
    column-gutter: 1em,
    align: center + horizon,
    [常规字重：],
    text(font: FONT_TIMES, size: 42pt, weight: "regular", "ABC123"),
    text(font: FONT_YAHEI, size: 42pt, weight: "regular", "微软雅黑"),
    [`weight: "bold"`：],
    text(font: FONT_TIMES, size: 42pt, weight: "bold", "ABC123"),
    text(font: FONT_YAHEI, size: 42pt, weight: "bold", "微软雅黑"),
    [显式描边：],
    fakebold(text(font: FONT_TIMES, size: 42pt, "ABC123")),
    fakebold(text(font: FONT_YAHEI, size: 42pt, "微软雅黑"))
  )
)

== 斜体

斜体能否生效取决于字体家族中是否存在可用的斜体字形。仓库附带的中文字体和 Times New Roman 文件并未覆盖所有斜体字形，系统字体环境不同也可能产生不同结果。

但 Typst 是支持斜体的；系统已安装 Roboto Mono 时，可得到斜体样式 #text(font: "Roboto Mono")[_ABC123_]。仓库未附带该字体，其他环境可能回退到不同字体。

== 下划线

文本内容使用 `#underline[...]` 增加下划线；数学模式使用 `$underline(...)$`。`sym` 是 Typst 的内置符号模块，不是社区包，具体用法见#ref(<sec-math-symbol>)。

#figure(
  caption: [下划线示例],
  kind: image,
  typst-code-example(```typst
  吃#underline()[猕Hotel #sym.alpha]？
  数学下划线：$underline(alpha)$
  ```)
)

== 注释

注释用于在论文源码中添加说明，不会渲染到最终文档中。Typst 支持单行和块注释；本教程源码统一使用 \/\* 注释 \*\/ 块注释，并将其作为仓库后续修改应遵守的写法。例如：

#figure(
  caption: [注释示例],
  kind: image,
  typst-code-example(```typst
  说话！
  /* 吃吧。
     从从容容，游刃有余，
     不要匆匆忙忙、连滚带爬。 */
  ```)
)

== 转义

若要显示 \*、\_、\= 这类“会触发语法”的字符时，可通过在字符前加一个反斜杠进行转义。

#figure(
  caption: [字符转义示例],
  kind: image,
  typst-code-example(```typst
  \* \= \_ \= \# 呃 \~
  ```)
)

== 原始文本

如果使用 \` 包裹文本，Typst 则会使用等宽字体来渲染文本，此时多个空格将不会被合并，换行也不会被替换为一个空格，特殊字符也无需转义。

#figure(
  caption: [原始文本(raw)示例],
  kind: image,
  typst-code-example(```typst
`= Shawarma Legend  萨威玛传奇 _ *`
```)
)

== 脚注

脚注代码 `#footnote[补充说明]`。模板为正文及其后的页面设置页眉，并在该作用域内逐页重置脚注编号；摘要、目录等更早的前置内容不在这条重置规则内。不要手工输入圈码或在正文中模拟脚注线#footnote[这是一个脚注]。

== 标签与交叉引用 <sec-labels>

在需要引用的元素后添加唯一标签：

#figure(
  caption: [标签与交叉引用代码示例],
  kind: image,
  ```typst
  == 实验设计 <sec-experiment>
  #figure(
    caption: [图题],
    rect(width: 3cm, height: 1.5cm, fill: luma(230)),
  ) <fig-workflow>
  $ E = m c^2 $ <eq-objective>
  == 小结
  实验设计见 @sec-experiment，实验流程见 @fig-workflow，评价函数见 @eq-objective。
  ```
)

标签建议使用统一前缀：章节用 `sec-`，图片用 `fig-`，表格用 `tab-`，公式用 `eq-`。引用时写 `@标签`，Typst 会自动计算编号并添加前缀、后缀。例如，本小节可以直接引用为 @sec-labels。除了使用 `@标签` 方式引用以外，也可以通过 `#ref(<标签>)` 命令来引用，如#ref(<sec-writing>)。当前社科模式的二级及以下标题显示“一、”“（一）”等格式，但标题引用仍使用阿拉伯数字路径并追加“小节”；正式使用社科模式时应核对引用文字。

== 样式边界

普通论文内容不应重复设置全局字体、页边距、标题编号和页眉页脚。这些由模板控制。局部确有需要时，将样式限制在内容块中：

#figure(
  caption: [样式边界代码示例],
  kind: image,
  typst-code-example(```typst
  #block[
    #set par(first-line-indent: 0em)
    首行不缩进。

    #block[
      #set par(first-line-indent: (amount: 2em, all: true))
      这里首行缩进。

      这里也缩进。
    ]
    还是不缩进。
  ]
  ```)
)

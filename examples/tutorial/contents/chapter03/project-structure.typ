= 项目结构与编译流程

== 项目结构

建议保持以下最小结构：

#figure(
  caption: [最小目录结构],
  table(
    columns: 2, align: horizon + left,
    table.hline(stroke: 1.2pt),
    "目录结构", "解释",
    table.hline(stroke: 0.5pt),
    "nt3/",                   "",
    "├ assets/",              "模板使用的字体和学校标志",
    "├ template/",            "模板实现，普通写作通常不修改",
    "└ examples/",            "",
    "  ├ empty/",             "空论文项目，模板使用最小示例",
    "  ├ tutorial/",          "该模板使用教程的项目代码",
    "  └ my-thesis/",         "实际论文项目，可任取名称",
    "    ├ assets/",          "论文的图片和数据",
    "    ├ contents/",        "论文各章节",
    "    ├ main.typ",         "配置、元数据和章节装配入口",
    "    └ references.bib",   "参考文献数据库",
    table.hline(stroke: 0.5pt),
  )
)

`main.typ` 是用户入口；`template/nenu-template.typ` 是模板入口。论文内容应放在自己的示例目录中，模板样式调整才进入 `template`。这样升级内容与排查样式时不会混在一起。

== 模板生成顺序

`#show: nenu-template.with(config, info)` 只接管它之后的内容。完整输出分为三部分：

· 模板生成的前置内容：由 `showCover` 控制的 A3 外封面、A4 中英文信息页、委员会页、声明页、摘要和全文目录，以及由三个 `show...` 开关控制的插图目录、附表目录和缩略语说明；

· 用户正文：章节由 `main.typ` 按顺序加载，参考文献、附录和后记由 `nenu-back-matter` 统一装配；

· 模板追加的后置内容：成果与获奖页，以及博士模式下的导师评语和答辩委员会决议页。

因此，不要在 `#show` 之前写正文章节，也不要误以为模板会自动寻找参考文献或附录文件。

== 拆分章节

在 `main.typ` 中保留配置，然后按阅读顺序装配章节。下例中的章节文件需要先在 `contents` 目录中创建：

#figure(
  caption: [`main.typ` 入口文件的章节加载顺序],
  kind: image,
  ```typst
  // 文献引擎和论文模板分别接管后续内容
  #show: init-bibliography.with(
    read("references.bib"),
    style: "numeric",
    show-url: false,
    show-online: false,
    show-doi: false,
    show-accessed: false,
    show-backlinks: false,
  )
  #show: nenu-template.with(config, info)
  // 加载章节
  #include "contents/01-introduction.typ"
  #include "contents/02-method.typ"
  #include "contents/03-experiments.typ"
  #include "contents/04-conclusion.typ"
  // 参考文献、附录和后记
  #nenu-back-matter(
    appendices: [
      = 补充材料
      这里撰写附录内容。
    ],
  )[
    = 后记
  ]
  ```
)

每个章节文件直接从一级标题开始：

#figure(
  caption: [章节文件源码示例],
  kind: image,
  ```typst
  = 绪论
  这里撰写研究背景、研究问题和论文结构。
  == 研究背景
  这里撰写小节内容。
  ```
)

== 路径、include 与 import

相对路径以写出该路径的 `.typ` 文件为起点。例如，`contents/01-introduction.typ` 中的 `../assets/imgs/typst.png` 指向论文目录下的图片。以 `/` 开头的路径从 `--root` 指定的项目根目录解析，因此模板导入写作 `/template/nenu-template.typ`。

`include` 将另一个文件的可排版内容插入当前位置；`import` 则导入函数、变量等定义：

#figure(
  caption: [路径解释],
  kind: image,
  ```typst
  // 先创建该文件，再通过 include 插入其内容
  #include "contents/01-introduction.typ"
  #import "/template/nenu-template.typ": nenu-template
  ```
)

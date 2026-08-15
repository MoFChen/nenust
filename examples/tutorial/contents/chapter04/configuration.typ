= 论文类型与信息配置

== 模板配置开关

#figure(
  caption: [模板配置开关],
  table(
    columns: 2,
    table.hline(stroke: 1.2pt),
    table.header([字段],[解释]),
    table.hline(stroke: 0.5pt),
    [`anonymous`],[是否隐藏作者、导师、学科及评审人员信息],
    [`double-sided`],[是否按双面打印要求插入分页],
    [`isThesis`],[`true` 为硕士论文，`false` 为博士论文],
    [`isAcademic`],[`true` 为学术型，`false` 为专业型],
    [`showCover`],[是否显示 A3 外封面],
    [`showIllustrationCatalog`],[是否显示插图目录],
    [`showTablesCatalog`],[是否显示附表目录],
    [`showAbbreviationsList`],[是否显示符号和缩略语说明],
    table.hline(stroke: 1.2pt),
  ),
) <tab-template-config>

`anonymous: true` 会清空模板页面中的作者、导师、学科和评审人员信息，并清空 PDF 作者元数据，但匿名检查不能只依赖这一开关。标题、关键词、正文、图片、文件名、致谢、成果、博士评语、决议和参考文献自引仍可能泄露身份。

常见学位类型组合如下：

#figure(
  caption: [学位类型组合],
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([论文类型],[`isThesis`],[`isAcademic`]),
    table.hline(stroke: 0.5pt),
    [学术型硕士], [`true`],  [`true`],
    [专业型硕士], [`true`],  [`false`],
    [学术型博士], [`false`], [`true`],
    [专业型博士], [`false`], [`false`],
    table.hline(stroke: 1.2pt),
  ),
)

== 基本信息

`info` 中可修改的字段包括：

#figure(
  caption: [`info` 配置字段解释],
  table(
    columns: 2,
    table.hline(stroke: 1.2pt),
    table.header([字段],[解释]),
    table.hline(stroke: 0.5pt),
    [`cover`], [封面信息，一般不作修改],
    [`title`], [中英文论文题目],
    [`author`], [中英文姓名和学号],
    [`supervisors`], [可以填写一位或多位导师],
    [`subjects`], [学术型对应一级、二级学科，专业型对应学位类别、领域],
    [`date`], [日期，使用 `datetime(year: ..., month: ..., day: ...)`],
    [`reviewer`], [学位论文评阅专家信息],
    [`committee`], [答辩委员会人员信息],
    [`abstract`], [中英文摘要],
    [`keywords`], [中英文关键词数组],
    [`abbreviations`], [符号与缩略语说明],
    [`achievements`], [成果],
    [`award`], [获奖],
    [`comments`], [评语],
    table.hline(stroke: 1.2pt),
  ),
)

中英文内容应一一对应。英文姓名、题目和学科名称应使用学院认可的正式译法。标题中的简单符号优先直接写 Unicode；复杂公式使用可选的 `display_zh`、`display_en` 内容字段。`zh`、`en` 都必须保留纯文本，其中 `zh` 还用于 PDF metadata 和博士 A3 书脊。

显示开关只控制页面是否渲染，不会让 `info` 字段变成可选项。始终保留 `examples/empty/empty.typ` 中的完整结构；无数据时使用空字符串或空数组 `()`。

== 评阅人与委员会

#figure(
  caption: [评阅人与委员会代码示例],
  kind: image,
  ```typst
  // 学位论文评阅专家信息
  reviewer: (
    (name: "评阅专家甲", title: "示例大学/教授", comment: "优秀"),
    (name: "评阅专家乙", title: "示例大学/教授", comment: "良好"),
    (name: "", title: "", comment: ""),   // 不能直接删除，留空即可不显示
    (name: "", title: "", comment: ""),   // 总数必须为 5 个
    (name: "", title: "", comment: ""),
  ),
  // 答辩委员会人员信息
  committee: (
    (name: "答辩主席",   work: "示例大学", title: "教授"),
    (name: "答辩委员甲", work: "示例大学", title: "教授"),
    (name: "答辩委员乙", work: "示例大学", title: "副教授"),
    (name: "", work: "", title: ""),      // 不能直接删除，留空即可不显示
    (name: "", work: "", title: ""),      // 总数必须为 7 个
    (name: "", work: "", title: ""),
    (name: "", work: "", title: ""),
  ),
  ```
)

当前委员会页面采用固定表格布局。`reviewer` 应保留 5 个字典，`committee` 应保留 7 个字典；暂时没有信息的条目将各字段留空，不要删除整个条目，否则会引起模板信息匹配错误。

`committee` 第一项固定显示为主席，其余 6 项显示为委员；`reviewer.title` 对应“工作单位/职称”合并列，需要时应同时填写单位和职称。

== 摘要与关键词

摘要内容可以通过 `include` 命令导入，或者通过 `[]` 启用标记模式直接写下内容。以上两种方式可以支持命令模式、数学模式。除此之外也可以使用 `""` 输入纯文本。

#figure(
  caption: [摘要内容代码示例],
  kind: image,
  ```typst
  abstract: (
    zh: include "contents/abstract-zh.typ",     // include 命令载入
    en: [NENU thesis Typst template. $theta$],  // 标记模式
    // en: "NENU thesis Typst template.",       // 纯文本
  )
  ```
)

上述内容写法只适用于摘要等明确允许可排版内容的字段。*姓名*、*学号*、*封面信息*和*导师记录*会参与字符串拼接或格式化，必须使用字符串。

关键词使用数组进行配置：

#figure(
  caption: [关键词代码示例],
  kind: image,
  ```typst
  keywords: (
    zh: ("Typst", "学位论文", "论文模板", [$theta$]),
    en: ("Typst", "graduate thesis", "thesis template", [$theta$]),
  ),
  ```
)

中英文关键词的数量、含义和顺序应对应，分隔符由模板自动生成。关键词可以包含数学等可排版内容；PDF 元数据只会收录其中的字符串条目，不能保存富文本或公式。

一般来说，中英文摘要建议各自放在独立文件中，并在 `main.typ` 中通过 `include` 读取为内容。摘要文件只写摘要正文，不需要添加“摘要”标题，模板会自动生成标题和关键词行。

== 目录与缩略语

模板自动生成全文目录、插图目录、附表目录以及符号和缩略语说明。标题、图片和表格只有使用标准 `heading` 与 `figure` 元素，才会被相应目录索引。

若不需要插图目录、附表目录以及符号和缩略语说明，可通过@tab-template-config 所示配置单独关闭渲染。

而缩略语通过 `info.abbreviations` 提供，可以是普通文本或数学内容：

#figure(
  caption: [符号和缩略语说明代码示例],
  kind: image,
  ```typst
  abbreviations: (
    (abbr: "PDF", description: "便携式文档格式"),
    (abbr: $sigma$, description: "标准差"),
  ),
  ```
)

== 参考文献、附录和后记

`nenu-back-matter` 会输出无编号的参考文献，把 `appendices` 中的一级标题自动编号为“附录A”“附录B”并按 `A.1.1.1` 编排小节，最后排版无编号的后记；文献引擎参数见@chapter-bibliography。

#figure(
  caption: [参考文献、附录和后记装配示例],
  kind: image,
  ```typst
  // 前面已按文献章节设置模板和文献引擎
  // 以下章节文件需先在 contents 目录中创建
  #include "contents/01-introduction.typ"
  #include "contents/02-method.typ"
  #include "contents/03-experiments.typ"
  #include "contents/04-conclusion.typ"
  #nenu-back-matter(
    appendices: [
      = 补充实验
      这里撰写补充实验。
    ],
  )[
    = 后记
    这里撰写后记。
  ]
  ```
)

== 成果、获奖与博士页面

`achievements` 和 `award` 由模板放在用户正文之后。成果记录字段包括名称、类别、刊物或出版社、时间和作者次序。没有获奖内容时必须使用空数组 `()` 才不会输出获奖内容。

#figure(
  caption: [成果与获奖配置示例],
  kind: image,
  ```typst
  // 在学期间取得成果
  achievements: (
    (
      title: "学位论文 Typst 模板的设计与实践",
      type: "学术论文",
      journal: "示例期刊",
      date: [2025年#parbreak()第12卷],   // 内容块可控制单元格内换行
      author: "1",
    ),
    (
      title: "学位论文 Typst 模板的设计与实践",
      type: "学术论文",
      journal: "示例期刊",
      date: "2025年07月",   // 也支持纯文本格式
      author: "1",
    ),
  ),
  // 参加的研究项目及获奖情况
  award: (
    "第一届全国大学生光电设计大赛东北赛区一等奖",
    "第一届全国大学生光电设计大赛国家一等奖",
    "其他获奖奖项",
  ),
  // 没有获奖内容必须使用空数组，如下
  // award: (),
  ```
)

博士模式还会根据 `comments.supervisors` 和 `comments.committee` 分别生成导师评语与答辩委员会决议页；硕士模式不会输出这两页。正式提交前仍需核对两页内容和版式。

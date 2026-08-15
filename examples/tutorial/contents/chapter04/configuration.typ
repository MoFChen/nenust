= 论文类型与信息配置

== 模板配置开关

#figure(
  caption: [模板配置开关],
  table(
    columns: 2,
    table.hline(stroke: 1.2pt),
    table.header([字段],[解释]),
    table.hline(stroke: 0.5pt),
    [`anonymous`],[隐藏封面等页面中的作者、导师和学科信息；评审页例外见下文],
    [`double_sided`],[是否按双面打印要求插入分页],
    [`degree_level`],[`"master"` 为硕士，`"doctoral"` 为博士],
    [`degree_type`],[`"academic"` 为学术型，`"professional"` 为专业型],
    [`discipline_group`],[`"science"` 为理工科编号，`"social"` 为社科编号],
    [`include_outer_cover`],[是否显示 A3 外封面],
    [`include_list_of_figures`],[是否显示插图目录],
    [`include_appendix_figures`],[插图目录是否收录附录图片],
    [`include_list_of_tables`],[是否显示附表目录],
    [`include_appendix_tables`],[附表目录是否收录附录表格],
    [`include_abbreviations`],[是否显示符号和缩略语说明],
    table.hline(stroke: 1.2pt),
  ),
) <tab-template-config>

`anonymous: true` 会清空作者姓名、导师和学科信息，把学号显示为七个方块，并清空 PDF 作者元数据。当前委员会页仍直接读取原始 `information.defense`，不会自动隐藏评阅人和答辩委员；制作匿名稿时还需手工将这 12 条记录的字段留空。标题、关键词、正文、图片、文件名、致谢、成果、博士评语、决议和参考文献自引也仍可能泄露身份。

常见学位类型组合如下：

#figure(
  caption: [学位类型组合],
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([论文类型],[`degree_level`],[`degree_type`]),
    table.hline(stroke: 0.5pt),
    [学术型硕士], [`"master"`],  [`"academic"`],
    [专业型硕士], [`"master"`],  [`"professional"`],
    [学术型博士], [`"doctoral"`], [`"academic"`],
    [专业型博士], [`"doctoral"`], [`"professional"`],
    table.hline(stroke: 1.2pt),
  ),
)

== 基本信息

`information` 中需要保留的字段包括：

#figure(
  caption: [`information` 配置字段解释],
  table(
    columns: 2,
    table.hline(stroke: 1.2pt),
    table.header([字段],[解释]),
    table.hline(stroke: 0.5pt),
    [`institution`], [学校中英文名称和学校代码],
    [`security`], [中英文密级],
    [`title`], [中英文论文题目],
    [`abstract`], [中英文摘要],
    [`abbreviations`], [符号与缩略语说明],
    [`keywords`], [中英文关键词数组],
    [`author`], [中英文姓名及学号],
    [`supervisors`], [可以填写一位或多位导师],
    [`program`], [一级学科、二级学科和研究方向],
    [`submission_date`], [提交日期，使用 `datetime(year: ..., month: ..., day: ...)`],
    [`defense`], [评阅专家和答辩委员会信息],
    [`achievements`], [成果],
    [`awards`], [获奖],
    [`review`], [导师评语和答辩委员会决议],
    table.hline(stroke: 1.2pt),
  ),
)

中英文内容应一一对应。英文姓名、题目和学科名称应使用学院认可的正式译法。`title.zh` 和 `title.en` 必须保留纯文本，其中 `title.zh` 还用于 PDF metadata。可选的 `display_en` 可以承载英文标题中的复杂公式；当前博士 A3 书脊会把 `display_zh` 交给只接受字符串的竖排函数，因此启用博士外封面时不要把 `display_zh` 设置为内容块。

显示开关只控制页面是否渲染，不会让 `information` 字段变成可选项。始终保留 `examples/empty/settings.typ` 中的完整结构；普通列表无数据时使用空数组 `()`，固定表格记录则保留条目并将字段写成空字符串。

`institution.name_zh` 和 `institution.name_en` 是保留字段，当前固定页面仍使用模板内置的学校名称；现阶段只有 `institution.school_code` 会进入封面信息。

== 评阅人与委员会

#figure(
  caption: [评阅人与委员会代码示例],
  kind: image,
  ```typst
  defense: (
    /* 学位论文评阅专家信息 */
    reviewers: (
      (name: "评阅专家甲", affiliation: "示例大学/教授", evaluation: "优秀"),
      (name: "评阅专家乙", affiliation: "示例大学/教授", evaluation: "良好"),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
    ),
    /* 答辩委员会人员信息 */
    committee: (
      (name: "答辩主席", affiliation: "示例大学", academic_title: "教授"),
      (name: "答辩委员甲", affiliation: "示例大学", academic_title: "教授"),
      (name: "答辩委员乙", affiliation: "示例大学", academic_title: "副教授"),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
    ),
  ),
  ```
)

当前委员会页面采用固定表格布局。`defense.reviewers` 应保留 5 个字典，`defense.committee` 应保留 7 个字典；暂时没有信息的条目将各字段留空，不要删除整个条目，否则会破坏固定行布局。

`defense.committee` 第一项固定显示为主席，其余 6 项显示为委员；`reviewers.affiliation` 对应“工作单位/职称”合并列，需要时应同时填写单位和职称。

== 摘要与关键词

摘要内容可以通过 `include` 命令导入，或者通过 `[]` 启用标记模式直接写下内容。以上两种方式可以支持代码模式、数学模式。除此之外也可以使用 `""` 输入纯文本。

#figure(
  caption: [摘要内容代码示例],
  kind: image,
  ```typst
  abstract: (
    zh: include "abstract/abstract-zh.typ",     /* include 命令载入 */
    en: [NENU thesis Typst template. $theta$],  /* 标记模式 */
    /* en: "NENU thesis Typst template.", */   /* 纯文本 */
  ),
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

一般来说，中英文摘要建议各自放在独立文件中，并在 `settings.typ` 的 `information.abstract` 中通过 `include` 读取为内容。摘要文件只写摘要正文，不需要添加“摘要”标题，模板会自动生成标题和关键词行。

== 目录与缩略语

模板自动生成全文目录、插图目录、附表目录以及符号和缩略语说明。标题、图片和表格只有使用标准 `heading` 与 `figure` 元素，才会被相应目录索引。

若不需要插图目录、附表目录以及符号和缩略语说明，可通过@tab-template-config 所示配置单独关闭渲染。

缩略语通过 `information.abbreviations` 提供，可以是普通文本或数学内容：

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

当前后置内容由三个显式步骤组成：`nenu-bibliography-render` 输出参考文献，`begin-appendices` 切换到附录编号，`end-appendices` 退出附录并生成无编号的“后记”标题。理工科附录小节使用 `A.1.1.1`，社科附录小节继续使用“一、”“（一）”“1.”等格式；文献引擎参数见@chapter-bibliography。

#figure(
  caption: [参考文献、附录和后记装配示例],
  kind: image,
  ```typst
  /* 前面已按文献章节设置模板和文献引擎 */
  /* 以下章节文件需先在 contents 目录中创建 */
  #include "contents/01-introduction.typ"
  #include "contents/02-method.typ"
  #include "contents/03-experiments.typ"
  #include "contents/04-conclusion.typ"

  #nenu-bibliography-render()

  #begin-appendices()
  = 补充实验
  这里撰写补充实验。
  #end-appendices()

  这里撰写后记正文。
  ```
)

== 成果、获奖与博士页面

`achievements` 和 `awards` 由模板放在用户正文之后。成果记录字段包括名称、类别、刊物或出版社、时间和作者次序。没有获奖内容时使用空数组 `()`；成果页本身仍会生成。

#figure(
  caption: [成果与获奖配置示例],
  kind: image,
  ```typst
  /* 在学期间取得成果 */
  achievements: (
    (
      title: "学位论文 Typst 模板的设计与实践",
      type: "学术论文",
      journal: "示例期刊",
      date: [2025年#parbreak()第12卷],   /* 内容块可控制单元格内换行 */
      author: "1",
    ),
    (
      title: "学位论文 Typst 模板的设计与实践",
      type: "学术论文",
      journal: "示例期刊",
      date: "2025年07月",   /* 也支持纯文本格式 */
      author: "1",
    ),
  ),
  /* 参加的研究项目及获奖情况 */
  awards: (
    "第一届全国大学生光电设计大赛东北赛区一等奖",
    "第一届全国大学生光电设计大赛国家一等奖",
    "其他获奖奖项",
  ),
  /* 没有获奖内容使用空数组：awards: () */
  ```
)

博士模式还会根据 `review.supervisors` 和 `review.committee` 分别生成导师评语与答辩委员会决议页；硕士模式不会输出这两页。正式提交前仍需核对两页内容和版式。

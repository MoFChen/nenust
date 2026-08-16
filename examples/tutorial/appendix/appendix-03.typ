本附录区分两类修改：`information`、`config` 和正文中的局部规则属于论文入口可控制的公开层；`template/` 下的常量与规则属于模板内部实现。下列标为“内部片段”的代码只用于展示应修改的源文件位置，不应粘贴到论文正文或 `information` 中执行。修改公开数据后至少运行完整检查；修改模板内部实现后同时运行最小与完整检查：

#figure(
  caption: [Typst 编译命令],
  kind: image,
  ```powershell
  typst compile --root . --font-path template/assets/fonts examples/empty/main.typ
  typst compile --root . --font-path template/assets/fonts examples/tutorial/main.typ
  ```
)

== 论文标题

`template/nenu-template.typ` 使用 `information.title.zh` 设置 PDF metadata；`template/modules/utils.typ` 的 `format_info` 将可选的 `display_zh`、`display_en` 用于固定页面排版，未提供时分别回退到 `zh`、`en`。因此，`zh` 和 `en` 必须保留为纯字符串。博士 A3 书脊始终使用纯文本 `zh`，所以两个显示字段都可以承载复杂公式等可排版内容：

#figure(
  caption: [模板 Title 参数填写示例],
  kind: image,
  ```typst
  title: (
    zh: "含参数 alpha 的论文标题",
    en: "A Thesis Title with Parameter Alpha",
    display_zh: [含参数 $alpha$ 的论文标题],
    display_en: [A Thesis Title with Parameter $alpha$],
  ),
  ```
)

标题内容是公开入口，但字号和位置不是配置项。A4 标题最终由 `template/pages/cover.typ` 的 `page-cover-template` 排版，其中标题位置与字体固定在同一函数内。若学校要求改变这些参数，只能编辑该内部规则；它同时服务 A3 正面和两个 A4 信息页，改动会影响所有调用方。

#figure(
  caption: [模板内部渲染标题的代码片段],
  kind: image,
  ```typst
  place(center + top, dy: 268pt, text(font: FONT_YAHEI, size: 16pt, title))
  ```
)

长标题可能超出可用宽度或与下方内容相碰，不能只以编译成功作为判断。修改后运行完整检查，并在临时 PDF 中同时核对 A3 正面、A4 中英文标题以及文档属性中的纯文本标题；若改了内部位置或字号，再补跑最小检查。

=== A3封面书脊标题

A3 外封面只在 `config.include_outer_cover` 为 `true` 时生成。`template/pages/cover.typ` 的 `page-cover-a3` 又只在 `degree_level: "doctoral"` 的分支生成书脊文字；`degree_type` 选择书脊上的“学”或“专”标记。书脊没有独立的公开标题字段，读取 `format_info` 从 `information.title.zh` 保留的 `plain_zh`；`display_zh` 用于封面正面、委员会页和博士评语、决议页的中文标题。要看到博士书脊，现有 `config` 中应使用：

#figure(
  caption: [博士论文模板配置示例],
  kind: image,
  ```typst
  degree_level: "doctoral",
  include_outer_cover: true,
  ```
)

书脊由 `template/pages/cover.typ` 中的固定 `dy`、字号、行距定位。`template/modules/utils.typ` 的 `v_cjk_latin` 会逐字符处理纯文本：空白变成竖向间距，拉丁字母转为大写并旋转。若需要缩小字号、移动起点或改变字符处理，只能修改这些内部位置；例如当前书脊规则如下图所示。

#figure(
  caption: [模板A3封面书脊标题规则],
  kind: image,
  ```typst
  #place(top + center, dy: 158pt,
    text(size: 16pt, fill: black, [
      #set par(leading: 0pt, spacing: 1pt)
      #v_cjk_latin(e.title.plain_zh)
    ])
  )
  ```
)

此外，`template/config/styles.typ` 的 `a3_book_spine_width` 使用硕士 `5pt`、博士 `20pt` 的内部偏移移动 A3 左右半页。修改它会改变折线两侧的整体位置，并非只移动书脊。检查时应以 `include_outer_cover: true`、`degree_level: "doctoral"` 编译，分别核对中英文混排、空格、长标题以及学术型和专业型标记；内部改动需运行本附录开头的两项编译检查。

== A4封面信息栏

`include_outer_cover` 只控制 A3 外封面。`template/nenu-template.typ` 在所有模式下都会生成 A4 中文和英文信息页，当前没有隐藏任一 A4 页的公开开关。公开层可通过 `information` 中的 `security`、`title`、`author`、`supervisors`、`program` 和 `submission_date` 改变内容，并通过 `config.anonymous`、`degree_level`、`degree_type` 选择模板已经实现的匿名、学位层次和学位类型分支；学校名称和代码固定在模板内部，这些开关也不能用来微调位置。

信息栏的通用几何布局位于 `template/pages/cover.typ` 的 `page-cover-template`。其中底部位置 `dy: -158pt`、行高 `19pt`、单元格内边距 `2pt` 和列结构都是内部常量：

#figure(
  caption: [模板中文信息栏显示代码],
  kind: image,
  ```typst
  place(center + bottom, dy: -158pt, dx: -offset)[
    #set text(size: 12pt)
    #grid(
      columns: (auto, width),
      rows: 19pt,
      inset: 2pt,
      align: (right + bottom, center + bottom),
      ..information,
    )
  ]
  ```
)

增加导师会增加信息栏行数，过长字段也可能换行或越界；固定位置因而可能与标题相碰。不要删除公开契约中的成对中英文字段来“腾出空间”，应先缩短为学院认可的正式表述，确有版式要求时再改内部常量。检查时除默认配置外，还应以 `include_outer_cover: false` 确认两个 A4 页面仍存在，并分别编译匿名与非匿名、硕士与博士、学术型与专业型分支。

=== 中文信息栏

中文页的数据由 `template/modules/utils.typ` 的 `format_info` 装配：页首使用固定学校代码 `10200`、`author.student_id` 和 `security.zh`，信息栏使用 `author.name.zh`、各导师的 `name.zh` 与 `academic_title.zh`，以及 `program` 的三个中英文字段。`template/pages/cover.typ` 的 `page-cover-a4-zh` 将这些值放入中文网格，并以 `submission_date.display("[year]年[month]月")` 输出日期。应在现有 `information` 中直接填写完整记录，例如：

#figure(
  caption: [模板配置填写示例],
  kind: image,
  ```typst
  security: (zh: "无", en: "None"),
  author: (name: (zh: "张三", en: "Zhang San"), student_id: "学号"),
  supervisors: (
    (name: (zh: "李四", en: "Li Si"),
     academic_title: (zh: "教授", en: "Professor")),
  ),
  program: (
    primary_discipline: (zh: "一级学科或学位类别", en: "Approved English name"),
    secondary_discipline: (zh: "二级学科或学位领域", en: "Approved English name"),
    research_area: (zh: "研究方向", en: "Research Area"),
  ),
  submission_date: datetime(year: 2025, month: 9, day: 25),
  ```
)

`config.degree_type` 在 `format_info` 中决定中文标签是“一级学科/二级学科”还是“学位类别/学位领域”，不要为了视觉对齐选择错误的论文类型。`config.anonymous` 会清空作者、导师、学科和评审等值，因此匿名模式下修改这些公开字段不会显示。

非匿名模式会通过 `template/modules/utils.typ` 的 `format_cjk_name` 格式化作者姓名，中文封面还会在排版导师姓名时调用同一函数；委员会姓名保持用户填写的字符串，匿名模式下则使用清空后的记录。两字姓名插入 `1em` 间距的内部规则位于同一文件：

#figure(
  caption: [模板自动处理姓名间距],
  kind: image,
  ```typst
  clusters.join([#h(1em)])
  ```
)

修改该值会影响所有调用 `format_cjk_name` 的两字姓名，而非只影响封面。中文网格右侧的下划线是值单元格的底边，因此它与右侧值列共用一个宽度；可在 `template/config/styles.typ` 的 `nenu-style.cover.underline_length_zh` 中调整，当前为 `140pt`：

#figure(
  caption: [中文信息栏值列宽度常量],
  kind: image,
  ```typst
  underline_length_zh: 140pt,
  ```
)

这不是公开字段。增大该值会延长横线、给内容更多空间并减少换行，但也会加宽整个网格，可能破坏视觉居中或逼近页边距；减小后版面更紧凑，却会让长值更早换行，并可能在固定 `19pt` 行高中与相邻行挤碰。模板不会自动截断过长内容，不易断行的值还可能直接越出列宽。检查时应使用两字和三字姓名、多个导师及最长的学科名称，分别查看匿名前后和学术型/专业型标签，并运行完整检查；改动姓名规则或线宽时再运行最小检查。

=== 英文信息栏

英文页从同一组公开数据读取 `security.en`、`author.name.en`、导师的 `name.en` 与 `academic_title.en`，以及三个 `program` 记录的 `en` 值。数据到页面的映射位于 `template/pages/cover.typ` 的 `page-cover-a4-en`；日期固定显示为 `"[year], [month]"`。导师当前按“职称 + 空格 + 姓名”拼接，相关字段必须是字符串：

#figure(
  caption: [英文导师字段填写示例],
  kind: image,
  ```typst
  supervisors: (
    (name: (zh: "李四", en: "Li Si"),
     academic_title: (zh: "教授", en: "Professor")),
  ),
  ```
)

学位层次标题 `A Thesis`/`A Dissertation` 和作者、导师、研究方向等英文标签在 `format_info` 内部确定，页脚文字固定在 `page-cover-a4-en`。这些文字没有对应的 `information` 或 `config` 字段。只有在学校认可的英文格式要求不同且确认要影响所有论文时，才应修改相应内部字符串。

例如，改变导师姓名与职称的顺序需要编辑 `template/pages/cover.typ` 的 `page-cover-a4-en`，而不是把标点塞进姓名字段。内部片段（仅用于定位）可由当前规则改为学院要求的顺序：

#figure(
  caption: [英文导师姓名与职称顺序],
  kind: image,
  ```typst
  /* 当前实现 */
  sv.academic_title.en + " " + sv.name.en
  /* 仅在规范要求如此时改为 */
  sv.name.en + ", " + sv.academic_title.en
  ```
)

英文网格右侧的下划线同样是值单元格的底边，右侧值列宽度可通过 `template/config/styles.typ` 的 `nenu-style.cover.underline_length_en` 调整，当前为 `210pt`：

#figure(
  caption: [英文信息栏值列宽度常量],
  kind: image,
  ```typst
  underline_length_en: 210pt,
  ```
)

增大该值会延长横线、容纳更长的英文值并减少换行，但会让网格更宽，可能需要重新检查视觉居中、水平偏移和页边距；减小后横线更短，却会使长学科名称或导师信息更早换行。不易断行的英文内容可能越出列宽，模板不会自动截断它。多位导师和手工加入的标点也可能造成换行或不一致。检查时应核对每个中英文字段的语义对应、导师顺序、日期、页首密级与页脚，并在匿名和非匿名模式下运行完整检查；修改内部标签、拼接规则或线宽后再运行最小检查。

=== 英文信息栏水平偏移

中文标签主要由方正、等宽的汉字组成，各标签宽度也较接近，因此两列网格直接居中时通常容易获得明确的视觉中心。英文提示词的长度却相差很大，例如短的 `Author` 与较长的学科提示词会共同决定自动标签列宽；即使整个两列网格在几何上居中，标签和值线的视觉重心仍可能显得偏离页面中心。

学术型与专业型模板使用的英文提示词不同，所以 `template/config/styles.typ` 的 `nenu-style.cover.horizon_offset_en` 分别设置视觉补偿：学术型为 `45pt`，专业型为 `5pt`。`page-cover-template` 以 `dx: -offset` 应用该值，只向左移动信息网格；标题、页首、页脚和日期不会随之移动。

内部片段（仅用于定位）：

#figure(
  caption: [英文信息栏视觉偏移常量],
  kind: image,
  ```typst
  horizon_offset_en: (academic: 45pt, professional: 5pt),
  ```
)

应先按真实学位类型设置 `config.degree_type`，不要为修正对齐而误用它。用户可根据论文实际填写的英文姓名、导师和学科信息，分别小幅调整 `academic`、`professional` 对应值；两套提示词和元数据长度不同，两个值应独立校准。正值增大时网格继续左移，可能接近页边界。修改后必须分别以 `degree_type: "academic"` 和 `degree_type: "professional"` 编译，使用各自真实且最长的英文信息检查网格与页面中心、下划线和页边距，再运行最小与完整检查。

== 符号和缩略语说明

公开层由 `config.include_abbreviations` 控制是否显示页面，由 `information.abbreviations` 提供按顺序排版的记录。`template/nenu-template.typ` 调用 `template/pages/abbreviations.typ` 的 `page-abbreviations` 完成排版。`abbr` 和 `description` 可使用字符串或数学等可排版内容，最小配置片段如下：

#figure(
  caption: [符号和缩略语配置示例],
  kind: image,
  ```typst
  include_abbreviations: true,

  abbreviations: (
    (abbr: "LLM", description: "大语言模型（Large Language Model）"),
    (abbr: $sigma$, description: "标准差"),
  ),
  ```
)

开关为 `false` 只是不生成该列表，不会把 `information` 的其他字段变成可选项；仍应保留完整契约。`page-abbreviations` 按元组原顺序遍历，不会自动排序、去重或统一术语。段落行距 `0.5em`、非两端对齐、单元格内边距 `0.489em` 和网格列宽均为内部规则，改变这些样式需要编辑 `template/pages/abbreviations.typ`。

较长公式可能挤压说明列，较长说明可能增加行高；调整顺序或措辞应在 `information.abbreviations` 完成，不要为单个条目修改模板。检查时分别使用 `include_abbreviations: true` 和 `false` 编译，并在开启状态下保留文本、数学符号和长说明三类条目；内部样式改动需运行最小与完整检查。

=== 列表左右单元格比例

列表比例没有公开 `information` 或 `config` 字段。`template/pages/abbreviations.typ` 将网格固定为 `columns: (1fr, 4fr)`，即扣除单元格内边距后的可分配宽度名义上按 1:4 分给缩略语和说明。若左列经常包含较宽公式，可直接在该内部位置调整，例如：

#figure(
  caption: [缩略语列表列宽比例],
  kind: image,
  ```typst
  columns: (1fr, 3fr),
  ```
)

增大左列占比会减少说明列宽并增加说明换行，缩小左列则可能使公式或长缩写换行；不存在对所有论文都最优的比例。只应根据实际最长条目做一次全局调整。修改后运行两项编译检查，并在临时 PDF 中核对最宽左项、最长说明、跨页处和页面右边界。

== 下划线

正文下划线的模板默认偏移位于 `template/nenu-template.typ` 的正文样式规则中，当前为 `3pt`，没有对应的 `information` 或 `config` 字段。只需改变论文某一局部时，不必修改模板，可在正文内容块中使用更靠后的局部规则：

#figure(
  caption: [正文局部下划线设置],
  kind: image,
  ```typst
  #block[
    #set underline(offset: 2pt)
    #underline[局部下划线]
  ]
  ```
)

若学校要求统一改变模板默认值，才编辑以下内部规则（片段仅用于定位）：

#figure(
  caption: [模板正文下划线默认值],
  kind: image,
  ```typst
  #set underline(offset: 3pt)
  ```
)

该规则作用于其后的摘要、目录和正文等内容中的 Typst `underline`，并不控制 A4 信息栏的横线。封面横线由 `template/pages/cover.typ` 中值单元格的 `0.5pt` 底边绘制，长度由 `template/config/styles.typ` 的 `underline_length_zh`、`underline_length_en` 控制。偏移过小会压住字形，过大则可能碰到下一行；检查时应同时观察中文、拉丁字母、上下标附近和连续多行的下划线。内部默认值改动后运行两项编译检查，局部规则只需运行完整检查。

== 数学公式字体

数学字体没有公开配置项。基础字体名定义在 `template/config/fonts.typ`，当前 `FONT_MATH` 为 `New Computer Modern Math`，并组成 `(FONT_MATH, FONT_SONGTI)` 回退序列；`template/nenu-template.typ` 将该序列应用于数学公式。要全局更换数学字体，应修改内部常量，而不是逐个公式设置字体：

#figure(
  caption: [数学字体内部常量],
  kind: image,
  ```typst
  #let FONT_MATH = "Libertinus Math"
  ```
)

上例来自 `template/config/fonts.typ` 已列出的候选字体名，但使用前仍须确认本机或 `template/assets/fonts` 中确实存在该字体。可先检查 Typst 能识别的字体族：

#figure(
  caption: [Typst 可用字体检查命令],
  kind: image,
  ```powershell
  typst fonts --font-path template/assets/fonts
  ```
)

数学字体会影响行内与独立公式的字形、符号覆盖、基线和公式宽度，但不会改变 `information` 内容。名称错误可能导致字体警告或回退，不同数学字体的度量也可能改变换行。修改后运行最小与完整检查，并重点查看教程数学章节中的希腊字母、算子、分式、矩阵、定界符、上下标以及中西文相邻处。

== 数学公式编号

作者只需使用标准独立公式和标签，编号与引用由模板生成，不应手写编号：

#figure(
  caption: [公式标签与引用示例],
  kind: image,
  ```typst
  $ E = m c^2 $ <eq-mass-energy>
  由 @eq-mass-energy 可知上述关系成立。
  ```
)

公式编号没有公开配置项。`template/nenu-template.typ` 在每个一级标题开始时把公式计数器清零；`template/config/rules.typ` 的 `equation-numbering` 使用当前一级标题计数和公式计数，在正文生成 `(1.1)`，在附录生成 `(A.1)`，`template/nenu-template.typ` 再将引用补充文字设为“公式”。若规范要求连字符，应同时保留正文和附录分支：

#figure(
  caption: [公式连字符编号规则],
  kind: image,
  ```typst
  #let equation-numbering(n) = chapter-numbering(n, "(1-1)", "(A-1)")
  ```
)

在 `template/config/rules.typ` 中改变该函数会同步影响公式及自动引用，但不会修复正文中手写的旧编号；这正是应始终使用标签的原因。移除一级标题处的重置还会改变全篇计数语义，不应作为仅更换分隔符的手段。修改后运行两项编译检查，并至少核对两个连续章节和一个附录中的首个、末个公式及 `@eq-...` 引用。

== 图表编号

公开的 `include_list_of_figures` 和 `include_list_of_tables` 只控制目录是否显示，不控制图表编号；`include_appendix_figures` 和 `include_appendix_tables` 只控制相应目录是否收录附录条目。作者应继续用标准 `figure` 包裹图片或表格并添加标签，以便编号、目录和引用使用同一元素；不要在图题或正文中手写序号。

图表编号由 `template/config/rules.typ` 的 `figure-numbering` 生成正文 `1.1` 和附录 `A.1`；`begin-appendices`、`end-appendices` 通过附录状态切换编号。`chapter-numbering` 在图表目标位置读取一级标题计数，因此跨章引用仍使用图表所在章的编号。`template/nenu-template.typ` 在每个一级标题开始时分别重置 `kind: table` 和 `kind: image` 的计数器，并设置表题位置和题注字号。若规范要求连字符，应保留正文和附录分支：

#figure(
  caption: [图表连字符编号规则],
  kind: image,
  ```typst
  #let figure-numbering(n) = chapter-numbering(n, "1-1", "A-1")
  ```
)

这条通用 `figure` 规则会影响图片、表格以及其他 figure 种类，但当前章首只显式重置图片和表格；若论文引入自定义 `kind`，应先确认其计数是否需要单独重置。插图目录和附表目录使用 Typst 原生的 `outline.entry.prefix()`，会自动采用图表实际的 `numbering` 和 `supplement`，无需维护第二套编号模式。自定义编号时应设置 `figure.numbering`，不要只在题注中手写序号。修改后运行两项编译检查，并核对至少两个章节和一个附录中的图、表、正文引用及目录。

== 章节引用前后缀

章节标题只需使用标准标题和标签，正文通过 `@标签` 或 `#ref(<标签>)` 引用。标题显示由 `template/config/rules.typ` 中理工科、社科及附录的 numberer 决定；普通标题引用则由同文件的 `heading-ref-numbering` 单独改写。当前正文一级标题引用显示为“第一章”，附录一级标题显示为“附录A”，二级及以下显示阿拉伯数字路径并追加“小节”。非标题引用交回 Typst，因此公式、图片、表格和文献引用仍使用元素自身的补充文字与编号。

前后缀没有公开 `information` 或 `config` 字段。要改变全篇章节引用文字，应编辑 `template/config/rules.typ` 的 `heading-ref-numbering`，而不是在正文每次引用前后拼接文字。当前核心片段为：

#figure(
  caption: [章节引用文字生成规则],
  kind: image,
  ```typst
  if appendix {
    if level == 1 {
      numbering("附录A", nums.first())
    } else {
      numbering("A.1.1.1", ..nums) + [小节]
    }
  } else {
    if level == 1 {
      numbering("第一章", nums.first())
    } else {
      numbering("1.1.1.1", ..nums) + [小节]
    }
  }
  ```
)

例如，一级标题若需阿拉伯数字可将正文分支改为 `numbering("第1章", nums.first())`；低层级若需“第...节”，则应在同一分支统一加入前缀和后缀。只改引用函数不会改变标题本身和目录中的编号；若两处都要改变，还需同步评估正文与附录 numberer。当前社科标题显示“一、”“（一）”等格式，但二级及以下引用仍使用阿拉伯数字路径，这是模板现有边界。修改后应搜索正文中已经手写的“第”“章”“节”，避免产生重复词，并运行两项编译检查，分别核对理工科和社科的一至四级标题引用、附录引用以及至少一个非标题引用。

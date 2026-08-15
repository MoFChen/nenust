本附录区分两类修改：`info`、`config` 和正文中的局部规则属于论文入口可控制的公开层；`template/` 下的常量与规则属于模板内部实现。下列标为“内部片段”的代码只用于展示应修改的源文件位置，不应粘贴到论文正文或 `info` 中执行。修改公开数据后至少运行完整检查；修改模板内部实现后同时运行最小与完整检查：

#figure(
  caption: [Typst 编译命令],
  kind: image,
  ```powershell
  typst compile --root . examples/empty/empty.typ
  typst compile --root . examples/tutorial/main.typ
  ```
)

== 论文标题

模板将“纯文本标题”和“排版标题”分开。`template/nenu-template.typ:46-52` 使用 `info.title.zh` 设置 PDF metadata；`template/nenu-template.typ:99-103` 将可选的 `display_zh`、`display_en` 用于排版，未提供时分别回退到 `zh`、`en`。因此，`zh` 和 `en` 必须保留为纯字符串；标题含复杂数学内容时，只在可选显示字段中使用内容块：

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

上述四个字段是标题内容的公开入口，但字号和位置不是配置项。A4 标题最终由 `template/modules/template-cover.typ:14-30` 的通用封面函数排版，其中标题位置与字体固定在 `template/modules/template-cover.typ:21-22`。若学校要求改变这些参数，只能编辑该内部规则；它同时服务 A3 正面和两个 A4 信息页，改动会影响所有调用方。

#figure(
  caption: [模板内部渲染标题的代码片段],
  kind: image,
  ```typst
  place(center + top, dy: 268pt, text(font: FONT_YAHEI, size: 16pt, title))
  ```
)

长标题可能超出可用宽度或与下方内容相碰，不能只以编译成功作为判断。修改后运行完整检查，并在临时 PDF 中同时核对 A3 正面、A4 中英文标题以及文档属性中的纯文本标题；若改了内部位置或字号，再补跑最小检查。

=== A3封面书脊标题

A3 外封面只在 `config.showCover: true` 时生成，调用位置为 `template/nenu-template.typ:160-165`。`template/modules/template-cover.typ:109-125` 又只在 `config.isThesis: false` 的博士分支生成书脊文字；`isAcademic` 只选择书脊上的“学”或“专”标记。书脊没有独立的公开标题字段，它始终读取 `template.title.plain_zh`，即纯字符串 `info.title.zh`。要看到博士书脊，现有 `config` 中应使用：

#figure(
  caption: [博士论文模板配置示例],
  kind: image,
  ```typst
  isThesis: false,
  showCover: true,
  ```
)

书脊从 `template/modules/template-cover.typ:119-123` 的固定 `dy`、字号、行距开始纵向排版。`template/modules/utils.typ:12-24` 的 `v_cjk_latin` 会逐字符处理纯文本：空白变成竖向间距，拉丁字母转为大写并旋转。数学内容不能通过 `display_zh` 进入书脊。若需要缩小字号、移动起点或改变字符处理，只能修改这些内部位置；例如当前书脊规则如下图所示。

#figure(
  caption: [模板A3封面书脊标题规则],
  kind: image,
  ```typst
  #place(top + center, dy: 158pt,
    text(size: 16pt, fill: black, [
      #set par(leading: 0pt, spacing: 1pt)
      #v_cjk_latin(template.title.plain_zh)
    ])
  )
  ```
)

此外，`template/modules/template-cover.typ:90-106` 用硕士 `5pt`、博士 `20pt` 的内部 `offset` 移动 A3 左右半页。修改它会改变折线两侧的整体位置，并非只移动书脊。检查时应以 `showCover: true`、`isThesis: false` 编译，分别核对中英文混排、空格、长标题以及学术型和专业型标记；内部改动需运行本附录开头的两项编译检查。

== A4封面信息栏

`showCover` 只控制 A3 外封面。`template/nenu-template.typ:167-179` 在所有模式下都会生成 A4 中文和英文信息页，当前没有隐藏任一 A4 页的公开开关。公开层可通过 `info.cover`、`info.title`、`info.author`、`info.supervisors`、`info.subjects` 和 `info.date` 改变内容，并通过 `config.anonymous`、`config.isThesis`、`config.isAcademic` 选择模板已经实现的匿名、学位层次和学位类型分支；这些开关不能用来微调位置。

信息栏的通用几何布局位于 `template/modules/template-cover.typ:14-30`。其中底部位置 `dy: -158pt`、行高 `19pt`、单元格内边距 `2pt` 和列结构都是内部常量：

#figure(
  caption: [模板中文信息栏显示代码],
  kind: image,
  ```typst
  place(center + bottom, dy: -158pt, dx: offset,
    text(size: 12pt)[
      #grid(columns: (auto, length), rows: 19pt, inset: 2pt,
        align: (right + bottom, center + bottom), ..infos)
    ]
  )
  ```
)

增加导师会增加信息栏行数，过长字段也可能换行或越界；固定位置因而可能与标题相碰。不要删除公开契约中的成对中英文字段来“腾出空间”，应先缩短为学院认可的正式表述，确有版式要求时再改内部常量。检查时除默认配置外，还应以 `showCover: false` 确认两个 A4 页面仍存在，并分别编译匿名与非匿名、硕士与博士、学术型与专业型分支。

=== 中文信息栏

中文页的数据装配位置是 `template/nenu-template.typ:85-119`：页首使用 `cover.school_code`、`author.id` 和 `cover.security_zh`，信息栏使用 `author.zh`、各导师的 `name_zh` 与 `title_zh`，以及 `subjects.category.zh`、`subjects.field.zh`、`subjects.research.zh`。`template/modules/template-cover.typ:60-87` 将这些值放入中文网格，并以 `date.display("[year]年[month]月")` 输出日期。应在现有 `info` 中直接填写完整记录，例如：

#figure(
  caption: [模板配置填写示例],
  kind: image,
  ```typst
  cover: (
    school_code: "10200",
    security_zh: "无",
    security_en: "None",
  ),
  author: (zh: "张三", en: "Zhang San", id: "学号"),
  supervisors: (
    (name_zh: "李四", name_en: "Li Si",
    title_zh: "教授", title_en: "Professor"),
  ),
  subjects: (
    category: (zh: "一级学科或学位类别", en: "Approved English name"),
    field: (zh: "二级学科或学位领域", en: "Approved English name"),
    research: (zh: "研究方向", en: "Research Area"),
  ),
  date: datetime(year: 2025, month: 9, day: 25),
  ```
)

`config.isAcademic` 在 `template/nenu-template.typ:134-142` 决定中文标签是“一级学科/二级学科”还是“学位类别/学位领域”，不要为了视觉对齐选择错误的论文类型。`config.anonymous` 会在 `template/nenu-template.typ:54-74` 清空作者、导师和学科等值，因此匿名模式下修改这些公开字段不会显示。

非匿名模式会在 `template/nenu-template.typ:76-81` 格式化作者和委员会姓名，中文封面还会在 `template/modules/template-cover.typ:70-74` 格式化导师姓名。两字姓名插入 `1em` 间距的内部规则位于 `template/modules/utils.typ:1-9`：

#figure(
  caption: [模板自动处理姓名间距],
  kind: image,
  ```typst
  clusters.join([#h(1em)])
  ```
)

修改该值会影响所有调用 `format_cjk_name` 的两字姓名，而非只影响封面。中文网格右侧的下划线是值单元格的底边，因此它与右侧值列共用一个宽度；可在 `template/modules/template-cover.typ:7-10` 的内部 `style.underline_zh_length` 中调整，当前为 `140pt`：

#figure(
  caption: [中文信息栏值列宽度常量],
  kind: image,
  ```typst
  underline_zh_length: 140pt,
  ```
)

这不是公开字段。增大该值会延长横线、给内容更多空间并减少换行，但也会加宽整个网格，可能破坏视觉居中或逼近页边距；减小后版面更紧凑，却会让长值更早换行，并可能在固定 `19pt` 行高中与相邻行挤碰。模板不会自动截断过长内容，不易断行的值还可能直接越出列宽。检查时应使用两字和三字姓名、多个导师及最长的学科名称，分别查看匿名前后和学术型/专业型标签，并运行完整检查；改动姓名规则或线宽时再运行最小检查。

=== 英文信息栏

英文页从同一组公开数据读取 `cover.security_en`、`author.en`、导师的 `name_en` 与 `title_en`，以及三个 `subjects` 记录的 `en` 值。数据到页面的准确映射位于 `template/modules/template-cover.typ:32-57`；日期固定显示为 `"[year], [month]"`。导师当前按“职称 + 空格 + 姓名”拼接，相关字段必须是字符串：

#figure(
  caption: [英文导师字段填写示例],
  kind: image,
  ```typst
  supervisors: (
    (name_zh: "李四", name_en: "Li Si",
     title_zh: "教授", title_en: "Professor"),
  ),
  ```
)

学位层次标题 `A Thesis`/`A Dissertation` 在 `template/nenu-template.typ:122-131` 内部确定，作者、导师和研究方向等英文标签在 `template/nenu-template.typ:93-117` 内部确定，页脚文字则固定在 `template/modules/template-cover.typ:55`。这些文字没有对应的 `info` 或 `config` 字段。只有在学校认可的英文格式要求不同且确认要影响所有论文时，才应修改相应内部字符串。

例如，改变导师姓名与职称的顺序需要编辑 `template/modules/template-cover.typ:42-45`，而不是把标点塞进姓名字段。内部片段（仅用于定位）可由当前规则改为学院要求的顺序：

#figure(
  caption: [英文导师姓名与职称顺序],
  kind: image,
  ```typst
  // 当前实现
  infoline(su.title_en + " " + su.name_en)
  // 仅在规范要求如此时改为
  infoline(su.name_en + ", " + su.title_en)
  ```
)

英文网格右侧的下划线同样是值单元格的底边，右侧值列宽度可通过 `template/modules/template-cover.typ:7-10` 的内部 `style.underline_en_length` 调整，当前为 `210pt`：

#figure(
  caption: [英文信息栏值列宽度常量],
  kind: image,
  ```typst
  underline_en_length: 210pt,
  ```
)

增大该值会延长横线、容纳更长的英文值并减少换行，但会让网格更宽，可能需要重新检查视觉居中、水平偏移和页边距；减小后横线更短，却会使长学科名称或导师信息更早换行。不易断行的英文内容可能越出列宽，模板不会自动截断它。多位导师和手工加入的标点也可能造成换行或不一致。检查时应核对每个中英文字段的语义对应、导师顺序、日期、页首密级与页脚，并在匿名和非匿名模式下运行完整检查；修改内部标签、拼接规则或线宽后再运行最小检查。

=== 英文信息栏水平偏移

中文标签主要由方正、等宽的汉字组成，各标签宽度也较接近，因此两列网格直接居中时通常容易获得明确的视觉中心。英文提示词的长度却相差很大，例如短的 `Author` 与较长的学科提示词会共同决定自动标签列宽；即使整个两列网格在几何上居中，标签和值线的视觉重心仍可能显得偏离页面中心。

学术型与专业型模板使用的英文提示词不同，所以 `template/nenu-template.typ:134-142` 为 `template.offset_en` 分别设置视觉补偿：学术型为 `-45pt`，专业型为 `-5pt`。这不是公开配置项。该值经 `template/modules/template-cover.typ:53-54` 传入通用函数，并在 `template/modules/template-cover.typ:23` 作为 `dx: offset` 只移动信息网格；标题、页首、页脚和日期不会随之移动。

内部片段（仅用于定位）：

#figure(
  caption: [英文信息栏视觉偏移常量],
  kind: image,
  ```typst
  template.offset_en = -45pt // 学术型
  template.offset_en = -5pt  // 专业型
  ```
)

应先按真实学位类型设置 `config.isAcademic`，不要为修正对齐而误用它。用户可根据论文实际填写的英文姓名、导师和学科信息，分别小幅调整对应分支的 `template.offset_en`；两套提示词和元数据长度不同，两个值应独立校准。负值的绝对值增大时网格继续左移，可能接近页边界。修改后必须分别以 `isAcademic: true` 和 `isAcademic: false` 编译，使用各自真实且最长的英文信息检查网格与页面中心、下划线和页边距，再运行最小与完整检查。

== 符号和缩略语说明

公开层由 `config.showAbbreviationsList` 控制是否显示页面，由 `info.abbreviations` 提供按顺序排版的记录。调用位置为 `template/nenu-template.typ:283-285`。`abbr` 和 `description` 可使用字符串或数学等可排版内容，最小配置片段如下：

#figure(
  caption: [符号和缩略语配置示例],
  kind: image,
  ```typst
  showAbbreviationsList: true,

  abbreviations: (
    (abbr: "LLM", description: "大语言模型（Large Language Model）"),
    (abbr: $sigma$, description: "标准差"),
  ),
  ```
)

开关为 `false` 只是不生成该列表，不会把 `info` 的其他字段变成可选项；仍应保留完整契约。`template/modules/template-abbr.typ:4-11` 按元组原顺序遍历，不会自动排序、去重或统一术语。段落行距 `0.5em`、非两端对齐、单元格内边距 `0.489em` 和网格列宽均为内部规则，改变这些样式需要编辑该模块。

较长公式可能挤压说明列，较长说明可能增加行高；调整顺序或措辞应在 `info.abbreviations` 完成，不要为单个条目修改模板。检查时分别使用 `showAbbreviationsList: true` 和 `false` 编译，并在开启状态下保留文本、数学符号和长说明三类条目；内部样式改动需运行最小与完整检查。

=== 列表左右单元格比例

列表比例没有公开 `info` 或 `config` 字段。`template/modules/template-abbr.typ:7-10` 将网格固定为 `columns: (1fr, 4fr)`，即扣除单元格内边距后的可分配宽度名义上按 1:4 分给缩略语和说明。若左列经常包含较宽公式，可直接在该内部位置调整，例如：

#figure(
  caption: [缩略语列表列宽比例],
  kind: image,
  ```typst
  columns: (1fr, 3fr),
  ```
)

增大左列占比会减少说明列宽并增加说明换行，缩小左列则可能使公式或长缩写换行；不存在对所有论文都最优的比例。只应根据实际最长条目做一次全局调整。修改后运行两项编译检查，并在临时 PDF 中核对最宽左项、最长说明、跨页处和页面右边界。

== 下划线

正文下划线的模板默认偏移位于 `template/nenu-template.typ:259-260`，当前为 `3pt`，没有对应的 `info` 或 `config` 字段。只需改变论文某一局部时，不必修改模板，可在正文内容块中使用更靠后的局部规则：

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

该规则作用于其后的摘要、目录和正文等内容中的 Typst `underline`，并不控制 A4 信息栏的横线。封面横线由 `template/modules/template-cover.typ:12` 的单元格底边 `0.5pt` 绘制，长度由同文件 `7-10` 的 `underline_zh_length`、`underline_en_length` 控制。偏移过小会压住字形，过大则可能碰到下一行；检查时应同时观察中文、拉丁字母、上下标附近和连续多行的下划线。内部默认值改动后运行两项编译检查，局部规则只需运行完整检查。

== 数学公式字体

数学字体没有公开配置项。基础字体名定义在 `template/modules/fonts.typ:2-18`，当前 `FONT_MATH` 为 `New Computer Modern Math`；`template/modules/fonts.typ:20-25` 再组成 `(FONT_MATH, FONT_SONGTI)` 回退序列。`template/nenu-template.typ:147-151` 将该序列应用于数学公式。要全局更换数学字体，应修改内部常量，而不是逐个公式设置字体：

#figure(
  caption: [数学字体内部常量],
  kind: image,
  ```typst
  #let FONT_MATH = "Libertinus Math"
  ```
)

上例来自 `template/modules/fonts.typ:13` 已列出的候选字体名，但使用前仍须确认本机或 `assets/fonts` 中确实存在该字体。可先检查 Typst 能识别的字体族：

#figure(
  caption: [Typst 可用字体检查命令],
  kind: image,
  ```powershell
  typst fonts --font-path assets/fonts
  ```
)

数学字体会影响行内与独立公式的字形、符号覆盖、基线和公式宽度，但不会改变 `info` 内容。名称错误可能导致字体警告或回退，不同数学字体的度量也可能改变换行。修改后运行最小与完整检查，并重点查看教程数学章节中的希腊字母、算子、分式、矩阵、定界符、上下标以及中西文相邻处。

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

公式编号没有公开配置项。`template/nenu-template.typ:198-207` 在每个一级标题开始时把公式计数器清零；`template/nenu-template.typ:230-234` 使用当前一级标题计数和公式计数生成 `(章号.公式号)`，并将引用补充文字设为“公式”。若规范要求连字符，只修改这条内部编号规则：

#figure(
  caption: [公式连字符编号规则],
  kind: image,
  ```typst
  set math.equation(numbering: (n) => {
    numbering("(1-1)", counter(heading).get().first(), n)
  }, supplement: [公式])
  ```
)

改变格式会同步影响自动引用的显示，但不会修复正文中手写的旧编号；这正是应始终使用标签的原因。移除一级标题处的重置还会改变全篇计数语义，不应作为仅更换分隔符的手段。修改后运行两项编译检查，并至少核对两个连续章节的首个和末个公式、章内递增、跨章重置及 `@eq-...` 引用。

== 图表编号

公开的 `showIllustrationCatalog` 和 `showTablesCatalog` 只控制目录是否显示，不控制图表编号。作者应继续用标准 `figure` 包裹图片或表格并添加标签，以便编号、目录和引用使用同一元素；不要在图题或正文中手写序号。

正文编号规则位于 `template/nenu-template.typ:225-229`，生成“章号.章内号”；`nenu-back-matter` 的 `appendices` 区域由 `template/modules/template-appendix.typ` 局部切换为 `A.1`、`B.2`。`template/nenu-template.typ:198-207` 在每个一级标题开始时分别重置 `kind: table` 和 `kind: image` 的计数器；表题位置和题注字号另由 `template/nenu-template.typ:235-238` 控制。若规范要求连字符，只修改对应区域的内部编号格式：

#figure(
  caption: [图表连字符编号规则],
  kind: image,
  ```typst
  set figure(numbering: (n) => {
    numbering("1-1", counter(heading).get().first(), n)
  })
  ```
)

这条通用 `figure` 规则会影响图片、表格以及其他 figure 种类，但当前章首只显式重置图片和表格；若论文引入自定义 `kind`，应先确认其计数是否需要单独重置。改变格式会同步改变自动引用和目录中的显示，手写图号或表号则会失去同步。修改后运行两项编译检查，并核对至少两个章节中的图片和表格是否分别递增、跨章归零，正文引用以及插图目录和附表目录是否一致。

== 章节引用前后缀

章节标题只需使用标准标题和标签，正文通过 `@标签` 或 `#ref(<标签>)` 引用。正文标题的编号层级由 `template/nenu-template.typ:300-301` 设置为 `"1.1.1.1"`，附录标题由 `template/modules/template-appendix.typ` 切换为“附录A”和 `A.1.1.1`；普通引用的前后缀则由 `template/nenu-template.typ:302-316` 单独改写。正文一级标题引用显示为“第一章”，附录一级标题显示为“附录A”，二级及以下显示对应编号并追加“小节”。非标题引用会在 `template/nenu-template.typ:304-307` 原样返回，因此公式、图片、表格和文献引用仍使用元素自身的补充文字与编号。

前后缀没有公开 `info` 或 `config` 字段。要改变全篇章节引用文字，应编辑内部 `body` 分支，而不是在正文每次引用前后拼接文字。当前核心片段为：

#figure(
  caption: [章节引用文字生成规则],
  kind: image,
  ```typst
  let appendix = el.at("supplement", default: none) == [附录]
  let body = if el.level == 1 {
    counter(heading).display(if appendix {"附录A"} else {"第一章"}, at: loc)
  } else {
    counter(heading).display(if appendix {"A.1.1.1"} else {"1.1.1.1"}, at: loc) + [小节]
  }
  ```
)

例如，一级标题若需阿拉伯数字可使用源文件中已经保留的 `"第1章"` 格式；低层级若需“第...节”，则应在同一分支统一加入前缀和后缀。只改引用分支不会改变标题本身和目录中的编号；若两处都要改变，还需同步评估 `template/nenu-template.typ:300-301` 的标题编号规则。修改后应搜索正文中已经手写的“第”“章”“节”，避免产生重复词，并运行两项编译检查，分别核对一级、二级、三级、四级标题引用以及至少一个非标题引用。

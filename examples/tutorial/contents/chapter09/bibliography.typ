#import "/template/nenu-template.typ": footcite, multicite

= 文献引用与参考文献 <chapter-bibliography>

== nenust 如何使用 bibst

nenust 随模板提供 #link("https://github.com/MoFChen/bibst")[bibst]。bibst 读取文献、解析引文、生成著录文本；nenust 决定论文中文献表的标题、编号框和段落布局。写论文从 `/template/nenu-template.typ` 导入即可，无需另行安装 bibst 或单独运行文献处理程序。以下示例使用 `examples/tutorial/references.bib`；最小示例中的同名文件是空的。

#figure(
  caption: [包含在线载体、URL 和 DOI 的文献元数据],
  kind: image,
  ```bibtex
  @article{chenjianjun2010,
    author   = {陈建军},
    title    = {从数字地球到智慧地球},
    journal  = {国土资源导刊},
    year     = {2010},
    volume   = {7},
    number   = {10},
    pages    = {93},
    medium   = {OL},
    url      = {https://d.wanfangdata.com.cn/periodical/hunandz201010038},
    doi      = {10.3969/j.issn.1672-5603.2010.10.038},
    appendix = {B.4 [5]},
    language = {chinese}
  }
  ```
)

`chenjianjun2010` 是此条文献的唯一引用键，正常排版时显示的是引文而非键名。建议核对责任者、题名、日期、卷期、页码、载体和语言。团体责任者使用双层花括号，例如 `author = {{中国互联网络信息中心}}`；多位责任者使用 `and` 分隔；中文著者-出版年制需要拼音排序时可补充 `sortkey` 或 `sortname`。

== 参考文献著录规则示例完整覆盖

`references.bib` 收录了 GB/T 7714—2025 附录 B 的 141 条编号示例。B.4 [11] 后还有一行未单独编号的英文平行著录，因此带 `appendix` 标记的记录有 142 条，另有 16 条其他示例，合计 158 条。

#figure(
    caption: [教程数据库收录的文献引用记录数],
    table(
      columns: 4,
      stroke: none,
      table.hline(stroke: 1.2pt),
      align: left + horizon,
      table.header([*附录*], [*类型*], [*编号数*], [*记录数*]),
      table.hline(stroke: 0.5pt),
      [B.1], [图书], [25], [25],
      [B.2], [图书析出文献], [10], [10],
      [B.3], [连续出版物], [4], [4],
      [B.4], [连续出版物析出文献], [20], [21],
      [B.5], [会议录], [12], [12],
      [B.6], [学位论文], [6], [6],
      [B.7], [报告], [6], [6],
      [B.8], [标准], [10], [10],
      [B.9], [专利], [8], [8],
      [B.10], [网站与软件], [13], [13],
      [B.11], [档案], [4], [4],
      [B.12], [地图], [10], [10],
      [B.13], [数据集], [9], [9],
      [B.14], [预印本], [4], [4],
      table.hline(stroke: 1.2pt),
    )
  )

每条附录来源记录的 `appendix` 值采用 `B.节 [序号]`；英文平行著录使用 `B.4 [11] EN`。这是教程用来核对覆盖范围的字段，不是撰写个人论文的必填项。bibst 支持带嵌套花括号的字段、字符串宏与拼接、`crossref` 字段继承；Windows 的 CRLF 与 LF 换行都可读取。花括号或引号内的 `%` 作为字段数据保留，例如 `url = {https://example.org/a%20b}` 中的百分号不必转义。

== 外文文献与语言字段

`toshokanyogo2004` 是日文图书，附录中还包含日文专利、法文标准和葡萄牙文网页；`kochetkov1993` 来自同一标准正文第 5.1 节的俄文示例。内置处理器依次检查 `langid`、`language`、`lang`。都未填写时，它主要按题名中的字符推断中文或英文，不能可靠地区分日文或识别俄文。多语种记录应显式填写语言。

#figure(
  caption: [日文与俄文 BibTeX 记录],
  kind: image,
  ```bibtex
  @book{toshokanyogo2004,
    editor    = {{図書館用語辞典編集委員会}},
    title     = {最新図書館用語大辭典},
    address   = {東京},
    publisher = {柏書房株式会社},
    year      = {2004},
    pages     = {154},
    appendix  = {B.1 [17]},
    language  = {japanese}
  }

  @article{kochetkov1993,
    author   = {Кочетков, А. Я.},
    title    = {Молибден-медно-золото-порфировое месторождение Рябиновое},
    journal  = {Отечественная геология},
    year     = {1993},
    number   = {7},
    pages    = {50--58},
    language = {russian}
  }
  ```
)

西文和俄文姓名建议使用 `姓, 名` 形式；团体责任者使用双层花括号。数据库应直接保存 UTF-8 字符，不要使用当前解析器不支持的 LaTeX 日文或西里尔字母命令。正文中的日文示例见@toshokanyogo2004，俄文示例见@kochetkov1993。

== 初始化文献引擎

在 `main.typ` 中把 *BibTeX 文本*传给 `init-bibliography`，因此应写 `read("references.bib")`，而不是只传文件名。每篇文档只初始化一次，并把文献规则写在论文模板之前，使模板生成的摘要与用户正文处于同一引文作用域。以下是教程默认预览所用的设置：

#figure(
  caption: [初始化文献引擎并显式列出全部开关],
  kind: image,
  ```typst
  #import "settings.typ": config, information
  #import "/template/nenu-template.typ": *
  #show: init-bibliography.with(
    read("references.bib"),
    style: "numeric",
    show-url: false,
    show-online: false,
    show-identifiers: false,
    show-doi: false,
    show-cstr: false,
    show-urn: false,
    show-pid: false,
    show-accessed: false,
    show-backlinks: false,
  )
  #show: nenu-template.with(config, information)
  ```
)

`style` 只有 `"numeric"` 和 `"author-date"` 两个值。顺序编码制按有效引用键第一次登记的次序编号；著者-出版年制按作者等信息排序，必要时用年份后缀区分同一作者同年的文献。可以按@sec-tutorial-previews 的方法比较两种输出。

上述显示开关的默认值均为 `true`，关闭是教程入口的选择。`show-online` 控制类型标识中的 `/OL`，`show-accessed` 控制适用条目的引用日期，`show-url` 控制访问路径。永久标识符另有总开关 `show-identifiers`：关闭后，即使 `show-doi: true` 也不单列 DOI。若只保留 DOI，让总开关和 `show-doi` 为 `true`，将 `show-cstr`、`show-urn`、`show-pid` 设为 `false`。`pid` 中能识别为 DOI、CSTR 或 URN 的值跟随相应类型开关；已包含在显示 URL 中的标识符不重复著录。`show-backlinks` 控制的是文献表返回引用处的箭头，不会关闭从正文到文献条目的链接。

== 正文引用

最短写法是 `@引用键`。例如，国际传播能力建设研究可参考@jiangfei2020a，在线期刊示例见@chenjianjun2010，数据集与预印本分别见@zhenghan2018 和@jenkins2012。也可显式调用 `cite`，例如系统学资料#cite(<qianxuesen2001>)。

引用具体页码时，把页码放在引用键后的方括号中，如 `@caoling2011[19]`，排版结果为@caoling2011[19]。合并多条来源可使用 `#multicite[@jiangfei2020a @walls2013 @jiangfei2020b]`，结果为#multicite[@jiangfei2020a @walls2013 @jiangfei2020b]。叙述式合并结果为#multicite("jiangfei2020a", "jiangfei2020b", form: "prose")。

每条来源都有独立补充信息时，内容块写法的实际结果为 #multicite[@caoling2011[19] @qianxuesen2001[序2-3]]。也可以用字典为每条引用分别提供补充信息，例如 #multicite((key: "fengyoulan2008", supplement: [第1版自序]), (key: "ayang2023", supplement: [15-18]))。

#figure(
  caption: [正文引用、合并引用和隐藏引用],
  kind: image,
  ```typst
  国际传播能力建设见 @jiangfei2020a。
  具体页码见 @caoling2011[19]。
  同一作者的文献：#multicite("jiangfei2020a", "jiangfei2020b", form: "prose")。
  多篇合并：#multicite("yangzongying1996", "wangbing1997")。
  各自带补充信息：#multicite[@caoling2011[19] @qianxuesen2001[序2-3]]。
  字典写法：#multicite(
    (key: "fengyoulan2008", supplement: [第1版自序]),
    (key: "ayang2023", supplement: [15-18]),
  )。
  #nocite("luxunmuseum2021") /* 纳入列表但不显示正文标记 */
  #nocite("*")               /* 纳入数据库中的全部记录 */
  ```
)

拆分出的章节拥有独立作用域；若章节直接调用 `footcite`、`multicite` 或 `nocite`，需要在该章节中导入对应名称。正文应始终使用引用键，不要手工输入 `[1]`，移动或增加引用后 Typst 会重新计算序号。

有不同输出需要时，可以显式写 `#cite(<jiangfei2020a>, form: "author")` 或将 `form` 换成 `"year"`、`"full"`；后者给出完整著录，可带补注。内置处理器遇到未知键时，可见的 `#cite(<missing>)` 会显示红色的 `[??missing??]`，不占有效文献的序号；`nocite` 或 `multicite` 中的未知键会报错。因此“能生成 PDF”并不等于所有引用都已找到。

== 脚注文献引用 <sec-footcite>

需要把单篇引文放在页底时，使用 `footcite` 创建文献脚注，不要再把它包进 `footnote`。正文只显示模板现有的脚注圈码；使用内置 GB/T 处理器时，脚注内容显示与参考文献列表一致的完整著录文本，并链接到参考文献中的对应条目。例如，脚注文献引用#footcite(<chenjianjun2010>)，带定位信息的写法见此处#footcite(<caoling2011>, supplement: [19])。

#figure(
  caption: [脚注文献引用],
  kind: image,
  ```typst
  脚注文献引用#footcite(<chenjianjun2010>)。
  带定位信息#footcite(<caoling2011>, supplement: [19])。
  ```
)

`footcite` 一次接收一个标签或键名字符串，补注随完整著录显示；脚注中的来源也参与编号和文献筛选。内置 GB/T 模式下由后文的文献表提供链接目标。不要在标题、图题或表题中放置文献脚注，以免它们在目录中再次排版。

== 参考文献、附录和后记

`nenu-bibliography-render()` 默认只输出已引用或通过 `nocite` 纳入的记录。仓库的最小示例和教程都显式选择了 `full: true`；教程用它展示库中全部 158 条记录。若从示例复制论文而只想列出已引用的文献，请去掉 `full: true`，也不要调用 `nocite("*")`。输出文献表后再用 `begin-appendices`、`end-appendices` 切换附录状态，后者同时生成无编号的“后记”标题：

#figure(
  caption: [后置内容装配],
  kind: image,
  ```typst
  #nenu-bibliography-render(full: true)

  #begin-appendices()
  = 补充材料
  这里撰写附录内容。
  #end-appendices()

  这里撰写后记正文。
  ```
)

`nenu-bibliography-render` 在顺序编码制下测量最宽序号，以定宽编号框和悬挂缩进对齐条目；著者-出版年制则使用不带编号框的段落。较长条目可跨页。定制对齐和间距见@sec-bib-layout。

== 已有 CSL 样式时怎样选择 <sec-csl-route>

若期刊或学院提供普通 CSL 样式，把它放在论文入口旁。下例假设文件名为 `style.csl`，可作为使用教程文献库的独立入口。在已有论文中，应*替换*原有的初始化和文献表调用；若章节调用了 `multicite`，还要把这些调用改为原生引文。不要保留第二条初始化规则。

```typst
#import "settings.typ": config, information
#import "/template/nenu-template.typ": *
#show: init-csl.with(read("references.bib"), read("style.csl"))
#show: nenu-template.with(config, information)

示例引文：@chenjianjun2010。
#render-bibliography()
```

- *普通 CSL*：交给 Typst 原生处理器。URL、载体、永久标识符和引用日期由样式决定，将对应开关设为 `false` 会报错。`multicite`、`get-cited-entries` 和自定义 `renderer` 不适用，多篇来源可用相邻的原生引文。文献表使用 `render-bibliography()`；nenust 的 `nenu-bibliography-render()` 自带 GB/T 专用渲染器，在此模式下会报错。
- *识别出的 Zotero 中文 GB/T 7714—2025 样式族*：bibst 改用内置兼容处理器，并按样式的引文制式选择输出；它不逐条执行该 XML 的宏。此时可使用 GB/T 开关和 nenust 的文献表布局。
- *其他含不支持的 CSL-M 扩展的样式*：初始化时报错，不会静默按普通 CSL 排版。要检查判定结果，可从 `/template/modules/bibliography.typ` 单独导入 `inspect-csl`，查看 `inspect-csl(read("style.csl")).mode`。

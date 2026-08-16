#import "/template/nenu-template.typ": multicite

= 文献引用与参考文献 <chapter-bibliography>

== 唯一示例数据库

本教程把用户可运行的完整文献示例集中在 `examples/tutorial/references.bib`。每条 BibTeX 记录都有一个仅在源码中使用的唯一引用键：

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

引用键只用于源码，不会显示在论文中。建议核对责任者、题名、日期、卷期、页码、载体和语言。团体责任者使用双层花括号，例如 `author = {{中国互联网络信息中心}}`；多位责任者使用 `and` 分隔；中文著者-出版年制需要拼音排序时可补充 `sortkey` 或 `sortname`。

== 参考文献著录规则示例完整覆盖

`references.bib` 完整收录了 GB/T 7714—2025 附录 B 的 141 条编号示例。B.4 [11] 后还有一行未单独编号的英文平行著录，因此数据库使用 `appendix` 字段标记 142 条附录来源记录；其中 18 条复用原有记录，最终共有 158 条记录。

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

每条来源记录的 `appendix` 值采用 `B.节 [序号]`；英文平行著录使用 `B.4 [11] EN`。这些记录用于展示和回归测试，不代替对原始文献的核验。完整标准文本中的 URL 若含 `%`，写入 BibTeX 时必须转义为 `\%`，否则 `%` 后的内容会被当作注释。

== 外文文献与语言字段

`toshokanyogo2004` 是日文图书，附录中还包含日文专利、法文标准和葡萄牙文网页；`kochetkov1993` 取自同一标准正文第 5.1 节的俄文示例。这些记录都显式填写 `language`：日文省略该字段会被 CJK 自动检测误判为中文，其他非英文外文省略时会被当作英文。

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

文献模块由模板直接导出，不需要社区包或 plugin。文献引擎必须先于论文模板应用：

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
    show-doi: false,
    show-accessed: false,
    show-backlinks: false,
  )
  #show: nenu-template.with(config, information)
  ```
)

两个 `show` 规则依次处理同一份文档，因此模板生成的摘要和用户正文共享引用顺序。`style` 也可设为 `"author-date"`。五个显示开关均默认为 `true`；教程入口显式关闭它们以缩短完整文献列表。`show-online: false` 只隐藏类型标识中的 `/OL`，`show-doi: false` 隐藏单独著录的 DOI、CSTR、URN 和 PID 等永久标识符，`show-backlinks: false` 只关闭文献表后的返回箭头。若永久标识符同时保存在 `url` 字段中，还需通过 `show-url` 决定该 URL 是否显示。

== 正文引用

最短写法是 `@引用键`。例如，国际传播能力建设研究可参考@jiangfei2020a，在线期刊示例见@chenjianjun2010，数据集与预印本分别见@zhenghan2018 和@jenkins2012。也可显式调用 `cite`，例如系统学资料#cite(<qianxuesen2001>)。

带页码或章节时，学校要求把引文页码作为独立上标，写成@caoling2011[19]。合并多条来源可使用 `#multicite[@jiangfei2020a @walls2013 @jiangfei2020b]`，结果为#multicite[@jiangfei2020a @walls2013 @jiangfei2020b]。叙述式合并结果为#multicite("jiangfei2020a", "jiangfei2020b", form: "prose")。

每条来源都有独立补充信息时，内容块写法的实际结果为 #multicite[@caoling2011[19] @qianxuesen2001[序2-3]]；各组“序号 + 页码”直接相邻，不插入标点。等价的字典写法结果为 #multicite((key: "fengyoulan2008", supplement: [第1版自序]), (key: "ayang2023", supplement: [15-18]))。

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

拆分出的章节拥有独立作用域；若章节直接调用 `multicite` 或 `nocite`，需要在该章节中导入对应名称。正文应始终使用引用键，不要手工输入 `[1]`，移动或增加引用后 Typst 会重新计算序号。

== 参考文献、附录和后记

正式论文调用 `nenu-bibliography-render()` 时默认只输出已引用或通过 `nocite` 纳入的记录；教程使用 `full: true` 检查全部 158 条记录。参考文献之后通过 `begin-appendices` 和 `end-appendices` 显式切换附录状态，后者同时生成无编号的“后记”标题：

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

`nenu-bibliography-render` 在顺序编码制下自动测量最宽序号，以定宽编号框和悬挂缩进对齐文献文本；较长条目仍可跨页。只有 `show-backlinks: true` 时才显示回链。著者-出版年制继续使用普通段落布局。编号对齐和间距的内部定制见附录“参考文献编号布局”。使用内置 GB/T 处理器时直接调用该函数即可；使用原生 CSL 时不能使用它提供的自定义 renderer，应改为直接调用底层 `render-bibliography()`。底层 API、CSL/CSL-M 路由和条目记录字段以 `template/modules/bibliography.typ` 与其子模块的当前导出为准。

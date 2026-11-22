= 项目结构与编译流程

上一章通过修改题名确认了论文可以编译。现在考虑另一种情况：在新文件里写好一章，保存后 PDF 却没有变化。编译器从指定的入口开始，只处理入口直接或间接使用的文件。本章沿着“文件由谁读取、内容在何处排版”这两条线索，说明一篇论文如何从几个文件组装成册。

== 项目结构

下面以在仓库中把 `examples/empty/` 复制为 `examples/my-thesis/` 为例。起步时只需保留副本中的入口、配置和文献库；`assets/`、`contents/` 在有图片或要分章时再创建。

#figure(
  caption: [仓库内的模板、示例与个人论文目录],
  table(
    columns: 2, align: horizon + left,
    table.hline(stroke: 1.2pt),
    "目录结构", "解释",
    table.hline(stroke: 0.5pt),
    "nenust/",                "",
    "├ template/",            "模板实现，普通写作通常不修改",
    "│ └ assets/",            "模板使用的字体和学校标志",
    "└ examples/",            "",
    "  ├ empty/",             "空论文项目，模板使用最小示例",
    "  ├ tutorial/",          "该模板使用教程的项目代码",
    "  └ my-thesis/",         "实际论文项目，可任取名称",
    "    ├ assets/",          "论文的图片和数据",
    "    ├ contents/",        "论文各章节",
    "    ├ main.typ",         "模板、章节和后置内容装配入口",
    "    ├ settings.typ",     "模板配置和论文信息",
    "    └ references.bib",   "参考文献数据库",
    table.hline(stroke: 0.5pt),
  )
)

论文的 `main.typ` 是编译入口；`template/nenu-template.typ` 提供论文版式以及 bibst 的常用引文函数。文献引擎由 `template/modules/bibliography.typ` 及同级的 `bibliography/` 目录共同组成。升级模板时应保留这两部分，自己的章节、图片和 `.bib` 文件则留在论文目录中。

可以从要改的对象反推源文件。例如，封面和 PDF 属性里的中文题名都来自 `settings.typ` 的 `information.title.zh`；若只是封面题名需要数学排版，保留纯文本题名，另填 `display_zh`。调整章节顺序则只需移动 `main.typ` 中的 `include`，不必重命名文件。修改已引用论文的页码或卷期，应改 `references.bib` 里对应键的记录，而不是在生成的文献表上改字。

== 模板生成顺序

`#show: nenu-template.with(config, information)` 只接管它之后的内容。完整输出分为三部分：

- 前置部分：`include_outer_cover` 只控制 A3 外封面。A4 中英文信息页、委员会页、声明页、双语摘要和全文目录仍会生成。插图目录、附表目录和符号说明各有独立开关；

- 用户正文：章节由 `main.typ` 按顺序加载，随后显式渲染参考文献、进入附录、退出附录并撰写后记；

- 模板追加的后置内容：成果表、非空时的获奖列表，以及博士模式下的导师评语和答辩委员会决议页。

这里有两个容易混淆的步骤。`read("references.bib")` 读到的是文本；`init-bibliography` 把这些文本作为后续引文的数据源。它并不在初始化位置印出文献表，文献表要到调用 `nenu-bibliography-render()` 的位置才出现。同理，`settings.typ` 虽然包含摘要，决定摘要出现在声明页之后、目录之前的却是论文模板。因此两个 `show` 规则应放在入口开头，正文章节放在它们之后。

核对页序时，可以从正文首页往两侧翻：向前应找到目录与摘要，向后应依次找到自己装配的章节、文献表、附录与后记。若没有写附录标题，单独调用 `begin-appendices()` 不会凭空生成一章；`end-appendices()` 会生成“后记”标题，随后直接接后记内容即可。

== 对照教程的预览版本 <sec-tutorial-previews>

不指定参数时，`examples/tutorial/main.typ` 使用 `settings.typ` 的配置，按顺序编码制列出完整文献库。要比较另一种制式，无需编辑配置或复制教程。在仓库根目录运行：

```powershell
typst compile --root . --font-path template/assets/fonts --input preview=author-date-full examples/tutorial/main.typ author-date-full.pdf
```

`examples/tutorial/previews.json` 列出可用的预览名。`anonymous-double` 同时启用匿名与双面排版；`author-date-full` 与 `numeric-full` 则对同一文献库采用两种引文制式。预览覆盖只在教程入口生效。要生成与 Pages 一致的整套 PDF 和对照页面，运行 `python scripts/build_pages.py`，从 `_site/` 提供静态页面。

对照时先确定要观察什么。比较两种文献制式，可以在两个 PDF 中找到同一条正文引文，再沿链接跳到文献表：来源不变，标注方式和排序可能改变。比较 `tutorial` 与 `anonymous-double` 时，要分开看两件事：作者栏留空来自匿名设置，插入空白页来自双面设置。若要判断某个开关是否造成变化，在自己的 `settings.typ` 中每次只改一项，给两次编译指定不同的 PDF 文件名。

== 拆分章节

在 `settings.typ` 中保存 `config` 和 `information`，在 `main.typ` 中按阅读顺序装配章节。下例中的章节文件需要先在 `contents` 目录中创建：

#figure(
  caption: [`main.typ` 入口文件的章节加载顺序],
  kind: image,
  ```typst
  #import "settings.typ": config, information
  #import "/template/nenu-template.typ": *

  /* 文献引擎和论文模板分别接管后续内容 */
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

  /* 加载章节 */
  #include "contents/01-introduction.typ"
  #include "contents/02-method.typ"
  #include "contents/03-experiments.typ"
  #include "contents/04-conclusion.typ"

  /* 参考文献 */
  #nenu-bibliography-render()

  /* 附录 */
  #begin-appendices()
  = 补充材料
  这里撰写附录内容。
  #end-appendices()

  这里撰写后记正文。
  ```
)

拆分的单位是可以独立维护的内容，不是 PDF 的某一页。一个章节可以跨页，也可以再包含多个小节文件。先试拆绪论：创建 `contents/01-introduction.typ`，把原来在入口中的标题和正文一并移入文件，再把原位置替换为一条 `include`。不要同时保留两份标题。下面给标题加上标签，方便稍后的方法章引用：

#figure(
  caption: [章节文件源码示例],
  kind: image,
  ```typst
  = 绪论 <chap-intro>
  这里撰写研究背景、研究问题和论文结构。
  == 研究背景
  这里撰写小节内容。
  ```
)

在后面的章节写 `研究问题见 @chap-intro。`，然后编译论文的 `main.typ`。目录中应当只有一个“绪论”，引用应当跳到该标题。这个小练习把三种常见现象区分开了：目录中没有绪论，先查入口有没有包含文件；出现两次，查标题是否复制后没有移走；有标题却不能跳转，查标签和引用的拼写。

== 路径、include 与 import

读路径时要分清三个位置：终端的工作目录、Typst 的项目根目录、写下这条路径的源文件。下面三条路径可以在同一次编译中出现，各自有不同的参照点：

- 在仓库根目录执行 `typst compile --root . --font-path template/assets/fonts examples/my-thesis/main.typ`。命令中的入口和字体目录从终端当前目录查找；`.` 将仓库指定为项目根目录。
- 入口中的 `/template/nenu-template.typ` 从上述项目根目录查找，开头的 `/` 不表示系统盘根目录。`read("references.bib")` 则读取入口文件旁边的文献库。
- 若从 `contents/01-introduction.typ` 调用 `image("../assets/imgs/typst.png")`，先从 `contents/` 返回论文目录，再进入 `assets/imgs/`。把这条调用移入更深一层的文件时，应重新计算相对路径。

`include` 将另一个文件的可排版内容插入当前位置；`import` 则导入函数、变量等定义：

#figure(
  caption: [路径解释],
  kind: image,
  ```typst
  /* 先创建该文件，再通过 include 插入其内容 */
  #include "contents/01-introduction.typ"
  #import "/template/nenu-template.typ": nenu-template
  ```
)

这一区别也解释了为什么在入口里导入过 `multicite`，被包含的章节仍可能报告找不到它。每个 `.typ` 文件有自己的变量作用域：在哪个章节直接调用该函数，就在哪个章节写 `#import "/template/nenu-template.typ": multicite`。不必在章节里再次初始化文献引擎。

至此，个人论文已有稳定的入口、清楚的素材路径和可验证的章序。下一章转向 `settings.typ`：在保持这些文件关系不变的前提下，选择学位类型，并填入将出现在固定页面上的论文信息。


下面列出的问题指的是在 Typst 中需要特殊处理或目前仍无法完整处理的排版问题。部分问题及其解决方法引用自：

/ Typst 中文社区导航: https://typst-doc-cn.github.io/guide/
/ Typst 中文排版的差距: https://typst-doc-cn.github.io/clreq/

“Typst 中文排版的差距”（下称 clreq-gap）是中文社区维护的早期草案，并未获得 W3C 或 Typst GmbH 背书。以下内容按本教程使用的 Typst 0.15.1 整理；这里的“尚未解决”是指没有完整、原生或足够稳健的通用方案，并不表示所有情况下都无法排版。部分问题可以由模板、局部设置或社区包缓解，但仍需检查最终 PDF。

== 文本方向与页面等价

=== 原生直排与书脊模拟

*引擎限制*：Typst 尚无完整的原生直排行文模式。真正的直排不仅要改变文字流向，还涉及标点形态和位置、中西文字符方向、纵中横、分栏以及图表标题等规则，不能用旋转整个文本块等价替代。

*模板现状*：A3 封面的书脊由 `template/modules/template-cover.typ` 调用 `template/modules/utils.typ` 中的 `v_cjk_latin`，逐个排列字符并将拉丁字母旋转 90 度。这只是书脊专用模拟，不支持正文直排；标题含较多拉丁字符时差异尤其明显。

*实际处理*：普通论文继续使用横排。若书脊必须与官方模板严格一致，应缩短或改写标题、局部手工调整，或者将校方确认过的书脊作为独立图形处理；不要把 `v_cjk_latin` 当成通用直排函数。

参见 #link("https://typst-doc-cn.github.io/clreq/#vertical")[clreq-gap：直排]、#link("https://github.com/typst/typst/issues/5908")[Typst issue 5908] 和 #link("https://www.w3.org/TR/clreq/#writing_modes_in_chinese_composition")[W3C CLReq：行文模式]。

=== Word 式二维网格与逐页等价

*引擎限制*：Typst 可以进行两端对齐，但尚不能像传统稿纸或 Word“文档网格”那样，让字符在横向和纵向同时严格落入固定网格。Typst 与 Word 的断行、字体度量和行距模型也不同，所以相同字体、字号和页边距仍可能得到不同的断行与分页。

*模板缓解*：`template/nenu-template.typ` 已设置 A4 页边距、中文字体、`top-edge: "ascender"`、`bottom-edge: "descender"`、显式 `leading` 和 `justify: true`，用于逼近学校格式。这些设置不能保证与 Word 逐字、逐行、逐页相同。

*实际处理*：提交前应以最终 PDF 为准，逐页检查标题、孤行、图表浮动和总页数。若学院要求毫米级位置或与官方 Word 模板逐页一致，应优先使用官方模板，而不是继续叠加全局负间距或强制分页。

参见 #link("https://typst-doc-cn.github.io/clreq/#strict-2d-grid")[clreq-gap：严格二维网格]、#link("https://github.com/typst/typst/issues/4404")[Typst issue 4404] 和 #link("https://typst-doc-cn.github.io/guide/word.html")[面向 Word 用户的快速入门向导]。

== 标点、禁则与断行

=== `show` 规则可能打断标点压缩

*引擎限制*：连续中文标点原本可以按地区规则压缩，但用替换型 `show` 规则把某个标点改写成新内容后，替换前后的标点可能不再作为连续文本共同压缩。这不表示所有 `show` 规则都会出错，风险主要来自直接替换标点字符的规则。

*模板现状*：模板使用多处 `show` 规则设置样式，但没有全局替换普通中文标点。用户添加标点美化规则或引入会改写标点的包时，仍可能触发这一问题。

*实际处理*：优先用 `set` 或 show-set 规则修改字体、颜色等样式，避免把标点替换成字符串、`box` 或其它新元素。确需替换时，应专门测试连续闭括号、句号和逗号在行中及行末的效果。

参见 #link("https://typst-doc-cn.github.io/clreq/#show-interrupt-punct")[clreq-gap：`show` 打断标点挤压]和 #link("https://github.com/typst/typst/issues/5474")[Typst issue 5474]。

=== 破折号悬挂与 `overhang` 定制

*引擎限制*：中文二字破折号不应作为普通行尾点号悬挂。Typst 在两端对齐时可能悬挂两个连续的 U+2014 `——`；同时，`text.overhang` 目前只有开关，不能按字符分别指定是否悬挂及悬挂比例。

*模板现状*：正文启用了 `justify: true`，但模板没有覆盖默认的 `overhang: true`，所以窄行、图题或长破折号附近可能出现差异。

*实际处理*：可优先使用 Unicode 推荐的 U+2E3A `⸺`，并确认所用字体包含该字形；也可在要求严格的局部内容中设置 `#set text(overhang: false)`。后者会关闭该作用域内所有可悬挂字符，不能只修复破折号，因此仍需检查两端对齐效果。

参见 #link("https://typst-doc-cn.github.io/clreq/#two-em-dash-overhung")[clreq-gap：破折号被悬挂]、#link("https://typst-doc-cn.github.io/clreq/#customize-overhang")[clreq-gap：定制标点悬挂]、#link("https://github.com/typst/typst/issues/6735")[Typst issue 6735]和 #link("https://typst.app/docs/reference/text/text/#parameters-overhang")[`text.overhang` 文档]。

=== 段首夹注符号压缩

*引擎限制*：段落以括号、书名号等夹注符号开始时，标点有时不会按预期压缩半字宽。首行缩进越明确，这种视觉偏差越容易被发现。

*模板现状*：正文统一设置两字首行缩进，因此以 `《`、`（` 等字符开头的段落需要重点检查。

*实际处理*：不要全局改写所有开括号。只在实际出现问题的段落中局部调整水平间距，或者改写句子以避免标点位于段首；手工调整后还要重新检查换行位置。

参见 #link("https://typst-doc-cn.github.io/clreq/#paren-par-start")[clreq-gap：段首夹注符号]和 #link("https://github.com/typst/typst/issues/2348")[Typst issue 2348]。

=== 间隔号的行首禁则

*引擎限制*：人名音译常用的 U+00B7 `·` 按中文基本禁则不应位于行首，但当前断行仍可能把它放到下一行开头。

*模板现状*：模板没有为间隔号添加专门的断行规则。问题主要出现在较窄的表格单元格、图题、标题或长音译姓名中。

*实际处理*：优先改写列宽或句子，让换行避开间隔号。短姓名可整体放入 `box` 以禁止内部断行，但这会增加上一行留白，不适合长串文本。

参见 #link("https://typst-doc-cn.github.io/clreq/#interpunct-line-start")[clreq-gap：间隔号不能位于行首]、#link("https://github.com/typst/typst/issues/6774")[Typst issue 6774]和 #link("https://www.w3.org/TR/clreq/#prohibition_rules_for_line_start_end")[W3C CLReq：行首行尾禁则]。

=== 源码换行产生空格

*语法边界*：同一段内的普通源码换行会被解释为空格。中文虽然不以空格分词，但 Typst 默认不会自动删除两个 CJK 字符之间由源码换行产生的空格。

*模板现状*：模板不改写正文源码，教程的正文写作章节已经说明这一行为。

*实际处理*：不希望出现空格时，可把句子连续书写，或使用 `cjk-unbreak`、`cjk-spacer` 等社区包。使用包会改变整个作用域的源码空白规则，应同时测试中西文混排、代码和有意保留的空格。

参见 #link("https://typst-doc-cn.github.io/clreq/#ignore-linebreak")[clreq-gap：忽略 CJK 源码换行]、#link("https://typst-doc-cn.github.io/guide/FAQ/chinese-remove-space.html")[中文指南：删除源码换行空格]和 #link("https://github.com/typst/typst/issues/792")[Typst issue 792]。

== 中西文与行内元素

=== `raw` 和行内公式两侧的间距

*引擎限制*：Typst 已能在普通相邻的 CJK 与 Latin 字符之间自动加入间距，但该机制尚未完整覆盖 `raw` 和行内 `math.equation` 等独立元素。因此，汉字紧邻 `raw` 内容或行内公式 `$A$` 时，不会自动得到与普通中西文相同的间距。

*模板现状*：`template/nenu-template.typ` 分别为 `raw` 和数学公式设置了字体，但没有给它们的两侧统一加空白，避免在行首、列表项等位置产生额外间距。

*实际处理*：可在需要处手工加入 `#h(0.25em, weak: true)`。也可为行内公式定义 `show` 规则统一添加弱间距，但中文指南记录了它在列表项开头等位置的副作用，所以不应在未检查全文时全局启用。

参见 #link("https://typst-doc-cn.github.io/clreq/#cjk-latin-around-raw")[clreq-gap：`raw` 两侧间距]、#link("https://typst-doc-cn.github.io/clreq/#cjk-latin-around-math")[clreq-gap：行内公式两侧间距]和 #link("https://typst-doc-cn.github.io/guide/FAQ/chinese-space.html")[中文指南：行内公式与中文间距]。

=== 下划线的高度与边缘间距

*引擎限制*：中西文通常使用不同字体，其度量不同，混合文本的下划线可能高低不齐。此外，下划线若结束在自动中西文间距处，线段可能延伸进该间距。

*模板缓解*：模板统一设置 `underline(offset: 3pt)`，可减轻宋体和 Times New Roman 混排时的高度问题，但不能判断某一段线是否应覆盖自动间距。

*实际处理*：局部使用 `offset`、`stroke` 和 `evade` 微调，并检查数字、英文、引号和标点交界处。不要通过全局负间距修正个别词；若线段边缘仍不合适，可把中西文拆成多个 `underline` 范围。

参见 #link("https://typst-doc-cn.github.io/clreq/#underline-misalign")[clreq-gap：中西文下划线错位]、#link("https://typst-doc-cn.github.io/clreq/#underline-cjk-latin")[clreq-gap：下划线延伸到中西间距]和 #link("https://typst-doc-cn.github.io/guide/FAQ/underline-misplace.html")[中文指南：下划线错位]。

=== 中西文引号字形与智能引号

*引擎限制*：中文全宽引号与西文比例宽引号共用 U+2018 至 U+201D 等码位，仅凭字符本身无法始终选择正确字体和宽度。中文不以空格分词，ASCII 直引号转换成智能引号时也存在嵌套或相邻中文判断错误的情况。

*模板缓解*：`template/modules/fonts.typ` 使用 `covers: "latin-in-cjk"` 区分中西文字体；`template/nenu-template.typ` 又让 `smartquote` 使用 Times New Roman。这与中文指南的变通思路相同，但依赖作者区分输入方式。

*实际处理*：中文正文使用输入法直接输入成对的 `“”`、`‘’`，让它们采用中文字体；西文撇号和引号可输入 ASCII `'`、`"`，交由 `smartquote` 转换。复杂嵌套若转换错误，应直接输入最终弯引号并检查字体，不要继续叠加自动替换规则。

参见 #link("https://typst-doc-cn.github.io/clreq/#quotation-mark-width")[clreq-gap：中西文引号宽度]、#link("https://typst-doc-cn.github.io/clreq/#smartquote-wrong")[clreq-gap：中文智能引号]和 #link("https://typst-doc-cn.github.io/guide/FAQ/smartquote-font.html")[中文指南：引号字体与宽度]。

== 行内注与行间注

=== 拼音、注音与 ruby

*引擎限制*：Typst 尚无原生 ruby 模型，因而不能统一处理汉语拼音、注音符号及日文振假名的对齐、跨行和语义。社区包可以完成常见示例，但复杂内容可能在对齐、断行和 PDF 文本选择方面出现问题。

*模板现状*：模板没有封装拼音或注音接口，也不会为社区包调整行高。

*实际处理*：需求较少时可手工组合，重复使用时可评估 `hundouk` 等社区包。无论采用哪种方式，都应测试多音节文本、标点、行末换行、复制文字和最终 PDF；不要只凭单行示例判断可用性。

参见 #link("https://typst-doc-cn.github.io/clreq/#pinyin")[clreq-gap：标注拼音]、#link("https://github.com/typst/typst/issues/1489")[Typst issue 1489]和 #link("https://www.w3.org/TR/clreq/#h_inline_notes")[W3C CLReq：行间注]。

=== 割注

*引擎限制*：Typst 尚无专用、稳健的割注模型。用小字号、`grid` 或 `stack` 可以模拟短例子，但难以自动满足两行分配、标点、跨行和直排时的完整规则。

*模板现状*：模板没有实现割注。普通学位论文通常也不需要这种传统行内注释形式。

*实际处理*：若学校规范允许，优先改用 Typst 原生脚注或正文括注；必须使用割注时，应限制内容长度、局部手工排版并逐处复核。原生脚注本身是已支持功能，不应因割注缺失而写成“Typst 不支持脚注”。

参见 #link("https://typst-doc-cn.github.io/clreq/#warichu")[clreq-gap：割注]、#link("https://github.com/typst/typst/issues/193")[Typst issue 193]和 #link("https://www.w3.org/TR/jlreq/#inline_cutting_note")[JLReq：割注]。

== PDF 标准与无障碍

=== Tagged PDF、PDF/UA 与合规性

*引擎能力与边界*：Typst 默认生成 Tagged PDF，并支持 PDF/UA-1 和多种 PDF/A 标准，所以“Typst 不支持无障碍 PDF”或“Typst 不能导出 PDF/A”都是错误说法。不过，默认带标签只提供无障碍基础，不代表文档已经符合 PDF/UA；PDF/UA-2 目前也尚未支持。

*模板缓解*：`template/nenu-template.typ` 设置了文档标题、作者、关键词、日期以及 `lang: "zh"`、`region: "cn"`，并尽量使用标题、列表、图表等语义元素。这些设置不能替代作者提供替代文本，也不能在模板源码内强制 CLI 的 PDF 标准参数。

*实际处理*：需要无障碍交付时，应使用 `--pdf-standard ua-1` 编译，并修复编译器报告的问题；还要人工检查阅读顺序、颜色对比和语义是否正确。普通编译成功不能作为 PDF/UA 合规证明。

参见 #link("https://typst.app/docs/reference/pdf/")[Typst PDF 文档]和 #link("https://typst.app/docs/guides/accessibility/")[Typst 无障碍指南]。

=== 图片与公式替代文本

*引擎能力与作者责任*：`image` 和 `math.equation` 都支持 `alt`。PDF/UA-1 要求有语义的图片和公式提供替代描述，其中公式目前必须由作者用自然语言描述，Typst 不会自动从公式生成可访问的说明。

*模板现状*：模板不会自动猜测图片或公式含义，也没有给所有教程图片补写 `alt`。图题 `caption` 与替代文本用途不同，不能相互代替。

*实际处理*：为内容图片设置简洁、与上下文相关的 `alt`；纯装饰内容使用 `pdf.artifact`；为需要无障碍导出的公式设置 `math.equation(alt: ...)`。应使用 Typst 原生标题、列表、`figure`、`table` 等元素，而不是只画出相同外观。

参见 #link("https://typst.app/docs/guides/accessibility/#textual-representations")[无障碍指南：文本替代]、#link("https://typst.app/docs/reference/visualize/image/#parameters-alt")[`image.alt`]和 #link("https://typst.app/docs/reference/math/#accessibility")[数学公式无障碍]。

=== 表格语义与复杂表格

*引擎能力与边界*：原生 `table` 能保留表格语义，`table.header` 可标记表头；用于视觉排列的 `grid` 没有表格语义。复杂表格的 `pdf.table-summary`、显式表头单元格和数据单元格 API 目前仍是临时功能，需要启用 `a11y-extras`，且官方 Web App 暂不提供这些功能。

*模板现状*：模板对 `table` 的边距、对齐和线条设置不会自动判断哪些行是表头。用户若用 `grid` 模拟数据表，视觉上相似也不会获得相同的无障碍结构。

*实际处理*：数据表使用 `table` 和 `table.header`，仅做版面排列时才使用 `grid`。复杂表格应尽量简化，并在正文或图题中说明核心结论；只有确有导航困难时才考虑临时的 PDF 专用 API。

参见 #link("https://typst.app/docs/guides/accessibility/#layout-containers")[无障碍指南：布局容器]、#link("https://typst.app/docs/reference/pdf/#pdf-specific-functionality")[PDF 专用无障碍功能]和 #link("https://typst.app/docs/reference/pdf/table-summary/")[`pdf.table-summary`]。

=== 作为图像嵌入的 PDF

*引擎限制*：把 PDF 文件作为图像嵌入时，其版本不能高于输出 PDF；当前也不能在指定 PDF/A、PDF/UA 等标准导出时使用这类 PDF 图像。源 PDF 中已有的标签不会保留，因此不能依赖它们提供无障碍信息。

*模板现状*：教程允许插入 PDF 图像，并已在插图章节说明这些限制；模板本身无法转换或修复用户提供的 PDF 图像。

*实际处理*：需要标准化或无障碍导出时，优先把矢量图转换为 SVG，并为图像提供新的 `alt`。不要把整页文字或数据表作为 PDF 图片嵌入。

参见 #link("https://typst.app/docs/reference/visualize/image/#parameters-format")[`image` 的 PDF 格式限制]和 #link("https://typst.app/docs/guides/accessibility/#textual-representations")[无障碍指南：图片文本替代]。

== 已有支持与表述边界

=== 脚注并非未支持

Typst 有原生 `footnote`，模板还通过页眉上下文让脚注圈码逐页重新编号。clreq-gap 的“脚注、尾注等”章节目前只是待继续调查，不能据此推断中文脚注不可用。已知的具体边界之一是标题中的脚注也会出现在目录内容中；最简单的做法是避免在标题中使用脚注，确有需要时再采用状态变量变通。

参见 #link("https://typst.app/docs/reference/model/footnote/")[Typst 脚注文档]和 #link("https://typst-doc-cn.github.io/guide/FAQ/footnote-in-heading.html")[中文指南：避免标题脚注进入目录]。

=== 不应扩大为通用缺陷

Typst 0.15.1 已默认支持普通 CJK 与 Latin 字符之间的自动间距、可变字体、Tagged PDF、PDF/UA-1 和多种 PDF/A 标准。本附录记录的是这些能力在特定元素边界、专业中文规则或合规工作流中的剩余限制，不应概括成“中西文间距不可用”“可变字体不可用”或“Typst 没有无障碍输出”。功能和问题状态会随 Typst 版本变化，升级后应重新检查 clreq-gap、官方变更日志及相关 issue。

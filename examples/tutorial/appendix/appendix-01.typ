#import "../utils.typ": *

高级功能只应解决已经出现的问题。普通论文如果只包含文字、公式、图片、表格和文献，不需要循环、上下文或额外绘图库。

本附录只介绍论文中较常用的编程能力，并以 Typst 0.15.1 为准。完整语法见#link("https://typst.app/docs/reference/scripting/")[官方 Scripting 参考]，各种内置类型和函数见#link("https://typst.app/docs/reference/foundations/")[Foundations 参考]。

== 语法模式、值与类型

Typst 默认处于标记模式，`#` 从标记模式进入一个代码表达式，`$...$` 进入数学模式；代码中的 `[...]` 又会创建可排版的内容。简单变量可直接写成 `#name`，含运算符的表达式应写成 `#(1 + 2)`。

#figure(
  caption: [语法模式与常用类型],
  kind: image,
  typst-code-example(```typst
  #let count = 42
  #let progress = 75%
  #let body = [*内容值*]

  计算：#(count + 8) \
  公式：$sum_(i=1)^3 i$ \
  进度：#progress \
  类型：#type(count)，#type(body)
  ```)
) <fig-appendix-test>

常用值还包括字符串 `"Typst"`、布尔值 `true`/`false`、长度 `8pt`、数组 `(1, 2)`、字典 `(name: "张三")`、缺省值 `none` 和智能默认值 `auto`。用 `type(value)` 检查类型；判断缺省值时直接写 `value == none`。涉及金额等十进制精确计算时使用 `decimal("0.1")`，不要把已经不精确的浮点字面量传给 `decimal(0.1)`。

官方参考：#link("https://typst.app/docs/reference/syntax/")[Syntax]、#link("https://typst.app/docs/reference/foundations/type/")[Type]、#link("https://typst.app/docs/reference/foundations/decimal/")[Decimal]。

== 绑定、解构与代码块

`let` 创建变量或函数绑定；没有赋值的绑定以 `none` 初始化。变量在当前代码块或文件后续部分可见，也可以用 `=`、`+=` 等重新赋值。数组按位置解构，字典按键名解构；`..name` 收集剩余项，`_` 丢弃不需要的项。

#figure(
  caption: [绑定与解构],
  kind: image,
  typst-code-example(```typst
  #let (x, y) = (3, 4)
  #let values = (1, 2, 3, 4)
  #let (first, ..middle, last) = values
  #let student = (
    name: "李华",
    major: "物理学",
  )
  #let (name, major: subject) = student

  坐标：(#x, #y) \
  三段：#first，#middle，#last \
  学生：#name（#subject）
  ```)
)

花括号 `{...}` 是代码块，内部语句用换行或分号分隔，不需要重复写 `#`。代码块会依次合并各表达式的结果；`let` 和赋值产生 `none`，不会留下可见内容。不要简单记成“总是返回最后一行”，而应避免无意中让中间表达式产生输出。

#figure(
  caption: [代码块与赋值],
  kind: image,
  typst-code-example(```typst
  #let result = {
    let count = 3
    count += 2
    let square = count * count
    [结果：*#square*]
  }

  #result
  ```)
)

官方参考：#link("https://typst.app/docs/reference/scripting/#bindings")[Bindings and Destructuring]、#link("https://typst.app/docs/reference/scripting/#blocks")[Blocks]。

== 条件与循环

条件本身也是表达式，会产生被选中分支的值。分支既可以使用 `{...}` 计算普通值，也可以使用 `[...]` 直接生成内容。条件适合根据配置或数据做少量选择：

#figure(
  caption: [条件语句示例],
  kind: image,
  typst-code-example(```typst
  #let score = 86
  #let result = if score >= 90 {
    "优秀"
  } else if score >= 60 {
    "合格"
  } else {
    "不合格"
  }

  成绩：#score；结果：#result。
  ```)
)

`for` 适合从数组、字典或字符串生成重复内容；循环变量也支持解构。字典可以直接写成 `for (key, value) in dict`，不必先构造临时的 `.pairs()` 数组。

#figure(
  caption: [循环语句示例],
  kind: image,
  typst-code-example(```typst
  #let terms = ("Typst", "PDF", "BibTeX")
  #for term in terms [
    - #term
  ]
  ```)
)

`while` 更适合次数由状态决定的计算。循环每次迭代的结果也会被合并，因此可以让每轮返回单元素数组，最终得到一个完整数组：

#figure(
  caption: [while 循环示例],
  kind: image,
  typst-code-example(```typst
  #let powers = {
    let n = 1
    while n <= 8 {
      (n,)
      n *= 2
    }
  }

  #powers.map(str).join("、")
  ```)
)

`break` 提前结束循环，`continue` 跳过当前轮。如果手写三项更清楚，就不要为了“可扩展”改成数据驱动。

官方参考：#link("https://typst.app/docs/reference/scripting/#conditionals")[Conditionals]、#link("https://typst.app/docs/reference/scripting/#loops")[Loops]。

== 数组、字典与方法

数组 `(a, b)` 按整数索引保存值，索引从零开始，负索引从末尾计算。单元素数组必须写成 `(a,)`，空数组写成 `()`。字典 `(key: value)` 按字符串键保存值，空字典必须写成 `(:)`；已知键可用 `.key`，动态键或需要默认值时用 `.at("key", default: ...)`。

#figure(
  caption: [数组、字典与方法],
  kind: image,
  typst-code-example(```typst
  #let records = (
    (name: "李华", score: 86),
    (name: "王伟", score: 58),
    (name: "张敏", score: 93),
  )
  #let passed = (
    records
      .filter(it => it.score >= 60)
      .map(it => it.name)
      .join("、")
  )
  #let info = (title: "论文", year: 2026)

  通过：#passed \
  末项：#records.at(-1).name \
  作者：#info.at("author", default: "未填写")
  ```)
)

`value.method(args)` 是类型作用域函数的简写，例如 `word.len()` 等价于 `str.len(word)`。常用数组方法有 `map`、`filter`、`find`、`enumerate`、`zip`、`sum`、`join` 和 `sorted`。Typst 目前不能定义自己的方法；`push`、`pop`、`insert`、`remove` 等内置方法会修改接收它们的值，普通数据转换优先使用返回新数组的 `map` 和 `filter`。

官方参考：#link("https://typst.app/docs/reference/foundations/array/")[Array]、#link("https://typst.app/docs/reference/foundations/dictionary/")[Dictionary]、#link("https://typst.app/docs/reference/scripting/#methods")[Methods]。

== 内容值

方括号创建 `content`。正文标记和大多数排版函数的结果都是 content，因此可以保存在变量中、传给函数，也可以用 `+` 拼接或乘以整数。花括号负责计算，方括号负责组织要排版的内容，两者可以任意嵌套。

#figure(
  caption: [content 的组合与复用],
  kind: image,
  typst-code-example(```typst
  #let greeting = (
    [你好，] + strong[Typst] + [！]
  )
  #let answer = {
    let value = 6 * 7
    [答案是 *#value*。]
  }

  #greeting \
  #answer \
  #([重复] * 2)
  ```)
)

代表元素的 content 还带有字段。例如显式创建的 `heading(level: 2)[方法]` 可读取 `.body` 和 `.level`。可选字段只有在构造元素时显式给出才保证可直接读取；由 set rule 提供的样式值应通过 `context` 获取。

官方参考：#link("https://typst.app/docs/reference/foundations/content/")[Content]、#link("https://typst.app/docs/reference/scripting/#fields")[Fields]。

== 自定义函数与模块

=== 自定义函数

重复三次以上且规则稳定的排版可以提取为函数。参数可以是必需的位置参数、带默认值的命名参数和尾随 content 参数；函数体可以是一个表达式或代码块，必要时可用 `return` 提前返回。

#figure(
  caption: [自定义函数示例],
  kind: image,
  typst-code-example(```typst
  #let note(
    title,
    fill: luma(235),
    body,
  ) = block(
    fill: fill,
    inset: 8pt,
    radius: 4pt,
    [*#title* \ #body],
  )
  #let warning = note.with(
    "注意",
    fill: rgb("#fff2cc"),
  )

  #warning[先完成正文，再提取组件。]
  ```)
)

匿名函数 `x => x * x` 常作为 `map`、`filter` 等方法的参数。`..sink` 可以收集多余参数，反过来，`..array` 或 `..dictionary` 可以把集合展开为函数实参：

#figure(
  caption: [参数汇与参数展开],
  kind: image,
  typst-code-example(```typst
  #let total(..values) = (
    values.pos().sum(default: 0)
  )
  #let numbers = (2, 3, 5)

  总和：#total(..numbers)
  ```)
)

自定义函数是纯函数：相同参数会得到相同结果。少数修改接收值的内置方法是例外。函数只在一个章节使用时放在该章节顶部，被多个章节复用时再移入独立模块。

官方参考：#link("https://typst.app/docs/reference/foundations/function/")[Function]、#link("https://typst.app/docs/reference/foundations/arguments/")[Arguments]。

=== 模块、import 与 include

`import` 读取另一个文件公开的变量和函数，但不插入该文件的正文；`include` 执行文件并把产生的 content 插入当前位置。下面是多文件关系，只展示源码而不在本教程内执行：

#figure(
  caption: [模块导入与内容包含],
  kind: image,
  block[
    *`utils.typ`*
    ```typst
    #let note(title, body) = block(
      fill: luma(235),
      inset: 8pt,
      [*#title* \ #body],
    )
    ```

    *`chapter.typ`*
    ```typst
    == 实验结果

    本章正文。
    ```

    *`main.typ`*
    ```typst
    #import "utils.typ": note

    #note("提示")[模块导入成功。]
    #include "chapter.typ"
    ```
  ]
)

写 `#import "utils.typ"` 会得到名为 `utils` 的模块，随后可调用 `utils.note`；写冒号则直接导入指定定义，`as` 可以重命名。公共模块应优先显式列出需要的定义，不必习惯性使用 `*`。Typst 0.15 的路径统一使用正斜杠 `/`；相对路径从当前 `.typ` 文件所在目录解析，以 `/` 开头的路径从项目根目录解析。

官方参考：#link("https://typst.app/docs/reference/scripting/#modules")[Modules]、#link("https://typst.app/docs/reference/foundations/module/")[Module]、#link("https://typst.app/docs/reference/foundations/path/")[Path]。

== 上下文

样式、页码、计数器和当前位置等信息会随内容放置位置变化，需要使用 `context`。上下文表达式会延迟到实际排版位置求值，并形成不透明的 content；依赖上下文值的判断和计算都要留在 `context` 内部。

#figure(
  caption: [读取样式上下文],
  kind: image,
  typst-code-example(```typst
  #let language-name = context {
    if text.lang == "zh" {
      [中文]
    } else {
      [English]
    }
  }

  #set text(lang: "zh")
  #language-name \
  #set text(lang: "en")
  #language-name
  ```)
)

同一个 `language-name` 放在不同样式环境中会得到不同结果，不能在 context 外把它当作普通字符串比较。计数器的当前值同样依赖位置；更新计数器所产生的 content 必须实际插入文档才会生效：

#figure(
  caption: [上下文计数器示例],
  kind: image,
  typst-code-example(```typst
  #let count = counter("appendix-demo")
  #count.step()
  第一次：#context count.display() \
  #count.step()
  第二次：#context count.display()
  ```)
)

context 内的代码可能因排版收敛而执行零次、一次或多次，不要依赖执行次数。上下文代码较难调试，只有确实需要读取样式、计数器或位置时才使用；普通交叉引用直接使用标签。

官方参考：#link("https://typst.app/docs/reference/context/")[Context]、#link("https://typst.app/docs/reference/introspection/counter/")[Counter]。

#import "fonts.typ": *

/* 附录状态 */
#let appendix-state = state("nenu-appendix", false)

/* 判断指定位置是否位于附录 */
#let is-appendix-at(loc) = appendix-state.at(loc)

/* 理工科标题 */
#let num-science(..args) = numbering("1.1.1.1", ..args.pos())

/* 社科标题 */
#let num-social(..args) = {
  let nums = args.pos()
  let formats = ("第一章", "一、", "（一）", "1.")
  numbering(formats.at(nums.len() - 1, default: "1."), nums.last()) + if nums.len() != 1 {h(-0.3em)}
}

#let normal-heading-numberers = (
  science: num-science,
  social: num-social,
)

/* 附录标题编号 */
#let num-science-appendix(..args) = {
  let nums = args.pos()
  numbering(if nums.len() == 1 {"附录A"} else {"A.1.1.1"}, ..nums)
}
#let num-social-appendix(..args) = {
  let nums = args.pos()
  let formats = ("附录A", "一、", "（一）", "1.")
  numbering(formats.at(nums.len() - 1, default: "1."), nums.last()) + if nums.len() != 1 {h(-0.3em)}
}

#let appendix-heading-numberers = (
  science: num-science-appendix,
  social: num-social-appendix,
)

/* 标题视觉样式 */
#let heading-styles = (
  // 一级标题
  (
    before: 42pt,
    after: 29pt,
    alignment: center,
    block: (width: 100%),
    text: (font: FONTS_HEITI, size: 16pt, weight: "regular")
  ),
  // 二级标题
  (
    before: 0pt,
    after: 4pt,
    alignment: left,
    block: (breakable: false),
    text: (font: FONTS_HEITI, size: 14pt, weight: "regular")
  ),
  // 三级标题
  (
    before: 0pt,
    after: 2pt,
    alignment: left,
    block: (breakable: false),
    text: (size: 12pt, weight: "bold")
  ),
  // 四级标题
  (
    before: -4pt,
    after: 2pt,
    alignment: left,
    block: (breakable: false),
    text: (size: 12pt, weight: "regular")
  )
)

/* 每章需要重置的计数器 */
#let chapter-counters = (
  counter(figure.where(kind: table)),
  counter(figure.where(kind: image)),
  counter(math.equation)
)

#let reset-chapter-counters() = {
  for c in chapter-counters {
    c.update(0)
  }
}

/* 标题交叉引用编号 */
#let heading-ref-numbering(level, appendix, ..args) = {
  let nums = args.pos()
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
      numbering("1.1.1.1", ..nums,) + [小节]
    }
  }
}

/* 章内编号 */
#let chapter-numbering-at(loc, n, normal, appendix) = {
  let pattern = if is-appendix-at(loc) {appendix} else {normal}
  let chapter = counter(heading).at(loc).first()
  numbering(pattern, chapter, n)
}

/* 正文中的章内编号 */
#let chapter-numbering(n, normal, appendix) = context {
  chapter-numbering-at(here(), n, normal, appendix)
}

/* 图、表编号 */
#let figure-numbering(n) = chapter-numbering(n, "1.1", "A.1")

/* 数学公式编号 */
#let equation-numbering(n) = chapter-numbering(n, "(1.1)", "(A.1)")

/* 页码控制 */
#let nenu-page-numbering(..args) = context {
  let nums = args.pos()
  let n = nums.first()
  let front-start = counter(page).at(<nenu-front-matter-start>).first()
  let main-start = counter(page).at(<nenu-main-matter-start>).first()
  if n < front-start {
    // 封面、声明页等
    none
  } else if n < main-start {
    numbering("I", n - front-start + 1)
  } else {
    numbering("1", n - main-start + 1)
  }
}

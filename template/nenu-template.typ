#import "@preview/cuti:0.4.0": show-cn-fakebold

#import "config/fonts.typ": (FONT_TIMES, FONTS_CODE, FONTS_HEITI, FONTS_MATH, FONTS_SONGTI, FONTS_YAHEI)
#import "config/rules.typ": *
#import "config/styles.typ": nenu-style

#import "modules/bibliography.typ": (
  get-cited-entries,
  init-bibliography,
  init-csl,
  multicite,
  nocite,
  render-bibliography
)
#import "modules/utils.typ": format_info

#import "pages/cover.typ": *
#import "pages/committee.typ": *
#import "pages/declaration.typ": *
#import "pages/abbreviations.typ": *
#import "pages/achievements.typ": *
#import "pages/review-sheet.typ": *

#let nenu-bibliography-render(full: false) = {
  set heading(numbering: none)

  render-bibliography(
    full: full,
    renderer: entries => {
      set par(justify: true, first-line-indent: 0em, hanging-indent: 0em, leading: 0.25em, spacing: 0.5em)

      if entries.len() == 0 {
        none
      } else if entries.first().style == "numeric" {
        grid(
          columns: (auto, 1fr),
          column-gutter: 0.5em,
          row-gutter: 0.5em,
          align: left,

          ..for entry in entries {
            (
              text(
                "[" + str(entry.order) + "]"
              ),
              entry.labeled-rendered,
            )
          },
        )
      } else {
        for entry in entries [
          #entry.labeled-rendered
          #parbreak()
        ]
      }
    }
  )
}

/* 进入附录：切换状态并重置底层 heading counter */
#let begin-appendices() = [
  #appendix-state.update(true)
  #counter(heading).update(0)
]

#let end-appendices() = [
  #appendix-state.update(false)
  #heading(level: 1, numbering: none)[后记]
]


#let nenu-template(config, information, body) = {
  /* 设置文档元数据 */
  set document(
    title: information.title.zh,
    author: if config.anonymous {""} else {information.author.name.zh},
    description: none,
    keywords: (..information.keywords.zh, ..information.keywords.en).filter(keyword => type(keyword) == str),
    date: information.submission_date
  )

  /* 处理论文信息和封面信息 */
  let (info, cover-param) = format_info(config, information)

  /* 章节分页函数 */
  let pagebreak2() = if config.double_sided {
    if config.include_outer_cover {
      pagebreak(to: "even", weak: false)
    } else {
      pagebreak(to: "odd", weak: false)
    }
  } else {
    pagebreak(weak: false)
  }

  /* 设置全文基础样式 */
  set text(lang: "zh", region: "cn", font: FONTS_SONGTI, size: 12pt, baseline: 0pt, top-edge: "ascender", bottom-edge: "descender")
  /* 设置 raw 命令字体 */
  show raw: set text(font: FONTS_CODE)
  /* 设置数学公式字体 */
  show math.equation: set text(font: FONTS_MATH)
  /* 设置智能引号 */
  set smartquote(enabled: true)
  show smartquote: set text(font: FONT_TIMES)
  /* 设置伪粗体 */
  show: show-cn-fakebold
  /* 设置目录样式 */
  set outline(indent: 1em)
  show outline.entry: set block(above: 0.935em)
  show outline.entry.where(level: 1): set text(font: FONTS_HEITI)

  /* 根据学科选择正文标题编号 */
  let normal-heading-numberer = normal-heading-numberers.at(
    config.discipline_group,
    default: num-science,
  )
  let appendix-heading-numberer = appendix-heading-numberers.at(
    config.discipline_group,
    default: num-science-appendix,
  )

  /* 统一 heading numbering */
  let heading-numbering(..args) = context {
    let nums = args.pos()
    if is-appendix-at(here()) {
      appendix-heading-numberer(..nums)
    } else {
      normal-heading-numberer(..nums)
    }
  }
  set heading(numbering: heading-numbering)

  /* 统一 heading show rule */
  show heading: it => context {
    /* 本模板只自定义 1~4 级标题。 */
    /* 五级及以上直接使用 Typst 默认 heading 样式。 */
    let style = heading-styles.at(it.level - 1, default: none)
    if style == none {
      it
    } else {
      /* 一级标题 */
      if it.level == 1 {
        let raw-chapter = counter(heading).get().first()
        /* 第一章不分页；正文从第二章开始分页；所有附录一级标题都分页。 */
        if is-appendix-at(here()) or raw-chapter != 1 {
          pagebreak2()
        }
        /* 每章 / 每个附录重新计数图、表、公式。 */
        reset-chapter-counters()
      }
      /* 根据 heading-styles 统一绘制标题 */
      v(style.before)
      align(
        style.alignment,
        block(..style.block)[#text(..style.text, it)],
      )
      v(style.after)
    }
  }

  /* 标题交叉引用 */
  /* 非 heading 引用完全交回 Typst：图/表/公式/bibliography citation/page ref */
  show ref.where(form: "normal"): it => context {
    let el = it.element
    if el == none or el.func() != heading {
      it
    } else {
      let loc = el.location()
      let appendix = is-appendix-at(loc)
      let nums = counter(heading).at(loc)
      link(loc, heading-ref-numbering(el.level, appendix, ..nums,))
    }
  }

  /* 附录目录过滤 */
  show outline.entry: it => context {
    let el = it.element
    let loc = el.location()
    let appendix = is-appendix-at(loc)

    /* 是否隐藏当前条目 */
    let hidden = (
      /* 正文目录：附录只列一级标题 */
      (el.func() == heading and appendix and el.level > 1)

      /* 插图目录：按开关决定是否列出附录插图 */
      or (el.func() == figure and el.kind == image and appendix and not config.include_appendix_figures)

      /* 附表目录：按开关决定是否列出附录附表 */
      or (el.func() == figure and el.kind == table and appendix and not config.include_appendix_tables)
    )

    if hidden {
      none
    } else {
      let prefix = if el.func() == heading and appendix {
        /* 附录标题 */
        if el.numbering == none {
          none
        } else {
          appendix-heading-numberer(..counter(heading).at(loc))
        }
      } else if el.func() == figure and el.kind == image {
        /* 插图 */
        let n = counter(figure.where(kind: image)).at(loc).first()
        let number = chapter-numbering-at(loc, n, "1.1", "A.1")
        [图 #number]
      } else if el.func() == figure and el.kind == table {
        /* 表格 */
        let n = counter(figure.where(kind: table)).at(loc).first()
        let number = chapter-numbering-at(loc, n, "1.1", "A.1")
        [表 #number]
      } else {
        /* 普通正文标题等 */
        it.prefix()
      }
      link(loc, it.indented(prefix, it.inner()))
    }
  }

  /* 设置正文段落 */
  set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 1em, spacing: 1em)
  /* 设置图/表 */
  set figure(numbering: figure-numbering, placement: none)
  /* 设置表题置于表格上方 */
  show figure.where(kind: table): set figure.caption(position: top)
  /* 设置图表 caption 字号 */
  show figure.caption: set text(size: 10.5pt)
  /* 设置正文表格 */
  set table(align: horizon + center, column-gutter: 1em, row-gutter: 0em, stroke: none)
  /* 设置数学公式 */
  set math.equation(numbering: equation-numbering, supplement: [公式])
  /* 设置脚注 */
  set footnote(numbering: "①")
  set footnote.entry(indent: 0em, separator: line(start: (5%, 0%), length: 32%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: 9pt)
    let loc = it.note.location()
    numbering("①", ..counter(footnote).at(loc))
    it.note.body
  }
  /* 设置下划线 */
  set underline(offset: 3pt)
  set super(typographic: false)
  /* 伪粗体 */
  show: show-cn-fakebold

  /* A3 封面页 */
  if config.include_outer_cover {
    /* 设置A3纸张规格 */
    set page(paper: "a3", numbering: none, flipped: true, margin: 0pt)
    page-cover-a3(config, cover-param, show-second-title: true)
  }

  /* 设置A4纸张规格 */
  set page(paper: "a4", numbering: nenu-page-numbering, margin: (top: 2.75cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm))
  /* A4 中文信息页 */
  page-cover-a4-zh(config, cover-param, show-second-title: false)
  pagebreak2()
  /* A4 英文信息页 */
  page-cover-a4-en(config, cover-param, show-second-title: false)
  pagebreak2()
  /* 委员会信息页 */
  page-committee(
    cover-param.title.zh,
    cover-param.author.val.zh,
    cover-param.supervisors.val.map(s => [#s.name.zh #s.academic_title.zh]).join("；"),
    info.defense.reviewers,
    info.defense.committee
  )
  pagebreak2()
  /* 声明 */
  page-declaration("")
  /* 开始正文前内容 */
  [
    /* 中文摘要 */
    #heading(numbering: none, level: 1)[摘#h(2em)要]
    #metadata(none) <nenu-front-matter-start>
    #info.abstract.zh
    #v(2em)
    #text(weight: "bold", "关键词：")#info.keywords.zh.join("；")
    /* 英文摘要 */
    #heading(numbering: none, level: 1)[*Abstract*]
    #info.abstract.en
    #v(2em)
    #par(first-line-indent: 0em)[#text(weight: "bold", "Key words: ")#info.keywords.en.join("; ")]
    /* 目录 */
    #heading(numbering: none, level: 1)[目#h(2em)录]
    #outline(title: none, depth: 3)
    /* 插图目录 */
    #if config.include_list_of_figures [
      #heading(numbering: none, level: 1)[插图目录]
      #show outline.entry.where(level: 1): set text(font: FONTS_SONGTI)
      #outline(title: none, target: figure.where(kind: image))
    ]
    /* 附表目录 */
    #if config.include_list_of_tables [
      #heading(numbering: none, level: 1)[附表目录]
      #show outline.entry.where(level: 1): set text(font: FONTS_SONGTI)
      #outline(title: none, target: figure.where(kind: table))
    ]
    /* 符号和缩略语说明 */
    #if config.include_abbreviations [
      #heading(numbering: none, level: 1)[符号和缩略语说明]
      #page-abbreviations(information.abbreviations)
    ]
    /* 设置页眉 */
    #set page(header: context[
      /* 重新计算每页的脚注序号 */
      #counter(footnote).update(0)
      /* 页眉内容 */
      #place(center + top, dy: 44pt,
        [
          #text(font: FONTS_HEITI, cover-param.page_header)
          #line(length: 100%, stroke: 0.5pt)
        ]
      )
    ])
    /* 分页，正文前内容结束标记 */
    #pagebreak2()
    #metadata(none) <nenu-main-matter-start>
    /* 开始正文 */
    #body
    /* 学术成果 */
    #page-achievements(information.achievements, information.awards)
    /* 评语 */
    #if config.degree_level == "doctoral" [
      #page-supervisor-review(
        cover-param.title.zh,
        cover-param.author.val.zh,
        cover-param.supervisors.val.map(s => [#s.name.zh #s.academic_title.zh]).join("；"),
        information.review.supervisors
      )
      #page-committee-review(
        cover-param.title.zh,
        cover-param.author.val.zh,
        cover-param.supervisors.val.map(s => [#s.name.zh #s.academic_title.zh]).join("；"),
        information.review.committee
      )
    ]
  ]
}

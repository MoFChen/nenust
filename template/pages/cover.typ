#import "../config/fonts.typ": FONT_YAHEI, FONTS_HEITI
#import "../config/styles.typ": nenu-style
#import "../modules/utils.typ": format_cjk_name, v_cjk_latin

#let page-cover-template(header, top-info, logo, title, second-title, information, width, offset, footer, date) = {
  set par(leading: 0.65em)
  let place-top(y, body) = place(center + top, dy: y)[#body]
  let place-bottom(y, body) = place(center + bottom, dy: -y)[#body]

  place-top(37.5pt)[#text(size: 14pt)[#header]]
  place-top(68pt)[
    #set text(size: 10.5pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      align: (right, center, left),
      gutter: 1em,
      ..top-info
    )
  ]
  place-top(92pt)[#line(length: 94%, stroke: 0.5pt)]
  place-top(166pt)[#image(logo, width: 92pt)]
  place-top(268pt)[#text(font: FONT_YAHEI, size: 16pt, title)]
  place-top(316pt)[#text(font: FONT_YAHEI, size: 16pt, second-title)]
  
  place(center + bottom, dy: -158pt, dx: -offset)[
    #set text(size: 12pt)
    #grid(
      columns: (auto, width),
      rows: 19pt,
      inset: 2pt,
      align: (right + bottom, center + bottom),
      stroke: (none, (bottom: 0.5pt + black)),
      ..information
    )
  ]
  place-bottom(98pt)[#text(size: 12pt)[#footer]]
  place-bottom(62pt)[#text(size: 14pt)[#date]]
}

#let name-in-grid(x, y) = grid(
  columns: (1fr, 1fr),
  align: (right, left),
  gutter: 1em,
  x,
  y
)

#let page-cover-a4-zh(c, e, show-second-title: false) = page-cover-template(
  e.header.zh,
  e.top_info.zh,
  e.logo,
  e.title.zh,
  if show-second-title {e.title.en} else {""},
  (
    e.author.key.zh,
    e.author.val.zh,
    ..for (index, sv) in e.supervisors.val.enumerate() {(
      if index == 0 {e.supervisors.key.zh} else {""},
      name-in-grid(format_cjk_name(sv.name.zh), sv.academic_title.zh)
    )},
    e.program.key.primary_discipline.zh,
    e.program.val.primary_discipline.zh,
    e.program.key.secondary_discipline.zh,
    e.program.val.secondary_discipline.zh,
    e.program.key.research_area.zh,
    e.program.val.research_area.zh
  ),
  nenu-style.cover.underline_length_zh,
  nenu-style.cover.horizon_offset_zh,
  [#box(baseline: 2pt, image("/template/assets/imgs/nenu.svg", width: 86pt))#h(0.5em)学位评定委员会],
  e.submission_date.display("[year]年[month]月")
)

#let page-cover-a4-en(c, e, show-second-title: false) = page-cover-template(
  e.header.en,
  e.top_info.en,
  e.logo,
  e.title.en,
  if show-second-title {e.title.en} else {""},
  (
    e.author.key.en,
    e.author.val.en,
    ..for (index, sv) in e.supervisors.val.enumerate() {(
      if index == 0 {e.supervisors.key.en} else {""},
      sv.academic_title.en + " " + sv.name.en
    )},
    e.program.key.primary_discipline.en,
    e.program.val.primary_discipline.en,
    e.program.key.secondary_discipline.en,
    e.program.val.secondary_discipline.en,
    e.program.key.research_area.en,
    e.program.val.research_area.en
  ),
  nenu-style.cover.underline_length_en,
  nenu-style.cover.horizon_offset_en.at(c.degree_type, default: 0pt),
  [Northeast Normal University Academic Degree Evaluation Committee],
  e.submission_date.display("[year], [month]")
)

#let page-cover-a3(c, e, show-second-title: false) = {
  let offset = nenu-style.cover.a3_book_spine_width.at(c.degree_level, default: 0pt)

  /* 绘制背面 */
  place(
    top + left,
    dx: -offset,
    box(
      width: 50%,height: 100%, inset: (top: 2.75cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
      stroke: (right: stroke(dash: "dashed", thickness: 0.5pt), rest: none),
      place(
        center + horizon,
        dy: -40.5pt, dx: 7pt,
        text(font: FONTS_HEITI, size: 16pt)[
          #"勤奋创新".clusters().join([#h(1em)])
          #h(28pt)
          #"为人师表".clusters().join([#h(1em)])
        ]
      )
    )
  )

  /* 绘制顶面 */
  place(top + right, dx: offset,
    box(width: 50%, height: 100%, inset: (top: 2.75cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm), stroke: (left: stroke(dash: "dashed", thickness: 0.5pt), rest: none), page-cover-a4-zh(c, e, show-second-title: true))
  )

  /* 绘制书脊 */
  let main_color = nenu-style.color.book_spine.at(c.degree_level, default: "#808080")
  let chars = (academic: "学", professional: "专")
  let main_char = chars.at(c.degree_type, default: "无")
  if c.degree_level == "master" [
    #place(top + center, dy: 0pt, 
      rect(width: 24pt, height: 114pt, fill: rgb(main_color))
    )
  ] else if c.degree_level == "doctoral" [
    #place(top + center, dy: 118pt, 
      rect(width: 29pt, height: 29pt, fill: rgb(main_color), inset: (top: 7pt), text(font: FONT_YAHEI, size: 18pt, fill: white, main_char))
    )
    #place(top + center, dy: 158pt,
      text(size: 16pt, fill: black, [
        #set par(leading: 0pt, spacing: 1pt)
        #v_cjk_latin(e.title.plain_zh)
      ])
    )
  ] else [

  ]
}

#import "../config/fonts.typ": FONTS_HEITI

#let page-achievements(achievements, awards) = {
  heading(level: 1, numbering: none, "在学期间取得创新性成果情况")
  v(-2pt)
  context [
    #set par(leading: 0.25em, spacing: 0.25em)
    #grid(
      columns: (138pt, 58pt, 138pt, 62pt, 58pt),
      column-gutter: 0pt,
      inset: 5pt,
      rows: auto,
      stroke: 0.5pt,
      align: horizon + center,
      grid.header(
        [*成果名称*],
        [*成果类别*],
        [*刊物名称/出版社名称*],
        [*刊发时间*],
        [*作者次序*]
      ),
      ..for item in achievements {
        (item.title, item.type, item.journal, item.date, item.author)
      }
    )
  ]
  v(39pt)
  if awards.len() != 0 {
    align(
      center,
      [
        #block(width: 100%)[
          #text(font: FONTS_HEITI, size: 16pt, weight: "regular", "参加的研究项目及获奖情况")
          #v(24pt)
        ]
      ]
    )
    context [
      #set enum(indent: 2em, spacing: 1em, number-align: bottom)
      #for award in awards {enum.item(award)}
    ]
  }
}

#import "../config/fonts.typ": FONT_YAHEI
#import "../modules/utils.typ": join_vspace

#let page-committee(title, author, supervisors, reviewers, committee) = {
  place(center + top, dy: 42pt, text(font: FONT_YAHEI, size: 16pt, "学位论文评阅专家及答辩委员会人员信息"))
  place(center + top, dy: 90pt, dx: -5pt, grid(
    columns: (45pt, 34pt, 98pt, 175pt, 111pt),
    column-gutter: 0pt,
    rows: (52pt, 40pt, 40pt, 34pt),
    align: horizon + center,
    stroke: 0.5pt,
    [*论#h(0.25em)文#v(-0.8em)题#h(0.25em)目*],
    grid.cell(colspan: 4)[#title],
    [*作#h(0.25em)者#v(-0.8em)姓#h(0.25em)名*],
    grid.cell(colspan: 4)[#author],
    [*指#h(0.25em)导#v(-0.8em)教#h(0.25em)师*],
    grid.cell(colspan: 4)[#supervisors],
    grid.cell(rowspan: 6)[*#join_vspace("论文评阅人", 1fr)*],
    grid.cell(colspan: 2)[*姓#h(1em)名*],
    [*工作单位/职称*],
    [*总体评价*],

    ..for re in reviewers {(
      grid.cell(colspan: 2)[#re.name],
      [#re.affiliation],
      [#re.evaluation]
    )},

    grid.cell(rowspan: 8)[*#join_vspace("学位论文答辩委员会", 1fr)*],
    grid.cell(colspan: 2)[*姓#h(1em)名*],
    [*工作单位*],
    [*职#h(1em)称*],

    ..for (index, co) in committee.enumerate() {
      if index == 0 {
        (
          [*主#v(-0.8em)席*],
          [#co.name],
          [#co.affiliation],
          [#co.academic_title],
          grid.cell(rowspan: 6)[*委#v(-0.3em)员*]
        )
      } else {
        (
          [#co.name],
          [#co.affiliation],
          [#co.academic_title]
        )
      }
    }
  ))
}

#import "../modules/utils.typ": join_hspace

#let page-review-sheet(sheet_title, prompt, title, author, supervisors, comments) = {
  heading(numbering: none, level: 1)[#sheet_title]
  v(-2pt)
  table(
    columns: (86pt, 1fr, 86pt, 2fr),
    column-gutter: 0pt,
    rows: (50pt, 36pt, 500pt),
    align: horizon + center,
    stroke: 0.5pt,
    [*#join_hspace("论文题目", 1fr)*],
    table.cell(colspan: 3)[#title],
    [*#join_hspace("作者姓名", 1fr)*],
    author,
    [*#join_hspace("指导教师", 1fr)*],
    supervisors,
    table.cell(colspan: 4, align: left + top)[
      #set par(first-line-indent: 2em)
      *#prompt*
      
      #comments
    ]
  )
}

#let page-supervisor-review(title, author, supervisors, comments) = page-review-sheet(
  "导师（组）对学位论文的评语",
  "导师（组）对学位论文的评语：",
  title,
  author,
  supervisors,
  comments
)

#let page-committee-review(title, author, supervisors, comments) = page-review-sheet(
  "答辩委员会决议书",
  "答辩委员会对学位论文及答辩情况的评语：",
  title,
  author,
  supervisors,
  comments
)

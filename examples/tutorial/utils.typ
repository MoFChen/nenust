/* 在模板中用于展示 Typst 代码及其渲染效果，另起项目时不需要，可删除。 */
#let typst-code-example(x) = grid(
  columns: 3, column-gutter: 1em,
  align: (horizon + left, horizon, horizon + left),
  [
    #set par(leading: 0.25em, first-line-indent: 0em)
    #set text(baseline: 0pt)
    #v(0.5em)
    #rect(x, fill: rgb("#eff0f3"), radius: 6pt)
  ],
  $|=>$,
  [
    #set par(leading: 0.25em, spacing: 0.25em, first-line-indent: 0em)
    #set text(baseline: 0pt)
    #v(0.5em)
    #rect(eval(x.text, mode: "markup"), fill: rgb("#eff0f3"), radius: 6pt)
  ]
)

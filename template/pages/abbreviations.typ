#let page-abbreviations(entries) = {
  set par(leading: 0.5em, justify: false)
  grid(
    columns: (1fr, 4fr),
    align: horizon + left,
    inset: 0.489em,
    ..for entry in entries { (entry.abbr, entry.description) }
  )
}
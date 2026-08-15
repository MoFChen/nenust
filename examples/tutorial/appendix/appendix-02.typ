
- A3、A4中英文封面排版不统一（甚至自然科学和人文社科的封面都不一致）
- 封面标题的中英之间缺少空格（无伤大雅，可以自己调整）
- 中文封面信息栏没有对齐
- 奇怪的英文封面信息栏
- 人文社科模板的目录条目与编号之间的间距过大
- 图题之间不定的间距，模板没有做出定义（无伤大雅，可以自己调整）
- 三线表水平偏移（无伤大雅，可以自己调整）
- 页码错乱（无伤大雅，可以自己调整）
- 缺少公式、代码等示例

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.header([方法], [样本数], [准确率]),
    table.hline(stroke: 0.5pt),
    [基线方法#super[a]], [120], [91.2%],
    [本文方法#super[b]], [120], [94.8%],
    table.hline(stroke: 1.2pt),
    table.cell(colspan: 3, align: left)[
      #set text(size: 10.5pt)
      #grid(align: left, columns: 2,
        super[a], [基线方法指MLP],
        super[b], [这是一个非常非常非常非常非常非常长的表格注释，导致表格被拓宽],
      )
    ]
  ),
  caption: [带表注的简单表格示例],
)

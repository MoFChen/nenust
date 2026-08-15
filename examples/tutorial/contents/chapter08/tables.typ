= 表格

== 三线表与表注

模板会把表题放在表格上方。三线表先用 `stroke: none` 关闭默认网格，再添加顶线、表头分隔线和底线：

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
) <tab-results>

正文可直接引用@tab-results。表题应说明比较对象、条件或数据含义，不要复用其他示例的标题。

Typst 尚未支持表注。表下注释可增加一个跨全部列的单元格，并在其中缩小字号、左对齐。确有必要时才使用上标标记。

== 多级表头与合并单元格

复杂表头通过 `table.cell` 的 `rowspan` 和 `colspan` 合并行列：

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(stroke: 1.2pt),
    table.cell(colspan: 2)[Ads空间],
    table.hline(stroke: 0.5pt, start: 0, end: 2),
    table.cell(colspan: 1)[边界CFT],
    table.hline(stroke: 0.5pt, start: 2),
    [几何属性], [场论元素], [CFT算子],
    table.hline(stroke: 1.2pt),
    [黑洞温度], [$T_h=kappa/(2pi)$], [热场双态],
    [曲率半径], [$R^4/alpha'=g^2_(Y M) N$], ['t Hooft 耦合 λ],
    [额外维度紧致化], [Kaluza-Klein 模], [R 对称性荷],
    [时空测地线], [$e^(-m L)$], [两点函数 $⟨O(x)O(y)⟩$],
    table.hline(stroke: 1.2pt),
  ),
  caption: [复杂表格示例],
) <tab-grouped-results>

合并后应核对每行实际占用的单元格数量。出现编译错误或表格错位时，先检查 `rowspan`、`colspan` 和被占用的单元格。

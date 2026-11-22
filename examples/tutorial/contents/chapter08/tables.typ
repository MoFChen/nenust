= 表格

== 三线表与表注

模板会把表题放在表格上方，并已全局设置 `stroke: none` 关闭默认网格。三线表只需添加顶线、表头分隔线和底线；若脱离本模板单独使用示例，再显式补上 `stroke: none`：

#let tablenote(mark, body) = par(
 first-line-indent: 0em , hanging-indent: 0.5em, spacing: 0em, leading: 0em
)[
  #set text(size: 10.5pt)
  #box(width: 0.5em)[#super(mark)]#body
]

#figure(
  table(
    columns: (1fr,1fr,1fr,1fr),
    table.hline(stroke: 1.2pt),
    table.header([方法], [测试样本数], [预测正确数], [准确率#super[b]]),
    table.hline(stroke: 0.5pt),
    [基线方法#super[a]], [120], [110], [91.7%],
    [对比方法], [120], [114], [95.0%],
    table.hline(stroke: 1.2pt),
    table.cell(colspan: 4, align: left)[
      #tablenote([a])[本例假设基线分类器为多层感知机（MLP）。]
      #tablenote([b])[两种方法对同一批样本各预测一次。准确率为预测正确数除以样本数，以百分数表示并保留一位小数。]
    ]
  ),
  caption: [两种分类方法在同一测试集上的准确率（虚构数据，仅示范排版）],
) <tab-results>

正文可直接引用@tab-results。表题应说明比较对象、条件或数据含义，不要复用其他示例的标题。

这里的表注由本章的 `tablenote` 辅助函数排版：在底线下加一个跨全部列的单元格，缩小字号并左对齐。它与页底的 `footnote` 不同，表注标记由作者填写，不占用模板的页脚圈码。

== 多级表头与合并单元格

复杂表头可以用 `colspan` 把相关列归到同一组。下表以 $"AdS"_5 times S^5$ 上的 IIB 型弦论与四维 $cal(N)=4$ 超对称 $"SU"(N)$ 杨–米尔斯理论之间的对偶为例。取自然单位 $ℏ=c=k_"B"=1$，规范耦合采用 $g_"YM"^2=4 pi g_s$ 的约定#footnote[参见 Aharony 等，#link("https://arxiv.org/abs/hep-th/9905111")[Large N Field Theories, String Theory and Gravity]，第 3 章。]。

#figure(
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header(
      table.cell(colspan: 2)[引力侧],
      [边界场论侧],
      [几何对象], [物理量或对称群], [对应的物理意义],
    ),
    table.hline(stroke: 0.5pt),
    [平衡黑洞的视界], [$T_"H"=kappa/(2 pi)$], [边界热态的温度],
    [曲率半径 $R$], [$R^4/(alpha')^2$], [#text(font: "Times New Roman")[’t Hooft] 耦合 $lambda=g_"YM"^2 N$],
    [$S^5$ 的旋转对称性], [$"SO"(6)$], [与 R 对称群 $"SU"(4)$ 有相同的李代数],
    [连接边界两点的测地线], [$exp(-m L_"ren")$], [重标量算符两点函数的主导指数因子],
    table.hline(stroke: 1.2pt),
  ),
  caption: [AdS/CFT 中的对应关系（分组表头示例）],
) <tab-grouped-results>

表中 $kappa$ 是按边界时间归一化的视界表面引力；$alpha'$ 是弦长的平方，所以 $R^4/(alpha')^2$ 无量纲。最后一行采用欧氏测地线近似：体内标量场的质量满足 $m R >> 1$，且一条测地线占主导，$L_"ren"$ 是它的重整化长度。

两层表头共用一条 0.5 pt 的分隔线，放在整个 `table.header` 之后；顶线和底线均为 1.2 pt。合并后若有错位，先核对 `rowspan`、`colspan` 和每行实际占用的单元格数量。

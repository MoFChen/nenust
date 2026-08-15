= 数学公式与交叉引用

“数学模式”是一种 Typst 专门用于排版数学公式的模式。用户可通过用 `$` 字符将公式括起来来启用该模式；这种操作在标记模式和代码模式中均适用。与 LaTeX 对比，Typst 使用更简化的语法和库函数来排版数学公式。

== 行内公式与独立公式

如果公式在开头和结尾都保留空格（例如 `$ x^2 $`），它会被单独排列在一个区块中；若两端都不留空格（例如 `$x^2$`），公式则以行内形式显示。

比如非厄米哈密顿量的本征值方程 $hat(H)|psi_n chevron.r=E_n|psi_n chevron.r, hat(H)!=hat(H)^dagger$，这是一个行内公式。

模板会在每个一级标题开始时重置公式计数器，正文按 `(章号.公式号)`、附录按 `(附录字母.公式号)` 生成编号。需要引用的独立公式应添加唯一标签，不要手工输入括号编号。

== 常用语法

#figure(
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([用途], [代码], [结果]),
    table.hline(stroke: 0.5pt),
    [上下标], [`` `$x_i^2$` ``], [$x_i^2$],
    [分数], [`` `$(a+b)/c$` ``], [$(a+b)/c$],
    [根式], [`` `$sqrt(x)$` ``], [$sqrt(x)$],
    [求和], [`` `$sum_(i=1)^n x_i$` ``], [$sum_(i=1)^n x_i$],
    [希腊字母], [`` `$alpha, beta, Omega$` ``], [$alpha, beta, Omega$],
    [直立文本], [`` `$x " if " x > 0$` ``], [$x " if " x > 0$],
    table.hline(stroke: 1.2pt),
  ),
  caption: [常用数学语法],
)

== 多行公式与矩阵

下面是一个等号对齐的独立公式示例：

$ frac(partial rho, partial t) + nabla dot (rho bold(upright(v))) &= 0 \
  rho(frac(partial bold(upright(v)), partial t)+bold(upright(v)) dot nabla bold(upright(v))) &= -nabla p + mu nabla^2 bold(upright(v)) + (lambda+mu)nabla(nabla dot bold(upright(v)))+rho bold(upright(g)) \
  rho c_p (frac(partial T, partial t)+bold(upright(v)) dot nabla T) &= nabla dot (k nabla T) + Phi + beta T frac(partial p, partial t) \
  p &= rho R T \ 
$ <eq-navier-stokes>

下面是两个矩阵公式示例：

$
F_(mu,nu)=mat(
  0, B_z, -B_y, -i E_x;
  -B_z, 0, B_x, -i E_y;
  B_y, -B_x, 0, -i E_z;
  i E_x, i E_y, i E_z, 0;
)
$

$
underbrace(mat(delim: "[",
  w_(11), ..., w_(1n);
  dots.v, dots.down, dots.v;
  w_(m 1), ..., w_(m n);
), "权重矩阵 "bold(upright(W)) ) + 
overbrace(mat(delim: "[",
  b_1; dots.v; b_m;
), "偏置向量 "bold(upright(b)) ) = bold(upright(Z))
$

分段表达式和带左花括号的方程组可直接使用 `cases`：

$
cases(
  display(x + y + z & = 1),
  display(    y + z & = 0),
  display(    y - z & = 2),
)
$

`cases` 中的 `&` 已经负责跨行对齐。需要自定义行距、定界符或矩阵式布局时，也可以使用 `mat`；在 `mat` 中使用分号换行，下面给出两个例子：

$
lr(
  \{
  mat(
  display(x/t + y/t + z/t & = 1) ;
  display(    y/x + z/x & = 0) ;
  display(        z/y & = 2) ;
  delim: #none,
  row-gap: #0.5em
))
$

$
lr(
mat(
  display(a subset beta \, b subset beta \, a inter b = P) ;
  display(a || alpha \, b || alpha) ;
  delim: #none
) \}) => alpha || beta
$

同一个数学环境下的多个公式只会有一个编号。如果需要分开编号，则需要分开独立的数学环境。

$ frac(partial J(theta), partial theta_j) = - frac(1,m)sum^m_(i=1)(y^i-h_theta (x^i))x^i_j $ <eq-mlp>

$ cal(L)=EE_(q_phi.alt)[log p_theta(x|z)]-beta D_(K L)(q_phi.alt (z|x) || p(z)) $ <eq-vae-loss>

如果需要在文中引用公式，需要在数学环境最后的`$`符号后输入标签, 在正文中引用示例见@sec-labels。

数学环境同样可以呈现简单的化学方程式。

#let bu(x) = math.upright(math.bold(x))

$ bu(Z n)^(2+) stretch(harpoons.rtlb)^(+2 upright(O H)^-)_(+2upright(H)^+) limits(bu(Z n(O H))_2 arrow.b)_("amphoteres Hydroxid") stretch(harpoons.rtlb)^(+2 upright(O H)^-)_(+2upright(H)^+) limits([bu(Z n (O H))_4]^(2-))_("Hydroxozinkat") $

试着引用上面的例子，@eq-navier-stokes 是流体力学的可压缩 Navier-Stokes 方程组；@eq-mlp 描述了代价函数对参数的梯度；变分自编码器（VAE）的目标函数如@eq-vae-loss 所示。

Typst 会根据主体大小自动调整上下标位置。例如 ${NN^1_2}^3_4$ 的外层上下标会远离中心。若确需与内层主体对齐，可加入不可见空白主体：`${NN^1_2}\ ^3_4$`，结果为 ${NN^1_2}\ ^3_4$。

== 数学符号 <sec-math-symbol>

在 Typst 中提供了两个模块 sym#footnote[#link("https://typst.app/docs/reference/symbols/sym/")] <footnote-sym-link> 和 emoji#footnote[#link("https://typst.app/docs/reference/symbols/emoji/")] <footnote-emoji-link> ，这两个模块用于为符号和表情符号分配名称，从而便于使用普通键盘进行输入。当然，也可以直接在文本和公式中输入 Unicode 符号。

如下表所示，数学模式可直接使用符号名 `zeta` 或 Unicode 码（\\u{03B6}）；标记模式则使用代码表达式 `#sym.zeta` 或直接输入 Unicode 字符。`sym.zeta` 本身不是数学模式中的变量，不能直接写成 `$sym.zeta$`。

#figure(
  caption: [符号使用方式],
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([模式], [示例代码], [渲染样式]),
    table.hline(stroke: 0.5pt),
    table.cell(rowspan: 2)[数学模式],
    table.cell(rowspan: 1)[`$zeta$`],
    table.cell(rowspan: 2)[$zeta$],
    table.cell(rowspan: 1)[`$\u{03B6}$`],
    table.cell(rowspan: 2)[标记模式],
    table.cell(rowspan: 1)[`#sym.zeta`],
    table.cell(rowspan: 2)[#sym.zeta],
    table.cell(rowspan: 1)[`\u{03B6}`],
    table.hline(stroke: 1.2pt),
  )
)

常见的符号见下表。

#figure(
  caption: [常见符号的分类及代码举例],
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([分类],[代码],[渲染样式]),
    table.hline(stroke: 0.5pt),
    [希腊字母],[`$Omega,omega$`],[$Omega, omega$],
    [双线字母],[`$RR,NN$`],[$RR,NN$],
    [箭头符号],[`$->,=>,~>,|->,>->,<=>$`],[$->,=>,~>,|->,>->,<=>$],
    [关系符号],[`$=,:=,<,>,<=,>=,!=,>>,<<$`],[$=,:=,<,>,<=,>=,!=,>>,<<$],
    [算术运算],[`$+,-,times,div,sum,product,integral$`],[$+,-,times,div,sum,product,integral$],
    [逻辑符号],[`$and,or,xor,exists,exists.not,forall$`],[$and,or,xor,exists,exists.not,forall$],
    [括号与分隔符],[`$(),[],{},chevron.l chevron.r,||$`],[$(),[],{},chevron.l chevron.r,||$],
    [其他],[`$dot,dot.o,bullet,degree$`],[$dot,dot.o,bullet,degree$],
    table.hline(stroke: 1.2pt),
  ),
)

详细的数学符号表见官网参考文档。

== 数学定理体系（定理、引理、推论、定义、证明）<sec-math-env>

Typst 核心尚未内置数学定理体系。简单文档可以像下例一样手工排版；需要自动编号和引用时，可按项目需求选用 `ctheorems`、`theorion` 等现有社区包。

引用需要输入标签和引用文字，通过 `link` 函数引用，群的定义见#link(<mathenv-def-group>, "定义7.1") 。

#context [
  #set par(first-line-indent: 0em)
  *定义7.1* <mathenv-def-group> (群) 设非空集合 G 和二元运算 #sym.dot ，满足：
  - 结合律：$(a dot b) dot c = a dot (b dot c)$
  - 单位元：$exists e in G "使" forall a in G, e · a = a$,
  - 逆元：$forall a in G, exists b in G "使" a dot b = e$,
  则称 $(G,dot)$ 是一个群。
]

#context [
  #set par(first-line-indent: 0em)
  *公理7.1* <mathenv-axiom-choice> (选择公理) 对任何非空集合族 ${A_i} \ _(i in I)$，存在映射 $f:I-> union.big_i A_i "使得" forall i in I, f(i) in A_i$ 。
]

#context [
  #set par(first-line-indent: 0em)
  *定理7.1* <mathenv-theorem-lagrange> (拉格朗日定理) 有限群 G 的子群 H 的阶整除 G 的阶：|H| | |G|。
]

#context [
  #set par(first-line-indent: 0em)
  *引理7.1* <mathenv-lemmas> 若群 $G$ 中元素 $g$ 的阶为 $n$，则 $g_k = e$ 当且仅当 $n|k$ 。\
  证明 设 $k = n_q + r(0 <= r < n)$，则：\
  $g^k = g^(n q+r) = (g^n)\ ^q · g^r = e^q · g^r = g^r$ \
  故 $g_k = e$ 当且仅当 $r = 0$，即 $n|k$ 。
  #h(1fr)$qed$
]

#context [
  #set par(first-line-indent: 0em)
  *推论7.1* <mathenv-corollarie> 素数阶群必为循环群。
]

#context [
  #set par(first-line-indent: 0em)
  *命题7.1* <mathenv-proposition> 阿贝尔群的子群均为正规子群。
]

#context [
  #set par(first-line-indent: 0em)
  *例7.1* <mathenv-example> (对称群) 集合 $X={1,2,3}$ 上所有双射构成的群 $S_3$（阶为 6），运算为复合映射。
]

== 算法环境

Typst 核心同样没有内置算法环境。可以手工排版简单算法，也可以按需选用 `algorithmic`、`algo` 等社区包。



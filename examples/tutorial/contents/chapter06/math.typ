= 数学公式与交叉引用

“数学模式”是一种 Typst 专门用于排版数学公式的模式。用户可通过用 `$` 字符将公式括起来来启用该模式；这种操作在标记模式和代码模式中均适用。与 LaTeX 对比，Typst 使用更简化的语法和库函数来排版数学公式。

== 行内公式与独立公式

如果公式在开头和结尾都保留空格（例如 `$ x^2 $`），它会被单独排列在一个区块中；若两端都不留空格（例如 `$x^2$`），公式则以行内形式显示。

例如，非厄米哈密顿量满足 $hat(H) != hat(H)^dagger$，其中 $dagger$ 表示厄米共轭。它的右本征态满足 $hat(H) |psi_n chevron.r = E_n |psi_n chevron.r$。这两个公式都是行内公式。

模板会在每个一级标题开始时重置公式计数器，正文按 `(章号.公式号)`、附录按 `(附录字母.公式号)` 生成编号。需要引用的独立公式应添加唯一标签，不要手工输入括号编号。

== 常用语法

#figure(
  table(
    columns: 3,
    table.hline(stroke: 1.2pt),
    table.header([用途], [代码], [结果]),
    table.hline(stroke: 0.5pt),
    [上下标], [`$x_i^2$`], [$x_i^2$],
    [分数], [`$(a+b)/c$`], [$(a+b)/c$],
    [根式], [`$sqrt(x)$`], [$sqrt(x)$],
    [求和], [`$sum_(i=1)^n x_i$`], [$sum_(i=1)^n x_i$],
    [希腊字母], [`$alpha, beta, Omega$`], [$alpha, beta, Omega$],
    [直立文本], [`$x " if " x > 0$`], [$x " if " x > 0$],
    table.hline(stroke: 1.2pt),
  ),
  caption: [常用数学语法],
)

== 多行公式与矩阵

以可压缩牛顿流体的 Navier–Stokes 方程组为例，各行可以按等号对齐。设气体满足理想气体状态方程，动力黏度 $mu$ 和第二黏性系数 $lambda$ 为常数，热流服从傅里叶定律，且无外加体积热源。用 $D_t = frac(partial, partial t) + bold(v) dot nabla$ 表示沿流体运动的物质导数，则

$ frac(partial rho, partial t) + nabla dot (rho bold(v)) &= 0 \
  rho D_t bold(v) &= -nabla p + mu nabla^2 bold(v) + (lambda + mu) nabla (nabla dot bold(v)) + rho bold(g) \
  rho c_p D_t T &= D_t p + nabla dot (k nabla T) + Phi \
  p &= rho R_s T
$ <eq-navier-stokes>

@eq-navier-stokes 的前两行分别表示质量守恒和动量守恒，$bold(g)$ 是单位质量所受的体力。第三行是能量方程的焓形式：$c_p$ 是定压比热容，$k$ 是导热系数，$Phi$ 是单位体积的黏性耗散功率。压力项 $D_t p$ 包含对流项 $bold(v) dot nabla p$。最后一行是状态方程，$R_s$ 是单位质量气体的气体常数。

电磁场张量的矩阵取决于坐标和符号约定。取 $x^mu = (c t,x,y,z)$、度规号差 $(+,-,-,-)$、四维势 $A^mu = (phi/c, bold(A))$，并定义 $F^(mu nu) = partial^mu A^nu - partial^nu A^mu$。按时间、空间的顺序排列行列，其逆变分量为

$
  (F^(mu nu)) = mat(
    0, -E_x/c, -E_y/c, -E_z/c;
    E_x/c, 0, -B_z, B_y;
    E_y/c, B_z, 0, -B_x;
    E_z/c, -B_y, B_x, 0;
  )
$

全连接层的仿射变换是 $bold(z) = bold(W) bold(x) + bold(b)$。权重矩阵有 $m$ 行、$n$ 列；先乘以 $n$ 维输入列向量，再加 $m$ 维偏置列向量，所得输出也是 $m$ 维列向量：

$
underbrace(mat(delim: "[",
  w_(1 1), ..., w_(1 n);
  dots.v, dots.down, dots.v;
  w_(m 1), ..., w_(m n);
), "权重矩阵 "bold(W)) mat(delim: "[", x_1; dots.v; x_n) +
overbrace(mat(delim: "[",
  b_1; dots.v; b_m;
), "偏置向量 "bold(b)) = bold(z)
$

分段表达式和带左花括号的方程组可直接使用 `cases`：

$
cases(
  display(x + y + z & = 1),
  display(    y + z & = 0),
  display(    y - z & = 2),
)
$

`cases` 中的 `&` 用于跨行对齐。若需自定义行距或定界符，可用 `mat`，以分号换行。下面的分式方程组约定 $t != 0$、$x != 0$、$y != 0$：

$
lr(
  \{
  mat(
  display(x/t + y/t + z/t & = 1);
  display(      y/x + z/x & = 3);
  display(            z/y & = 2);
  delim: #none,
  row-gap: #0.5em
))
$ <eq-separate-fractions>

@eq-separate-fractions 逐项保留分母以展示对齐方式。把 $t$ 视作给定的非零实数：由第三行得 $z=2y$，代入第二行得 $x=y$，再由第一行得 $4y=t$。因此解为 $(x,y,z)=(t/4,t/4,t/2)$。例如取 $t=4$，将 $(1,1,2)$ 代回原式，三行的左端依次为 1、3、2。

右花括号可用于列出判定条件。例如在三维欧氏空间中，若平面 $beta$ 内两条相交直线均平行于另一平面 $alpha$，则两平面平行。交集写作单点集 ${P}$：

$
lr(
mat(
  a subset beta and b subset beta and a inter b = {P};
  a parallel alpha and b parallel alpha;
  delim: #none
) \}) => alpha parallel beta
$

一个独立公式即使分成多行也只取一个编号。下面两个学习问题使用各自的独立公式和标签，便于分别引用。

对 $m$ 个样本做线性回归，令预测值为 $hat(y)_i = theta^"T" bold(x)_i$，目标函数为 $J(theta) = 1/(2m) sum_(i=1)^m (hat(y)_i - y_i)^2$。记 $x_(i j)$ 为第 $i$ 个样本的第 $j$ 个特征，则梯度的第 $j$ 个分量为

$ frac(partial J(theta), partial theta_j) = 1/m sum_(i=1)^m (hat(y)_i - y_i) x_(i j) $ <eq-ls-gradient>

变分自编码器（VAE）使用近似后验 $q_(phi)(z | x)$、解码分布 $p_(theta)(x | z)$ 和先验 $p(z)$。在 Typst 中写 `q_(phi)(z | x)`，第一对括号限定下标，第二对括号才是函数的自变量。对一个观测 $x$，将 KL 散度的权重记为 $beta > 0$，按*最小化损失*的约定写成

$ ell_(beta)(x) = - EE_(z ∼ q_(phi)(z | x)) [log p_(theta)(x | z)]
  + beta D_("KL")(q_(phi)(z | x) || p(z)) $ <eq-vae-loss>

@eq-ls-gradient 是平方误差目标的偏导数；@eq-vae-loss 则是损失本身。取 $beta = 1$ 时，最小化后者等价于最大化标准 VAE 的证据下界（ELBO）#footnote[见 Kingma 与 Welling，#link("https://arxiv.org/abs/1312.6114")[Auto-Encoding Variational Bayes]，第 2.2 节。]；改变 $beta$ 得到加权的 $beta$-VAE 目标。引用时把标签放在独立公式结尾的 `$` 之后，见@sec-labels。

上下标的位置也会改变公式含义。例如群元素的幂写作 `$g^k$`，结果为 $g^k$；`$g_k$` 得到的 $g_k$ 通常表示带编号的元素。

== 化学方程式

以下示例只用 Typst 内置的数学模式。元素符号用直立体：`"Zn"^(2+)` 给出 $"Zn"^(2+)$，括号使 `2+` 整体成为电荷上标。`->` 给出单向反应箭头 $->$；表示可逆反应时，用 `harpoons.rtlb` 得到上下两支方向相反的平衡箭头 $harpoons.rtlb$。

*沉淀与配合平衡。* 在水溶液中，锌离子与氢氧根可形成氢氧化锌沉淀；氢氧根过量时，沉淀又可溶解，形成四羟基合锌酸根。沉淀也能溶于酸。前两行写平衡，第三行写酸过量时的净反应方向：

$ "Zn"^(2+) "(aq)" + 2 "OH"^- "(aq)" &harpoons.rtlb "Zn"("OH")_2 "(s)" \
  "Zn"("OH")_2 "(s)" + 2 "OH"^- "(aq)" &harpoons.rtlb ["Zn"("OH")_4]^(2-) "(aq)" \
  "Zn"("OH")_2 "(s)" + 2 "H"^+ "(aq)" &-> "Zn"^(2+) "(aq)" + 2 upright(H_(2)O) "(l)" $ <eq-zinc-equilibria>

@eq-zinc-equilibria 的第二行中，`["Zn"("OH")_4]^(2-)` 把配体数 4 放在圆括号外，把整个配离子的电荷放在方括号外。`(aq)`、`(s)`、`(l)` 分别表示水溶液中的物种、固态和液态。

*在箭头上下标注条件。* 五水硫酸铜脱水与无水硫酸铜水合可以合写为一个总反应。`dot` 连接盐和结晶水；`stretch` 让箭头适应标注宽度。下面的源码可直接放入 `.typ` 文件：

#let hydrate-example = ```typst
$ "CuSO"_4 dot 5 upright(H_(2)O) "(s)"
  stretch(harpoons.rtlb)^"加热脱水"_"吸收水汽"
  "CuSO"_4 "(s)" + 5 upright(H_(2)O) "(g)" $ <eq-hydrate>
```
#hydrate-example
#eval(hydrate-example.text, mode: "markup")

读@eq-hydrate 时，上方标注对应向右脱水，下方标注对应向左水合；`(g)` 表示气态。系数 5 记录总共失去或结合的水分子数，并不表示脱水只经历一步。

*半反应与总反应。* 以锌–铜原电池为例，在同一个数学环境内用 `\` 换行、在箭头前用 `&` 对齐。第一行中锌失去两个电子，第二行中铜离子得到两个电子；相加时消去电子，得到第三行的总反应：

$ "Zn" "(s)" &-> "Zn"^(2+) "(aq)" + 2 upright(e)^- \
  "Cu"^(2+) "(aq)" + 2 upright(e)^- &-> "Cu" "(s)" \
  "Zn" "(s)" + "Cu"^(2+) "(aq)" &-> "Zn"^(2+) "(aq)" + "Cu" "(s)" $

== 数学符号 <sec-math-symbol>

在 Typst 中提供了两个模块 sym#footnote[#link("https://typst.app/docs/reference/symbols/sym/")] <footnote-sym-link> 和 emoji#footnote[#link("https://typst.app/docs/reference/symbols/emoji/")] <footnote-emoji-link> ，这两个模块用于为符号和表情符号分配名称，从而便于使用普通键盘进行输入。当然，也可以直接在文本和公式中输入 Unicode 符号。

如下表所示，小写希腊字母 ζ 的 Unicode 码位是 `U+03B6`。数学模式可直接用符号名 `zeta`；数学和标记模式都可以输入字符 ζ 或转义序列 `\u{03B6}`。

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

手工排版时，`link` 的显示文字也要手工填写，例如#link(<mathenv-def-group>, "定义 7.1")。

#context [
  #set par(first-line-indent: 0em)
  *定义 7.1* <mathenv-def-group>（群）设 $G$ 是非空集合，运算 $dot$ 把 $G times G$ 的每一对元素映到 $G$。若满足下列条件，则称 $(G,dot)$ 为群：
  - 结合律：对任意 $a,b,c in G$，有 $(a dot b) dot c = a dot (b dot c)$。
  - 单位元：存在 $e in G$，使任意 $a in G$ 都满足 $e dot a = a dot e = a$。
  - 逆元：对每个 $a in G$，存在 $b in G$，使 $a dot b = b dot a = e$。
]

#context [
  #set par(first-line-indent: 0em)
  *公理 7.1* <mathenv-axiom-choice>（选择公理）设 $(A_i)_(i in I)$ 是一族集合，且每个 $A_i$ 都非空。存在选择函数 $f: I -> union.big_(i in I) A_i$，使对每个 $i in I$ 都有 $f(i) in A_i$。
]

#context [
  #set par(first-line-indent: 0em)
  *定理 7.1* <mathenv-theorem-lagrange>（拉格朗日定理）设 $H$ 是有限群 $G$ 的子群，则 $abs(G) = [G : H] abs(H)$，其中 $[G : H]$ 是左陪集的个数。因此 $abs(H) divides abs(G)$。
]

#context [
  #set par(first-line-indent: 0em)
  *引理 7.1* <mathenv-lemmas> 设群元素 $g$ 的阶为有限正整数 $n$。对任意整数 $k$，有 $g^k = e$ 当且仅当 $n divides k$。\
  *证明*　带余除法给出 $k = q n + r$，其中 $0 <= r < n$。于是 $g^k = (g^n)^q g^r = g^r$。由于 $n$ 是使 $g^n = e$ 的最小正整数，该范围内只有 $r = 0$ 满足 $g^r = e$。这正是 $n divides k$ 的条件。
  #h(1fr)$qed$
]

#context [
  #set par(first-line-indent: 0em)
  *推论 7.1* <mathenv-corollarie> 素数阶群必为循环群。事实上，取任意非单位元，它生成的子群的阶大于 1，又由拉格朗日定理整除群的阶，因此该子群就是全群。
]

#context [
  #set par(first-line-indent: 0em)
  *命题 7.1* <mathenv-proposition> 阿贝尔群的每个子群都是该群的正规子群。
]

#context [
  #set par(first-line-indent: 0em)
  *例 7.1* <mathenv-example>（对称群）从 $X={1,2,3}$ 到自身的所有双射在映射复合下构成对称群 $S_3$，其阶为 $3! = 6$。
]

== 算法环境

Typst 核心同样没有内置算法环境。可以手工排版简单算法，也可以按需选用 `algorithmic`、`algo` 等社区包。



= 插图与多图排版

== 素材、路径与注意事项

将论文图片放在 `examples/my-thesis/assets` 中，而不是放进模板目录。常用格式包括 PNG、JPEG、SVG、WebP 和 PDF；流程图、结构图等优先使用 SVG，照片和实验截图通常使用 PNG 或 JPEG。

如果论文需要大量图片，也可以分章节存储。可在 `contents` 下建立章节文件夹，并在各章内统一使用 `imgs` 或 `assets` 子目录；本章源码采用与文件同级的 `imgs` 目录，因此下面的相对路径均写作 `imgs/...`。

Typst 支持的插图格式包括：“png”、“jpg”、“gif”、“svg”、“pdf”、“webp”，以及原始像素数据（即未经编码的图像数据）。GIF 在 PDF 中只会输出静态画面。

默认情况下，图片的格式会自动被检测出来。因此，通常只有在提供原始字节数据作为图片来源时才需要手动指定图片格式（Typst 仍会尝试自动判断格式，但不一定能成功）。

请注意，在将 PDF 文件作为图像使用时存在一些限制：

- 作为插图嵌入的源 PDF 版本不能高于输出文档的 PDF 版本。

- 在本教程使用的 Typst 0.15.1 中，若输出文档指定 PDF/A 或 PDF/UA 等标准，不能嵌入 PDF 图片；矢量图可改用 SVG。这是对嵌入图片的限制，并非模板不能导出 PDF。

- 作为图片使用的源 PDF 不能有密码保护。

- 源 PDF 的标签不会随图片保留。有语义的插图应另写替代描述。

image 函数的更多参数和更多示例见 Typst 文档#footnote[#link("https://typst.app/docs/reference/visualize/image/")] <footnote-visualize-image>。

== 图片、图题和引用

使用 `figure` 包裹 `image`，模板才能生成图题、章内编号和插图目录条目：

#figure(
  caption: [SVG 插图颜色替换示例],
  /* SVG 本质上是文本，可以在载入前替换其中的颜色值。 */
  image(bytes(read("imgs/typst.svg").replace("currentColor", "#338eba")), width: 35%, alt: "蓝色 Typst 标志"),
) <fig-svg-color>

通过 `image` 的 `width` 或 `height` 参数控制图片大小。正文可写“如@fig-svg-color 所示”，不要手工输入图号；标签和引用规则见@sec-labels。

== 多图排版

把多张图片放入同一个 `grid`，再用一个 `figure` 加图题，就能共用一个图号。对于以网格组织的组合图，像下例一样显式设置 `kind: image`，使编号与插图目录的筛选条件一致。

#figure(
  caption: [多图纵向排版],
  kind: image,
  grid(
    columns: 40%, /* 单列，宽度为 40% */
    row-gutter: 0.5em,  /* 行间隔 */
    image("imgs/AL.png"),
    image("imgs/BL.png"),
    image("imgs/CL.png"),
    image("imgs/DL.png"),
  ),
)

通过控制 grid 的行列参数可以实现纵向或横向等多种方式排版。

#figure(
  caption: [多图横向排版],
  kind: image,
  grid(
    columns: 4,
    rows: 25%,                /* 控制行高为 25% */
    column-gutter: 0.5em,     /* 列间隔 */
    image("imgs/AH.png"),
    image("imgs/BH.png"),
    image("imgs/CH.png"),
    image("imgs/DH.png"),
  ),
)

#figure(
  caption: [多图矩阵排版],
  kind: image,
  grid(
    columns: (120pt, 120pt),  /* 限制列宽为 120pt */
    gutter: 0.5em,            /* 行列间隔 */
    image("imgs/A.png"),
    image("imgs/B.png"),
    image("imgs/C.png"),
    image("imgs/D.png"),
  ),
)

#figure(
  caption: [多图矩阵不规则排版],
  kind: image,
  grid(
    columns: 2,
    rows: 120pt,          /* 限制行高为 120pt */
    gutter: 0.5em,        /* 行列间隔 */
    align: (right, left), /* 控制每列的对齐方式 */
    image("imgs/AH.png"),
    image("imgs/B.png"),
    image("imgs/CH.png"),
    image("imgs/D.png"),
  ),
)

如果在 grid 里内嵌 figure 就可以每张图分别编号。注意当前模板没有自动生成“(a)”“(b)”子图编号。

/* align 命令用于居中显示。 */
/* 使用 box 包裹 grid 并指定 inset 参数，使得 grid 上下正文的间距为 1em。 */
#align(center,
  box(inset: 1em,
    grid(
      columns: 2,
      rows: 120pt,
      column-gutter: 1em,
      row-gutter: 2.5em,
      align: horizon + center,
      figure(caption: "左上图", image("imgs/A.png")),
      figure(caption: "右上图", image("imgs/B.png")),
      figure(caption: "左下图", image("imgs/C.png")),
      figure(caption: "右下图", 
        grid(
          columns: 4,
          column-gutter: 0.5em,
          image("imgs/AH.png"),
          image("imgs/BH.png"),
          image("imgs/CH.png"),
          image("imgs/DH.png"),
        )
      ),
    )
  )
)

== 尺寸与质量

· 优先只设置 `width`，让高度按原始比例自动计算。

· 位图在目标排版尺寸下应保持足够分辨率；流程图和结构图优先使用 SVG。

· 检查最终 PDF 的图片文字和线条，确认 SVG 没有丢失外部字体或链接资源。

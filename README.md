# nenust

> 东北师范大学（NENU）研究生学位论文 Typst 模板

**[🌐 在线预览](https://mofchen.github.io/nenust/)**
**[📦 下载最新模板](https://github.com/MoFChen/nenust/releases/tag/latest)**
[GB/T 7714-2025 参考文献规则](GBT7714-2025参考文献著录规则.md)
[Typst](https://typst.app/) ·
[Cuti](https://typst.app/universe/package/cuti/)

`nenust` 是一个面向 **东北师范大学研究生学位论文** 的 Typst 模板，支持博士 / 硕士、学术型 / 专业型、理工 / 社科等多种学位论文排版场景。

> [!IMPORTANT]
> 本项目是个人维护的**非官方学术资源**，并非东北师范大学官方发布或授权的论文模板。
>
> 正式提交论文前，请务必以东北师范大学及所在学院最新发布的论文撰写、排版和提交要求为准，并与学校最新版官方模板进行核对。

---

## 📦 下载模板

推荐直接从 GitHub Releases 下载最新构建的模板。

### 带字体版本

适合希望下载后直接使用模板自带字体的用户：

**[⬇️ nenust-template-with-fonts.zip](https://github.com/MoFChen/nenust/releases/download/latest/nenust-template-with-fonts.zip)**

其中包含模板所需字体文件。

### 不带字体版本

适合已经安装相关字体，或者希望自行管理字体文件的用户：

**[⬇️ nenust-template-no-fonts.zip](https://github.com/MoFChen/nenust/releases/download/latest/nenust-template-no-fonts.zip)**

### 单独字体包

如果已经下载了不带字体的模板，可以单独下载字体：

**[⬇️ nenust-fonts.zip](https://github.com/MoFChen/nenust/releases/download/latest/nenust-fonts.zip)**

解压后将字体放入模板的目录即可。

```text
assets/fonts/
```

---

## 🌐 在线预览

无需下载模板或安装 Typst，可以直接通过 GitHub Pages 查看当前模板生成的 PDF：

### 👉 https://mofchen.github.io/nenust/

---

## ✨ 主要特性

* 支持 **博士 / 硕士** 学位论文
* 支持 **学术型 / 专业型** 学位
* 支持不同学科类型的论文排版
* 支持 **匿名评审**
* 支持 **双面排版**
* 支持论文封面
* 支持答辩信息页
* 支持中文摘要与关键词
* 支持英文摘要与关键词
* 支持自动目录
* 支持图目录
* 支持表目录
* 支持缩略语表
* 支持章节、图、表、公式等自动编号
* 支持附录
* 支持后记
* 支持 BibLaTeX / BibTeX 参考文献数据库
* 支持 **GB/T 7714-2025**
* 支持 `numeric` 引用方式
* 支持 `author-date` 引用方式
* 参考文献相关处理使用 Typst 实现
* 提供最小论文示例
* 提供完整教程示例

---

## 🚀 快速开始

### 方式一：从 Release 下载

如果只需要模板核心文件，可以直接下载：

**[nenust-template-with-fonts.zip](https://github.com/MoFChen/nenust/releases/download/latest/nenust-template-with-fonts.zip)**

如果还希望参考完整示例，推荐同时查看：

* [`examples/empty/`](examples/empty/)
* [`examples/tutorial/`](examples/tutorial/)

---

### 方式二：克隆完整仓库

如果希望获得模板、示例、教程以及完整项目结构，推荐克隆仓库：

```bash
git clone https://github.com/MoFChen/nenust.git
cd nenust
```

---

## 📝 创建自己的论文

推荐从 `examples/empty/` 开始。

可以复制为自己的论文目录：

```bash
cp -r examples/empty thesis
```

得到：

```text
thesis/
├── main.typ
├── settings.typ
└── references.bib
```

其中：

* `main.typ`：论文正文入口
* `settings.typ`：论文类型、作者、导师等配置
* `references.bib`：参考文献数据库

---

## ⚙️ 论文配置

论文的主要配置位于 `settings.typ`

通常包括两部分：

* `config`：控制论文类型和排版行为
* `information`：填写作者、论文、导师、答辩等基本信息

常见配置包括：

| 配置               | 说明 | 示例                            |
| ------------------ | ---- | ------------------------------- |
| `degree_level`     | 学位层次 | `"doctoral"` / `"master"`       |
| `degree_type`      | 学位类型 | `"academic"` / `"professional"` |
| `discipline_group` | 学科类别 | `"science"` / `"social"`        |
| `anonymous`        | 匿名评审 | `true` / `false`                |
| `double_sided`     | 双面排版 | `true` / `false`                |

具体填写方式建议参考 `examples/tutorial/settings.typ`

---

## 👤 匿名评审

模板支持匿名评审模式。

启用 `anonymous: true` 后，模板会根据匿名论文要求隐藏或调整相关个人信息。

正常提交版本使用 `anonymous: false`。

建议在最终提交前分别检查：

* 匿名评审 PDF
* 正式论文 PDF

确保个人信息显示符合学院要求。

---

## 📄 双面排版

如果学校或学院要求双面打印，可以启用 `double_sided: true`。

单面排版则使用 `double_sided: false`。

GitHub Pages 中提供了不同配置的 PDF，可以直接用于比较单面和双面模式下的页面效果。

---

## 🧑‍🏫 答辩信息

论文答辩相关信息在 `settings.typ` 中配置。

建议保留模板已有的数据结构。

其中 `defense.reviewers` 必须保留 **5 项**；

`defense.committee` 必须保留 **7 项**。

暂时未知的信息可以填写空字符串，而不是直接删除对应数据项，以避免影响模板的既有排版逻辑。

---

## 📖 编译论文

在仓库根目录执行：

```bash
typst compile \
  --root . \
  --font-path template/assets/fonts \
  examples/empty/main.typ
```

编译完成后会生成对应 PDF。

如果复制为了 `thesis/` 则可以运行：

```bash
typst compile \
  --root . \
  --font-path template/assets/fonts \
  thesis/main.typ
```

---

## 👀 实时预览

写作过程中推荐使用 `typst watch`：

```bash
typst watch \
  --root . \
  --font-path template/assets/fonts \
  thesis/main.typ
```

修改 `.typ` 文件后并保存，Typst 会自动重新编译 PDF。

---

## 📚 参考文献

模板提供针对 **GB/T 7714-2025** 的参考文献支持。

参考文献数据通过 `references.bib` 管理。

例如：

```bibtex
@article{example,
  author  = {张三 and 李四},
  title   = {示例论文标题},
  journal = {示例期刊},
  year    = {2025},
  volume  = {1},
  number  = {2},
  pages   = {1--10},
}
```

支持两种主要引用样式 `numeric` 以及 `author-date`。

项目中同时提供了 GB/T 7714-2025 相关规则整理：

**[GBT7714-2025 参考文献著录规则](GBT7714-2025参考文献著录规则.md)**

---

## 🧪 示例

项目目前提供两类主要示例。

### `examples/empty`

```text
examples/empty/
```

最小论文示例。

适合作为新论文的起点，只保留必要的论文结构和配置。

推荐实际写论文时从这里复制。

### `examples/tutorial`

```text
examples/tutorial/
```

完整功能教程。

用于展示模板提供的主要页面、排版功能、引用方式和配置方式。

如果不想本地编译，也可以通过 GitHub Pages 查看这些配置生成后的 PDF：

**https://mofchen.github.io/nenust/**

---

## 📁 项目结构

```text
nenust/
├── .github/
│   └── workflows/
│       ├── deploy-pages.yml
│       └── release.yml
│
├── examples/
│   ├── empty/
│   │   ├── main.typ
│   │   ├── settings.typ
│   │   └── references.bib
│   │
│   └── tutorial/
│       ├── main.typ
│       ├── settings.typ
│       └── ...
│
├── template/
│   ├── assets/
│   │   └── fonts/
│   ├── config/
│   ├── modules/
│   ├── pages/
│   └── ...
│
├── GBT7714-2025参考文献著录规则.md
├── index.html
├── LICENSE
└── README.md
```

各目录用途：

| 目录                       | 用途                      |
| ------------------------ | ----------------------- |
| `template/`              | 模板核心实现                  |
| `template/assets/`       | 模板资源文件                  |
| `template/assets/fonts/` | 模板字体                    |
| `template/config/`       | 模板配置                    |
| `template/modules/`      | 功能模块                    |
| `template/pages/`        | 封面等固定页面                 |
| `examples/empty/`        | 最小论文示例                  |
| `examples/tutorial/`     | 完整教程                    |
| `.github/workflows/`     | 自动构建、Release 和 Pages 部署 |

---

## 🤝 反馈与贡献

如果发现以下问题，欢迎提交 Issue 或 Pull Request：

* 模板与学校最新格式要求存在差异
* 某类学位论文排版异常
* 封面或答辩页格式问题
* 匿名评审模式存在问题
* 双面排版存在问题
* 参考文献格式不符合要求
* Typst 新版本兼容性问题
* 文档或教程存在遗漏
* GitHub Pages 预览异常

### 提交格式问题时

建议同时提供：

* 学位层次：博士 / 硕士
* 学位类型：学术型 / 专业型
* 学院或学科
* 当前输出效果
* 期望输出效果
* 对应的学校或学院官方要求
* 必要时提供截图

---

## ⚠️ 使用说明

不同年份、学院、专业和学位类型的论文格式要求可能存在差异。

本模板尽可能依据相关格式要求实现自动化排版，但无法保证所有情况下都完全符合最新要求。

因此在正式提交前，请重点检查：

* 封面
* 原创性声明等固定页面
* 答辩信息
* 中英文摘要
* 页边距
* 页眉页脚
* 字体和字号
* 标题层级
* 图表格式
* 公式编号
* 参考文献
* 附录
* 双面打印时的奇偶页行为
* 匿名评审版本中的个人信息

最终请以东北师范大学及所在学院的官方要求为准。

---

## 📄 License

本项目采用 [MIT License](LICENSE)。

---

如果这个模板对你有所帮助，欢迎点一个 **Star ⭐**。

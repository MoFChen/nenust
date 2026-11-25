# nenust

东北师范大学研究生学位论文的**非官方 Typst 模板**，支持硕士和博士、学术型和专业型、理工科和社科。正式提交请以学校及所在学院的最新要求为准。

**[在线版式对照](https://mofchen.github.io/nenust/)** · [使用教程（PDF）](https://mofchen.github.io/nenust/tutorial.pdf) · [下载模板与字体](https://github.com/MoFChen/nenust/releases/tag/latest)

想看配置有什么区别？在版式对照台选「实名 / 匿名」或「两种引文制」，即可对齐两份 PDF 的差异页，无需安装 Typst。

## 快速开始

安装 [Typst CLI](https://github.com/typst/typst/releases)（已验证 0.15.1），然后克隆包含示例的完整仓库：

```sh
git clone https://github.com/MoFChen/nenust.git
cd nenust
```

将整个 [`examples/empty/`](examples/empty/) 目录复制为 `thesis/`，与 `template/` 并列。在 `thesis/settings.typ` 填写论文信息，在 `thesis/main.typ` 写正文。从仓库根目录运行：

```sh
typst watch --root . --font-path template/assets/fonts thesis/main.typ
```

保存后会自动更新 `thesis/main.pdf`；只编译一次可将 `watch` 换成 `compile`。本机尚未缓存 `@preview/cuti:0.4.0` 时，首次编译需联网。

已有论文工程时，可从 Release 下载带字体或不带字体的模板包。包内不含示例；沿用上面的目录结构时，将解压后的 `nenust-template/` 改名为 `template/`。

## 论文配置

[`settings.typ` 示例](examples/tutorial/settings.typ)中，`information` 填写题名、作者、导师及答辩信息，`config` 控制版式：

| 配置项 | 可选值 |
| --- | --- |
| `degree_level` | `"master"`（硕士）、`"doctoral"`（博士） |
| `degree_type` | `"academic"`（学术型）、`"professional"`（专业型） |
| `discipline_group` | `"science"`（理工科）、`"social"`（社科） |
| `anonymous`、`double_sided` | 分别设为 `true` 可启用匿名评审、双面排版 |

- **匿名送审：**模板会隐藏固定栏位的身份信息并清空 PDF 作者字段；仍需自行检查正文、图片、自引和文件名。
- **答辩名单：**`defense.reviewers` 保留 5 项，`defense.committee` 保留 7 项（主席在首位），空位填空字符串。

## 参考文献

将条目写入 `thesis/references.bib`，在正文用 `@文献键` 引用。内置 [bibst](https://github.com/MoFChen/bibst) 按 [GB/T 7714-2025](GBT7714-2025参考文献著录规则.md) 排版，无需安装 Biber。

在 `main.typ` 中用 `style: "numeric"` 选择顺序编码制，或用 `style: "author-date"` 选择著者–出版年制。示例默认展示全库；只列已引文献时，将 `nenu-bibliography-render` 的 `full` 改为 `false`。

[完整教程源码](examples/tutorial/) · [文献引用示例](examples/tutorial/contents/chapter09/bibliography.typ) · [预览站构建步骤](.github/workflows/deploy-pages.yml) · [反馈问题](https://github.com/MoFChen/nenust/issues) · [MIT 许可证](LICENSE)

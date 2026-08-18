# nenust

东北师范大学（NENU）研究生学位论文 Typst 模板。

- 覆盖博士 / 硕士、学术型 / 专业型、理工 / 社科等学位与学科组合
- 内置 GB/T 7714-2025 参考文献著录与纯 Typst 文献解析（numeric / author-date）
- 支持匿名双盲评审、双面排版、图表目录、缩略语表、附录与后记
- 附带完整使用教程示例（`examples/tutorial/`）与最小示例（`examples/empty/`）

> 本模板为个人开发的非官方学术资源，非学校授权或提供。正式提交前请以学校及学院最新要求为准，并与学校最新版官方 Word 模板逐项核对。

## 环境要求

- Typst 0.15.1
- 仓库自带全部所需字体（`template/assets/fonts/`），无需额外安装
- 首次编译需联网下载 `@preview/cuti:0.4.0`

## 快速开始

在仓库根目录运行：

```powershell
typst compile --root . --font-path template/assets/fonts examples/empty/main.typ
```

生成 `examples/empty/main.pdf`。开发时可把 `compile` 换成 `watch`。

## 使用方式

1. 复制 `examples/empty/` 作为论文起点（`main.typ` + `settings.typ` + `references.bib`）。
2. 在 `settings.typ` 中填写 `config`（学位、学科、开关项）与 `information`（题目、作者、导师、答辩信息等）。不要删除空字段；答辩页要求 `defense.reviewers` 保留 5 项、`defense.committee` 保留 7 项，未知内容填空字符串。
3. 正文写在 `nenu-template` 之后、`nenu-bibliography-render` 之前。
4. 入口顺序固定：`init-bibliography` → `nenu-template` → 正文 → `nenu-bibliography-render` → `begin-appendices` / `end-appendices` → 后记。

完整功能说明见教程编译 PDF：编译 `examples/tutorial/main.typ` 后阅读，或访问 GitHub Pages 在线预览（master 分支推送后自动构建）。

## 目录结构

```
examples/empty/      最小示例与公开数据契约
examples/tutorial/   完整教程与文献示例
template/config/     字体、编号与视觉常量
template/pages/      固定页面（封面、答辩页等）
template/modules/    数据整形与文献处理
```

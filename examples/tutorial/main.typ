#import "settings.typ": config, information
#import "/template/nenu-template.typ": *

/* 仅构建指定预览版时覆盖教程配置。 */
#let preview = if "preview" in sys.inputs {
  json("previews.json").at(sys.inputs.preview)
} else { (:) }
#let overrides = preview.at("config", default: (:))
#for (key, value) in overrides {
  assert.eq(type(value), type(config.at(key)), message: "预览配置字段类型不符：" + key)
}

/* 应用文献引擎规则 */
#show: init-bibliography.with(
  read("references.bib"),
  style: preview.at("style", default: "numeric"),
  show-url: false,
  show-online: false,
  show-identifiers: false,
  show-doi: false,
  show-cstr: false,
  show-urn: false,
  show-pid: false,
  show-accessed: false,
  show-backlinks: false,
)
/* 应用模板规则 */
#show: nenu-template.with(config + overrides, information)

/* 教程自定义规则 */
#show raw.where(lang: "typst"): set par(leading: 0pt, spacing: 0pt)
#show raw.where(lang: "powershell"): set par(leading: 0pt, spacing: 0pt)
#show raw.where(lang: "bibtex"): set par(leading: 0pt, spacing: 0pt)

#include "contents/chapter00/before-use.typ"
#include "contents/chapter01/typst-introduction.typ"
#include "contents/chapter02/quick-start.typ"
#include "contents/chapter03/project-structure.typ"
#include "contents/chapter04/configuration.typ"
#include "contents/chapter05/writing.typ"
#include "contents/chapter06/math.typ"
#include "contents/chapter07/figures.typ"
#include "contents/chapter08/tables.typ"
#include "contents/chapter09/bibliography.typ"

/* 参考文献 */
#nenu-bibliography-render(full: preview.at("full", default: true))

/* 附录 */
#begin-appendices()

= 在 Typst 中编程
#include "appendix/appendix-01.typ"

= 当前模板与学校官方的差异
#include "appendix/appendix-02.typ"

= 模板自定义
#include "appendix/appendix-03.typ"

= Typst 排版边界与已有支持
#include "appendix/appendix-04.typ"

#end-appendices()

/* 后记 */
定稿时，请从自己的 `main.typ` 编译提交稿：先翻到目录核对章首页，再任选一条带页码的引文，检查它是否指向正确的文献。教程的完整文献表和预览组合用于对照，不是每篇论文都应采用的提交设置。匿名稿还需单独检查身份信息；版式与学校或学院现行要求不同时，以正式要求为准。


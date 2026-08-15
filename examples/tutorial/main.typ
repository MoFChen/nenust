#import "settings.typ": config, information
#import "/template/nenu-template.typ": *

/* 应用文献引擎规则 */
#show: init-bibliography.with(
  read("references.bib"),
  style: "numeric",
  show-url: false,
  show-online: false,
  show-doi: false,
  show-accessed: false,
  show-backlinks: false,
)
/* 应用模板规则 */
#show: nenu-template.with(config, information)

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
#nenu-bibliography-render(full: true)

/* 附录 */
#begin-appendices()

= 在 Typst 中编程
#include "appendix/appendix-01.typ"

= 当前模板与学校官方的差异
#include "appendix/appendix-02.typ"

= 模板自定义
#include "appendix/appendix-03.typ"

= 目前尚未解决的问题
#include "appendix/appendix-04.typ"

#end-appendices()

/* 后记 */
本教程以“先完成论文，再按需学习 Typst”为原则组织。若教程示例与学校或学院的最新要求不一致，应以正式要求为准，并在提交前重新编译和逐页核对最终 PDF。


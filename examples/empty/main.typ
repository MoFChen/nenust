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

= 引言

= 研究意义

= 实验

= 结论

/* 参考文献 */
#nenu-bibliography-render(full: true)

/* 附录 */
#begin-appendices()

#end-appendices()

/* 后记 */

#import "others/abbreviations.typ": abbreviations
#import "others/review.typ": supervisors-review, committee-review

#let config = (
  anonymous: false,
  double_sided: false,

  degree_level: "doctoral", /* "master" */
  degree_type: "academic",  /* "professional" */
  discipline_group: "science",  /* "social" */

  include_outer_cover: true,
  include_list_of_figures: true,
  include_appendix_figures: false,
  include_list_of_tables: true,
  include_appendix_tables: false,
  include_abbreviations: true,
)

#let information = (
  security: (zh: "无", en: "None"),
  title: (
    zh: "东北师范大学研究生学位论文 Typst 模板使用教程",
    en: "A Practical Guide to the NENU Graduate Thesis Typst Template",
    /* display_zh: [], */
    /* display_en: [], */
  ),
  abstract: (
    zh: include "abstract/abstract-zh.typ",
    en: include "abstract/abstract-en.typ"
  ),
  abbreviations: abbreviations,
  keywords: (
    zh: ("Typst", "学位论文", "论文模板"),
    en: ("Typst", "graduate thesis", "thesis template")
  ),
  author: (name: (zh: "张三", en: "Zhang San"), student_id: "2077114514"),
  supervisors: (
    (name: (zh: "李四", en: "Li Si"), academic_title: (zh: "教授", en: "Professor")),
    (name: (zh: "王老五", en: "Wang Laowu"), academic_title: (zh: "副教授", en: "Associate Professor")),
  ),
  program: (
    primary_discipline:   (zh: "计算机科学与技术", en: "Computer Science and Technology"),
    secondary_discipline: (zh: "计算机软件与理论", en: "Computer Software and Theory"),
    research_area:        (zh: "学术文档自动化", en: "Academic Document Automation"),
  ),
  submission_date: datetime(year: 2026, month: 9, day: 25),
  defense: (
    reviewers: (
      (name: "评阅专家甲", affiliation: "示例大学/教授", evaluation: "优秀"),
      (name: "评阅专家乙", affiliation: "匿名评阅", evaluation: "优秀"),
      (name: "评阅专家丙", affiliation: "匿名评阅", evaluation: "优秀"),
      (name: "评阅专家丁", affiliation: "匿名评阅", evaluation: "优秀"),
      (name: "", affiliation: "", evaluation: "")
    ),
    committee: (
      (name: "答辩主席", affiliation: "示例大学", academic_title: "教授"),
      (name: "答辩委员甲", affiliation: "示例大学", academic_title: "教授"),
      (name: "答辩委员乙", affiliation: "示例大学", academic_title: "教授"),
      (name: "答辩委员丙", affiliation: "示例大学", academic_title: "副教授"),
      (name: "答辩委员丁", affiliation: "示例大学", academic_title: "副教授"),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: "")
    )
  ),
  achievements: (
    (
      title: "学位论文 Typst 模板的设计与实践",
      type: "学术论文",
      journal: "示例期刊",
      date: [2025年#parbreak()第12卷],   /* 可用内容块控制单元格内换行 */
      author: "1",
    ),
    (
      title: "学位论文 Typst 模板的设计与实践",
      type: "学术论文",
      journal: "示例期刊",
      date: "2025年07月",   /* 也支持纯文本格式 */
      author: "1",
    ),
  ),
  awards: (
    "第一届全国大学生光电设计大赛东北赛区一等奖",
    "第一届全国大学生光电设计大赛国家一等奖",
    "其他获奖奖项",
  ),
  review: (
    supervisors: supervisors-review,
    committee: committee-review
  )
)

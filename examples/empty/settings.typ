#let config = (
  anonymous: false,
  double_sided: false,

  degree_level: "doctoral", // "master"
  degree_type: "academic",  // "professional"
  discipline_group: "science",  // "social"

  include_outer_cover: true,
  include_list_of_figures: true,
  include_appendix_figures: false,
  include_list_of_tables: true,
  include_appendix_tables: false,
  include_abbreviations: true,
)

#let information = (
  institution: (
    name_zh: "东北师范大学",
    name_en: "Northeast Normal University",
    school_code: "10200"
  ),
  security: (zh: "无", en: "None"),
  title: (
    zh: "",
    en: "",
    //display_zh: [],
    //display_en: []
  ),
  abstract: (
    zh: "",
    en: ""
  ),
  abbreviations: (),
  keywords: (
    zh: (),
    en: ()
  ),
  author: (name: (zh: "", en: ""), student_id: ""),
  supervisors: (
    (name: (zh: "", en: ""), academic_title: (zh: "", en: "")),
  ),
  program: (
    primary_discipline:   (zh: "", en: ""),
    secondary_discipline: (zh: "", en: ""),
    research_area:        (zh: "", en: ""),
  ),
  submission_date: datetime(year: 2026, month: 9, day: 25),
  defense: (
    reviewers: (
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: "")
    ),
    committee: (
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: "")
    )
  ),
  achievements: (),
  awards: (),
  review: (
    supervisors: "",
    committee: ""
  )
)
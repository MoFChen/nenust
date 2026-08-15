#import "../config/styles.typ": nenu-style

/* 处理内容纵向间距 */
#let join_vspace(s, val) = {
  [
    #v(val)
    #s.clusters().join([#v(val)])
    #v(val)
  ]
}

/* 处理内容横向间距 */
#let join_hspace(s, val) = {
  [
    #h(val)
    #s.clusters().join([#h(val)])
    #h(val)
  ]
}

/* 处理两字中文人名之间的间距 */
#let format_cjk_name(name) = {
  let clusters = name.clusters()
  if clusters.len() == 2 {
    clusters.join([#h(1em)])
  } else {
    name
  }
}

/* 处理竖排字符串中的英文/数字 */
#let v_cjk_latin(s) = {
  for ch in s {
    if ch.trim() == "" {
      v(0.25em)
      continue
    }
    if ch.contains(regex("[A-Za-z0-9]")) {
      text(baseline: 1pt)[#rotate(90deg, reflow: true, upper(ch))]
    } else {
      [#ch#v(0em)]
    }
  }
}

/* 处理用户配置 */
#let format_info(config, information) = {
  if config.anonymous {
    /* 处理匿名 */
    information.author.student_id = "█" * 7
    information.author.name.zh = ""
    information.author.name.en = ""
    information.supervisors = (
      (name: (zh: "", en: ""), academic_title: (zh: "", en: "")),
    )
    information.program = (
      primary_discipline:   (zh: "", en: ""),
      secondary_discipline: (zh: "", en: ""),
      research_area:        (zh: "", en: "")
    )
    information.defense.reviewers = (
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: ""),
      (name: "", affiliation: "", evaluation: "")
    )
    information.defense.committee = (
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: ""),
      (name: "", affiliation: "", academic_title: "")
    )
  } else {
    /* 格式化中文名 */
    information.author.name.zh = format_cjk_name(information.author.name.zh)
    for el in information.defense.committee {
      el.name = format_cjk_name(el.name)
    }
  }
  
  /* 初始化封面参数 */
  let cover_param = (
    header: (zh: "", en: ""),
    top_info: (
      zh: (
        "学校代码：" + information.institution.school_code,
        "研究生学号：" + information.author.student_id,
        "密级：" + information.security.zh
      ),
      en: (
        "School code: " + information.institution.school_code,
        "Student ID: " + information.author.student_id,
        "Security level: " + information.security.en
      )
    ),
    title: (
      zh: information.title.at("display_zh", default: information.title.zh),
      en: information.title.at("display_en", default: information.title.en),
      plain_zh: information.title.zh
    ),
    author: (
      key: (zh: [作#h(2em)者], en: "Author"),
      val: (zh: information.author.name.zh, en: information.author.name.en)
    ),
    supervisors: (
      key: (zh: "指导教师", en: "Supervisors"),
      val: information.supervisors
    ),
    program: (
      key: (
        primary_discipline:   (zh: "", en: ""),
        secondary_discipline: (zh: "", en: ""),
        research_area:        (zh: "研究方向", en: "Research Area"),
      ),
      val: information.program
    ),
    submission_date: information.submission_date
  )

  /* 根据配置调整参数 */
  if config.degree_level == "doctoral" {
    cover_param.page_header = "东北师范大学博士学位论文"
    cover_param.header.zh = "博士研究生学位论文"
    cover_param.header.en = "A Dissertation"
  } else if config.degree_level == "master" {
    cover_param.page_header = "东北师范大学硕士学位论文"
    cover_param.header.zh = "硕士研究生学位论文"
    cover_param.header.en = "A Thesis"
  }
  cover_param.logo = bytes(read("/template/assets/imgs/nenu-logo.svg").replace("#000000", nenu-style.color.logo.at(config.degree_level, default: "#808080")))

  if config.degree_type == "academic" {
    cover_param.program.key.primary_discipline = (zh: "一级学科", en: "Primary Subject Classification")
    cover_param.program.key.secondary_discipline = (zh: "二级学科", en: "Secondary Subject Classification")
  } else if config.degree_type == "professional" {
    cover_param.program.key.primary_discipline = (zh: "学位类别", en: "Degree category")
    cover_param.program.key.secondary_discipline = (zh: "学位领域", en: "Degree field")
  }

  return (information, cover_param)
}

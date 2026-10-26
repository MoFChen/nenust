#import "bibliography/bibtex.typ": bibtex-keys, parse-bibtex
#import "bibliography/csl.typ": csl-style-info
#import "bibliography/gbt.typ": (
  author-label,
  author-identity,
  author-sort-key,
  entry-language,
  entry-year,
  render-entry-text,
)

#let _bib-data = state("nenu-bibliography-data", (:))
#let _bib-config = state("nenu-bibliography-config", (
  style: "numeric",
  show-url: true,
  show-online: true,
  show-identifiers: true,
  show-doi: true,
  show-cstr: true,
  show-urn: true,
  show-pid: true,
  show-accessed: true,
  show-backlinks: true,
))
#let _csl-config = state("nenu-csl-config", none)
#let _citation-model = state("nenu-bibliography-model", (
  order: (:), keys: (), suffixes: (:), labels: (:), years: (:), full: false, ready: false,
))

#let _ref-label(key) = label("nenu-bibliography-ref-" + key)

#let _cite-marker(key, supplement: none, form: none) = [#metadata((
    key: key,
    supplement: supplement,
    form: form,
  ))<nenu-bibliography-cite>]

#let _collect-citations() = _citation-model.final()

#let _full-requested() = query(<nenu-bibliography-request>).any(marker => marker.value.full)

#let _suffix(index) = numbering("a", index + 1)

#let _year-suffixes(data, keys) = {
  let groups = (:)
  let selected = (:)
  for key in keys { selected.insert(key, true) }
  for key in data.keys() {
    if key not in selected { continue }
    let entry = data.at(key)
    let group = author-identity(entry) + "|" + entry-year(entry)
    if group not in groups {
      groups.insert(group, ())
    }
    groups.at(group).push(key)
  }

  let result = (:)
  for keys in groups.values() {
    if keys.len() < 2 { continue }
    for (index, key) in keys.enumerate() {
      result.insert(key, _suffix(index))
    }
  }
  result
}

#let _selected-keys(data, citations, full) = {
  let keys = citations.order.keys().filter(key => key in data)
  if full {
    keys += data.keys().filter(key => key not in citations.order)
  }
  keys
}

#let _resolved-author-label(data, key, keys) = {
  let entry = data.at(key)
  let base = author-label(entry)
  let identity = author-identity(entry)
  let ambiguous = keys.any(other => (
    other != key
      and author-label(data.at(other)) == base
      and author-identity(data.at(other)) != identity
  ))
  author-label(entry, detailed: ambiguous)
}

#let _build-citation-model(data, order, full, style) = {
  let keys = _selected-keys(data, (order: order), full)
  let suffixes = (:)
  let labels = (:)
  let years = (:)
  if style == "author-date" {
    suffixes = _year-suffixes(data, keys)
    let identities = (:)
    let ambiguous = (:)
    let bases = (:)
    for key in keys {
      let entry = data.at(key)
      let base = author-label(entry)
      let identity = author-identity(entry)
      bases.insert(key, base)
      if base in identities and identities.at(base) != identity {
        ambiguous.insert(base, true)
      } else {
        identities.insert(base, identity)
      }
    }
    for key in keys {
      let entry = data.at(key)
      labels.insert(key, if bases.at(key) in ambiguous { author-label(entry, detailed: true) } else { bases.at(key) })
      years.insert(key, entry-year(entry, year-suffix: suffixes.at(key, default: "")))
    }
    keys = keys.sorted(key: key => author-sort-key(data.at(key)) + "|" + suffixes.at(key, default: ""))
  }
  (order: order, keys: keys, suffixes: suffixes, labels: labels, years: years, full: full, ready: true)
}

/* 集中发布与标记位置无关的引用语义数据；回链位置仅在文献表渲染时收集，
   避免正文位置变化导致每处引用重复计算作者消歧和编号。 */
#let _publish-citation-model() = context {
  if query(<nenu-bibliography-init>).len() > 1 {
    panic("the built-in GB/T processor supports one bibliography initialization per document")
  }
  let order = (:)
  let data = _bib-data.get()
  for marker in query(<nenu-bibliography-cite>) {
    let item = marker.value
    if item.key not in data { continue }
    if item.key not in order { order.insert(item.key, order.len() + 1) }
  }
  let config = _bib-config.get()
  _citation-model.update(_build-citation-model(data, order, _full-requested(), config.style))
}

#let _backlink-index() = {
  let result = (:)
  for marker in query(<nenu-bibliography-cite>) {
    let item = marker.value
    if item.form == none { continue }
    if item.key not in result { result.insert(item.key, ()) }
    result.at(item.key).push(marker.location())
  }
  result
}

#let _entry-record(key, order, entry, config, suffix: "", backlinks: (), request-full: false) = {
  let rendered-text = render-entry-text(
    entry,
    style: config.style,
    show-url: config.show-url,
    show-online: config.show-online,
    show-identifiers: config.show-identifiers,
    show-doi: config.show-doi,
    show-cstr: config.show-cstr,
    show-urn: config.show-urn,
    show-pid: config.show-pid,
    show-accessed: config.show-accessed,
    year-suffix: suffix,
  )
  let full-marker = if request-full { [#metadata((full: true))<nenu-bibliography-request>] } else { [] }
  let rendered = [#full-marker#text(rendered-text)]
  let ref-label = _ref-label(key)
  let backlink-content = backlinks.enumerate().map(((index, location)) => (
    link(location, super(text("↩" + str(index + 1))))
  )).join([ ])
  (
    key: key,
    order: order,
    style: config.style,
    year-suffix: suffix,
    lang: entry-language(entry),
    entry-type: entry.entry-type,
    fields: entry.fields,
    parsed-names: entry.names,
    rendered: rendered,
    rendered-text: rendered-text,
    ref-label: ref-label,
    backlinks: backlinks,
    labeled-rendered: [#rendered #ref-label#if backlink-content != [] { h(0.4em); backlink-content }],
  )
}

#let get-cited-entries(full: false) = {
  let csl = _csl-config.get()
  if csl != none and csl.mode == "native-csl" {
    panic("get-cited-entries is unavailable with the native CSL processor")
  }
  let data = _bib-data.get()
  let config = _bib-config.get()
  let citations = _collect-citations()
  if full and not citations.full {
    citations = _build-citation-model(data, citations.order, true, config.style)
  }
  let keys = citations.keys
  let suffixes = citations.suffixes
  let backlinks = if config.show-backlinks { _backlink-index() } else { (:) }

  keys.enumerate().map(((index, key)) => _entry-record(
    key,
    index + 1,
    data.at(key),
    config,
    suffix: suffixes.at(key, default: ""),
    backlinks: backlinks.at(key, default: ()),
    request-full: full,
  ))
}

#let _unknown-key(key) = text(fill: red, "[??" + key + "??]")

#let _render-single-cite(key, supplement, form) = {
  let config = _bib-config.get()
  let citations = _collect-citations()
  if not citations.ready { return [] }
  if form == none {
    if key not in citations.order {
      panic("unknown bibliography key: " + key)
    }
    return []
  }
  if key not in citations.order {
    return _unknown-key(key)
  }

  let suffix = citations.suffixes.at(key, default: "")
  let target = _ref-label(key)

  if form not in ("full", "author", "year") {
    let citation = if config.style == "author-date" {
      let author = citations.labels.at(key)
      let year = citations.years.at(key)
      if form == "prose" { [#author（#year）] } else { [（#author，#year）] }
    } else {
      text("[" + str(citations.order.at(key)) + "]")
    }
    if supplement != none {
      citation += if config.style == "author-date" { super(supplement) } else { supplement }
    }
    let linked = link(target, citation)
    return if config.style == "numeric" and form != "prose" { super(linked) } else { linked }
  }

  let data = _bib-data.get()
  let entry = data.at(key)

  if form == "full" {
    let citation = text(render-entry-text(
      entry,
      style: config.style,
      show-url: config.show-url,
      show-online: config.show-online,
      show-identifiers: config.show-identifiers,
      show-doi: config.show-doi,
      show-cstr: config.show-cstr,
      show-urn: config.show-urn,
      show-pid: config.show-pid,
      show-accessed: config.show-accessed,
      year-suffix: suffix,
    ))
    if supplement != none { citation += [#h(0.3em)#supplement] }
    return link(target, citation)
  }
  if form == "author" {
    return link(target, if config.style == "author-date" {
      citations.labels.at(key)
    } else { _resolved-author-label(data, key, citations.keys) })
  }
  if form == "year" {
    return link(target, entry-year(entry, year-suffix: suffix))
  }

}

#let footcite(key, supplement: none) = context {
  let csl = _csl-config.get()
  if csl != none and csl.mode == "native-csl" {
    footnote(cite(label(str(key)), supplement: supplement, form: "full"))
  } else {
    /* 脚注正文在局部 show cite 规则之外实现，因此在调用处登记引用并显式渲染真实文献。 */
    let key = str(key)
    _cite-marker(key, supplement: supplement, form: "full")
    footnote(context _render-single-cite(key, supplement, "full"))
  }
}

#let _normalize-multicite-args(args) = {
  let raw = args.pos()
  if raw.len() == 1 and type(raw.first()) == content {
    let body = raw.first()
    let children = if body.has("children") { body.children } else { (body,) }
    return children.filter(item => type(item) == content and item.func() in (ref, cite)).map(item => {
      if item.func() == ref {
        let supplement = item.at("supplement", default: none)
        if supplement == auto { supplement = none }
        (key: str(item.target), supplement: supplement)
      } else {
        (key: str(item.key), supplement: item.at("supplement", default: none))
      }
    })
  }

  raw.map(item => {
    if type(item) == str {
      (key: item, supplement: none)
    } else {
      (key: item.key, supplement: item.at("supplement", default: none))
    }
  })
}

#let multicite(..args) = {
  let items = _normalize-multicite-args(args)
  let form = args.named().at("form", default: "normal")
  if items.len() == 0 { return [] }

  for item in items {
    _cite-marker(item.key, supplement: item.supplement, form: form)
  }

  context {
    let csl = _csl-config.get()
    if csl != none and csl.mode == "native-csl" {
      panic("multicite is unavailable with the native CSL processor; use adjacent native citations")
    }
    let config = _bib-config.get()
    let citations = _collect-citations()
    if not citations.ready { return [] }
    let missing = items.find(item => item.key not in citations.order)
    if missing != none {
      panic("unknown bibliography key in multicite: " + missing.key)
    }
    if form == none { return [] }

    if config.style == "author-date" {
      if items.any(item => item.supplement != none) {
        let rendered = items.map(item => {
          let author = citations.labels.at(item.key)
          let year = citations.years.at(item.key)
          let citation = if form == "prose" {
            [#author（#year）]
          } else {
            [（#author，#year）]
          }
          if item.supplement != none { citation += super(item.supplement) }
          link(_ref-label(item.key), citation)
        })
        return rendered.join([；])
      }

      let groups = ()
      for item in items {
        let author = citations.labels.at(item.key)
        let year = citations.years.at(item.key)
        if groups.len() > 0 and groups.last().author == author {
          groups.last().years.push((year: year, key: item.key))
        } else {
          groups.push((author: author, years: ((year: year, key: item.key),)))
        }
      }
      let labels = groups.map(group => [
        #group.author，#group.years.map(item => link(_ref-label(item.key), item.year)).join([，])
      ])
      return if form == "prose" {
        groups.map(group => [
          #group.author（#group.years.map(item => link(_ref-label(item.key), item.year)).join([，])）
        ]).join([；])
      } else {
        [（#labels.join([；])）]
      }
    }

    let has-supplements = items.any(item => item.supplement != none)
    let body = if has-supplements {
      items.map(item => {
        let order = citations.order.at(item.key, default: citations.order.len() + 1)
        link(
          _ref-label(item.key),
          [#text("[" + str(order) + "]")#if item.supplement != none { item.supplement }],
        )
      }).join()
    } else {
      let unique = items
        .sorted(key: item => citations.order.at(item.key, default: citations.order.len() + 1))
        .dedup(key: item => item.key)
      let ranges = ()
      let index = 0
      while index < unique.len() {
        let start = index
        let end = index
        let end-number = citations.order.at(unique.at(end).key)
        while end + 1 < unique.len() and citations.order.at(unique.at(end + 1).key) == end-number + 1 {
          end += 1
          end-number += 1
        }
        ranges.push((start: start, end: end))
        index = end + 1
      }
      let parts = ranges.map(range => {
        let first = unique.at(range.start)
        let first-number = citations.order.at(first.key)
        if range.start == range.end {
          link(_ref-label(first.key), str(first-number))
        } else {
          let last = unique.at(range.end)
          let last-number = citations.order.at(last.key)
          [#link(_ref-label(first.key), str(first-number))-#link(_ref-label(last.key), str(last-number))]
        }
      })
      [\[#parts.join([,])\]]
    }
    if form == "prose" { body } else { super(body) }
  }
}

#let nocite(..keys) = context {
  let csl = _csl-config.get()
  if csl != none and csl.mode == "native-csl" {
    for requested in keys.pos() {
      if str(requested) == "*" {
        for key in bibtex-keys(csl.bib) {
          cite(label(key), form: none)
        }
      } else {
        cite(label(str(requested)), form: none)
      }
    }
  } else {
    let data = _bib-data.get()
    for requested in keys.pos() {
      for key in if str(requested) == "*" { data.keys() } else { (str(requested),) } {
        if key not in data {
          panic("unknown bibliography key in nocite: " + key)
        }
        _cite-marker(key, form: none)
      }
    }
  }
}

#let _render-gbt-bibliography(title: auto, full: false, renderer: none) = {
  [#metadata((full: full))<nenu-bibliography-request>]
  context {
    let config = _bib-config.get()
    let entries = get-cited-entries(full: full)
    let actual-title = if title == auto { heading(numbering: none)[参考文献] } else { title }
    if actual-title != none { actual-title }

    if renderer != none {
      renderer(entries)
    } else {
      set par(first-line-indent: 0em, hanging-indent: 2em)
      for entry in entries {
        if config.style == "numeric" {
          [\[#entry.order\]#h(0.5em)#entry.labeled-rendered]
        } else {
          entry.labeled-rendered
        }
        parbreak()
      }
    }
  }
}

#let _stub-bib(data) = data.keys().map(key => (
  "@misc{" + key + ",title={Reference}}\n"
)).join("", default: "")

/* 此上下文只捕获源数据，使持续编译时的正文编辑可以复用 BibTeX 解析和占位书目。 */
#let _initialize-source(source) = context {
  let data = parse-bibtex(source)
  _bib-data.update(data)
  let stub = _stub-bib(data)
  if stub != "" {
    show bibliography: none
    bibliography(bytes(stub), title: none)
  }
}

#let init-bibliography(
  source,
  style: "numeric",
  show-url: true,
  show-online: true,
  show-identifiers: true,
  show-doi: true,
  show-cstr: true,
  show-urn: true,
  show-pid: true,
  show-accessed: true,
  show-backlinks: true,
  body,
) = {
  if style not in ("numeric", "author-date") {
    panic("style must be 'numeric' or 'author-date'")
  }

  _initialize-source(source)
  _bib-config.update((
    style: style,
    show-url: show-url,
    show-online: show-online,
    show-identifiers: show-identifiers,
    show-doi: show-doi,
    show-cstr: show-cstr,
    show-urn: show-urn,
    show-pid: show-pid,
    show-accessed: show-accessed,
    show-backlinks: show-backlinks,
  ))

  [#metadata(none)<nenu-bibliography-init>]

  show cite: citation => {
    let key = str(citation.key)
    _cite-marker(key, supplement: citation.supplement, form: citation.form)
    context _render-single-cite(key, citation.supplement, citation.form)
  }

  body
  _publish-citation-model()
}

#let init-csl(
  source,
  style,
  show-url: true,
  show-online: true,
  show-identifiers: true,
  show-doi: true,
  show-cstr: true,
  show-urn: true,
  show-pid: true,
  show-accessed: true,
  show-backlinks: true,
  body,
) = {
  let info = csl-style-info(style)
  if info.mode == "unsupported-csl-m" {
    panic(
      "unsupported CSL-M features: " + info.features.join(", ")
        + "; use init-bibliography unless the style is the recognized GB/T 7714-2025 family",
    )
  }
  if info.mode == "native-csl" and (
    not show-url or not show-online or not show-identifiers
      or not show-doi or not show-cstr or not show-urn or not show-pid or not show-accessed
  ) {
    panic("show-url/show-online/show-identifiers/show-doi/show-cstr/show-urn/show-pid/show-accessed are controlled by the CSL style in native-csl mode")
  }

  _csl-config.update((
    mode: info.mode,
    bib: source,
    style: style,
    info: info,
  ))

  if info.mode == "gbt-2025-compat" {
    init-bibliography(
      source,
      style: if info.citation-format == "author-date" { "author-date" } else { "numeric" },
      show-url: show-url,
      show-online: show-online,
      show-identifiers: show-identifiers,
      show-doi: show-doi,
      show-cstr: show-cstr,
      show-urn: show-urn,
      show-pid: show-pid,
      show-accessed: show-accessed,
      show-backlinks: show-backlinks,
      body,
    )
  } else {
    body
  }
}

#let render-bibliography(title: auto, full: false, renderer: none) = context {
  let config = _csl-config.get()
  if config == none or config.mode == "gbt-2025-compat" {
    _render-gbt-bibliography(title: title, full: full, renderer: renderer)
  } else {
    if renderer != none {
      panic("renderer is only available for the built-in GB/T processor")
    }
    bibliography(
      bytes(config.bib),
      title: title,
      full: full,
      style: bytes(config.style),
    )
  }
}

#let inspect-csl = csl-style-info

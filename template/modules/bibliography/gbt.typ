// GB/T 7714-2025 bibliography formatter for normalized entry dictionaries.

#let _as-string(value) = {
  if value == none {
    ""
  } else if type(value) == str {
    value.trim()
  } else {
    str(value)
  }
}

#let _field(entry, keys) = {
  let fields = entry.at("fields", default: (:))
  for key in keys {
    let value = _as-string(fields.at(key, default: none))
    if value != "" {
      return value
    }
  }
  ""
}

#let _names(entry, role) = {
  let names = entry.at("names", default: (:)).at(role, default: ())
  if type(names) == array { names } else { () }
}

#let _name-part(person, key) = {
  if type(person) == str {
    if key == "literal" { person.trim() } else { "" }
  } else {
    _as-string(person.at(key, default: none))
  }
}

#let _has-cjk(value) = value.contains(regex("[\u{3040}-\u{30ff}\u{3400}-\u{9fff}\u{ac00}-\u{d7af}\u{f900}-\u{faff}]"))

#let entry-language(entry) = {
  let explicit = lower(_field(entry, ("langid", "language", "lang"))).replace("_", "-")
  if explicit != "" {
    if explicit.starts-with("zh") or explicit.contains("chinese") or explicit == "中文" {
      return "zh"
    }
    if explicit.starts-with("ja") or explicit.contains("japanese") or explicit == "日文" {
      return "ja"
    }
    if explicit.starts-with("ru") or explicit.contains("russian") or explicit == "俄文" {
      return "ru"
    }
    if explicit.starts-with("en") or explicit.contains("english") or explicit == "英文" {
      return "en"
    }
    return explicit.split("-").first()
  }

  let title = _field(entry, ("title", "booktitle", "journaltitle", "journal"))
  if _has-cjk(title) {
    return "zh"
  }
  if title != "" {
    return "en"
  }

  for role in ("author", "editor", "translator", "bookauthor") {
    for person in _names(entry, role) {
      let sample = _name-part(person, "literal") + _name-part(person, "family") + _name-part(person, "given")
      if _has-cjk(sample) {
        return "zh"
      }
    }
  }
  "en"
}

#let _is-cjk-language(language) = language in ("zh", "ja", "ko")

#let _initials(given) = {
  let result = ()
  for word in given.replace(".", "").split(" ") {
    if word == "" {
      continue
    }
    let hyphenated = ()
    for part in word.split("-") {
      if part != "" {
        hyphenated.push(upper(part.clusters().first()))
      }
    }
    if hyphenated.len() > 0 {
      result.push(hyphenated.join("-"))
    }
  }
  result.join(" ", default: "")
}

#let _format-name(person) = {
  let literal = _name-part(person, "literal")
  if literal != "" {
    return literal
  }

  let family = _name-part(person, "family")
  let given = _name-part(person, "given")
  let prefix = _name-part(person, "prefix")
  let suffix = _name-part(person, "suffix")
  if _has-cjk(family + given) {
    return (prefix + family + given + suffix).trim()
  }

  let surname = (prefix, family).filter(value => value != "").join(" ")
  (surname, _initials(given), suffix).filter(value => value != "").join(" ")
}

#let _format-names(names, language) = {
  if names.len() == 0 {
    return ""
  }
  let has-others = lower(_name-part(names.last(), "literal")) == "others"
  let people = if has-others { names.slice(0, names.len() - 1) } else { names }
  let count = if people.len() > 3 { 3 } else { people.len() }
  let result = people.slice(0, count).map(person => _format-name(person)).filter(value => value != "").join("，", default: "")
  if (has-others or people.len() > 3) and result != "" {
    result + (if _is-cjk-language(language) { "，等" } else { "，et al." })
  } else {
    result
  }
}

#let _translator(entry, language) = {
  let people = _names(entry, "translator")
  let result = _format-names(people, language)
  if result == "" {
    ""
  } else {
    result + (if _is-cjk-language(language) { "，译" } else { "，trans." })
  }
}

#let _primary-names(entry, allow-editor: true) = {
  let authors = _names(entry, "author")
  if authors.len() > 0 {
    authors
  } else if allow-editor {
    _names(entry, "editor")
  } else {
    ()
  }
}

#let _primary-text(entry, language, allow-editor: true) = _format-names(
  _primary-names(entry, allow-editor: allow-editor),
  language,
)

#let _container-responsibility(entry, language) = {
  let people = _names(entry, "bookauthor")
  if people.len() == 0 {
    people = _names(entry, "editor")
  }
  _format-names(people, language)
}

#let _entry-type(entry) = {
  let kind = lower(_as-string(entry.at("entry-type", default: "misc")))
  let subtype = lower(_field(entry, ("entrysubtype", "type")))
  for candidate in (
    "standard", "newspaper", "preprint", "archive", "map", "dataset", "database",
    "software", "webpage", "online", "patent", "report", "thesis",
  ) {
    if subtype.contains(candidate) {
      return candidate
    }
  }

  let note = lower(_field(entry, ("note",)))
  if note == "newspaper" or note.contains("type: newspaper") {
    return "newspaper"
  }
  let number = upper(_field(entry, ("number", "standard-number")))
  if number.match(regex("^(GB|GB/T|ISO|IEC|IEEE|ANSI|DIN|JIS|BS|NB/T|ASTM|AIAA|EN|RFC)([^A-Z]|$)")) != none {
    return "standard"
  }
  let journal = _field(entry, ("journaltitle", "journal"))
  if kind == "article" and journal.ends-with("报") and not journal.ends-with("学报") and not journal.ends-with("通报") {
    return "newspaper"
  }
  kind
}

#let _type-codes = (
  book: "M", inbook: "M", incollection: "M", chapter: "M",
  article: "J", periodical: "J", newspaper: "N",
  proceedings: "C", inproceedings: "C", conference: "C",
  phdthesis: "D", mastersthesis: "D", thesis: "D",
  techreport: "R", report: "R", standard: "S", patent: "P",
  online: "EB", webpage: "EB", archive: "A", map: "CM",
  dataset: "DS", preprint: "PP", software: "CP", collection: "G",
  database: "DB", misc: "Z",
)

#let _type-code(entry, kind) = {
  let mark = upper(_field(entry, ("mark", "usera"))).replace("[", "").replace("]", "").split("/").first()
  if mark in _type-codes.values() {
    return mark
  }
  _type-codes.at(kind, default: "Z")
}

#let _medium(entry, kind) = {
  let result = upper(_field(entry, ("medium", "media", "carrier"))).replace("[", "").replace("]", "")
  let mark = upper(_field(entry, ("mark", "usera"))).replace("[", "").replace("]", "")
  if result == "" and mark.contains("/") {
    result = mark.split("/").last()
  }
  if result.contains("/") {
    result = result.split("/").last()
  }
  if result in ("ONLINE", "INTERNET", "联机网络") {
    return "OL"
  }
  if result in ("MAGNETIC TAPE", "磁带") { return "MT" }
  if result in ("DISK", "磁盘") { return "DK" }
  if result in ("CD-ROM", "CDROM", "光盘") { return "CD" }
  if result in ("MICROFORM", "MICROFORM MATERIALS", "缩微资料") { return "MM" }
  if result in ("PRINT", "PAPER") {
    return ""
  }
  if result != "" {
    return result
  }

  let inherently-online = kind in ("online", "webpage", "dataset", "preprint")
  if inherently-online {
    return "OL"
  }
  if kind == "article" {
    let online-first = _field(entry, ("volume", "number", "issue")) == ""
    let has-access = _field(entry, ("url", "doi", "pid", "cstr", "urn")) != ""
    return if online-first and has-access { "OL" } else { "" }
  }
  if _field(entry, ("url", "doi", "pid", "cstr", "urn")) != "" { "OL" } else { "" }
}

#let _marker(entry, kind, show-online: true) = {
  let medium = _medium(entry, kind)
  if not show-online and medium == "OL" {
    medium = ""
  }
  "[" + _type-code(entry, kind) + (if medium == "" { "" } else { "/" + medium }) + "]"
}

#let _join-colon(parts) = parts.filter(value => value != "").join("：")

#let _title(entry) = _join-colon((
  _field(entry, ("title",)),
  _field(entry, ("subtitle", "titleaddon")),
))

#let _container-title(entry) = _join-colon((
  _field(entry, ("booktitle", "containertitle", "eventtitle", "journaltitle", "journal")),
  _field(entry, ("booksubtitle", "containersubtitle")),
))

#let _journal-title(entry) = _join-colon((
  _field(entry, ("journaltitle", "journal")),
  _field(entry, ("journalsubtitle",)),
))

#let _marked(value, entry, kind, show-online: true) = if value == "" { "" } else {
  value + _marker(entry, kind, show-online: show-online)
}

#let _edition(entry, language) = {
  let value = _field(entry, ("edition",))
  if value == "" {
    return ""
  }
  let normalized = lower(value).replace(" ", "").replace(".", "")
  if normalized in ("1", "1版", "第1版", "1st", "1sted", "1stedition", "firsted", "firstedition", "初版") {
    return ""
  }
  if value.contains(regex("^[0-9]+$")) {
    if _is-cjk-language(language) {
      return value + "版"
    }
    let suffix = if value.ends-with("11") or value.ends-with("12") or value.ends-with("13") {
      "th"
    } else if value.ends-with("1") {
      "st"
    } else if value.ends-with("2") {
      "nd"
    } else if value.ends-with("3") {
      "rd"
    } else {
      "th"
    }
    return value + suffix + " ed"
  }
  value
}

#let _publication-date(entry) = _field(entry, ("date", "publication-date", "issued", "year"))

#let _publication-year(entry) = {
  let year = _field(entry, ("year",))
  if year != "" {
    return year
  }
  let date = _publication-date(entry)
  if date.contains(regex("^[0-9]{4}")) {
    date.slice(0, 4)
  } else if _entry-type(entry) == "standard" {
    let number = _field(entry, ("standard-number", "number"))
    let chars = number.clusters()
    let candidate = if chars.len() >= 4 { chars.slice(chars.len() - 4).join() } else { "" }
    if candidate.match(regex("^[0-9]{4}$")) != none { candidate } else { date }
  } else {
    date
  }
}

#let _year(entry, year-suffix: "") = {
  let year = _publication-year(entry)
  if year == "" { "" } else { year + year-suffix }
}

#let _body-date(entry, author-date: false, year-suffix: "") = {
  let date = _publication-date(entry)
  let year = _publication-year(entry)
  if author-date and date == year {
    ""
  } else if not author-date and date == year and date != "" {
    date + year-suffix
  } else {
    date
  }
}

#let _pages(entry) = _field(entry, ("pages", "page", "eid", "article-number")).replace("--", "-").replace("–", "-")

#let _place-date(place, publisher, date, pages) = {
  let result = if place != "" and publisher != "" {
    place + "：" + publisher
  } else if place != "" {
    place
  } else {
    publisher
  }
  if date != "" {
    result += (if result == "" { "" } else { "，" }) + date
  }
  if pages != "" {
    result += (if result == "" { "" } else { "：" }) + pages
  }
  result
}

#let _serial-info(entry, include-year: true, year-suffix: "") = {
  let result = _journal-title(entry)
  let publication-date = _publication-date(entry)
  let publication-year = _publication-year(entry)
  let date = if publication-date != publication-year {
    publication-date
  } else if include-year {
    _year(entry, year-suffix: year-suffix)
  } else {
    ""
  }
  let volume = _field(entry, ("volume",))
  let issue = _field(entry, ("number", "issue"))
  let pages = _pages(entry)
  let has-date-or-volume = date != "" or volume != ""
  for value in (date, volume) {
    if value != "" {
      result += (if result == "" { "" } else { "，" }) + value
    }
  }
  if issue != "" {
    result += (if result != "" and not has-date-or-volume { "，" } else { "" }) + "（" + issue + "）"
  }
  if pages != "" {
    result += (if result == "" { "" } else { "：" }) + pages
  }
  result
}

#let _newspaper-info(entry) = {
  let result = _journal-title(entry)
  let date = _publication-date(entry)
  let edition = _field(entry, ("pages", "page", "number", "issue"))
  if date != "" {
    result += (if result == "" { "" } else { "，" }) + date
  }
  if edition != "" {
    result += "（" + edition + "）"
  }
  result
}

#let _period-point(date, volume, issue) = {
  let result = date
  if volume != "" {
    result += (if result == "" { "" } else { "，" }) + volume
  }
  if issue != "" {
    result += "（" + issue + "）"
  }
  result
}

#let _temporal(entry, show-accessed: true) = {
  let created = _publication-date(entry)
  let accessed = if show-accessed { _field(entry, ("urldate", "accessed", "access-date", "accessed-date")) } else { "" }
  let result = if created == "" { "" } else { "（" + created + "）" }
  result + (if accessed == "" { "" } else { "[" + accessed + "]" })
}

#let _strip-prefix(value, prefixes) = {
  let lower-value = lower(value)
  for prefix in prefixes {
    if lower-value.starts-with(lower(prefix)) {
      return value.slice(prefix.len()).trim()
    }
  }
  value.trim()
}

#let _clean-doi(value) = _strip-prefix(value, (
  "https://doi.org/",
  "http://doi.org/",
  "https://dx.doi.org/",
  "http://dx.doi.org/",
  "doi:",
  "doi：",
))

#let _clean-id(value, label) = _strip-prefix(value, (label + ":", label + "："))

#let _url-contains(url, identifier) = url != "" and identifier != "" and lower(url).contains(lower(identifier))

#let _identifier-parts(entry, show-url: true, show-doi: true) = {
  if not show-doi {
    return ()
  }
  let result = ()
  let url = if show-url { _field(entry, ("url",)) } else { "" }
  let doi = _clean-doi(_field(entry, ("doi",)))
  if show-doi and doi != "" and not _url-contains(url, doi) {
    result.push("DOI：" + doi)
  }

  let cstr = _clean-id(_field(entry, ("cstr",)), "CSTR")
  if cstr != "" and not _url-contains(url, cstr) {
    result.push("CSTR：" + cstr)
  }
  let urn = _clean-id(_field(entry, ("urn",)), "URN")
  if urn != "" and not _url-contains(url, urn) {
    result.push("URN：" + urn)
  }

  let pid = _field(entry, ("pid",))
  if pid != "" {
    let lower-pid = lower(pid)
    let label = upper(_field(entry, ("pid-type", "identifier-type")))
    let clean = pid
    if lower-pid.starts-with("doi:") or lower-pid.starts-with("doi：") or lower-pid.starts-with("http://doi.org/") or lower-pid.starts-with("https://doi.org/") or lower-pid.starts-with("http://dx.doi.org/") or lower-pid.starts-with("https://dx.doi.org/") {
      label = "DOI"
      clean = _clean-doi(pid)
    } else if lower-pid.starts-with("cstr:") or lower-pid.starts-with("cstr：") {
      label = "CSTR"
      clean = _clean-id(pid, label)
    } else if lower-pid.starts-with("urn:") or lower-pid.starts-with("urn：") {
      label = "URN"
      clean = _clean-id(pid, label)
    } else if label != "" {
      clean = _clean-id(pid, label)
    } else {
      label = "PID"
    }

    let duplicate = (doi != "" and lower(clean) == lower(doi)) or (cstr != "" and lower(clean) == lower(cstr)) or (urn != "" and lower(clean) == lower(urn))
    if clean != "" and not duplicate and not _url-contains(url, clean) {
      if label == "DOI" {
        if show-doi {
          result.push("DOI：" + clean)
        }
      } else {
        result.push(label + "：" + clean)
      }
    }
  }
  result
}

#let _dot-join(parts) = {
  let parts = parts.filter(value => value != "")
  if parts.len() == 0 {
    return ""
  }
  let result = ""
  for part in parts {
    if result != "" {
      result += if result.ends-with(".") { " " } else { ". " }
    }
    result += part
  }
  if not result.ends-with(".") {
    result += "."
  }
  result
}

#let _citation-person(person, detailed: false) = {
  let literal = _name-part(person, "literal")
  if literal != "" {
    return literal
  }
  let family = _name-part(person, "family")
  let given = _name-part(person, "given")
  let prefix = _name-part(person, "prefix")
  if _has-cjk(family + given) {
    family + given
  } else if detailed {
    (prefix, family, given, _name-part(person, "suffix")).filter(value => value != "").join(" ")
  } else {
    (prefix, family).filter(value => value != "").join(" ")
  }
}

#let author-label(entry, detailed: false) = {
  let language = entry-language(entry)
  let people = _primary-names(entry)
  if people.len() == 0 {
    if _is-cjk-language(language) { "佚名" } else { "Anon" }
  } else if detailed {
    let has-others = lower(_name-part(people.last(), "literal")) == "others"
    let actual = if has-others { people.slice(0, people.len() - 1) } else { people }
    let result = actual.map(person => _citation-person(person, detailed: true)).join("，", default: "")
    if has-others and result != "" {
      result + (if _is-cjk-language(language) { "，等" } else { "，et al." })
    } else {
      result
    }
  } else {
    let first = _citation-person(people.first())
    if people.len() > 1 {
      first + (if _is-cjk-language(language) { " 等" } else { " et al." })
    } else {
      first
    }
  }
}

#let author-identity(entry) = {
  let people = _primary-names(entry).filter(person => lower(_name-part(person, "literal")) != "others")
  if people.len() == 0 {
    "anonymous"
  } else {
    people.map(person => (
      _name-part(person, "literal"),
      _name-part(person, "prefix"),
      _name-part(person, "family"),
      _name-part(person, "given"),
      _name-part(person, "suffix"),
    ).join("|"))
      .join(";")
  }
}

#let entry-year(entry, year-suffix: "") = {
  let year = _year(entry, year-suffix: year-suffix)
  if year == "" {
    (if _is-cjk-language(entry-language(entry)) { "日期不详" } else { "n.d." }) + year-suffix
  } else {
    year
  }
}

#let author-year-label(entry, year-suffix: "") = (
  author-label(entry) + "，" + entry-year(entry, year-suffix: year-suffix)
)

#let _sort-person(person) = {
  let literal = _name-part(person, "literal")
  if literal != "" {
    return lower(literal)
  }
  lower((_name-part(person, "prefix"), _name-part(person, "family"), _name-part(person, "given"))
    .filter(value => value != "")
    .join(" "))
}

#let author-sort-key(entry) = {
  let language = entry-language(entry)
  let rank = if language == "zh" { "0" } else if language == "ja" { "1" } else if language == "en" { "2" } else if language == "ru" { "3" } else { "4" }
  let people = _primary-names(entry)
  let explicit = lower(_field(entry, ("sortkey", "sortname", "presort")))
  let author = if explicit != "" {
    explicit
  } else if people.len() == 0 {
    lower(_title(entry))
  } else {
    people.map(person => _sort-person(person)).join("|")
  }
  (rank, author, _publication-year(entry)).join("|")
}

#let format-citation-numbers(numbers, range-min: 2) = {
  if numbers.len() == 0 {
    return ""
  }
  let unique = numbers.map(int).sorted().dedup()
  let minimum = calc.max(range-min, 2)
  let result = ()
  let start = unique.first()
  let previous = start
  for number in unique.slice(1) {
    if number == previous + 1 {
      previous = number
    } else {
      let length = previous - start + 1
      if length >= minimum {
        result.push(str(start) + "-" + str(previous))
      } else {
        for value in range(start, previous + 1) {
          result.push(str(value))
        }
      }
      start = number
      previous = number
    }
  }
  let length = previous - start + 1
  if length >= minimum {
    result.push(str(start) + "-" + str(previous))
  } else {
    for value in range(start, previous + 1) {
      result.push(str(value))
    }
  }
  result.join(",")
}

#let render-entry-text(
  entry,
  style: "numeric",
  show-url: true,
  show-online: true,
  show-doi: true,
  show-accessed: true,
  year-suffix: "",
) = {
  let kind = _entry-type(entry)
  let language = entry-language(entry)
  let author-date = lower(style) in ("author-date", "author-year", "authoryear")
  let component = kind in ("inbook", "incollection", "chapter", "inproceedings", "conference")
  let parts = ()
  let primary = if kind == "standard" { "" } else { _primary-text(entry, language, allow-editor: not component) }
  if author-date {
    let responsibility = if primary == "" {
      if _is-cjk-language(language) { "佚名" } else { "Anon" }
    } else {
      primary
    }
    parts.push(responsibility + "，" + entry-year(entry, year-suffix: year-suffix))
  } else if primary != "" {
    parts.push(primary)
  }

  let title = _title(entry)
  let body-year = if author-date { "" } else { _year(entry, year-suffix: year-suffix) }
  let pages = _pages(entry)
  let place = _field(entry, ("location", "address", "place"))
  let publisher = _field(entry, ("publisher",))
  let translator = _translator(entry, language)

  if component {
    let container-person = _container-responsibility(entry, language)
    let container-title = _container-title(entry)
    let component-title = _marked(title, entry, kind, show-online: show-online)

    let simple-conference = kind in ("inproceedings", "conference") and place == "" and publisher == ""
    if simple-conference {
      let event-date = _field(entry, ("eventyear", "eventdate", "year", "date"))
      if author-date and event-date == _publication-year(entry) {
        event-date = ""
      }
      if event-date != "" {
        container-title += (if container-title == "" { "" } else { "，" }) + event-date
      }
      if pages != "" {
        container-title += (if container-title == "" { "" } else { "：" }) + pages
      }
    }
    let has-container = container-person != "" or container-title != ""

    if not has-container {
      parts.push(component-title)
      parts.push(translator)
    } else if translator != "" {
      parts.push(component-title)
      let origin = translator + "//" + container-person
      if container-person == "" {
        origin += container-title
        container-title = ""
      }
      parts.push(origin)
      parts.push(container-title)
    } else {
      let origin = component-title + "//" + container-person
      if container-person == "" {
        origin += container-title
        container-title = ""
      }
      parts.push(origin)
      parts.push(container-title)
    }
    parts.push(_edition(entry, language))
    if not simple-conference {
      parts.push(_place-date(place, publisher, body-year, pages))
    }
  } else if kind == "article" {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(translator)
    parts.push(_serial-info(
      entry,
      include-year: not author-date,
      year-suffix: year-suffix,
    ))
  } else if kind == "newspaper" {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(translator)
    parts.push(_newspaper-info(entry))
  } else if kind == "periodical" {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    let coverage = _field(entry, ("date-range", "year-volume", "coverage"))
    let start-year = _publication-year(entry)
    let end-year = _field(entry, ("endyear", "end-year"))
    if coverage == "" {
      let start = _period-point(start-year, _field(entry, ("volume",)), _field(entry, ("number", "issue")))
      let end = _period-point(
        end-year,
        _field(entry, ("endvolume", "end-volume")),
        _field(entry, ("endnumber", "end-number", "endissue", "end-issue")),
      )
      coverage = if start == "" { end } else { start + "—" + end }
    }
    parts.push(coverage)
    let publication-span = start-year + (if start-year == "" { "" } else { "—" + end-year })
    parts.push(_place-date(place, publisher, publication-span, ""))
  } else if kind in ("book", "proceedings", "collection", "misc") {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(translator)
    parts.push(_edition(entry, language))
    parts.push(_place-date(place, publisher, body-year, pages))
  } else if kind in ("phdthesis", "mastersthesis", "thesis") {
    let institution = _field(entry, ("institution", "school", "university", "publisher"))
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(_place-date(place, institution, body-year, pages))
  } else if kind in ("techreport", "report") {
    let report-title = _join-colon((title, _field(entry, ("report-number", "number"))))
    let date = _body-date(entry, author-date: author-date, year-suffix: year-suffix)
    let report-publisher = _field(entry, ("institution", "organization", "publisher"))
    parts.push(_marked(report-title, entry, kind, show-online: show-online))
    parts.push(_place-date(place, report-publisher, date, pages))
  } else if kind == "standard" {
    let number = _field(entry, ("standard-number", "number"))
    let year = _publication-year(entry)
    if number != "" and year != "" and not number.contains(year) {
      let international = upper(number).starts-with("ISO ") or upper(number).starts-with("IEC/") or upper(number).starts-with("IEC ")
      number += (if international { "：" } else { "—" }) + year
    }
    let standard-title = if number != "" and title != "" { number + "  " + title } else { number + title }
    parts.push(_marked(standard-title, entry, kind, show-online: show-online))
  } else if kind == "patent" {
    let patent-title = _join-colon((title, _field(entry, ("patent-number", "number"))))
    let date = _body-date(entry, author-date: author-date, year-suffix: year-suffix)
    parts.push(_marked(patent-title, entry, kind, show-online: show-online))
    parts.push(_place-date("", "", date, pages))
  } else if kind in ("online", "webpage") {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(_temporal(entry, show-accessed: show-accessed))
  } else if kind == "archive" {
    let archive-title = _join-colon((title, _field(entry, ("archive-number", "number"))))
    let collector = _field(entry, ("archive", "collector", "institution", "organization"))
    let date = _body-date(entry, author-date: author-date, year-suffix: year-suffix)
    parts.push(_marked(archive-title, entry, kind, show-online: show-online))
    parts.push(_place-date(place, collector, date, pages))
  } else if kind == "map" {
    let scale = _field(entry, ("scale",))
    if scale == "" {
      parts.push(_marked(title, entry, kind, show-online: show-online))
    } else {
      parts.push(title)
      parts.push(scale + _marker(entry, kind, show-online: show-online))
    }
    parts.push(_edition(entry, language))
    parts.push(_place-date(place, publisher, body-year, pages))
    parts.push(_field(entry, ("dimensions", "size")))
  } else if kind in ("dataset", "database", "preprint", "software") {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(_field(entry, ("version",)))
    let platform = _field(entry, ("platform", "repository", "publisher", "organization", "institution"))
    let temporal = _temporal(entry, show-accessed: show-accessed)
    parts.push(platform + (if platform != "" and temporal != "" { " " } else { "" }) + temporal)
  } else {
    parts.push(_marked(title, entry, kind, show-online: show-online))
    parts.push(translator)
    parts.push(_edition(entry, language))
    parts.push(_place-date(place, publisher, body-year, pages))
  }

  let url = _field(entry, ("url",))
  if show-url and url != "" {
    parts.push(url)
  }
  for identifier in _identifier-parts(entry, show-url: show-url, show-doi: show-doi) {
    parts.push(identifier)
  }
  _dot-join(parts)
}

#let render-entry(
  entry,
  style: "numeric",
  show-url: true,
  show-online: true,
  show-doi: true,
  show-accessed: true,
  year-suffix: "",
) = text(render-entry-text(
  entry,
  style: style,
  show-url: show-url,
  show-online: show-online,
  show-doi: show-doi,
  show-accessed: show-accessed,
  year-suffix: year-suffix,
))

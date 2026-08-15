#let _is-space(char) = char in (" ", "\t", "\r", "\n", "\u{000c}")

#let _join(parts, separator: "") = parts.join(separator, default: "")

#let _without-comments(source) = {
  let lines = ()
  for line in source.split("\n") {
    if not line.contains("%") {
      lines.push(line)
      continue
    }

    let chars = line.clusters()
    let result = ()
    let pos = 0
    while pos < chars.len() {
      let char = chars.at(pos)
      if char == "\\" and pos + 1 < chars.len() {
        result.push(char)
        result.push(chars.at(pos + 1))
        pos += 2
      } else if char == "%" {
        break
      } else {
        result.push(char)
        pos += 1
      }
    }
    lines.push(_join(result))
  }
  _join(lines, separator: "\n")
}

#let _skip-space(chars, start) = {
  let pos = start
  while pos < chars.len() and _is-space(chars.at(pos)) {
    pos += 1
  }
  pos
}

#let _strip-braces(source) = {
  let chars = source.clusters()
  let result = ()
  let depth = 0
  let pos = 0

  while pos < chars.len() {
    let char = chars.at(pos)
    if char == "\\" {
      result.push(char)
      pos += 1
      if pos < chars.len() {
        result.push(chars.at(pos))
        pos += 1
      }
    } else if char == "{" {
      depth += 1
      pos += 1
    } else if char == "}" {
      if depth == 0 {
        panic("unmatched closing brace in BibTeX name")
      }
      depth -= 1
      pos += 1
    } else {
      result.push(char)
      pos += 1
    }
  }

  if depth != 0 {
    panic("unclosed brace in BibTeX name")
  }
  _join(result)
}

#let _decode-tex(source, preserve-tilde: false) = {
  let escaped-open = "\u{e000}"
  let escaped-close = "\u{e001}"
  let result = source.replace("\\{", escaped-open).replace("\\}", escaped-close)
  for pair in (
    ("\\LaTeX", "LaTeX"), ("\\TeX", "TeX"),
    ("\\&", "&"), ("\\%", "%"), ("\\_", "_"), ("\\#", "#"),
    ("\\$", "$"), ("\\ ", " "),
  ) {
    result = result.replace(pair.first(), pair.last())
  }
  for (command, letters) in (
    ("\\'", (("a", "á"), ("A", "Á"), ("c", "ć"), ("C", "Ć"), ("e", "é"), ("E", "É"), ("i", "í"), ("I", "Í"), ("l", "ĺ"), ("L", "Ĺ"), ("n", "ń"), ("N", "Ń"), ("o", "ó"), ("O", "Ó"), ("r", "ŕ"), ("R", "Ŕ"), ("s", "ś"), ("S", "Ś"), ("u", "ú"), ("U", "Ú"), ("y", "ý"), ("Y", "Ý"), ("z", "ź"), ("Z", "Ź"))),
    ("\\`", (("a", "à"), ("A", "À"), ("e", "è"), ("E", "È"), ("i", "ì"), ("I", "Ì"), ("o", "ò"), ("O", "Ò"), ("u", "ù"), ("U", "Ù"))),
    ("\\^", (("a", "â"), ("A", "Â"), ("c", "ĉ"), ("C", "Ĉ"), ("e", "ê"), ("E", "Ê"), ("g", "ĝ"), ("G", "Ĝ"), ("h", "ĥ"), ("H", "Ĥ"), ("i", "î"), ("I", "Î"), ("j", "ĵ"), ("J", "Ĵ"), ("o", "ô"), ("O", "Ô"), ("s", "ŝ"), ("S", "Ŝ"), ("u", "û"), ("U", "Û"), ("w", "ŵ"), ("W", "Ŵ"), ("y", "ŷ"), ("Y", "Ŷ"))),
    ("\\\"", (("a", "ä"), ("A", "Ä"), ("e", "ë"), ("E", "Ë"), ("i", "ï"), ("I", "Ï"), ("o", "ö"), ("O", "Ö"), ("u", "ü"), ("U", "Ü"), ("y", "ÿ"), ("Y", "Ÿ"))),
    ("\\~", (("a", "ã"), ("A", "Ã"), ("i", "ĩ"), ("I", "Ĩ"), ("n", "ñ"), ("N", "Ñ"), ("o", "õ"), ("O", "Õ"), ("u", "ũ"), ("U", "Ũ"))),
    ("\\=", (("a", "ā"), ("A", "Ā"), ("e", "ē"), ("E", "Ē"), ("i", "ī"), ("I", "Ī"), ("o", "ō"), ("O", "Ō"), ("u", "ū"), ("U", "Ū"), ("y", "ȳ"), ("Y", "Ȳ"))),
    ("\\u", (("a", "ă"), ("A", "Ă"), ("e", "ĕ"), ("E", "Ĕ"), ("g", "ğ"), ("G", "Ğ"), ("i", "ĭ"), ("I", "Ĭ"), ("o", "ŏ"), ("O", "Ŏ"), ("u", "ŭ"), ("U", "Ŭ"))),
    ("\\v", (("c", "č"), ("C", "Č"), ("d", "ď"), ("D", "Ď"), ("e", "ě"), ("E", "Ě"), ("l", "ľ"), ("L", "Ľ"), ("n", "ň"), ("N", "Ň"), ("r", "ř"), ("R", "Ř"), ("s", "š"), ("S", "Š"), ("t", "ť"), ("T", "Ť"), ("z", "ž"), ("Z", "Ž"))),
    ("\\c", (("c", "ç"), ("C", "Ç"), ("s", "ş"), ("S", "Ş"), ("t", "ţ"), ("T", "Ţ"))),
    ("\\k", (("a", "ą"), ("A", "Ą"), ("e", "ę"), ("E", "Ę"), ("i", "į"), ("I", "Į"), ("u", "ų"), ("U", "Ų"))),
    ("\\r", (("a", "å"), ("A", "Å"), ("u", "ů"), ("U", "Ů"))),
    ("\\H", (("o", "ő"), ("O", "Ő"), ("u", "ű"), ("U", "Ű"))),
    ("\\.", (("e", "ė"), ("E", "Ė"), ("g", "ġ"), ("G", "Ġ"), ("i", "i"), ("I", "İ"), ("z", "ż"), ("Z", "Ż"))),
  ) {
    for (letter, decoded) in letters {
      result = result.replace(command + "{" + letter + "}", decoded)
      if letter == "i" { result = result.replace(command + "{\\i}", decoded) }
      if letter == "j" { result = result.replace(command + "{\\j}", decoded) }
      if command in ("\\'", "\\`", "\\^", "\\\"", "\\~", "\\=", "\\.") {
        result = result.replace(command + letter, decoded)
      } else {
        result = result.replace(command + " " + letter, decoded)
      }
    }
  }
  for (command, decoded) in (
    ("\\OE", "Œ"), ("\\oe", "œ"), ("\\AE", "Æ"), ("\\ae", "æ"),
    ("\\AA", "Å"), ("\\aa", "å"), ("\\O", "Ø"), ("\\o", "ø"),
    ("\\L", "Ł"), ("\\l", "ł"), ("\\SS", "ẞ"), ("\\ss", "ß"),
    ("\\i", "ı"), ("\\j", "ȷ"),
  ) {
    result = result.replace("{" + command + "}", decoded).replace(command + "{}", decoded).replace(command + " ", decoded)
  }
  if not preserve-tilde {
    result = result.replace("~", " ")
  }
  if result.contains("\\") {
    panic("unsupported TeX command in BibTeX value: " + result)
  }
  _strip-braces(result).replace(escaped-open, "{").replace(escaped-close, "}")
}

#let _value(text, braced: none) = (
  text: text,
  braced: if braced == none { text } else { braced },
)

#let _parse-braced(chars, start) = {
  let text = ()
  let braced = ()
  let depth = 1
  let pos = start + 1

  while pos < chars.len() {
    let char = chars.at(pos)
    if char == "\\" {
      text.push(char)
      braced.push(char)
      pos += 1
      if pos < chars.len() {
        text.push(chars.at(pos))
        braced.push(chars.at(pos))
        pos += 1
      }
    } else if char == "{" {
      depth += 1
      braced.push(char)
      pos += 1
    } else if char == "}" {
      depth -= 1
      if depth == 0 {
        return (pos + 1, _value(_join(text), braced: _join(braced)))
      }
      braced.push(char)
      pos += 1
    } else {
      text.push(char)
      braced.push(char)
      pos += 1
    }
  }

  panic("unclosed braced BibTeX value")
}

#let _parse-quoted(chars, start) = {
  let text = ()
  let braced = ()
  let depth = 0
  let pos = start + 1

  while pos < chars.len() {
    let char = chars.at(pos)
    if char == "\\" {
      text.push(char)
      braced.push(char)
      pos += 1
      if pos < chars.len() {
        text.push(chars.at(pos))
        braced.push(chars.at(pos))
        pos += 1
      }
    } else if char == "{" {
      depth += 1
      braced.push(char)
      pos += 1
    } else if char == "}" {
      if depth == 0 {
        panic("unmatched closing brace in quoted BibTeX value")
      }
      depth -= 1
      braced.push(char)
      pos += 1
    } else if char == "\"" and depth == 0 {
      return (pos + 1, _value(_join(text), braced: _join(braced)))
    } else {
      text.push(char)
      braced.push(char)
      pos += 1
    }
  }

  panic("unclosed quoted BibTeX value")
}

#let _parse-bare(chars, start, close, macros) = {
  let pos = start
  while pos < chars.len() {
    let char = chars.at(pos)
    if _is-space(char) or char in ("#", ",", close) {
      break
    }
    pos += 1
  }

  if pos == start {
    panic("expected a BibTeX value")
  }

  let token = _join(chars.slice(start, pos))
  let name = lower(token)
  (pos, if name in macros { macros.at(name) } else { _value(token) })
}

#let _parse-value(chars, start, close, macros) = {
  let text = ""
  let braced = ""
  let pos = start

  while true {
    pos = _skip-space(chars, pos)
    if pos >= chars.len() {
      panic("unclosed BibTeX entry while reading a value")
    }

    let char = chars.at(pos)
    if char in ("#", ",", close) {
      panic("expected a BibTeX value component")
    }

    let parsed = if char == "{" {
      _parse-braced(chars, pos)
    } else if char == "\"" {
      _parse-quoted(chars, pos)
    } else {
      _parse-bare(chars, pos, close, macros)
    }
    pos = parsed.at(0)
    text += parsed.at(1).text
    braced += parsed.at(1).braced
    pos = _skip-space(chars, pos)

    if pos >= chars.len() {
      panic("unclosed BibTeX entry after a value")
    }
    if chars.at(pos) == "#" {
      pos += 1
    } else {
      return (pos, _value(text, braced: braced))
    }
  }
}

#let _skip-enclosed(chars, start, open, close, label) = {
  let pos = start

  if open == "{" {
    let depth = 1
    while pos < chars.len() {
      let char = chars.at(pos)
      if char == "\\" {
        pos += 2
      } else if char == "{" {
        depth += 1
        pos += 1
      } else if char == "}" {
        depth -= 1
        pos += 1
        if depth == 0 {
          return pos
        }
      } else {
        pos += 1
      }
    }
  } else {
    let depth = 1
    let brace-depth = 0
    let quoted = false
    while pos < chars.len() {
      let char = chars.at(pos)
      if char == "\\" {
        pos += 2
      } else if char == "{" {
        brace-depth += 1
        pos += 1
      } else if char == "}" {
        if brace-depth == 0 {
          panic("unmatched closing brace in " + label)
        }
        brace-depth -= 1
        pos += 1
      } else if char == "\"" and brace-depth == 0 {
        quoted = not quoted
        pos += 1
      } else if not quoted and brace-depth == 0 and char == "(" {
        depth += 1
        pos += 1
      } else if not quoted and brace-depth == 0 and char == ")" {
        depth -= 1
        pos += 1
        if depth == 0 {
          return pos
        }
      } else {
        pos += 1
      }
    }
  }

  panic("unclosed " + label)
}

#let _parse-string(chars, start, close, macros) = {
  let pos = _skip-space(chars, start)
  let name-start = pos
  while pos < chars.len() {
    let char = chars.at(pos)
    if _is-space(char) or char in ("=", ",", close) {
      break
    }
    pos += 1
  }

  let name = lower(_join(chars.slice(name-start, pos)).trim())
  if name == "" {
    panic("missing name in @string")
  }
  pos = _skip-space(chars, pos)
  if pos >= chars.len() or chars.at(pos) != "=" {
    panic("expected '=' in @string " + name)
  }

  let parsed = _parse-value(chars, pos + 1, close, macros)
  pos = _skip-space(chars, parsed.at(0))
  if pos < chars.len() and chars.at(pos) == "," {
    pos = _skip-space(chars, pos + 1)
  }
  if pos >= chars.len() or chars.at(pos) != close {
    panic("unclosed @string " + name)
  }

  (pos + 1, name, parsed.at(1))
}

#let _parse-entry(chars, start, close, entry-type, macros) = {
  let pos = _skip-space(chars, start)
  let key-start = pos
  while pos < chars.len() and chars.at(pos) not in (",", close) {
    pos += 1
  }
  if pos >= chars.len() {
    panic("unclosed @" + entry-type + " entry")
  }

  let key = _join(chars.slice(key-start, pos)).trim()
  if key == "" {
    panic("missing key in @" + entry-type + " entry")
  }

  let fields = (:)
  let sources = (:)
  if chars.at(pos) == close {
    return (
      pos + 1,
      key,
      (key: key, entry-type: entry-type, fields: fields, sources: sources),
    )
  }
  pos += 1

  while true {
    pos = _skip-space(chars, pos)
    if pos >= chars.len() {
      panic("unclosed @" + entry-type + " entry " + key)
    }
    if chars.at(pos) == close {
      return (
        pos + 1,
        key,
        (key: key, entry-type: entry-type, fields: fields, sources: sources),
      )
    }

    let field-start = pos
    while pos < chars.len() {
      let char = chars.at(pos)
      if _is-space(char) or char in ("=", ",", close) {
        break
      }
      pos += 1
    }
    let field = lower(_join(chars.slice(field-start, pos)).trim())
    if field == "" {
      panic("missing field name in BibTeX entry " + key)
    }

    pos = _skip-space(chars, pos)
    if pos >= chars.len() or chars.at(pos) != "=" {
      panic("expected '=' after field " + field + " in entry " + key)
    }

    let parsed = _parse-value(chars, pos + 1, close, macros)
    pos = _skip-space(chars, parsed.at(0))
    fields.insert(field, _decode-tex(
      parsed.at(1).braced,
      preserve-tilde: field in ("url", "doi", "pid", "cstr", "urn"),
    ))
    sources.insert(field, parsed.at(1).braced)

    if pos >= chars.len() {
      panic("unclosed @" + entry-type + " entry " + key)
    } else if chars.at(pos) == "," {
      pos += 1
    } else if chars.at(pos) == close {
      return (
        pos + 1,
        key,
        (key: key, entry-type: entry-type, fields: fields, sources: sources),
      )
    } else {
      panic("expected ',' or '" + close + "' after field " + field + " in entry " + key)
    }
  }
}

#let _month(text) = _value(text)

#let _months = (
  jan: _month("January"),
  feb: _month("February"),
  mar: _month("March"),
  apr: _month("April"),
  may: _month("May"),
  jun: _month("June"),
  jul: _month("July"),
  aug: _month("August"),
  sep: _month("September"),
  oct: _month("October"),
  nov: _month("November"),
  dec: _month("December"),
)

#let _split-words(source) = {
  let chars = source.clusters()
  let words = ()
  let current = ()
  let depth = 0
  let pos = 0

  while pos < chars.len() {
    let char = chars.at(pos)
    if char == "\\" {
      current.push(char)
      pos += 1
      if pos < chars.len() {
        current.push(chars.at(pos))
        pos += 1
      }
    } else if char == "{" {
      depth += 1
      current.push(char)
      pos += 1
    } else if char == "}" {
      if depth == 0 {
        panic("unmatched closing brace in BibTeX name")
      }
      depth -= 1
      current.push(char)
      pos += 1
    } else if depth == 0 and _is-space(char) {
      if current.len() > 0 {
        words.push(_join(current))
        current = ()
      }
      pos += 1
    } else {
      current.push(char)
      pos += 1
    }
  }

  if depth != 0 {
    panic("unclosed brace in BibTeX name")
  }
  if current.len() > 0 {
    words.push(_join(current))
  }
  words
}

#let _split-commas(source) = {
  let chars = source.clusters()
  let parts = ()
  let current = ()
  let depth = 0
  let pos = 0

  while pos < chars.len() {
    let char = chars.at(pos)
    if char == "\\" {
      current.push(char)
      pos += 1
      if pos < chars.len() {
        current.push(chars.at(pos))
        pos += 1
      }
    } else if char == "{" {
      depth += 1
      current.push(char)
      pos += 1
    } else if char == "}" {
      if depth == 0 {
        panic("unmatched closing brace in BibTeX name")
      }
      depth -= 1
      current.push(char)
      pos += 1
    } else if depth == 0 and char == "," {
      parts.push(_join(current).trim())
      current = ()
      pos += 1
    } else {
      current.push(char)
      pos += 1
    }
  }

  if depth != 0 {
    panic("unclosed brace in BibTeX name")
  }
  parts.push(_join(current).trim())
  parts
}

#let _split-names(source) = {
  let names = ()
  let current = ()

  for word in _split-words(source) {
    if lower(word) == "and" {
      if current.len() == 0 {
        panic("empty name around 'and'")
      }
      names.push(_join(current, separator: " "))
      current = ()
    } else {
      current.push(word)
    }
  }

  if current.len() > 0 {
    names.push(_join(current, separator: " "))
  } else if names.len() > 0 {
    panic("empty name after 'and'")
  }
  names
}

#let _whole-braced(source) = {
  let chars = source.trim().clusters()
  if chars.len() < 2 or chars.first() != "{" {
    return false
  }

  let depth = 0
  let pos = 0
  while pos < chars.len() {
    let char = chars.at(pos)
    if char == "\\" {
      pos += 2
    } else if char == "{" {
      depth += 1
      pos += 1
    } else if char == "}" {
      depth -= 1
      if depth == 0 and pos != chars.len() - 1 {
        return false
      }
      pos += 1
    } else {
      pos += 1
    }
  }
  depth == 0
}

#let _part(source) = {
  let part = _decode-tex(source).trim()
  if part == "" { none } else { part }
}

#let _starts-lower(word) = {
  for char in _strip-braces(word) {
    if lower(char) != upper(char) {
      return char == lower(char)
    }
  }
  false
}

#let _name(family: none, given: none, prefix: none, suffix: none, literal: none) = (
  family: family,
  given: given,
  prefix: prefix,
  suffix: suffix,
  literal: literal,
)

#let _parse-name(source) = {
  let source = source.trim()
  let plain = _decode-tex(source).trim()
  if plain == "" {
    panic("empty BibTeX name")
  }
  if lower(plain) == "others" {
    return _name(literal: "others")
  }
  if _whole-braced(source) {
    return _name(literal: plain)
  }

  let comma-parts = _split-commas(source)
  if comma-parts.len() == 1 {
    let words = _split-words(comma-parts.first())
    if words.len() == 1 {
      return _name(family: _part(words.first()))
    }

    let prefix-start = none
    let pos = 0
    while pos < words.len() - 1 {
      if _starts-lower(words.at(pos)) {
        prefix-start = pos
        break
      }
      pos += 1
    }

    if prefix-start == none {
      return _name(
        family: _part(words.last()),
        given: _part(_join(words.slice(0, words.len() - 1), separator: " ")),
      )
    }

    let family-start = prefix-start
    while family-start < words.len() - 1 and _starts-lower(words.at(family-start)) {
      family-start += 1
    }
    return _name(
      family: _part(_join(words.slice(family-start), separator: " ")),
      given: _part(_join(words.slice(0, prefix-start), separator: " ")),
      prefix: _part(_join(words.slice(prefix-start, family-start), separator: " ")),
    )
  }

  let last-words = _split-words(comma-parts.first())
  if last-words.len() == 0 {
    panic("missing family name before comma")
  }
  let family-start = 0
  while family-start < last-words.len() - 1 and _starts-lower(last-words.at(family-start)) {
    family-start += 1
  }

  let suffix = if comma-parts.len() >= 3 { _part(comma-parts.at(1)) } else { none }
  let given = if comma-parts.len() == 2 {
    _part(comma-parts.at(1))
  } else {
    _part(_join(comma-parts.slice(2), separator: ", "))
  }
  _name(
    family: _part(_join(last-words.slice(family-start), separator: " ")),
    given: given,
    prefix: _part(_join(last-words.slice(0, family-start), separator: " ")),
    suffix: suffix,
  )
}

#let parse-names(source) = _split-names(source).map(_parse-name)

#let _resolve-entry(key, entries, stack) = {
  if key in stack {
    panic("crossref cycle: " + _join(stack + (key,), separator: " -> "))
  }

  let entry = entries.at(key)
  let fields = entry.fields
  let sources = entry.sources
  if "crossref" in fields {
    let parent-key = fields.at("crossref")
    if parent-key in entries {
      let parent = _resolve-entry(parent-key, entries, stack + (key,))
      for (field, value) in parent.fields {
        if field != "crossref" and field not in fields {
          fields.insert(field, value)
          sources.insert(field, parent.sources.at(field))
        }
      }
    }
  }

  (
    key: entry.key,
    entry-type: entry.entry-type,
    fields: fields,
    sources: sources,
  )
}

#let _name-fields = ("author", "editor", "translator", "bookauthor")

#let bibtex-keys(source) = {
  let chars = _without-comments(source).clusters()
  let keys = ()
  let pos = 0
  while true {
    pos = _skip-space(chars, pos)
    while pos < chars.len() and chars.at(pos) != "@" { pos += 1 }
    if pos >= chars.len() { break }

    pos = _skip-space(chars, pos + 1)
    let type-start = pos
    while pos < chars.len() and not _is-space(chars.at(pos)) and chars.at(pos) not in ("{", "(") {
      pos += 1
    }
    let entry-type = lower(_join(chars.slice(type-start, pos)).trim())
    pos = _skip-space(chars, pos)
    if pos >= chars.len() or chars.at(pos) not in ("{", "(") {
      panic("expected '{' or '(' after @" + entry-type)
    }
    let open = chars.at(pos)
    let close = if open == "{" { "}" } else { ")" }
    let body-start = pos + 1

    if entry-type not in ("comment", "preamble", "string", "xdata") {
      let key-start = _skip-space(chars, body-start)
      let key-end = key-start
      while key-end < chars.len() and chars.at(key-end) not in (",", close) { key-end += 1 }
      let key = _join(chars.slice(key-start, key-end)).trim()
      if key != "" and key not in keys { keys.push(key) }
    }
    pos = _skip-enclosed(chars, body-start, open, close, "@" + entry-type)
  }
  keys
}

#let parse-bibtex(source) = {
  let chars = _without-comments(source).clusters()
  let macros = _months
  let entries = (:)
  let pos = 0

  while true {
    pos = _skip-space(chars, pos)
    if pos >= chars.len() {
      break
    }
    if chars.at(pos) != "@" {
      while pos < chars.len() and chars.at(pos) != "@" {
        pos += 1
      }
      continue
    }

    pos = _skip-space(chars, pos + 1)
    let type-start = pos
    while pos < chars.len() and not _is-space(chars.at(pos)) and chars.at(pos) not in ("{", "(") {
      pos += 1
    }
    let entry-type = lower(_join(chars.slice(type-start, pos)).trim())
    if entry-type == "" {
      panic("missing BibTeX entry type")
    }

    pos = _skip-space(chars, pos)
    if pos >= chars.len() or chars.at(pos) not in ("{", "(") {
      panic("expected '{' or '(' after @" + entry-type)
    }
    let open = chars.at(pos)
    let close = if open == "{" { "}" } else { ")" }
    pos += 1

    if entry-type in ("comment", "preamble") {
      pos = _skip-enclosed(chars, pos, open, close, "@" + entry-type)
    } else if entry-type == "string" {
      let parsed = _parse-string(chars, pos, close, macros)
      pos = parsed.at(0)
      macros.insert(parsed.at(1), parsed.at(2))
    } else {
      let parsed = _parse-entry(chars, pos, close, entry-type, macros)
      pos = parsed.at(0)
      let key = parsed.at(1)
      if key in entries {
        panic("duplicate BibTeX key: " + key)
      }
      entries.insert(key, parsed.at(2))
    }
  }

  let result = (:)
  for key in entries.keys() {
    let entry = _resolve-entry(key, entries, ())
    let names = (author: (), editor: (), translator: (), bookauthor: ())
    for field in _name-fields {
      if field in entry.sources {
        names.insert(field, parse-names(entry.sources.at(field)))
      }
    }
    result.insert(key, (
      key: entry.key,
      entry-type: entry.entry-type,
      fields: entry.fields,
      names: names,
    ))
  }
  result
}

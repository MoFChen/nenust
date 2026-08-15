#let _children(node, tag: none) = {
  if type(node) != dictionary { return () }
  node.at("children", default: ()).filter(child => (
    type(child) == dictionary
      and (tag == none or child.at("tag", default: "") == tag)
  ))
}

#let _child(node, tag) = _children(node, tag: tag).first(default: none)

#let _text(node) = {
  if type(node) == str { return node }
  if type(node) != dictionary { return "" }
  node.at("children", default: ()).map(_text).join("").trim()
}

#let _walk(node) = {
  if type(node) != dictionary { return () }
  let result = (node,)
  for child in _children(node) {
    result += _walk(child)
  }
  result
}

#let _feature(features, value) = {
  if value in features { features } else { features + (value,) }
}

#let csl-style-info(source) = {
  let tree = xml(bytes(source))
  let root = tree.find(node => type(node) == dictionary and node.at("tag", default: "") == "style")
  if root == none {
    panic("CSL style has no <style> root")
  }

  let info = _child(root, "info")
  let title = _text(_child(info, "title"))
  let id = _text(_child(info, "id"))
  let citation = _child(root, "citation")
  let category = _children(info, tag: "category").find(node => "citation-format" in node.attrs)
  let citation-format = if category != none {
    category.attrs.at("citation-format")
  } else if citation != none and citation.attrs.at("collapse", default: "") == "citation-number" {
    "numeric"
  } else {
    "author-date"
  }

  let features = ()
  for node in _walk(root) {
    let tag = node.at("tag", default: "")
    let attrs = node.at("attrs", default: (:))
    if tag == "layout" and "locale" in attrs {
      features = _feature(features, "locale-layout")
    }
    if tag == "institution" or tag == "institution-part" {
      features = _feature(features, "institution")
    }
    if tag == "conditions" or tag == "condition" {
      features = _feature(features, "conditions")
    }
    if tag == "court-class" {
      features = _feature(features, "court-class")
    }
    if tag == "term" and attrs.at("name", default: "") == "citation-range-delimiter" {
      features = _feature(features, "citation-range-delimiter")
    }
    let variables = attrs.at("variable", default: "").split(" ")
    for variable in variables {
      if variable in ("CSTR", "hereinafter", "original-container-title", "publication-date") {
        features = _feature(features, "variable:" + variable)
      }
    }
    for attribute in (
      "parallel-first", "parallel-last", "track-containers",
      "consolidate-containers", "suppress-min", "suppress-max",
      "require", "reject", "context",
    ) {
      if attribute in attrs {
        features = _feature(features, "attribute:" + attribute)
      }
    }
  }

  let is-gbt-2025 = (
    id.starts-with("https://zotero-chinese.com/styles/GB-T-7714—2025")
      and title.starts-with("GB-T-7714—2025")
  )
  (
    title: title,
    id: id,
    class: root.attrs.at("class", default: "in-text"),
    version: root.attrs.at("version", default: "1.0"),
    default-locale: root.attrs.at("default-locale", default: "en-US"),
    citation-format: citation-format,
    features: features,
    is-gbt-2025: is-gbt-2025,
    mode: if is-gbt-2025 {
      "gbt-2025-compat"
    } else if features.len() == 0 and not root.attrs.at("version", default: "1.0").contains("mlz") {
      "native-csl"
    } else {
      "unsupported-csl-m"
    },
  )
}

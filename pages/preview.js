(() => {
  const $ = (id) => document.getElementById(id);
  const data = window.NENU_PREVIEW;
  if (!data?.variants || !Object.keys(data.variants).length) {
    $("error").hidden = false;
    $("error").textContent = "未找到预览索引。请打开部署后的站点，或先运行 python scripts/build_pages.py。";
    $("library").disabled = $("single").disabled = $("compare").disabled = true;
    return;
  }
  const editions = data.variants,
    ids = Object.keys(editions),
    sides = ["a", "b"];
  const valid = (id) => Object.hasOwn(editions, id);
  const presetList = [
    ["实名 / 匿名", "tutorial", "anonymous", "中文封面"],
    ["单面 / 双面", "tutorial", "double-sided", "空白页"],
    ["理工 / 社科", "doctoral-academic-science", "doctoral-academic-social", "开始前必读"],
    ["两种引文制", "numeric-full", "author-date-full", "参考文献"],
    ["附表含附录", "tutorial", "appendix-tables", "附表目录"],
  ].filter(([, a, b]) => valid(a) && valid(b));
  const labels = {
    same: "页面相同",
    edit: "内容或版式",
    edge: "仅页边",
    add: "仅 B 有",
    remove: "仅 A 有",
    single: "单份阅读",
  };
  const S = {
    a: ids[0],
    b: ids[1] || ids[0],
    compare: true,
    rows: [],
    at: 0,
    mobile: "a",
    zoom: { a: 100, b: 100 },
  };
  const views = {};
  let listed = [],
    generation = 0;
  const node = (tag, text, cls) => {
    const n = document.createElement(tag);
    n.textContent = text;
    if (cls) n.className = cls;
    return n;
  };
  const press = (el, yes) => el.setAttribute("aria-pressed", String(yes));
  const pg = (side, n) => editions[S[side]].pages[n - 1];
  const other = (s) => (s === "a" ? "b" : "a");

  function rows() {
    if (!S.compare)
      return editions[S.a].pages.map((p, i) => ({ a: i + 1, b: 0, type: "single", title: p[2] }));
    let run = S.a === S.b ? `${editions[S.a].pages.length}M` : data.pairs[`${S.a}|${S.b}`];
    const reverse = !run;
    if (reverse) run = data.pairs[`${S.b}|${S.a}`];
    const result = [];
    let ai = 0,
      bi = 0;
    for (const [, count, code] of run.matchAll(/(\d+)([MAB])/g)) {
      for (let i = 0; i < Number(count); i++) {
        const a = code === (reverse ? "A" : "B") ? 0 : ++ai,
          b = code === (reverse ? "B" : "A") ? 0 : ++bi;
        const x = pg("a", a),
          y = pg("b", b);
        const type = !a ? "add" : !b ? "remove" : x[0] === y[0] ? "same" : x[1] === y[1] ? "edge" : "edit";
        result.push({ a, b, type, title: (x || y)[2] });
      }
    }
    return result;
  }

  function configure(a, b, compare = true, anchor = null, topic = "") {
    Object.assign(S, { a, b, compare });
    S.rows = rows();
    $("filter").value = "all";
    let i = anchor ? S.rows.findIndex((r) => r.a === anchor.a && (!compare || r.b === anchor.b)) : -1;
    if (i < 0 && anchor?.a) i = S.rows.findIndex((r) => r.a === anchor.a);
    if (i < 0 && topic) i = S.rows.findIndex((r) => r.title === topic && r.type !== "same");
    if (i < 0 && compare) i = S.rows.findIndex((r) => r.type !== "same");
    S.at = Math.max(0, i);
    for (const side of sides) views[side].select.value = S[side];
    press($("single"), !compare);
    press($("compare"), compare);
    $("panes").classList.toggle("single", !compare);
    views.b.root.hidden = !compare;
    document.querySelector(".mobile-sides").hidden = !compare;
    for (const id of ["swap", "filter"]) $(id).hidden = !compare;
    document.querySelector(".toggles").hidden = !compare;
    document.querySelector(".steppers").hidden = !compare;
    $("nav-title").textContent = compare ? "差异导航" : "章节导航";
    [...$("presets").querySelectorAll("button")].forEach((el, k) =>
      press(el, compare && a === presetList[k][1] && b === presetList[k][2]),
    );
    buildList();
    show();
  }
  function buildList() {
    const filter = $("filter").value;
    listed = [];
    S.rows.forEach((r, i) => {
      if (
        S.compare
          ? r.type !== "same" &&
            (filter === "all" ||
              r.type === filter ||
              (filter === "gap" && ["remove", "add"].includes(r.type)))
          : !i || r.title !== S.rows[i - 1].title
      )
        listed.push(i);
    });
    $("nav-count").textContent = listed.length;
    const list = $("row-list");
    list.replaceChildren();
    for (const i of listed) {
      const r = S.rows[i],
        btn = node("button", "", "row");
      btn.dataset.index = i;
      btn.append(
        node("strong", r.title),
        node("em", S.compare ? labels[r.type] : ""),
        node("small", S.compare ? `A ${r.a || "—"}　↔　B ${r.b || "—"}` : `第 ${r.a} 页`),
      );
      btn.onclick = () => jump(i);
      list.append(btn);
    }
    if (!listed.length)
      list.append(
        node("p", filter === "all" ? "两份 PDF 逐页画面相同。" : "此筛选下没有差异页。", "empty-note"),
      );
  }
  function gapText(r) {
    return r.type === "add" ? "此页仅在 B 版出现" : "此页仅在 A 版出现";
  }
  function nextIndex(side, step) {
    for (let i = S.at + step; i >= 0 && i < S.rows.length; i += step) if (S.rows[i][side]) return i;
    return -1;
  }
  function jump(i) {
    if (i >= 0 && i < S.rows.length) {
      S.at = i;
      show();
    }
  }
  function show() {
    const r = S.rows[S.at],
      gen = ++generation;
    $("badge").textContent = labels[r.type];
    $("section").textContent = r.title;
    $("hint").textContent = !S.compare
      ? "这里使用 PDF 物理页码；查找或复制正文可打开原 PDF。"
      : r.type === "add" || r.type === "remove"
        ? `${gapText(r)}；另一栏留空。`
        : r.type === "same"
          ? "这两页画面相同。"
          : "色块提示可见变化的位置；页码分别对应两份原 PDF。";
    $("prev-diff").disabled = !listed.some((i) => i < S.at);
    $("next-diff").disabled = !listed.some((i) => i > S.at);
    const active = S.compare ? S.at : listed.filter((i) => i <= S.at).at(-1);
    for (const btn of $("row-list").querySelectorAll("button"))
      btn.setAttribute("aria-current", String(Number(btn.dataset.index) === active));
    const list = $("row-list"),
      current = list.querySelector("[aria-current=true]");
    if (current && list.clientHeight) {
      const box = current.getBoundingClientRect(),
        bounds = list.getBoundingClientRect();
      if (box.top < bounds.top) list.scrollTop += box.top - bounds.top;
      else if (box.bottom > bounds.bottom) list.scrollTop += box.bottom - bounds.bottom;
    }
    for (const side of S.compare ? sides : ["a"]) {
      const v = views[side],
        n = r[side],
        ed = editions[S[side]];
      v.input.value = n || "";
      v.input.max = ed.pages.length;
      v.total.textContent = ed.pages.length;
      v.prev.disabled = nextIndex(side, -1) < 0;
      v.next.disabled = nextIndex(side, 1) < 0;
      v.open.href = n ? `${ed.file}#page=${n}` : ed.file;
      v.download.href = ed.file;
      v.caption.textContent = n ? `PDF 第 ${n} 页 · ${pg(side, n)[2]}` : "无对应物理页";
      v.sheet.hidden = !n;
      v.placeholder.hidden = !!n;
      v.mask.hidden = true;
      v.viewport.scrollTo(0, 0);
      if (n) {
        v.img.alt = `${ed.label}，第 ${n} 页，${pg(side, n)[2]}`;
        v.img.src = `sheets/${pg(side, n)[0]}.webp`;
      } else {
        v.img.removeAttribute("src");
        v.placeholder.textContent = gapText(r);
      }
    }
    if (S.compare && r.a && r.b && r.type !== "same" && $("mark").checked) paint(gen, true);
    const hash = new URLSearchParams({ a: S.a });
    if (S.compare) {
      hash.set("b", S.b);
      hash.set("pb", r.b);
    } else hash.set("mode", "single");
    hash.set("pa", r.a);
    history.replaceState(null, "", "#" + hash.toString());
  }

  async function paint(gen, focus) {
    const { a, b } = views;
    try {
      await Promise.all([a.img.decode(), b.img.decode()]);
    } catch {
      return;
    }
    if (gen !== generation || !$("mark").checked) return;
    if (a.img.naturalWidth * b.img.naturalHeight !== b.img.naturalWidth * a.img.naturalHeight) return;
    const w = 430,
      h = Math.round((w * a.img.naturalHeight) / a.img.naturalWidth);
    const sample = document.createElement("canvas");
    sample.width = w;
    sample.height = h;
    const ctx = sample.getContext("2d", { willReadFrequently: true });
    const pixels = (v) => {
      ctx.drawImage(v.img, 0, 0, w, h);
      return ctx.getImageData(0, 0, w, h).data;
    };
    const x = pixels(a),
      y = pixels(b),
      masks = sides.map((s) => {
        const c = views[s].mask;
        c.width = w;
        c.height = h;
        c.hidden = false;
        const m = c.getContext("2d");
        m.fillStyle = s === "a" ? "rgba(202,86,48,.29)" : "rgba(23,145,137,.29)";
        return m;
      });
    let first = h;
    for (let j = 0; j < h; j += 6)
      for (let i = 0; i < w; i += 6) {
        let changed = 0;
        for (let yy = j; yy < Math.min(j + 6, h); yy++)
          for (let xx = i; xx < Math.min(i + 6, w); xx++) {
            const p = (yy * w + xx) * 4;
            if (
              Math.max(Math.abs(x[p] - y[p]), Math.abs(x[p + 1] - y[p + 1]), Math.abs(x[p + 2] - y[p + 2])) >
              33
            )
              changed++;
          }
        if (changed >= 2) {
          first = Math.min(first, j);
          masks.forEach((m) => m.fillRect(i, j, 6, 6));
        }
      }
    if (focus && first < h)
      for (const v of [a, b])
        v.viewport.scrollTop = Math.max(
          0,
          (first / h) * v.sheet.clientHeight - v.viewport.clientHeight * 0.34,
        );
  }

  function zoom(side, value) {
    for (const s of S.compare && $("sync").checked ? sides : [side]) {
      const v = views[s];
      S.zoom[s] = value;
      v.sheet.style.setProperty("--zoom", value + "%");
      v.sheet.style.setProperty("--factor", value / 100);
      v.scale.textContent = value + "%";
      v.smaller.disabled = value <= 75;
      v.larger.disabled = value >= 200;
    }
  }
  function createPane(side) {
    const root = $("pane-template").content.firstElementChild.cloneNode(true),
      q = (cls) => root.querySelector("." + cls);
    const v = {
      root,
      select: q("edition"),
      input: q("page-no"),
      prev: q("previous"),
      next: q("next"),
      total: q("total"),
      viewport: q("viewport"),
      img: root.querySelector("img"),
      sheet: q("sheet"),
      mask: root.querySelector("canvas"),
      placeholder: q("absent"),
      caption: q("page-caption"),
      open: q("open-pdf"),
      download: q("download"),
      smaller: q("smaller"),
      larger: q("larger"),
      scale: q("scale"),
    };
    views[side] = v;
    root.dataset.side = side;
    q("letter").textContent = side.toUpperCase();
    v.viewport.setAttribute("aria-label", side.toUpperCase() + " 版页面预览");
    v.select.setAttribute("aria-label", side.toUpperCase() + " 版配置");
    v.input.setAttribute("aria-label", side.toUpperCase() + " 版 PDF 页码");
    let group;
    for (const [id, ed] of Object.entries(editions)) {
      if (!group || group.label !== ed.group) {
        group = document.createElement("optgroup");
        group.label = ed.group;
        v.select.append(group);
      }
      group.append(new Option(ed.label, id));
    }
    v.select.onchange = () =>
      configure(side === "a" ? v.select.value : S.a, side === "b" ? v.select.value : S.b, S.compare);
    v.prev.onclick = () => jump(nextIndex(side, -1));
    v.next.onclick = () => jump(nextIndex(side, 1));
    v.input.onchange = () => {
      const n = Math.max(1, Math.min(Number(v.input.max), Math.floor(Number(v.input.value) || 1)));
      jump(S.rows.findIndex((r) => r[side] === n));
    };
    v.smaller.onclick = () => zoom(side, Math.max(75, S.zoom[side] - 25));
    v.larger.onclick = () => zoom(side, Math.min(200, S.zoom[side] + 25));
    v.scale.textContent = "100%";
    v.img.onerror = () => {
      if (!v.sheet.hidden) {
        v.placeholder.hidden = false;
        v.sheet.hidden = true;
        v.placeholder.textContent = "此页图像未能载入，可打开下方原 PDF。";
      }
    };
    v.viewport.onscroll = () => {
      if (!S.compare || !$("sync").checked || performance.now() < (v.hold || 0)) return;
      const peer = views[other(side)];
      if (!peer || !peer.viewport.clientWidth) return;
      peer.hold = performance.now() + 70;
      for (const [pos, full, visible] of [
        ["scrollTop", "scrollHeight", "clientHeight"],
        ["scrollLeft", "scrollWidth", "clientWidth"],
      ]) {
        peer.viewport[pos] =
          (v.viewport[pos] / Math.max(1, v.viewport[full] - v.viewport[visible])) *
          (peer.viewport[full] - peer.viewport[visible]);
      }
    };
    $("panes").append(root);
  }
  function mobile(side) {
    S.mobile = side;
    $("panes").dataset.active = side;
    for (const s of sides) press($("show-" + s), s === side);
  }
  function fromURL() {
    const h = new URLSearchParams(location.hash.slice(1)),
      pick = (key, fallback) => (valid(h.get(key)) ? h.get(key) : fallback);
    const def = presetList[0] || ["", ids[0], ids[1] || ids[0], ""];
    configure(
      pick("a", def[1]),
      pick("b", def[2]),
      h.get("mode") !== "single",
      h.has("pa") ? { a: Number(h.get("pa")), b: Number(h.get("pb")) } : null,
      h.size ? "" : def[3],
    );
  }
  function library() {
    const list = $("catalog-list"),
      query = $("search").value.trim().toLowerCase();
    list.replaceChildren();
    let current = "",
      count = 0;
    for (const [id, ed] of Object.entries(editions)) {
      if (!`${ed.label} ${ed.group} ${id}`.toLowerCase().includes(query)) continue;
      if (current !== ed.group) {
        list.append(node("h3", ed.group));
        current = ed.group;
      }
      const item = node("div", "", "catalog-item"),
        read = node("button", "阅读"),
        compare = node("button", "与 A 对照");
      read.onclick = () => {
        $("catalog").close();
        configure(id, S.b, false);
      };
      compare.onclick = () => {
        $("catalog").close();
        configure(S.a, id);
      };
      item.append(node("span", ed.label), node("small", ed.pages.length + " 页"), read, compare);
      list.append(item);
      count++;
    }
    if (!count) list.append(node("p", "没有匹配的示例。", "empty-note"));
  }
  sides.forEach(createPane);
  sides.forEach((s) => ($("show-" + s).onclick = () => mobile(s)));
  mobile("a");
  $("edition-count").textContent = ids.length;
  $("navigator").open = !matchMedia("(max-width:700px)").matches;
  for (const [title, a, b, topic] of presetList) {
    const btn = node("button", title);
    btn.onclick = () => configure(a, b, true, null, topic);
    $("presets").append(btn);
  }
  $("filter").onchange = () => {
    buildList();
    jump(listed[0] ?? S.at);
  };
  $("prev-diff").onclick = () => jump(listed.filter((i) => i < S.at).at(-1));
  $("next-diff").onclick = () => jump(listed.find((i) => i > S.at));
  $("single").onclick = () => configure(S.a, S.b, false, S.rows[S.at]);
  $("compare").onclick = () => configure(S.a, S.b, true);
  $("swap").onclick = () => {
    const r = S.rows[S.at];
    configure(S.b, S.a, true, { a: r.b, b: r.a });
  };
  $("mark").onchange = () => {
    const r = S.rows[S.at];
    if ($("mark").checked && r.a && r.b && r.type !== "same") paint(generation, false);
    else for (const s of sides) views[s].mask.hidden = true;
  };
  $("sync").onchange = () => {
    if ($("sync").checked) {
      zoom("a", S.zoom.a);
      views.a.viewport.dispatchEvent(new Event("scroll"));
    }
  };
  $("copy").onclick = async () => {
    try {
      await navigator.clipboard.writeText(location.href);
      $("hint").textContent = "已复制当前配置与页码的链接。";
    } catch {
      $("hint").textContent = "当前配置与页码已写入地址栏，可直接复制网址。";
    }
  };
  $("library").onclick = () => {
    $("search").value = "";
    library();
    $("catalog").showModal();
    $("search").focus();
  };
  $("close-lib").onclick = () => $("catalog").close();
  $("search").oninput = library;
  window.addEventListener("hashchange", fromURL);
  $("app").hidden = false;
  fromURL();
})();

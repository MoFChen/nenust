/* BASE FONT */
#let FONT_HEITI   = "SimHei"
#let FONT_SONGTI  = "SimSun"
#let FONT_YAHEI   = "Microsoft YaHei UI"
#let FONT_TIMES   = (name: "Times New Roman", covers: "latin-in-cjk")
#let FONT_CODE    = "Roboto Mono"
#let FONT_MATH    = "New Computer Modern Math"
//#let FONT_MATH    = "New Computer Modern Sans Math"
//#let FONT_MATH    = "DejaVu Math TeX Gyre"
//#let FONT_MATH    = "GFS Neohellenic Math"
//#let FONT_MATH    = "Lete Sans Math"
//#let FONT_MATH    = "Libertinus Math"
//#let FONT_MATH    = "Luciole Math"
//#let FONT_MATH    = "TeX Gyre Bonum Math"
//#let FONT_MATH    = "TeX Gyre Pagella Math"
//#let FONT_MATH    = "TeX Gyre Schola Math"
//#let FONT_MATH    = "TeX Gyre Termes Math"

/* FONT FALLBACK */
#let FONTS_HEITI  = (FONT_TIMES, FONT_HEITI)
#let FONTS_SONGTI = (FONT_TIMES, FONT_SONGTI)
#let FONTS_YAHEI  = (FONT_TIMES, FONT_YAHEI)
#let FONTS_CODE   = (FONT_CODE, FONT_SONGTI)
#let FONTS_MATH   = (FONT_MATH, FONT_SONGTI)
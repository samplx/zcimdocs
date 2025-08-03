
#let cursive-font = "Edu NSW ACT Foundation"
#let cursive-font-name = "'hand-written' text"

#let default-tab-stop = 8

#let leading-length = 0.95em

#let listing-fill = rgb(255, 255, 248)
#let listing-leading-length = 0.55em
#let listing-font-size = 1em

#let mono-font = "Atkinson Hyperlegible Mono"

#let page-size = "us-letter"
#let print-listing-fill = rgb(248, 255, 255)
#let print-listing-font-size = 0.7em

#let sans-font = "Atkinson Hyperlegible Next"
#let serif-font = "EB Garamond"

#let title-font = "Cheerful Donuts"

#let ui-fill = purple
#let ui-fill-name = "purple"

#let title-page(
  project: [Zcim Project],
  title-text: [],
  version: [],
) = {
  align(center)[
    #pad(top: 64pt)[
      #text(size: 24pt)[
        #text(font: title-font, project) \
        #title-text \
      ]
    ]
    #v(1fr)
    #pad(bottom: 24pt)[
      #text(size: 14pt)[
        #text(font: title-font, version) \
      ]
    ]
  ]  
}

#let credits-page(
  copyright: [],
  disclaimer: none,
  trademarks: none,
  printing: [],
  license: [
    The original Digital Research Inc assets license is available at \
    #link("http://cpm.z80.de/license.html")[http://cpm.z80.de/license.html]. \
    This _Zcim Project edition_ is licensed under the \
    Creative Commons Attribution 4.0 International license. #link("https://creativecommons.org/licenses/by/4.0/")[*CC BY 4.0*].    
  ],
) = {
  align(center)[
    #pad(top: 2em)[
      *Copyright* \
      #copyright
    ]
    #pad(top: 2em)[
      *License* \
      #license
    ]
    #if disclaimer != none [
      #pad(top: 2em)[
        *Disclaimer* \
        #disclaimer
      ]
    ]
    #if trademarks != none [
      #pad(top: 2em)[
        *Trademarks* \
        #trademarks
      ]
    ]
    #v(1fr)
    #pad(bottom: 24pt)[
      *Printing* \
      #printing
    ]
  ]
}


#let bdos-entry(
  c,
  caption,
  e: none,
  de: none,
  return-a: none,
  return-hl: none,
  return-other: none,
  return-h: none,
  flavor: none,
  globals: (),
) = {
  let c_str = str(c)
  let c_hex = upper(str(c, base: 16))
  if c_hex.len() < 2 {
    c_hex = "0" + c_hex
  }
  c_hex = c_hex + "H"
  let prefix = "Function " + c_str
  let children = (
    table.cell(align: left)[*Entry Parameters:*], [],
    [Register `C`:], [#raw(c_str) = #raw(c_hex)],
  )
  if e != none {
    children.push([Register `E`:])
    children.push([#e])
  }
  if de != none {
    children.push([Registers `DE`:])
    children.push([#de])
  }
  if return-a != none {
    children.push(table.cell(align: left)[*Returned Value:*])
    children.push([])
    children.push([Register `A`:])
    children.push([#return-a])
    if return-h != none {
      children.push([Register `H`:])
      children.push([#return-h])
    }
    if return-other != none {
      children.push([Other:])
      children.push([#return-other])
    }
    if return-hl != none {
      children.push([Registers `HL`:])
      children.push([#return-hl])
    }
  } else if return-hl != none {
    children.push(table.cell(align: left)[*Returned Value:*])
    children.push([])
    children.push([Registers `HL`:])
    children.push([#return-hl])
    if return-other != none {
      children.push([Other:])
      children.push([#return-other])
    }
  } else if return-other != none {
    children.push(table.cell(align: left)[*Returned Value:*])
    children.push([#return-other])
  } else {
    children.push(table.cell(align: left)[*Returned Value:*])
    children.push([*none*])
  }
  if globals.len() > 0 {
    children.push(table.cell(align: left)[*Global State:*])
    children.push([])
    for (v, s) in globals {
      children.push(raw(v))
      children.push(s)
    }
  }
  if flavor != none {
    children.push(table.cell(align: left)[*Version Specific:*])
    children.push([])
    children.push(table.cell(align: center, colspan: 2)[#flavor])
  }
  align(center)[
    #figure(
      table(
        columns: (25%, auto),
        align: (right, left),
        stroke: none,
        ..children,        
      ),
      caption: [#text(weight: "bold", prefix): #caption],
      numbering: none
    )
  ]  
}

#let zcim-project = text(font: title-font)[Zcim Project]

#let cmd-line(content) = {
  pad(left: 5em, content)
}

#let paged-listing(
  list-fill: listing-fill,
  content
) = {
  set par(leading: listing-leading-length)
  block(
    breakable: false,
    fill: list-fill,
    inset: 1em,
    content
  )
  pagebreak()
}

#let source-listing(
  list-fill: listing-fill,
  content
) = {
  set par(leading: listing-leading-length)
  block(
    fill: list-fill,
    inset: 1em,
    content
  )
}


#let rect-listing(
  tabs: default-tab-stop,
  list-fill: listing-fill,
  content
) = {
  rect(
    fill: list-fill,
    stroke: 1pt,
    width: 100%,
    inset: 1em
  )[
    #set align(left)
    #set par(leading: listing-leading-length)
    #set raw(tab-size: tabs)
    #block(
      inset: 1em,
      content
    )
  ]
}

#let rect-print-listing(
  tabs: default-tab-stop,
  list-fill: print-listing-fill,
  content
) = {
  rect(
    fill: list-fill,
    stroke: 1pt,
    width: 100%,
    inset: 1em
  )[
    #set align(left)
    #set par(leading: listing-leading-length)
    #set raw(tab-size: tabs)
    #set text(size: print-listing-font-size)
    #block(
      inset: 1em,
      content
    )
  ]
}


#let sample-stack(
  tabs: default-tab-stop,
  commentary: [],
  content
) = {
  pad(
    y: 2em,
    box(
      stroke: 2pt,
      outset: 16pt,
      radius: 8pt,
      width: 1fr,
      stack(
        dir: ltr,
        spacing: -100%,
        block(
          width: 100%,
          [
            #set align(left)
            #set raw(tab-size: tabs)
            #set par(leading: listing-leading-length)
            #content
          ]
        ),
        block(
          width: 100%,
          [
            #set text(font: cursive-font)
            #set par(leading: listing-leading-length)
            #commentary
          ]
        )
      )
    )
  )
}

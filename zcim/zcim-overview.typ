// -------------------------------------------------------------------------------
// START of COMMON
// -------------------------------------------------------------------------------
#import "/zcim-library.typ": *

// define the page size
#set page(paper: page-size)
// default font
#set text(font: sans-font)
// default font for raw text
#show raw : set text(font: mono-font)
// set default leading
#set par(leading: leading-length)

// make visible control characters a little more visible
#show "␍" : text(font: mono-font, size: 1.8em, baseline: 2pt)[␍]
#show "␊" : text(font: mono-font, size: 1.8em, baseline: 2pt)[␊]

// don't split these at the slash
#show "CP/M" : box([CP/M])
#show "MP/M" : box([MP/M])
#show "PL/M" : box([PL/M])
#show "PL/I" : box([PL/I])

#import "@preview/headcount:0.1.0": *

#let document-version = [draft 2025-07-28]

// -------------------------------------------------------------------------------
// END of COMMON
// -------------------------------------------------------------------------------

#title-page(
  title-text: [
_Zcim System Overview_
  ],
  version: document-version
)

#pagebreak()

= Overview

== Document Layout

- legacy content
  - version specific
    - 1.3
    - 1.4
    - 2.0
    - 2.2
    - 3.0
    
  - tool specific
    - cbasic
    - despool
    - mac80
    - link80
    - pascal mt+
    - ed
    - ddt
    - asm
    - pl/m
    - pl/i
    - sid
    - tex
    
- project content
  - web content
  - reference
    - manual pages
    - file formats
    
  

== Tasks

- site directory layout
- build process
- Zcim design specifications
  - Zcim CLI Manual Pages
- `bdos-tests` and docs
- local BDOS tests
- Zcim BDOS specifications
- re-engineered sources
- Typst documents
  - manual page template
  - general template
  - DRI template
- `test-system`
- z80pack device drivers


== Follow-On Features

- 1.4 Flavor support
- 3.0 Flavor support
- Bank Switch Memory
- 8080 CPU support
- 8085 CPU support
- Traditional CP/M memory layout
- MITS disk format support
- TeleDisk image format support
  - standard format
  - advanced format
  - write support
- ImageDisk image format
  - read support
  - write support
- Cycle-time Audit / Tracking
- Pacing

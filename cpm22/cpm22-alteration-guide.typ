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

#let document-version = [version 2025-07-31]

// -------------------------------------------------------------------------------
// END of COMMON
// -------------------------------------------------------------------------------
#title-page(
  title-text: [
Digital Research \
    _CP/M® 2.2 Alteration Guide_
  ],
  version: document-version
)

#pagebreak()
#credits-page(
  copyright: [
Copyright ©1979 by Digital Research. All rights reserved. No part of this publication may be reproduced, transmitted, transcribed, stored in a retrieval system, or translated into any language or computer language, in any form or by any means, electronic, mechanical, magnetic, optical, chemical, manual or otherwise, without the prior written permission of \
#strike[Digital Research, Post Office Box  579, Pacific Grove, California 93950]. \
#strike[http://www.lineo.com] \
DRDOS, Inc [Bryan Sparks] \
Copyright © 2025 by James Burlingame.
   
  ],
  disclaimer: [
Digital Research makes no representations or warranties with respect to  the
contents hereof and specifically disclaims any implied warranties of
merchantability or fitness for any particular purpose. Further, Digital
Research reserves the right to revise this publication and to make changes  from
time to time in the content hereof without obligation of Digital  Research to
notify any person of such revision or changes.    
  ],
  trademarks: [
CP/M is a registered trademark of Digital Research.
MP/M, MAC and SID are trademarks of Digital Research.
  ],
  printing: [
    #zcim-project edition: #document-version
  ]
)
#pagebreak()

#set heading(numbering: "1.", supplement: [Section])
#set page(numbering: "i")
#set figure(numbering: dependent-numbering("1-1"))
#outline()
#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)
#pagebreak()
#counter(page).update(1)
#set page(numbering: "1")
#set heading(numbering: "1.", supplement: [Section])
= Introduction

#set heading(numbering: none)
#pagebreak()
= Notes on the #zcim-project Edition

The #zcim-project goal is to improve the accessibility of legacy Z80 CP/M era content.
As part of the project, Jim Burlingame (_jb\@samplx.org_) created a _Typst_ version of this manual.

You can find out more about the project at its site #link("https://www.z80cim.org")[z80cim.org].
The sources of this document are available on
#link("https://github.com/samplx/zcimdocs")[GitHub].


*This document is a stub. Please use the source material*

The source material is from the
#link("http://cpm.z80.de/drilib.html")[_Tim Olmstead Memorial Digital Research CP/M Library_]

The individual documents from the archive include:

- #link("http://cpm.z80.de/randyfiles/DRI/CPM_2_0_System_Alteration_Guide.pdf")[_CP/M 2.0 Alteration Guide_ (pdf)]

Additional documents are available from #link("https://www.icl1900.co.uk/unix4fun/z80pack/index.html")[z80pack], including:

- #link("https://www.icl1900.co.uk/unix4fun/z80pack/ftp/manuals/DRI/cpm-2.2/CPM_2.2_Alteration_Guide_1979.pdf")[_CP/M 2.2 Alteration Guide_ (pdf)]

The contents of the manual were edited using the #link("https://Typst.app/")[Typst.app] site.

The sources of the document are available at
#link("https://github.com/samplx/zcimdocs")[GitHub].

== License

The source documentation is under a license granted by the owner
of the Digital Research intellectual property 
in an email available at #link("http://cpm.z80.de/license.html").

The #zcim-project edition is under the Creative Commons Attribution 4.0 International license. #link("https://creativecommons.org/licenses/by/4.0/")[*CC BY 4.0*].


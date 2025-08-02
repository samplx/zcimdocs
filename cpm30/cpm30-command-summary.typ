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

#let document-version = [stub 2025-08-01]

// -------------------------------------------------------------------------------
// END of COMMON
// -------------------------------------------------------------------------------
#title-page(
  title-text: [
    _CP/M Plus Operating System \
    Command Summary_
  ],
  version: document-version
)

#pagebreak()
#credits-page(
  copyright: [
Copyright ©1984 by Digital Research. All rights reserved. No part of this publication may be reproduced, transmitted, transcribed, stored in a retrieval system, or translated into any language or computer language, in any form or by any means, electronic, mechanical, magnetic, optical, chemical, manual or otherwise, without the prior written permission of \
#strike[Digital Research, 60 Garden Court, Box DRI, Monterey, California 93942]. \
#strike[http://www.lineo.com] \
DRDOS, Inc [Bryan Sparks] \
Copyright © 2025 by James Burlingame.
   
  ],
  disclaimer: [
#upper[Digital Research makes no representations or warranties with respect to  the
contents hereof and specifically disclaims any implied warranties of
merchantability or fitness for any particular purpose.] Further, Digital
Research reserves the right to revise this publication and to make changes  from
time to time in the content hereof without obligation of Digital  Research to
notify any person of such revision or changes.    
  ],
  trademarks: [
    CP/M and Digital Research and its logo are registered trademarks of Digital Research Inc. CP/M Plus, LINK-80, MAC, MP/M, PL/1-80, RMAC, SID, TEX, and XREF are trademarks of Digital Research Inc. Intel is a registered trademark of Intel Corporation. Microsoft is a registered trademark of Microsoft Corporation.
  ],
  printing: [
    First Edition: March 1984 \
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
#counter(page).update(0)
#pagebreak()
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

- #link("http://cpm.z80.de/manuals/cpm3-cmd.pdf")[_CP/M 3 Command Summary_ (pdf)]

The contents of the manual were edited using the #link("https://Typst.app/")[Typst.app] site.

== License

The source documentation is under a license granted by the owner
of the Digital Research intellectual property 
in an email available at #link("http://cpm.z80.de/license.html").

The #zcim-project edition is under the Creative Commons Attribution 4.0 International license. #link("https://creativecommons.org/licenses/by/4.0/")[*CC BY 4.0*].


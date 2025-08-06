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

#let document-version = [draft 2025-09-04]

#import "/bdos-common.typ": bdos-system-call-spec, bdos-function-support-table

// -------------------------------------------------------------------------------
// END of COMMON
// -------------------------------------------------------------------------------

#title-page(
  title-text: [
    Digital Research CP/M® \
_Basic Disk Operating System (BDOS) Specifications_
  ],
  version: document-version
)

#pagebreak()
#credits-page(
  copyright: [
Copyright © 1976, 1977, 1978, 1979, 1982, and 1983 by Digital
Research. All rights reserved. No part of this publication may be  reproduced,
transmitted, transcribed, stored in a retrieval system, or  translated into any
language or computer language, in any form or by any  means, electronic,
mechanical, optical, chemical, manual or otherwise,  without the prior written permission of \
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
CP/M and CP/NET are registered trademarks of Digital Research. ASM,
DESPOOL, DDT, LINK-80, MAC, MP/M, PL/I-80, and SID are trademarks of  Digital
Research. Intel is a registered trademark of Intel Corporation. TI  Silent 700
is a trademark of Texas Instruments Incorporated. Zilog and Z80  are registered
trademarks of Zilog, Inc.    
  ],
  printing: [
    #zcim-project edition: #document-version
  ]
)
#pagebreak()

#set heading(numbering: "1.", supplement: [Section])
#set page(numbering: "i")
#set figure(numbering: "1.")
#outline()
#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)
#pagebreak()
#counter(page).update(1)
#set page(numbering: "1")
#set heading(numbering: "1.", supplement: [Section])
#show figure: set block(breakable: true)
= Introduction

This document is a set of reverse engineered specifications of the Basic Disk Operating System (BDOS) component of the CP/M Operating System. These specifications are related to the 8-bit version of CP/M, that was in later years called CP/M-80. Other versions of CP/M on 16-bit and 32-bit processors are not included.

Similarly, MP/M is a related, but distinct product and is not included in these specifications.

The goal of these specifications is to provide enough information to reproduce, or at least
imitate, the behavior of CP/M as part of the #zcim-project.

== Known Versions

Since CP/M is a legacy product, the list of known versions, or more accurately, the versions
where the source code is available, is largely fixed.
Copies of these versions are available. Other versions are known to have
existed but are not available (e.g. `2.1`).

#figure(
  table(
    columns: (auto, 1fr),
    align: (center, left),
    inset: 10pt,
    table.header([*Id*], [*Description*]),
    [`1975`], [An early version from 1975 - supported 2 drives, combined FDOS],
    [`1.3`], [CP/M 1.3],
    [`1.4`], [CP/M 1.4 - supports 4 drives],
    [`2.0`], [CP/M 2.0 - first 2.x release, BDOS/BIOS split, 16 drive support, random I/O],
    [`2.2`], [CP/M 2.2 - fixes bugs in 2.0, adds function 40],
    [`3.0nb`], [CP/M 3.0 aka CP/M Plus - non-banked - without banked-memory],
    [`3.0b`], [CP/M 3.0 aka CP/M Plus - banked - with banked-memory],
  ),
  caption: [Known CP/M Versions],
  numbering: "1",
)

== External Interfaces

The BDOS has three interfaces:

- Basic Input/Output System - BIOS
- Console Command Processor - CCP
- System Call Interface (`CALL 0005H`)

== Memory Layout

The memory layout used by CP/M evolved in each major version.

=== Original Version 1 Memory Layout

Memory organization of the original CP/M system is shown in
@CPM1MemoryOrg


#align(center)[
#figure(
  table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 5pt, y: 10pt),
    table.cell(align: end)[Top of Memory \ \ \
    `FBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 40pt))[FDOS],
    table.cell(align: bottom + end)[`CBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[CCP],
    table.cell(align: bottom + end)[`TBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 45pt))[TPA],
    table.cell(align: bottom + end)[`BOOT:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 10pt))[System Parameters]
  ),
  caption: [CP/M 1 Memory Organization]
) <CPM1MemoryOrg>
]

=== CP/M Version 2 Memory Layout


#align(center)[
#figure(
  table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 5pt, y: 10pt),
    table.cell(align: end)[Top of Memory \
    `BIOS Jump Table:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 10pt))[BIOS],
    table.cell(align: bottom + end)[`FBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[BDOS],
    table.cell(align: bottom + end)[`CBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[CCP],
    table.cell(align: bottom + end)[`TBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 45pt))[TPA],
    table.cell(align: bottom + end)[`BOOT:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 10pt))[System Parameters]
  ),
  caption: [CP/M 2 Memory Organization]
) <CPM2MemoryOrg>
]

=== CP/M 3 Memory Layout

There were two options in the version 3 memory layout, since it supported
*bank switching* in order to break through the dreaded 64KiB memory barrier.

#align(right)[#block(width: 70%)[Of course, at that time marketing had not perverted the concept of a *K*, so
it was always *64K*, since *KiB* had not been developed to keep pedantic fools
like me happy.]]

==== Non-Banked System

In a non-banked system, you still had to live with the 64K limit while still trying to
add more features.

#align(center)[
#figure(
  table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 5pt, y: 10pt),
    table.cell(align: end)[Top of Memory],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[Buffers],
    table.cell(align: bottom + end)[],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[O.S.],
    table.cell(align: bottom + end)[],
      table.cell(align: bottom, stroke: (left: 1pt, right: 1pt), inset: (x: 20pt, y: 45pt))[TPA],
    table.cell(align: bottom + end)[Low Memory \ `0000H`],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt, bottom: 1pt), inset: (x: 20pt, y: 10pt))[]
  ),
  caption: [CP/M 3 Non-Banked Memory Organization]
) <CPM3NonBankedMemoryOrg>
]

==== Banked-memory System

#align(center)[
#figure(
  table(
    columns: (1fr, 8em, 1em, 8em, 2em, 8em),
    stroke: none,
    inset: (x: 15pt, y: 10pt),
    table.cell(align: end)[Top of Memory],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[Buffers],
      [], [],
      [], [],
    table.cell(align: bottom + end)[Common],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[O.S.],
      [], [],
      [], [],
    table.cell(align: bottom + end)[],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt), fill: luma(200))[],
      [], [],
      [], [],
    table.cell(align: top + end)[Top of Banked Memory],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 45pt))[Banked O.S.],
      [],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt, top: 1pt), inset: (x: 20pt, y: 45pt), fill: luma(200))[],
      [],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt, top: 1pt), inset: (x: 20pt, y: 45pt), fill: luma(200))[],
    table.cell(align: bottom + end)[Bank Switched],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt), inset: (x: 20pt, y: 10pt))[],
      [],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt), inset: (x: 20pt, y: 10pt), fill: luma(200))[],
      [],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt), inset: (x: 20pt, y: 10pt), fill: luma(200))[],
    table.cell(align: bottom + end)[Low memory \ `0000H`],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt, bottom: 1pt), inset: (x: 20pt, y: 10pt))[],
      [],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt, bottom: 1pt), inset: (x: 20pt, y: 10pt), fill: luma(200))[],
      [],
      table.cell(align: horizon, stroke: (left: 1pt, right: 1pt, bottom: 1pt), inset: (x: 20pt, y: 10pt), fill: luma(200))[],
      [],
      [Bank 0], [], [Bank 1], [...], [Bank N],
  ),
  caption: [CP/M 3 Banked Memory Organization]
) <CPM3BankedMemoryOrg>
]


#pagebreak()


#figure(
  table(
  align: center,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*Field*], [*DR*], [*F1* … *F8*], [*T1*], [*T2*], [*T3*], [*EX*],
  [*S1*], [*S2*], [*RC*], [*D0* … *D15*],
  [*CR*], 
  [*Decimal*], [`00`],
  [`01 … 08`],
  [`09`],
  [`10`],
  [`11`],
  [`12`],
  [`13`],
  [`14`],
  [`15`],
  [`16 … 31`],
  [`32`],
  [*Hex*],[`00`],
  [`01 … 08`],
  [`09`],
  [`0A`],
  [`0B`],
  [`0C`],
  [`0D`],
  [`0E`],
  [`0F`],
  [`10 … 1F`],
  [`20`],
),
  caption: [File Control Block Format in CP/M 1]
)

#figure(
  table(
  align: center,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*Field*], [*DR*], [*F1* … *F8*], [*T1*], [*T2*], [*T3*], [*EX*],
  [*S1*], [*S2*], [*RC*], [*D0* … *D15*],
  [*CR*], [*R0*], [*R1*], [*R2*],
  [*Decimal*], [`00`],
  [`01 … 08`],
  [`09`],
  [`10`],
  [`11`],
  [`12`],
  [`13`],
  [`14`],
  [`15`],
  [`16 … 31`],
  [`32`],
  [`33`],
  [`34`],
  [`35`],
  [*Hex*],[`00`],
  [`01 … 08`],
  [`09`],
  [`0A`],
  [`0B`],
  [`0C`],
  [`0D`],
  [`0E`],
  [`0F`],
  [`10 … 1F`],
  [`20`],
  [`21`],
  [`22`],
  [`23`],
),
  caption: [File Control Block Format in CP/M 2 and later]
)

#figure(
  table(
    columns: (auto, 1fr),
    inset: 10pt,
    align: (center, left),
    table.header([*Field*], [*Definition*]),
    [*DR*], [drive code (0-16). 0=default, 1=Drive `A`:, 2=`B`:, … 16=`P`:],
    [*F1* … *F8*], [contains the filename in ASCII upper-case,
with high bits = `f1' … f8'` normally zero. \
*note*: although the CCP will convert
filename characters into upper-case, the underlying BDOS calls make no such requirement.
In fact, no errors are returned from the MAKE BDOS call (code 22) because of an invalid
filename.],
    [*T1*], [contains the first character of the filetype in ASCII upper-case,
with high bit = `t1'`. Set for Read/Only file.],
    [*T2*], [contains the second character of the filetype in ASCII upper-case with high bit = `t2'`. Set for SYS file, no DIR list.],
    [*T3*], [contains the third character of the filetype in ASCII upper-case with high bit = `t3'` normally zero.],
    [*EX*], [contains the current extent number, normally
set to `00H` by the user, but in range `0 … 31` during file I/O],
    [*S1*], [reserved for internal system use.],
    [*S2*], [reserved for internal system use. Set to zero on calls to *Open*, *Make* and *Search for First*. Before CP/M 3, this field was zero. In CP/M 3, this field becomes the number of unused bytes for exact file size support. range of `0 … 127`],
    [*RC*], [record count for extent *EX*; takes on values from `0 … 127`],
    [*D0* … *D15*], [filled in by CP/M; reserved for system use. contains either a single-byte map of 16 entries, or a double-byte (word) map of 8 entries. each entry defines an allocated block.],
    [*CR*], [current record to read or write in a
sequential file operation; normally set to
zero by user],
    [*R0*], [Optional Random Record Number low byte],
    [*R1*], [Optional Random Record Number high byte],
    [*R2*], [Optional Random Record Number overflow],
  ),
  caption: [File Control Block Fields]
)

Each file being accessed through CP/M must have a corresponding
FCB, which provides the name and allocation information for all
subsequent file operations. When  accessing files, it is the
programmer's responsibility to fill the lower 16 bytes of the FCB
and initialize the *CR* field.  Normally, bytes 1 through 11 are
set to the ASCII character values for the filename and filetype,
while all other fields are zero.

FCBs are stored in a directory area of the disk, and are brought
into central memory before the programmer proceeds with file
operations (see the
*Open* and
*Make* functions). The memory copy of
the FCB is updated as file operations take place and later
recorded permanently on disk at the termination of the file
operation, (see the
*Close* command).

The CCP constructs the first 16 bytes of two optional FCBs for a
transient by scanning the remainder of the line following the
transient name, denoted by _file1_ and _file2_ in the prototype
command line described above, with unspecified fields set to
ASCII blanks. The first FCB is constructed at location `BOOT+005CH`
and can be used as is for subsequent file operations. The second
FCB occupies the *D0* ... *Dn* portion of the first FCB and must be
moved to another area of memory before use. If, for example, the
following command line is typed:

```
PROGNAME B:X.ZOT Y.ZAP
```

the file `PROGNAME.COM` is loaded into the TPA, and the default FCB
at `BOOT+005CH` is initialized to drive code 2, filename `X`, and
filetype `ZOT`. The second drive code takes the default value 0,
which is placed at `BOOT+006CH`, with the filename `Y` placed into
location `BOOT+006DH` and filetype `ZAP` located 8 bytes later at
`BOOT+0075H`. All remaining fields through *CR* are set to zero. Note
again that it is the programmer's responsibility to move this
second filename and filetype to another area, usually a separate
file control block, before opening the file that begins at
`BOOT+005CH`, because the open operation overwrites the second name
and type.

If no filenames are specified in the original command, the fields
beginning at `BOOT+005DH` and `BOOT+006DH` contain blanks. In all
cases, the CCP translates lower-case alphabetic characters to upper-case to
be consistent with the CP/M file naming conventions

As an added convenience, the default buffer area at location
`BOOT+0080H` is initialized to the command line tail typed by the
operator following the program name. The first position contains
the number of characters, with the characters themselves
following the character count. Given the above command line, the
area beginning at `BOOT+0080H` is initialized as follows:


#figure(
  table(
  align: center,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*Offset*],
  [`80`],
  [`81`],
  [`82`],
  [`83`],
  [`84`],
  [`85`],
  [`86`],
  [`87`],
  [`88`],
  [`89`],
  [`8A`],
  [`8B`],
  [`8C`],
  [`8D`],
  [`8E`],
  [`8F`],
  [`90` … `FF`],
  [*Content*],
  [0EH],
  [_sp_],
  ['`B`'],
  ['`:`'],
  ['`X`'],
  ['`.`'],
  ['`Z`'],
  ['`O`'],
  ['`T`'],
  [_sp_],
  ['`Y`'],
  ['`.`'],
  ['`Z`'],
  ['`A`'],
  ['`P`'],
  [00H],
  [???]

),
  caption: [Command-line Layout]
)

where the characters are translated to upper-case ASCII with
uninitialized memory following the last valid character.  Again,
it is the responsibility of the programmer to extract the
information from this buffer before any file operations are
performed, unless the default DMA address is explicitly changed.

#pagebreak()
= CP/M System Calls

The CP/M System Call is initiated by executing a `CALL 0005H`
instruction. The calling convention has at least one parameter,
which is passed in the `C` register. It is the BDOS Function number.
Additional parameters are either passed in the `E` register,
the `DE` register pair. Many BDOS functions also depend upon,
and alter, shared state that CP/M maintains.

Individual functions are described in detail in the pages that
follow. For each function, to start, there is a table. In the table, the entry parameters are described, along with any returned values. If global state is used, that is described.
Also, if there differences between versions, that is summarized. After the table, there is more detail about the operation of the specific function.

Unless otherwise indicated, the value returned to the user code is
in two sets of registers. A single byte value is returned in register `A`, which
is also returned in register `L`. A two-byte value is returned
in the `HL` register-pair as well as register `B` (msb), and
register `A` (lsb).

No input registers are preserved.

Flags are not defined after a BDOS System Call.

#bdos-system-call-spec()

#pagebreak()
= System Call Support

#show figure: set block(breakable: true)
#bdos-function-support-table()

= System Control Block

The System Control Block (SCB) was introduced in CP/M 3.0.
It contains the shared BDOS state that CP/M maintains.
While the SCB was only used in CP/M 3.0, it is used internally in the
#zcim-project virtual CP/M layer for all flavors.

#show figure: set block(breakable: true)

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: (center, left, left),
    table.header(
      [*Offset*],
      [*Id*],
      [*Description*]
    ),
  [ `00H` ],
    [ `HashLength` ],
    [ Reserved for system use. hash length (0,2,3) ],
    
  [ `01H` ],
    [ `Hash1` ],
    [ Reserved for system use. hash entry first word],
    
  [ `03H` ],
    [ `Hash2` ],
    [ Reserved for system use. hash entry second word],
    
  [ `05H` ],
    [ `BDOSVersion` ],
    [ BDOS Version number ],
    
  [ `06H` ],
    [ `Utility1`],
    [ Reserved for user use. Use this word for your own flags or data. ],
  
  [ `08H` ],
    [ `Utility2`],
    [ Reserved for user use. Use this word for your own flags or data. ],
    
  [ `0AH` ],
    [ `DisplayFlag1`],
    [ Reserved for system use. display flags 1 ],
    
  [ `0CH` ],
    [ `DisplayFlag2`],
    [ Reserved for system use. display flags 2 ],
    
  [ `0EH` ],
    [ `CLPFlags`],
    [ CLP flags ],
    
  [ `0F` ],
    [ `SubmitFileDrive` ],
    [ Submit file drive number ],
    
  [ `10H` ],
    [ `ProgramReturnCode` ],
    [Program Error Return Code. This 2-byte field can be used by a program to pass an error code or value to a chained program. CP/M 3's conditional command facility also uses this field to determine if a program executes successfully. The BDOS Function 108 (Get/Set Program Return Code) is used to get/set this value. ],
    
  [ `12H` ],
    [ `MultipleCommandBufferPage` ],
    [ multiple command buffer page ],
    
  [ `13H` ],
    [ `CCPDrive` ],
    [ ccp default drive ],
    
  [ `14H` ],
    [ `CCPUser` ],
    [ ccp default user number ],
    
  [ `15H` ],
    [ `CCPBufferAddress` ],
    [ ccp console buffer address ],
    
  [ `17H` ],
    [ `CCPFlag1` ],
    [ ccp flags byte 1 ],
    
  [ `18H` ],
    [ `CCPFlag2` ],
    [ ccp flags byte 2 ],
    
  [ `19H` ],
    [ `CCPFlag3` ],
    [ ccp flags byte 3 ],
    
  [ `1AH` ],
    [ `ConsoleWidth` ],
    [ Console Width. This byte contains the number of columns, characters per line, on your console relative to zero. Most systems default this value to 79. You can set this default value by using the GENCPM or the DEVICE utility. The console width value is used by the banked version of CP/M 3 in BDOS function 10,
  CP/M 3's console editing input function. Note that typing a character into the last position of the screen, as specified by the Console Width field, must not cause the terminal to advance to the next line. ],
    
  [ `1BH` ],
    [ `ConsoleColumn` ],
    [ Console Column Position. This byte contains the current console column position. ],
  
    
  [ `1CH` ],
    [ `ConsolePageLength` ],
    [ Console Page Length. This byte contains the page length, lines per page, of your console. Most systems default this value to 24 lines per page. This default value may be changed by using the GENCPM or the DEVICE utility. ],
    
  [ `1DH` ],
    [ `ConsoleLine` ],
    [ current console line number ],
    
  [ `1EH` ],
    [ `ConsoleInputBufferAddress` ],
    [ console input buffer address ],
    
  [ `20H` ],
    [ `ConsoleInputBufferLength` ],
    [ console input buffer length ],
    
  [ `22H` ],
    [ `ConsoleInRedirection` ],
    [ console input (CONIN) redirection flag ],
    
  [ `24H` ],
    [ `ConsoleOutRedirection` ],
    [ console output (CONOUT) redirection flag ],
    
  [ `26H` ],
    [ `AuxInRedirection` ],
    [ auxiliary input (AUXIN) redirection flag ],
    
  [ `28H` ],
    [ `AuxOutRedirection` ],
    [ auxiliary output (AUXOUT) redirection flag ],
    
  [ `2AH` ],
    [ `ListOutRedirection` ],
    [ list output (LSTOUT) redirection flag ],
    
  [ `2CH` ],
    [ `PageMode` ],
    [ Page Mode. If this byte is set to zero, some CP/M 3 utilities and CCP built-in commands display one page of data at a time; you display the next page by pressing any key. If this byte is not set to zero, the system displays data on the screen without stopping. To stop and start the display, you can press CTRL-S and CTRL-Q, respectively. ],
    
  [ `2DH` ],
    [ `PageModeDefault` ],
    [ page mode default ],
    
  [ `2EH` ],
    [ `BackspaceFlag` ],
    table.cell(breakable: false)[ Determines if CTRL-H is interpreted as a rubout/DEL character. If this byte is set to `0`, then CTRL-H is a backspace character (moves back and deletes). If this byte is set to `0FFH`, then CTRL-H is a rubout/DEL character, echoes the deleted character. ],
    
  [ `2FH` ],
    [ `DeleteFlag` ],
    table.cell(breakable: false)[ Determines if rubout/DEL is interpreted as CTRL-H character. If this byte is set to `0`, then rubout/DEL echoes the deleted character. If this byte is set to `0FFH`, then rubout/DEL is interpreted as a CTRL-H character (moves back and deletes). ],
    
  [ `30H` ],
    [ `TypeAheadFlag` ],
    [ type ahead active ],
    
  [ `31H` ],
    [-],
    [ console translation subroutine ],
    
  [ `33H` ],
    [ `ConsoleMode` ],
    [ Console Mode. This is a 16-bit system parameter that determines the action of certain BDOS Console I/O functions. console mode (raw/cooked) ],
    
  [ `35H` ],
    [ `BDOSBuffer` ],
    [ 128 byte buffer available to banked BIOS ],
    
  [ `37H` ],
    [ `OutputDelimiter` ],
    [ Output delimiter character. The default output delimiter character is `$`, but you can change this value by using the BDOS Function 110, Get/Set Output Delimiter. ],
    
  [ `38H` ],
    [ `ListOutputFlag` ],
    [ List Output Flag. If this byte is set to `0`, console output is not echoed to the list device. If this byte is set to `1` console output is echoed to the list device. ],
    
  [ `39H` ],
    [ `ScrollFlag` ],
    [ queue flag for type ahead ],
    
  [ `3AH` ],
    [ `SCBAddress` ],
    [ system control block address ],
    
  [ `3CH` ],
    [ `DMAAddress` ],
    [ Current DMA Address. This address can be set by BDOS Function 26 (Set DMA Address). The CCP initializes this value to `0080H`. BDOS Function 13, Reset Disk System, also sets the DMA address to `0080H`. ],
    
  [ `3EH` ],
    [ `Disk` ],
    [ Current Disk. This byte contains the currently selected default disk number. This value ranges from `0`-`15` corresponding to drives `A`-`P`, respectively. BDOS Function 25, Return Current Disk, can be used to determine the current disk value. ],
    
  [ `3FH` ],
    [ `BDOSInfo` ],
    [ BDOS variable "info". Usually the `DE` register pair passed as a parameter, but it gets
  manipulated at times. ],
    
  [ `41H` ],
    [ `resel` ],
    [ disk reselect flag ],
    
  [ `42H` ],
    [ `SameDiskFlag` ],
    [ relog flag ],
    
  [ `43H` ],
    [ `BDOSFunction` ],
    [ function number ],
    
  [ `44H` ],
    [ `UserNumber` ],
    [Current User Number. This byte contains the current
  user number. This value ranges from `0`-`15`. BDOS Function 32, Set/Get User Code, can change or interrogate the currently active user number. ],
    
  [ `45H` ],
    [ `NextDirectory` ],
    [ directory record number ],
    
  [ `47H` ],
    [ `SearchFCB` ],
    [ fcb address for searchn function ],
    
  [ `49H` ],
    [ `SearchType` ],
    [ scan length for search functions ],
    
  [ `4AH` ],
    [ `MultiSectorCount` ],
    [ BDOS Multi-Sector Count. This field is set by BDOS Function 44,, Set Multi-Sector Count. ],
    
  [ `4BH` ],
    [ `BDOSErrorMode` ],
    [ BDOS Error Mode. This field is set by BDOS Function 45, Set BDOS Error Mode.
  If this byte is set to `0FFH`, the system returns to the current program without displaying any error messages. If it is set to `0FEH`, the system displays error messages before returning to the current program. Otherwise, the system terminates the program and displays error messages.],
    
  [ `4CH` ],
    [ `DriveSearch0` ],
    table.cell(breakable: false)[Drive Search Chain. The first byte contains the drive number of the first drive in the chain, the second byte contains the drive number of the second drive in the chain, and so on, for up to four bytes. If less than four drives are to be searched, the next byte is set to `0FFH`
  to signal the end of the search chain. The drive values range from `0`-`16`, where `0` corresponds to the default drive, while `1`-`16` corresponds to drives `A`-`P`, respectively.  ],
    
  [ `4DH` ],
    [ `DriveSearch1` ],
    [ search chain - 2nd drive ],
    
  [ `4EH` ],
    [ `DriveSearch2` ],
    [ search chain - 3rd drive ],
    
  [ `4FH` ],
    [ `DriveSearch3` ],
    [ search chain - 4th drive ],
    
  [ `50H` ],
    [ `TemporaryFileDrive` ],
    [ Temporary File Drive. This byte contains the drive number of the temporary file drive. The drive number ranges from `0`-`16`, where `0` corresponds to the default drive, while `1`-`16` corresponds to drives `A`-`P`, respectively.  ],
    
  [ `51H` ],
    [ `ErrorDrive` ],
    [ Error drive. This byte contains the drive number of the selected drive when the last physical or extended error occurred. ],
    
  [ `52H` ],
    [-],
    [ Unknown ],
    
  [ `54H` ],
    [ `OpenDoorFlag` ],
    [ drive door open flag ],
    
  [ `55H` ],
    [-],
    [ Unknown ],
    
  [ `57H` ],
    [ `BDOSFlags` ],
    table.cell(breakable: false)[ 
  BDOS Flags. Bit 7 applies to banked systems only. If bit 7 is set, then the system displays expanded error messages. The second error line displays the function number and FCB information. (See Section 2.3.13).
  Bit 6 applies only to nonbanked systems. If bit 6 is set, it indicates that GENCPM has specified single allocation vectors for the system. Otherwise, double allocation vectors have been defined for the system. Function 98, Free Blocks, returns temporarily allocated blocks to free space only if bit 6 is reset. ],
    
  [ `58H` ],
    [ `DayNumber` ],
    [Binary number of days since 1 January 1978. ],
  
  [ `5AH` ],
    [ `HoursBCD` ],
    [ Hour in BCD (2-digit Binary Coded Decimal). ],
  
  [ `5BH` ],
    [ `MinutesBCD` ],
    [ Minutes (BCD) ],
    
  [ `5CH` ],
    [ `SecondsBCD` ],
    [ Seconds (BCD) ],
  
  [ `5DH` ],
    [ `CommonMemoryBase` ],
    [ Common Memory Base Address. This value is zero for nonbanked systems and nonzero for banked systems. ],
  
  [ `5FH` ],
    [ `JMP` ],
    [ `JMP` opcode ],
  
  [ `60H` ],
    [ `BDOSErrorRoutine` ],
    [ BDOS error routine address],
  
  [ `62H` ],
    [ `BDOSAddress` ],
    [ top of user TPA (address at 6,7) ],
  ),
  caption: [System Control Block (SCB) Description]
)

#pagebreak()

#figure(
  table(
    columns: (auto, auto, auto, auto, 1fr),
    align: (center, left, center, center, left),
    table.header(
      [*Offset*],
      [*Id*],
      [*Size*],
      [*R/W* or *R/O*],
      [*Equate*]
    ),
  [ `00H` ],
    [ `HashLength` ],
    [ Byte ],
    [ R/O ],
    [ `hashl` ],
    
  [ `01H` ],
    [ `Hash1` ],
    [ Word ],
    [ R/O ],
    [ `hash` ],
    
  [ `03H` ],
    [ `Hash2` ],
    [ Word ],
    [ R/O ],
    [ `hash` ],
    
  [ `05H` ],
    [ `BDOSVersion` ],
    [ Byte ],
    [ R/O ],
    [ `bdos$version` ],
    
  [ `06H` ],
    [ `Utility1`],
    [ Word ],
    [ R/W ],
    [ `util$flgs` ],
  
  [ `08H` ],
    [ `Utility2`],
    [ Word ],
    [ R/W ],
    [ `util$flgs` ],
    
  [ `0AH` ],
    [ `DisplayFlag1`],
    [ Word ],
    [ R/O ],
    [ `dspl$flgs` ],
    
  [ `0CH` ],
    [ `DisplayFlag2`],
    [ Word ],
    [ R/O ],
    [ `dspl$flgs` ],
    
  [ `0EH` ],
    [ `CLPFlags`],
    [ Byte ],
    [ R/O ],
    [ `clp$flgs` ],
    
  [ `0FH` ],
    [ `SubmitFileDrive` ],
    [ Byte ],
    [ R/O ],
    [ `clp$drv` ],
    
  [ `10H` ],
    [ `ProgramReturnCode` ],
    [ Word ],
    [ R/W ],
    [ `prog$ret$code` ],
    
  [ `12H` ],
    [ `MultipleCommandBufferPage` ],
    [ Byte ],
    [ R/O ],
    [ `multi$rsx$pg` ],
    
  [ `13H` ],
    [ `CCPDrive` ],
    [ Byte ],
    [ R/O ],
    [ `ccpdrv` ],
    
  [ `14H` ],
    [ `CCPUser` ],
    [ Byte ],
    [ R/O ],
    [ `ccpusr` ],
    
  [ `15H` ],
    [ `CCPBufferAddress` ],
    [ Word ],
    [ R/O ],
    [ `ccpconbuf` ],
    
  [ `17H` ],
    [ `CCPFlag1` ],
    [ Byte ],
    [ R/O ],
    [ `ccpflag1` ],
    
  [ `18H` ],
    [ `CCPFlag2` ],
    [ Byte ],
    [ R/O ],
    [ `ccpflag2` ],
    
  [ `19H` ],
    [ `CCPFlag3` ],
    [ Byte ],
    [ R/O ],
    [ `ccpflag3` ],
    
  [ `1AH` ],
    [ `ConsoleWidth` ],
    [ Byte ],
    [ R/W ],
    [ `conwidth` ],
    
  [ `1BH` ],
    [ `ConsoleColumn` ],
    [ Byte ],
    [ R/O ],
    [ `concolumn` ],
  
    
  [ `1CH` ],
    [ `ConsolePageLength` ],
    [ Byte ],
    [ R/W ],
    [ `conpage` ],
    
  [ `1DH` ],
    [ `ConsoleLine` ],
    [ Byte ],
    [ R/O ],
    [ `conline` ],
    
  [ `1EH` ],
    [ `ConsoleInputBufferAddress` ],
    [ Word ],
    [ R/O ],
    [ `conbuffer` ],
    
  [ `20H` ],
    [ `ConsoleInputBufferLength` ],
    [ Word ],
    [ R/O ],
    [ `conbuffl` ],
    
  [ `22H` ],
    [ `ConsoleInRedirection` ],
    [ Word ],
    [ R/W ],
    [ `conin$rflg` ],
    
  [ `24H` ],
    [ `ConsoleOutRedirection` ],
    [ Word ],
    [ R/W ],
    [ `conout$rflg` ],
    
  [ `26H` ],
    [ `AuxInRedirection` ],
    [ Word ],
    [ R/W ],
    [ `auxin$rflg` ],
    
  [ `28H` ],
    [ `AuxOutRedirection` ],
    [ Word ],
    [ R/W ],
    [ `auxout$rflg` ],
    
  [ `2AH` ],
    [ `ListOutRedirection` ],
    [ Word ],
    [ R/W ],
    [ `listout$rflg` ],
    
  [ `2CH` ],
    [ `PageMode` ],
    [ Byte ],
    [ R/W ],
    [ `page$mode` ],
    
  [ `2DH` ],
    [ `PageModeDefault` ],
    [ Byte ],
    [ R/O ],
    [ `page$def` ],
    
  [ `2EH` ],
    [ `BackspaceFlag` ],
    [ Byte ],
    [ R/W ],
    [ `ctlh$act` ],
    
  [ `2FH` ],
    [ `DeleteFlag` ],
    [ Byte ],
    [ R/W ],
    [ `rubout$act` ],
    
  [ `30H` ],
    [ `TypeAheadFlag` ],
    [ Byte ],
    [ R/O ],
    [ `type$ahead` ],
    
  [ `31H` ],
    [-],
    [ Word ],
    [ R/O ],
    [ `contran` ],
    
  [ `33H` ],
    [ `ConsoleMode` ],
    [ Word ],
    [ R/W ],
    [ `con$mode` ],
    
  [ `35H` ],
    [ `BDOSBuffer` ],
    [ Word ],
    [ R/O ],
    [ `ten$buffer` ],
    
  [ `37H` ],
    [ `OutputDelimiter` ],
    [ Byte ],
    [ R/W ],
    [ `outdelim` ],
    
  [ `38H` ],
    [ `ListOutputFlag` ],
    [ Byte ],
    [ R/W ],
    [ `listcp` ],
    
  [ `39H` ],
    [ `ScrollFlag` ],
    [ Byte ],
    [ R/O ],
    [ `q$flag` ],
    
  [ `3AH` ],
    [ `SCBAddress` ],
    [ Word ],
    [ R/O ],
    [ `scbad` ],
    
  [ `3CH` ],
    [ `DMAAddress` ],
    [ Word ],
    [ R/O ],
    [ `dmaad` ],
    
  [ `3EH` ],
    [ `Disk` ],
    [ Byte ],
    [ R/O ],
    [ `seldsk` ],
    
  [ `3FH` ],
    [ `BDOSInfo` ],
    [ Word ],
    [ R/O ],
    [ `info` ],
    
  [ `41H` ],
    [ `FCBErrorFlag` ],
    [ Byte ],
    [ R/O ],
    [ `resel` ],
    
  [ `42H` ],
    [ `SameDiskFlag` ],
    [ Byte ],
    [ R/O ],
    [ `relog` ],
    
  [ `43H` ],
    [ `BDOSFunction` ],
    [ Byte ],
    [ R/O ],
    [ `fx` ],
    
  [ `44H` ],
    [ `UserNumber` ],
    [ Byte ],
    [ R/O ],
    [ `usrcode` ],
    
  [ `45H` ],
    [ `NextDirectory` ],
    [ Word ],
    [ R/O ],
    [ `dcnt` ],
    
  [ `47H` ],
    [ `SearchFCB` ],
    [ Word ],
    [ R/O ],
    [ `searcha` ],
    
  [ `49H` ],
    [ `SearchType` ],
    [ Byte ],
    [ R/O ],
    [ `searchl` ],
    
  [ `4AH` ],
    [ `MultiSectorCount` ],
    [ Byte ],
    [ R/W ],
    [ `multcnt` ],
    
  [ `4BH` ],
    [ `BDOSErrorMode` ],
    [ Byte ],
    [ R/W ],
    [ `errormode` ],
    
  [ `4CH` ],
    [ `DriveSearch0` ],
    [ Byte ],
    [ R/W ],
    [ `drv0` ],
    
  [ `4DH` ],
    [ `DriveSearch1` ],
    [ Byte ],
    [ R/W ],
    [ `drv1` ],
    
  [ `4EH` ],
    [ `DriveSearch2` ],
    [ Byte ],
    [ R/W ],
    [ `drv2` ],
    
  [ `4FH` ],
    [ `DriveSearch3` ],
    [ Byte ],
    [ R/W ],
    [ `drv3` ],
    
  [ `50H` ],
    [ `TemporaryFileDrive` ],
    [ Byte ],
    [ R/W ],
    [ `tempdrv` ],
    
  [ `51H` ],
    [ `ErrorDrive` ],
    [ Byte ],
    [ R/O ],
    [ `errdrv` ],
    
  [ `52H` ],
    [-],
    [ Word ],
    [ R/O ],
    [-],
    
  [ `54H` ],
    [ `OpenDoorFlag` ],
    [ Byte ],
    [ R/O ],
    [ `media$flag` ],
    
  [ `55H` ],
    [-],
    [ Word ],
    [ R/O ],
    [-],
    
  [ `57H` ],
    [ `BDOSFlags` ],
    [ Byte ],
    [ R/O ],
    [ `bdos$flags` ],
    
  [ `58H` ],
    [ `DayNumber` ],
    [ Word ],
    [ R/W ],
    [ `date` ],
  
  [ `5AH` ],
    [ `HoursBCD` ],
    [ Byte ],
    [ R/W ],
    [-],
  
  [ `5BH` ],
    [ `MinutesBCD` ],
    [ Byte ],
    [ R/W ],
    [-],
    
  [ `5CH` ],
    [ `SecondsBCD` ],
    [ Byte ],
    [ R/W ],
    [-],
  
  [ `5DH` ],
    [ `CommonMemoryBase` ],
    [ Word ],
    [ R/O ],
    [ `com$base` ],
  
  [ `5FH` ],
    [ `JMP` ],
    [ Byte ],
    [ R/O ],
    [ `error` ],
  
  [ `60H` ],
    [ `BDOSErrorRoutine` ],
    [ Word ],
    [ R/W ],
    [ `error$jmp` ],
  
  [ `62H` ],
    [ `BDOSAddress` ],
    [ Word ],
    [ R/O ],
    [ `top$tpa` ],
  
  ),
  caption: [SCB Details]
)

#pagebreak()
= BIOS Interface

== Pre-BIOS Versions

== Version 2 BIOS

== Version 3 BIOS

== BIOS Data Areas


#pagebreak()
= CP/M File System

The CP/M file system was designed around low-memory usage.
It provides a limited set of features, and very little in the way of
validation or error checking. Since a floppy disk is removable,
the focus of error handling was on preventing data loss when floppy disks
were removed at unexpected times.

It is a flat file system, with a single level directory structure.
Later
versions included the concept of a *user* which divided the system into
multiple flat file systems, since only the current user's files could be
accessed at any time. 


Unlike most file systems, it does not keep a list of available blocks
(free list) in permanent storage, on the disk itself.
While the BDOS/BIOS combination
supports multiple physical disk layouts, the file system
meta-data does not describe the layout of the disk.

This lead to many
inter-operability issues. In practice, the IBM 3740 8" Single-sided, Single-density
floppy disk was the only one likely to work between systems from two
different manufactures. Even if they both used the same version of CP/M.
One of the downfalls of the CP/M ecosystem was the number of floppy disk
formats that had to be maintained by software distributors.



== Floppy Disk Basics

The CP/M operating system was originally designed for the floppy disks
of the mid 1970's. The original disk was 8 inches in diameter and was created
for an #link("https://en.wikipedia.org/wiki/IBM_3740")[IBM 3740 Data Entry System].
This became the standard that was used
by the Shugart Associates drives that Gary Kildall used to create CP/M.

It is a single-sided device. It is recorded in what became called "Single-Density"
format. It supported 128 byte sectors. With 26 sectors per track, and 77 tracks per disk.
This is $128 * 26 * 77 = 256256$ bytes capacity, which is 250KiB.

The original CP/M only supported the "Standard" disk format.
The BDOS/BIOS split of the 2.x version added support for more varied disk layouts.
Version 2.2 added support for improved sector blocking and deblocking for physical
sector sizes that were more than the 128 byte logical sector size.

=== Disk Layout

Given its history, the BDOS/BIOS interface assumes the original floppy disk like disk layout.
It is a number of sectors and tracks of 128 byte sectors.

There is no concept of a side, or a head number. It also assumes that the
disk layout is fixed. That is, the number of sectors for the first track is the
same as the number of sectors in the last track. While later versions
provide some support for efficient blocking and deblocking of non-128 byte
sectors, the underlying file system always uses 128 byte logical sectors.

=== Hard Disk Considerations

The primary hard disk consideration is capacity, or lack thereof.
CP/M 2.2 supports disks with up-to 4MiB. CP/M 3.0 supports disks up to 512MiB.

All CP/M drives use the same sectors and tracks model.

It is possible to tell CP/M that the drive cannot be removed so that the
directory checksum map for the drive does not need to be allocated.

=== Sector Blocking and Deblocking

=== System Limitations

== File Control Blocks

== Directory Entries

=== Standard Directory Entry

=== Disk Label Entry

=== File Date and Time Stamp Entries

=== Directory Checksums

== Allocation Map

=== Purpose

=== Single-Bit Allocation Map

=== Two-Bit Allocation Map


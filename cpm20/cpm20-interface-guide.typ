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
#import "/bdos-common.typ": bdos-system-call-sections, bdos-function-summary-table, bdos-function-table
#let document-version = [version 2025-08-07]

// -------------------------------------------------------------------------------
// END of COMMON
// -------------------------------------------------------------------------------
#title-page(
  title-text: [
Digital Research \
    _CP/M® 2.0 Interface Guide_
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

This chapter describes CP/M (release 2) system organization
including the structure of memory and system entry points. This
section provides the information you need to write programs that
operate under CP/M and that use the peripheral and disk I/O
facilities of the system.

CP/M is logically divided into four parts, called the Basic
Input/Output System (BIOS), the Basic Disk Operating System
(BDOS), the Console Command Processor (CCP), and the Transient
Program Area (TPA). The BIOS is a hardware-dependent module that
defines the exact low level interface with a particular computer
system that is necessary for peripheral device I/O.  Although a
standard BIOS is supplied by Digital Research, explicit
instructions are provided for field reconfiguration of the BIOS
to match nearly any hardware environment, see Section 6.

The BIOS and BDOS are logically combined into a single module
with a common entry point and referred to as the FDOS. The CCP is
a distinct program that uses the FDOS to provide a human-oriented
interface with the information that is cataloged on the back-up
storage device. The TPA is an area of memory, not used by the
FDOS and CCP, where various nonresident operating system commands
and user programs are executed. The lower portion of memory is
reserved for system information and is detailed in later
sections. Memory organization of the CP/M system is shown in
@CPMMemoryOrg

#align(center)[
#figure(
  table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 5pt, y: 10pt),
    table.cell(align: end)[High Memory \
    `FBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[FDOS (BDOS + BIOS)],
    table.cell(align: bottom + end)[`CBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 15pt))[CCP],
    table.cell(align: bottom + end)[`TBASE:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 45pt))[TPA],
    table.cell(align: bottom + end)[`BOOT:`],
      table.cell(align: horizon, stroke: 1pt, inset: (x: 20pt, y: 10pt))[System Parameters]
  ),
  caption: [CP/M Memory Organization]
) <CPMMemoryOrg>
]
The exact memory addresses corresponding to `BOOT`, `TBASE`, `CBASE`,
and `FBASE` vary from version to version and are described fully in
Section 6.

All standard CP/M versions assume `BOOT=0000H`, which is
the base of random access memory. The machine code found at
location `BOOT` performs a system warm start, which loads and
initializes the programs and variables necessary to return
control to the CCP. Thus, transient programs need only jump to
location `BOOT` to return control to CP/M at the command level.
further, the standard versions assume `TBASE=BOOT+0100H`, which is
normally location `0100H`. The principal entry point to the FDOS is
at location `BOOT+0005H` (normally `0005H`) where a jump to `FBASE` is
found. The address field at `BOOT+0006H` (normally `0006H`) contains
the value of `FBASE` and can be used to determine the size of
available memory, assuming that the CCP is being overlaid by a
transient program.

Transient programs are loaded into the TPA and executed as
follows. The operator communicates with the CCP by typing command
lines following each prompt. Each command line takes one of the
following forms:

#cmd-line[_command_]
#cmd-line[_command_ _file1_]
#cmd-line[_command_ _file_ _file2_]

where _command_ is either a built-in function, such as `DIR` or `TYPE`,
or the name of a transient command or program. If the _command_ is
a built-in function of CP/M, it is executed immediately.
Otherwise, the CCP searches the currently addressed disk for a
file by the name

#cmd-line[_command_`.COM`]

If the file is found, it is assumed to be a memory image of a
program that executes in the TPA and thus implicitly originates at
`TBASE` in memory. The CCP loads the `COM` file from the disk into
memory starting at `TBASE` and can extend up to `CBASE`.

If the command is followed by one or two file specifications, the
CCP prepares one or two File Control Block (FCB) names in the
system parameter area. These optional FCBs are in the form
necessary to access files through the FDOS and are described in
@OSConventions.

The transient program receives control from the CCP and begins
execution, using the I/O facilities of the FDOS. The transient
program is called from the CCP. Thus, it can simply return to the
CCP upon completion of its processing, or can Jump to `BOOT` to
pass control back to CP/M. In the first case, the transient
program must not use memory above `CBASE`, while in the latter
case, memory up through `FBASE-1` can be used.

The transient program can use the CP/M I/O facilities to
communicate with the operator's console and peripheral devices,
including the disk subsystem. The I/O system is accessed by
passing a function number and an information address to CP/M
through the FDOS entry point at `BOOT+0005H`. In the case of a disk
read, for example, the transient program sends the number
corresponding to a disk read, along with the address of an FCB to
the CP/M FDOS. The FDOS, in turn, performs the operation and
returns with either a disk read completion indication or an error
number indicating that the disk read was unsuccessful.

= Operating System Call Conventions <OSConventions>

This section provides detailed information for performing direct
operating system calls from user programs. Many of the functions
listed below, however, are accessed more simply through the I/O
macro library provided with the `MAC` macro assembler and listed in
the #zcim-project manual entitled #link("https://www.z80cim.org/zcimdocs/mac80/mac80-manual.pdf")[CP/M® `MAC` Macro Assembler _Language Manual and Applications Guide_].

CP/M facilities that are available for access by transient
programs fall into two general categories: simple device I/O and
disk file I/O. The simple device operations are:

#cmd-line[
  - read a console character
  - write a console character
  - read a sequential character
  - write a sequential character
  - get or set I/O status
  - print console buffer
  - interrogate console ready
]

The following FDOS operations perform disk I/O:

#cmd-line[
  - disk system reset
  - drive selection
  - file creation
  - file close
  - directory search
  - file delete
  - file rename
  - random or sequential read
  - random or sequential write
  - interrogate available disks
  - interrogate selected disk
  - set DMA address
  - set/reset file indicators.
 
]

As mentioned above, access to the FDOS functions is accomplished
by passing a function number and information address through the
primary point at location `BOOT+0005H`. In general, the function
number is passed in register `C` with the information address in
the double byte pair `DE`. Single byte values are returned in
register `A`, with double byte values returned in `HL`, a zero value
is returned when the function number is out of range. For reasons
of compatibility, register `A` = `L` and register `B` = `H` upon return
in all cases.  Note that the register passing conventions of CP/M
agree with those of the Intel PL/M systems programming language.
CP/M functions and their numbers are listed below.

#bdos-function-table("2.0", caption: [CP/M 2.0 BDOS functions])

#cmd-line[*Note* Function 28 and Function 32 should be avoided
in application programs to
maintain upward compatibility with CP/M.]

Upon entry to a transient program, the CCP leaves the stack
pointer set to an eight-level stack area with the CCP return
address pushed onto the stack, leaving seven levels before
overflow occurs. Although this stack is usually not used by a
transient program (most transients return to the CCP through a
jump to location `0000H`) it is large enough to make CP/M system
calls because the FDOS switches to a local stack at system entry.
For example, the assembly-language program segment below reads
characters continuously until an asterisk is encountered, at
which time control returns to the CCP, assuming a standard CP/M
system with `BOOT=0000H`.

#block(breakable: false)[
#rect-listing[
 

```
BDOS   EQU 0005H    ;STANDARD CP/M ENTRY
CONIN  EQU 1        ;CONSOLE INPUT FUNCTION
;
       ORG 0100H    ;BASE OF TPA
NEXTC: MVI C,CONIN  ;READ NEXT CHARACTER
       CALL BDOS    ;RETURN CHARACTER IN <A>
       CPI  '*'     ;END OF PROCESSING?
       JNZ  NEXTC   ;LOOP IF NOT
       RET          ;RETURN TO CCP
       END
```
]
]

CP/M implements a named file structure on each disk, providing a
logical organization that allows any particular file to contain
any number of records from completely empty to the full capacity
of the drive. Each drive is logically distinct with a disk
directory and file data area. The disk filenames are in three
parts: the drive select code, the filename (consisting of one to
eight non-blank characters), and the filetype (consisting of zero
to three non-blank characters). The filetype names the generic
category of a particular file, while the filename distinguishes
individual files in each category. The filetypes listed in
@CPMFileTypes
name a few generic categories that have been established,
although they are somewhat arbitrary.

#figure(
  table(
    columns: (auto, auto),
    inset: 10pt,
    align: (center, left),
    table.header([*Filetype*], [*Meaning*]),
    [`ASM`], [Assembler Source],
    [`PRN`], [Printer Listing],
    [`HEX`], [Hex Machine Code],
    [`BAS`], [Basic Source File],
    [`INT`], [Intermediate Code],
    [`COM`], [Command File],
    [`PLI`], [PL/I Source File],
    [`REL`], [Relocatable Module],
    [`TEX`], [TEX Formatter Source],
    [`BAK`], [ED Source Backup],
    [`SYM`], [SID Symbol File],
    [`$$$`], [Temporary File],
  ),
  caption: [CP/M Filetypes]
) <CPMFileTypes>

Source files are treated as a sequence of ASCII characters, where
each line of the source file is followed by a carriage return,
and line-feed sequence (`0DH` followed by `0AH`). Thus, one 128-byte
CP/M record can contain several lines of source text.  The end of
an ASCII file is denoted by a CTRL-Z character (`1AH`) or a real
end-of-file returned by the CP/M read operation.  CTRL-Z
characters embedded within machine code files (for example, COM
files) are ignored and the end-of-file condition returned by CP/M
is used to terminate read operations.

Files in CP/M can be thought of as a sequence of up to `65536`
records of 128 bytes each, numbered from `0` through `65535`, thus
allowing a maximum of 8 megabytes per file. Note, however, that
although the records may be considered logically contiguous, they
may not be physically contiguous in the disk data area.
Internally, all files are divided into 16K byte segments called
logical extents, so that counters are easily maintained as 8-bit
values. The division into extents is discussed in the paragraphs
that follow: however, they are not particularly significant for
the programmer, because each extent is automatically accessed in
both sequential and random access modes.

In the file operations starting with
Function 15, `DE` usually
addresses a FCB. Transient programs often use the default FCB
area reserved by CP/M at location `BOOT+005CH` (normally `005CH`) for
simple file operations. The basic unit of file information is a
128-byte record used for all file operations. Thus, a default
location for disk I/O is provided by CP/M at location `BOOT+0080H`
(normally `0080H`) which is the initial default DMA address. See
Function 26.

All directory operations take place in a reserved area that does
not affect write buffers as was the case in release 1, with the
exception of
*Search for First* and
*Search for Next*, where compatibility is
required.

The FCB data area consists of a sequence of 33 bytes for
sequential access and a series of 36 bytes in the case when the
file is accessed randomly. The default FCB, normally located at
`005CH`, can be used for random access files, because the three
bytes starting at `BOOT+007DH` are available for this purpose.

#pagebreak()

#figure(
  table(
  align: center,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*Field*], [*DR*], [*F1* … *F8*], [*T1*], [*T2*], [*T3*], [*EX*],
  [*S1*], [*S2*], [*RC*], [*D0* … *D15*],
  [*CR*], [*R0*], [*R1*], [*R2*],
  [*Decimal*], [`00`],
  [`01` … `08`],
  [`09`],
  [`10`],
  [`11`],
  [`12`],
  [`13`],
  [`14`],
  [`15`],
  [`16` … `31`],
  [`32`],
  [`33`],
  [`34`],
  [`35`],
  [*Hex*],[`00`],
  [`01` … `08`],
  [`09`],
  [`0A`],
  [`0B`],
  [`0C`],
  [`0D`],
  [`0E`],
  [`0F`],
  [`10` … `1F`],
  [`20`],
  [`21`],
  [`22`],
  [`23`],
),
  caption: [File Control Block Format]
)

#figure(
  table(
    columns: (auto, 1fr),
    inset: 10pt,
    align: (center, left),
    table.header([*Field*], [*Definition*]),
    [*DR*], [drive code (0-16). 0=default, 1=Drive `A`:, 2=`B`:, … 16=`P`:],
    [*F1* … *F8*], [contain the filename in ASCII upper-case,
with high bits = `f1'` … `f8'` normally zero],
    [*T1*], [contains the first character of the filetype in ASCII upper-case,
with high bit = `t1'`. Set for Read/Only file.],
    [*T2*], [contains the second character of the filetype in ASCII upper-case with high bit = `t2'`. Set for SYS file, no DIR list.],
    [*T3*], [contains the third character of the filetype in ASCII upper-case with high bit = `t3'` normally zero.],
    [*EX*], [contains the current extent number, normally
set to 00 by the user, but in range 0-31
during file I/O],
    [*S1*], [reserved for internal system use],
    [*S2*], [reserved for internal system use. Set to zero on calls to *Open*, *Make* and *Search for First*],
    [*RC*], [record count for extent *EX*; takes on values from 0-127],
    [*D0* … *D15*], [filled in by CP/M; reserved for system use],
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

Individual functions are described in detail in the pages that
follow.

#bdos-system-call-sections("2.2", depth: 3)


= A Sample File-to-File Copy Program

The following program provides a relatively simple example of file
operations.  The program source file is created as `COPY.ASM` using
the CP/M `ED` program and then assembled using `ASM` or `MAC`, resulting
in a `HEX` file.  The `LOAD` program is used to produce a `COPY.COM`
file that executes directly under the CCP.  The program begins
by setting the stack pointer to a local area and proceeds to move
the second name from the default area at `006CH` to a 33-byte File
Control Block called `DFCB`.  The `DFCB` is then prepared for file
operations by clearing the current record  field.  At this point,
the source and destination FCBs are ready for processing, because
the `SFCB` at `005CH` is properly set up by the CCP upon entry to the
COPY program.  That is, the first name is placed into the default
FCB, with the proper fields zeroed, including the current record
field at `007CH`.  The program continues by opening the source
file, deleting any existing destination file, and creating the destination
file.  If all this is successful, the program loops at the label
`COPY` until each record is read from the source file and placed into the
destination file.  Upon completion of the data transfer, the
destination file is closed and the program returns to the
CCP command level by jumping to `BOOT`.


#rect-print-listing[
```
                ;        sample file-to-file copy program
                ;
                ;        at the ccp level, the command
                ;
                ;             copy a:x.y b:u.v
                ;
                ;        copies the file named x.y from drive
                ;        a to a file named u.v. on drive b.
                ;
 0000 =         boot     equ 0000h      ;system reboot
 0005 =         bdos     equ 0005h      ;bdos entry point
 005C =         fcbl     equ 005ch      ;first file name
 005C =         sfcb     equ fcbl       ;source fcb
 006C =         fcb2     equ 006ch      ;second file name
 0080 =         dbuff    equ 0080h      ;default buffer
 0100 =         tpa      equ 0100h      ;beginning of tpa
                ;
 0009 =         printf   equ 9          ;print buffer func#
 000F =         openf    equ 15         ;open file func#
 0010 =         closef   equ 16         ;close file func#
 0013 =         deletef  equ 19         ;delete file func#
 0014 =         readf    equ 20         ;sequential read
 0015 =         writef   equ 21         ;sequential write
 0016 =         makef    equ 22         ;make file func#
                ;
 0100                    org tpa        ;beginning of tpa
 0100 311A02             lxi sp,stack   ;local stack
                ;
                ;        move second file name to dfcb
 0103 0E10               mvi c,16       ;half an fcb
 0105 116C00             lxi d,fcb2     ;source of move
 0108 21D901             lxi h,dfcb     ;destination fcb
 010B 1A        mfcb:    ldax d         ;source fcb
 010C 13                 inx  d         ;ready next
 010D 77                 mov  m,a       ;dest fcb
 010E 23                 inx  h         ;ready next
 010F 0D                 dcr  c         ;count 16...0
 0110 C20B01             jnz  mfcb      ;loop 16 times
                ;
                ;        name has been removed, zero cr
 0113 AF                 xra  a         ;a = 00h
 0114 32F901             sta  dfcbcr    ;current rec = 0
                ;
                ;        source and destination fcbs ready
                ;
 0117 115C00             lxi  d,sfcb    ;source file
 011A CD6901             call open      ;error if 255
 011D 118701             lxi  d,nofile  ;ready message
 0120 3C                 inr  a         ;255 becomes 0
 0121 CC6101             cz   finis     ;done if no file
                ;
                ;        source file open, prep destination
 0124 11D901             lxi  d,dfcb    ;destination
 0127 CD7301             call delete    ;remove if present
                ;
 012A 11D901             lxi  d,dfcb    ;destination
 012D CD8201             call make      ;create the file
 0130 119601             lxi  d,nodir   ;ready message
 0133 3C                 inr  a         ;255 becomes 0
 0134 CC6101             cz   finis     ;done if no dir space
                ;
                ;        source file open, dest file open
                ;        copy until end of file on source
                ;
 0137 115C00    copy:    lxi  d,sfcb    ;source
 013A CD7801             call read      ;read next record
 013D B7                 ora  a         ;end of file?
 013E C25101             jnz  eofile    ;skip write if so
                ;
                ;        not end of file, write the record
 0141 11D901             lxi  d,dfcb    ;destination
 0144 CD7D01             call write     ;write record
 0147 11A901             lxi  d,space   ;ready message
 014A B7                 ora  a         ;00 if write ok
 014B C46101             cnz  finis     ;end if so
 014E C33701             jmp  copy      ;loop until eof
```]
#rect-print-listing[```
                ;
                eofile:  ;end of file, close destination
 0151 11D901             lxi  d,dfcb    ;destination
 0154 CD6E01             call close     ;255 if error
 0157 21BA01             lxi  h,wrprot  ;ready message
 015A 3C                 inr  a         ;255 becomes 00
 015B CC6101             cz   finis     ;should not happen
                ;
                ;        copy operation complete, end
 015E 11CB01             lxi  d,normal  ;ready message
                ;
                finis    ;write message given by de, reboot
 0161 0E09               mvi  c,printf
 0163 CD0500             call bdos      ;write message
 0166 C30000             jmp  boot      ;reboot system
                ;
                ;        system interface subroutines
                ;        (all return directly from bdos)
                ;
 0169 0E0F      open:    mvi  c,openf
 016B C30500             jmp  bdos
                ;
 016E 0E10      close:   mvi  c,closef
 0170 C30500             jmp  bdos
                ;
 0173 0E13      delete   mvi  c,deletef
 0175 C30500             jmp  bdos
                ;
 0178 0E14      read:    mvi  c,readf
 017A C30500             jmp  bdos
                ;
 017D 0E15      write:   mvi  c,writef
 017F C30500             jmp  bdos
                ;
 0182 0E16      make:    mvi  c,makef
 0184 C30500             jmp  bdos
                ;
                ;        console messages
 0187 6E6F20736Fnofile:  db   'no source file$'
 0196 6E6F206469nodir:   db   'no directory space$'
 01A9 6F7574206Fspace:   db   'out of dat space$'
 01BA 7772697465wrprot:  db   'write protected?$'
 01CB 636F707920normal:  db   'copy complete$'
                ;
                ;        data areas
 01D9           dfcb:    ds   33        ;destination fcb
 01F9 =         dfcbcr   equ  dfcb+32   ;current record
                ;
 01FA                    ds   32        ;16 level stack
                stack:
 021A                    end

```
]
Note that there are several simplifications in this
particular program.  First, there are no checks for invalid filenames
that could contain ambiguous references.  This
situation could be detected by scanning the 32-byte default area
starting at location `005CH` for ASCII question marks.  A check
should also be make to ensure that the filenames have
been included (check locations `005DH` and `006DH` for non-blank ASCII
characters).  Finally, a check should be made to ensure that the
source and destination filenames are different.  An improvement
in speed could be obtained by buffering more data on each read
operation.  One could, for example, determine the size of memory
by fetching `FBASE` from location `0006H` and using the entire
remaining portion of memory for a data buffer.  In this case, the
programmer simply resets the DMA address to the next successive
128-byte area before each read.  Upon writing to the destination
file, the DMA address is reset to the beginning of the buffer and
incremented by 128 bytes to the end as each record is
transferred to the destination file.

= A Sample File Dump Utility

The following file dump program is slightly more complex than
the simple copy program given in the previous section.  The dump
program reads an input file, specified in the CCP command line,
and displays the content of each record in hexadecimal format at
the console.  Note that the dump program saves the CCP's stack
upon entry, resets the stack to a local area, and restores the
CCP's stack before returning directly to the CCP.  Thus, the
dump program does not perform a warm start at the end of
processing.

#rect-print-listing[```

                ;       FILE DUMP PROGRAM, READS AN INPUT FILE AND PRINTS IN HEX
                ;
                ;       COPYRIGHT (C) 1975, 1976, 1977, 1978
                ;       DIGITAL RESEARCH
                ;       BOX 579, PACIFIC GROVE
                ;       CALIFORNIA, 93950
                ;
 0100                   ORG     100H
 0005 =         BDOS    EQU     0005H   ;DOS ENTRY POINT
 0001 =         CONS    EQU     1       ;READ CONSOLE
 0002 =         TYPEF   EQU     2       ;TYPE FUNCTION
 0009 =         PRINTF  EQU     9       ;BUFFER PRINT ENTRY
 000B =         BRKF    EQU     11      ;BREAK KEY FUNCTION (TRUE IF CHAR READY)
 000F =         OPENF   EQU     15      ;FILE OPEN
 0014 =         READF   EQU     20      ;READ FUNCTION
                ;
 005C =         FCB     EQU     5CH     ;FILE CONTROL BLOCK ADDRESS
 0080 =         BUFF    EQU     80H     ;INPUT DISK BUFFER ADDRESS
                ;
                ;       NON GRAPHIC CHARACTERS
 000D =         CR      EQU     0DH     ;CARRIAGE RETURN
 000A =         LF      EQU     0AH     ;LINE FEED
                ;
                ;       FILE CONTROL BLOCK DEFINITIONS
 005C =         FCBDN   EQU     FCB+0   ;DISK NAME
 005D =         FCBFN   EQU     FCB+1   ;FILE NAME
 0065 =         FCBFT   EQU     FCB+9   ;DISK FILE TYPE (3 CHARACTERS)
 0068 =         FCBRL   EQU     FCB+12  ;FILE'S CURRENT REEL NUMBER
 006B =         FCBRC   EQU     FCB+15  ;FILE'S RECORD COUNT (0 TO 128)
 007C =         FCBCR   EQU     FCB+32  ;CURRENT (NEXT) RECORD NUMBER (0 TO 127)
 007D =         FCBLN   EQU     FCB+33  ;FCB LENGTH
                ;
                ;       SET UP STACK
 0100 210000            LXI     H,0
 0103 39                DAD     SP
                ;       ENTRY STACK POINTER IN HL FROM THE CCP
 0104 221502            SHLD    OLDSP
                ;       SET SP TO LOCAL STACK AREA (RESTORED AT FINIS)
 0107 315702            LXI     SP,STKTOP
                ;       READ AND PRINT SUCCESSIVE BUFFERS
 010A CDC101            CALL    SETUP   ;SET UP INPUT FILE
 010D FEFF              CPI     255     ;255 IF FILE NOT PRESENT
 010F C21B01            JNZ     OPENOK  ;SKIP IF OPEN IS OK
                ;
                ;       FILE NOT THERE, GIVE ERROR MESSAGE AND RETURN
 0112 11F301            LXI     D,OPNMSG
 0115 CD9C01            CALL    ERR
 0118 C35101            JMP     FINIS   ;TO RETURN
                ;
                OPENOK: ;OPEN OPERATION OK, SET BUFFER INDEX TO END
 011B 3E80              MVI     A,80H
 011D 321302            STA     IBP     ;SET BUFFER POINTER TO 80H
                ;       HL CONTAINS NEXT ADDRESS TO PRINT
 0120 210000            LXI     H,0     ;START WITH 0000
                ;
                GLOOP:
 0123 E5                PUSH    H       ;SAVE LINE POSITION
 0124 CDA201            CALL    GNB
 0127 E1                POP     H       ;RECALL LINE POSITION
 0128 DA5101            JC      FINIS   ;CARRY SET BY GNB IF END FILE
 012B 47                MOV     B,A
                ;       PRINT HEX VALUES
                ;       CHECK FOR LINE FOLD
 012C 7D                MOV     A,L
 012D E60F              ANI     0FH     ;CHECK LOW 4 BITS
 012F C24401            JNZ     NONUM
                ;       PRINT LINE NUMBER
 0132 CD7201            CALL    CRLF
                ;
                ;       CHECK FOR BREAK KEY
 0135 CD5901            CALL    BREAK
                ;       ACCUM LSB = 1 IF CHARACTER READY
 0138 0F                RRC             ;INTO CARRY
 0139 DA5101            JC      FINIS   ;DON'T PRINT ANY MORE
                ;
 013C 7C                MOV     A,H
 013D CD8F01            CALL    PHEX
 0140 7D                MOV     A,L
 0141 CD8F01            CALL    PHEX
```]
#rect-print-listing[```
                NONUM:
 0144 23                INX     H       ;TO NEXT LINE NUMBER
 0145 3E20              MVI     A,' '
 0147 CD6501            CALL    PCHAR
 014A 78                MOV     A,B
 014B CD8F01            CALL    PHEX
 014E C32301            JMP     GLOOP
                ;
                FINIS:
                ;       END OF DUMP, RETURN TO CCP
                ;       (NOTE THAT A JMP TO 0000H REBOOTS)
 0151 CD7201            CALL    CRLF
 0154 2A1502            LHLD    OLDSP
 0157 F9                SPHL
                ;       STACK POINTER CONTAINS CCP'S STACK LOCATION
 0158 C9                RET             ;TO THE CCP
                ;
                ;
                ;       SUBROUTINES
                ;
                BREAK:  ;CHECK BREAK KEY (ACTUALLY ANY KEY WILL DO)
 0159 E5D5C5            PUSH H! PUSH D! PUSH B; ENVIRONMENT SAVED
 015C 0E0B              MVI     C,BRKF
 015E CD0500            CALL    BDOS
 0161 C1D1E1            POP B! POP D! POP H; ENVIRONMENT RESTORED
 0164 C9                RET
                ;
                PCHAR:  ;PRINT A CHARACTER
 0165 E5D5C5            PUSH H! PUSH D! PUSH B; SAVED
 0168 0E02              MVI     C,TYPEF
 016A 5F                MOV     E,A
 016B CD0500            CALL    BDOS
 016E C1D1E1            POP B! POP D! POP H; RESTORED
 0171 C9                RET
                ;
                CRLF:
 0172 3E0D              MVI     A,CR
 0174 CD6501            CALL    PCHAR
 0177 3E0A              MVI     A,LF
 0179 CD6501            CALL    PCHAR
 017C C9                RET
                ;
                ;
                PNIB:   ;PRINT NIBBLE IN REG A
 017D E60F              ANI     0FH     ;LOW 4 BITS
 017F FE0A              CPI     10
 0181 D28901            JNC     P10
                ;       LESS THAN OR EQUAL TO 9
 0184 C630              ADI     '0'
 0186 C38B01            JMP     PRN
                ;
                ;       GREATER OR EQUAL TO 10
 0189 C637      P10:    ADI     'A' - 10
 018B CD6501    PRN:    CALL    PCHAR
 018E C9                RET
                ;
                PHEX:   ;PRINT HEX CHAR IN REG A
 018F F5                PUSH    PSW
 0190 0F                RRC
 0191 0F                RRC
 0192 0F                RRC
 0193 0F                RRC
 0194 CD7D01            CALL    PNIB    ;PRINT NIBBLE
 0197 F1                POP     PSW
 0198 CD7D01            CALL    PNIB
 019B C9                RET
                ;
                ERR:    ;PRINT ERROR MESSAGE
                ;       D,E ADDRESSES MESSAGE ENDING WITH "$"
 019C 0E09              MVI     C,PRINTF        ;PRINT BUFFER FUNCTION
 019E CD0500            CALL    BDOS
 01A1 C9                RET
```]
#rect-print-listing[```
                ;
                ;
                GNB:    ;GET NEXT BYTE
 01A2 3A1302            LDA     IBP
 01A5 FE80              CPI     80H
 01A7 C2B301            JNZ     G0
                ;       READ ANOTHER BUFFER
                ;
                ;
 01AA CDCE01            CALL    DISKR
 01AD B7                ORA     A       ;ZERO VALUE IF READ OK
 01AE CAB301            JZ      G0      ;FOR ANOTHER BYTE
                ;       END OF DATA, RETURN WITH CARRY SET FOR EOF
 01B1 37                STC
 01B2 C9                RET
                ;
                G0:     ;READ THE BYTE AT BUFF+REG A
 01B3 5F                MOV     E,A     ;LS BYTE OF BUFFER INDEX
 01B4 1600              MVI     D,0     ;DOUBLE PRECISION INDEX TO DE
 01B6 3C                INR     A       ;INDEX=INDEX+1
 01B7 321302            STA     IBP     ;BACK TO MEMORY
                ;       POINTER IS INCREMENTED
                ;       SAVE THE CURRENT FILE ADDRESS
 01BA 218000            LXI     H,BUFF
 01BD 19                DAD     D
                ;       ABSOLUTE CHARACTER ADDRESS IS IN HL
 01BE 7E                MOV     A,M
                ;       BYTE IS IN THE ACCUMULATOR
 01BF B7                ORA     A       ;RESET CARRY BIT
 01C0 C9                RET
                ;
                SETUP:  ;SET UP FILE
                ;       OPEN THE FILE FOR INPUT
 01C1 AF                XRA     A       ;ZERO TO ACCUM
 01C2 327C00            STA     FCBCR   ;CLEAR CURRENT RECORD
                ;
 01C5 115C00            LXI     D,FCB
 01C8 0E0F              MVI     C,OPENF
 01CA CD0500            CALL    BDOS
                ;       255 IN ACCUM IF OPEN ERROR
 01CD C9                RET
                ;
                DISKR:  ;READ DISK FILE RECORD
 01CE E5D5C5            PUSH H! PUSH D! PUSH B
 01D1 115C00            LXI     D,FCB
 01D4 0E14              MVI     C,READF
 01D6 CD0500            CALL    BDOS
 01D9 C1D1E1            POP B! POP D! POP H
 01DC C9                RET
                ;
                ;       FIXED MESSAGE AREA
 01DD 46494C4520SIGNON: DB      'FILE DUMP VERSION 1.4$'
 01F3 0D0A4E4F20OPNMSG: DB      CR,LF,'NO INPUT FILE PRESENT ON DISK$'

                ;       VARIABLE AREA
 0213           IBP:    DS      2       ;INPUT BUFFER POINTER
 0215           OLDSP:  DS      2       ;ENTRY SP VALUE FROM CCP
                ;
                ;       STACK AREA
 0217                   DS      64      ;RESERVE 32 LEVEL STACK
                STKTOP:
                ;
 0257                   END



```]

= A Sample Random Access Program

This chapter concludes with an extensive example of random access operation.
The program listed below performs the simple function of reading or writing
random records upon command from the terminal.  When a
program has been created, assembled, and placed into a file
labeled `RANDOM.COM`, the CCP level command

`RANDOM X.DAT` \

starts the test program.  The program looks for a file by the
name `X.DAT` and, if found, proceeds to prompt the console for
input.  If not found, the file is created before the prompt is
given.  Each prompt takes the form

`next command?` \

and is followed by operator input, followed by a carriage
return.  The input commands take the form

_n_`W` _n_`R` `Q`

where _n_ is an integer value in the range `0` to `65535`, and `W`, `R`,
and `Q` are simple command characters corresponding to random
write, random read, and quit processing, respectively.  If the `W`
command is issued, the `RANDOM` program issues the prompt

`type data:` \

The operator then responds by typing up to 127 characters,
followed by a carriage return.  `RANDOM` then writes the character
string into the `X.DAT` file at record _n_.  If the `R` command is
issued, `RANDOM` reads record number _n_ and displays the string
value at the console,  If the `Q` command is issued, the `X.DAT` file
is closed, and the program returns to the CCP.  In the interest
of brevity, the only error message is

`error, try again.` \

The program begins with an initialization section where the input
file is opened or created, followed by a continuous loop at the
label ready where the individual commands are interpreted.  The
`DFBC` at `005CH` and the default buffer at `0080H` are used in all
disk operations.  The utility subroutines then follow, which
contain the principal input line processor, called `readc`.  This
particular program shows the elements of random access
processing, and can be used as the basis for further program
development.

#align(center)[*Sample Random Access Program for CP/M 2.0*]
#rect-print-listing[```
 0100                    org    100h      ;base of tpa
                ;
 0000 =         reboot   equ    0000h     ;system reboot
 0005 =         bdos     equ    0005h     ;bdos entry point
                ;
 0001 =         coninp   equ    1         ;console input function
 0002 =         conout   equ    2         ;console output function
 0009 =         pstring  equ    9         ;print string until '$'
 000A =         rstring  equ    10        ;read console buffer
 000C =         version  equ    12        ;return version number
 000F =         openf    equ    15        ;file open function
 0010 =         closef   equ    16        ;close function
 0016 =         makef    equ    22        ;make file function
 0021 =         readr    equ    33        ;read random
 0022 =         writer   equ    34        ;write random
                ;
 005C =         fcb      equ    005ch     ;default file control
                                          ;block
 007D =         ranrec   equ    fcb+33    ;random record position
 007F =         ranovf   equ    fcb+35    ;high order (overflow)
                                          ;byte
 0080 =         buff     equ    0080h     ;buffer address
                ;
 000D =         cr       equ    0dh       ;carriage return
 000A =         lf       equ    0ah       ;line feed
                ;
                ;        Load SP, Set-Up File for Random Access
                ;
 0100 31BC02             lxi    sp,stack
                ;
                ;        version 2.0
 0103 0E0C               mvi    c,version
 0105 CD0500             call   bdos
 0108 FE20               cpi    20h       ;version 2.0 or better?
 010A D21601             jnc    versok
                ;        bad version, message and go back
 010D 111B02             lxi    d,badver
 0110 CDDA01             call   print
 0113 C30000             jmp    reboot
                ;
                versok:
                ;        correct versionm for random access
 0116 0E0F               mvi    c,openf   ;open default fcb
 0118 115C00             lxi    d,fcb
 011B CD0500             call   bdos
 011E 3C                 inr    a         ;err 255 becomes zero
 011F C23701             jnz    ready
                ;
                ;        connot open file, so create it
 0122 0E16               mvi    c,makef
 0124 115C00             lxi    d,fcb
 0127 CD0500             call   bdos
 012A 3C                 inr    a         ;err 255 becomes zero
 012B C23701             jnz    ready
                ;
                ;        cannot create file, directory full
 012E 113A02             lxi    d,nospace
 0131 CDDA01             call   print
 0134 C30000             jmp    reboot    ;back to ccp
                ;
                ;        Loop Back to Ready After Each Command
                ;
                ready:
                ;        file is ready for processing
                ;
 0137 CDE501             call   readcom   ;read next command
 013A 227D00             shld   ranrec    ;store input record#
 013D 217F00             lxi    h,ranovf
 0140 3600               mvi    m,0       ;clear high byte if set
 0142 FE51               cpi    'Q'       ;quit?
 0144 C25601             jnz    notq
                ;
                ;        quit processing, close file
 0147 0E10               mvi    c,closef
 0149 115C00             lxi    d,fcb
 014C CD0500             call   bdos
 014F 3C                 inr    a         ;err 255 becomes 0
 0150 CAB901             jz     error     ;error message, retry
 0153 C30000             jmp    reboot    ;back to ccp
                ;
                ;
                ;        End of Quit Command, Process Write
```]
#rect-print-listing[```
                ;
                notq:
                ;        not the quit command, random write?
 0156 FE57               cpi    'W'
 0158 C28901             jnz    notw
                ;
                ;        this is a random write, fill buffer untill cr
 015B 114D02             lxi    d,datmsg
 015E CDDA01             call   print     ;data prompt
 0161 0E7F               mvi    c,127     ;up to 127 characters
 0163 218000             lxi    h,buff    ;destination
                rloop:   ;read next character to buff
 0166 C5                 push   b         ;save counter
 0167 E5                 push   h         ;next destination
 0168 CDC201             call   getchr    ;character to a
 016B E1                 pop    h         ;restore counter
 016C C1                 pop    b         ;restore next to fill
 016D FE0D               cpi    cr        ;end of line?
 016F CA7801             jz     erloop
                ;        not end, store character
 0172 77                 mov    m,a
 0173 23                 inx    h         ;next to fill
 0174 0D                 dcr    c         ;counter goes down
 0175 C26601             jnz    rloop     ;end of buffer?
                erloop:
                ;        end of read loop, store 00
 0178 3600               mvi    m,0
                ;
                ;        write the record to selected record number
 017A 0E22               mvi    c,writer
 017C 115C00             lxi    d,fcb
 017F CD0500             call   bdos
 0182 B7                 ora    a         ;erro code zero?
 0183 C2B901             jnz    error     ;message if not
 0186 C33701             jmp    ready     ;for another record
                ;
                ;        End of Write Command, Process Read
                ;
                notw:
                ;        not a write command, read record?
 0189 FE52               cpi    'R'
 018B C2B901             jnz    error     ;skip if not
                ;
                ;        read random record
 018E 0E21               mvi    c,readr
 0190 115C00             lxi    d,fcb
 0193 CD0500             call   bdos
 0196 B7                 ora    a         ;return code 00?
 0197 C2B901             jnz    error
                ;
                ;        read was successful, write to console
 019A CDCF01             call   crlf      ;new line
 019D 0E80               mvi    c,128     ;max 128 characters
 019F 218000             lxi    h,buff    ;next to get
                wloop:
 01A2 7E                 mov    a,m       ;next character
 01A3 23                 inx    h         ;next to get
 01A4 E67F               ani    7fh       ;mask parity
 01A6 CA3701             jz     ready     ;for another command
                                          ;if 00
 01A9 C5                 push   b         ;save counter
 01AA E5                 push   h         ;save next to get
 01AB FE20               cpi    ' '       ;graphic?
 01AD D4C801             cnc    putchr    ;skip output if not
 01B0 E1                 pop    h
 01B1 C1                 pop    b
 01B2 0D                 dcr    c         ;count=count-1
 01B3 C2A201             jnz    wloop
 01B6 C33701             jmp    ready
                ;
                ;        End of Read Command, All Errors End Up Here
                ;
                error:
 01B9 115902             lxi    d,errmsg
 01BC CDDA01             call   print
 01BF C33701             jmp    ready
                ;
```]
#rect-print-listing[```

                getchr:
                         ;read next console character to a
 01C2 0E01               mvi    c,coninp
 01C4 CD0500             call   bdos
 01C7 C9                 ret
                ;
                putchr:
                         ;write character from a to console
 01C8 0E02               mvi    c,conout
 01CA 5F                 mov    e,a       ;character to send
 01CB CD0500             call   bdos      ;send character
 01CE C9                 ret
                ;
                crlf:
                         ;send carriage return line feed
 01CF 3E0D               mvi    a,cr      ;carriage return
 01D1 CDC801             call   putchr
 01D4 3E0A               mvi    a,lf      ;line feed
 01D6 CDC801             call   putchr
 01D9 C9                 ret
                ;
                print:
                         ;print the buffer addressed by de untill $
 01DA D5                 push   d
 01DB CDCF01             call   crlf
 01DE D1                 pop    d         ;new line
 01DF 0E09               mvi    c,pstring
 01E1 CD0500             call   bdos      ;print the string
 01E4 C9                 ret
                ;
                readcom:
                         ;read the next command line to the conbuf
 01E5 116B02             lxi    d,prompt
 01E8 CDDA01             call   print     ;command?
 01EB 0E0A               mvi    c,rstring
 01ED 117A02             lxi    d,conbuf
 01F0 CD0500             call   bdos      ;read command line
                ;        command line is present, scan it
 01F3 210000             lxi    h,0       ;start with 0000
 01F6 117C02             lxi    d,conlin  ;command line
 01F9 1A        readc:   ldax   d         ;next command
                                          ;character
 01FA 13                 inx    d         ;to next command
                                          ;position
 01FB B7                 ora    a         ;cannot be end of
                                          ;command
 01FC C8                 rz
                ;        not zero, numeric?
 01FD D630               sui    '0'
 01FF FE0A               cpi    10        ;carry if numeric
 0201 D21302             jnc    endrd
                ;        add-in next digit
 0204 29                 dad    h         ;*2
 0205 4D                 mov    c,l
 0206 44                 mov    b,h       ;bc = value * 2
 0207 29                 dad    h         ;*4
 0208 29                 dad    h         ;*8
 0209 09                 dad    b         ;*2 + *8 = *10
 020A 85                 add    l         ;*digit
 020B 6F                 mov    l,a
 020C D2F901             jnc    readc     ;for another char
 020F 24                 inr    h         ;overflow
 0210 C3F901             jmp    readc     ;for another char
                endrd:
                ;        end of read, restore value in a
 0213 C630               adi    '0'       ;command
 0215 FE61               cpi    'a'       ;translate case?
 0217 D8                 rc
                ;        lower case, mask lower case bits
 0218 E65F               ani    101$1111b
 021A C9                 ret
```]
#rect-print-listing[```
                ;
                ;        String Data Area for Console Messages
                ;
                badver:
 021B 736F727279         db     'sorry, you need cp/m version 2$'
                nospace:
 023A 6E6F206469         db     'no directory space$'
                datmsg:
 024D 7479706520         db     'type data: $'
                errmsg:
 0259 6572726F72         db     'error, try again.$'
                prompt:
 026B 6E65787420         db     'next command? $'
                ;
                ;        Fixed and Variable Data Area
                ;
 027A 21        conbuf:  db     conlen     ;length of console buffer
 027B           consiz:  ds     1          ;resulting size after read
 027C           conlin:  ds     32         ;length 32 buffer
 0021 =         conlen   equ    $-consiz
                ;
 029C                    ds     32         ;16 level stack
                stack:
 02BC                    end
```]

Major improvements could be made to this particular program to enhance
its operation.  In fact, with some work, this program could
evolve into a simple data base management system.  One could, for
example, assume a standard record size of 128 bytes, consisting
to arbitrary fields within the record.  A program, called `GETKEY`,
could be developed that first reads a sequential file and
extracts a specific field defined by the operator.  For example,
the command

#cmd-line[`GETKEY NAMES.DAT LASTNAME 10 20`]

would cause `GETKEY` to read the data base file `NAMES.DAT` and
extract the `LASTNAME` field from each record, starting in
position `10` and ending at character `20`.  `GETKEY` builds a table in
memory consisting of each particular `LASTNAME` field, along with
its 16-bit record number location within the file.  The `GETKEY`
program then sorts this list and writes a new file, called
`LASTNAME.KEY`, which is an alphabetical list of `LASTNAME` fields
with their corresponding record numbers.  This list is called an
inverted index in information retrieval parlance.

If the programmer were to rename the program shown above as `QUERY`
and modify it so that it reads a sorted key file into memory,
the command line might appear as

#cmd-line[`QUERY NAMES.DAT LASTNAME.KEY`]

Instead of reading a number, the `QUERY` program reads an
alphanumeric string that is a particular key to find in the
`NAMES.DAT` data base.  Because the `LASTNAME.KEY` list is sorted, one
can find a particular entry rapidly by performing a binary
search, similar to looking up a name in the telephone book.
Starting at both ends of the list, one examines the
entry halfway in between and, if not matched, splits either the
upper half or the lower half for the next search.  You will
quickly reach the item you are looking for and find the
corresponding record number.  You should fetch and display
this record at the console, just as was done in the program shown
above.

With some more work, you can allow a fixed grouping size
that differs from the 128-byte record shown above.  This is
accomplished by keeping track of the record number and the
byte offset within the record.  Knowing the group size, you
randomly access the record containing the proper group, offset
to the beginning of the group within the record read sequentially
until the group size has been exhausted.

Finally, you can improve `QUERY` considerably by allowing boolean
expressions, which compute the set of records that satisfy
several relationships, such as a `LASTNAME` between `HARDY` and
`LAUREL` and an `AGE` lower than `45`.  Display all the records that
fit this description.  Finally, if your lists are getting
too big to fit into memory, randomly access key
files from the disk as well.

= System Function Summary
#show figure: set block(breakable: true)
#bdos-function-summary-table("2.0", caption: [BDOS System Function Summary])


#set heading(numbering: none)
#pagebreak()
= Notes on the #zcim-project Edition

The #zcim-project goal is to improve the accessibility of legacy Z80 CP/M era content.
As part of the project, Jim Burlingame (_jb\@samplx.org_) created a _Typst_ version of this manual.

You can find out more about the project at its site #link("https://www.z80cim.org")[z80cim.org].
The sources of this document are available on
#link("https://github.com/samplx/zcimdocs")[GitHub].


The source material is from the
#link("http://cpm.z80.de/drilib.html")[_Tim Olmstead Memorial Digital Research CP/M Library_]

The individual documents from the archive include:

- #link("http://cpm.z80.de/randyfiles/DRI/CPM_2_0_Interface_Guide.pdf")[_CP/M 2.0 Interface Guide_ (PDF)]

The contents of the manual were edited using the #link("https://Typst.app/")[Typst.app] site.

The sources of the document are available at
#link("https://github.com/samplx/zcimdocs")[GitHub].

== License

The source documentation is under a license granted by the owner
of the Digital Research intellectual property 
in an email available at #link("http://cpm.z80.de/license.html").

The #zcim-project edition is under the Creative Commons Attribution 4.0 International license. #link("https://creativecommons.org/licenses/by/4.0/")[*CC BY 4.0*].


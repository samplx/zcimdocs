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
#import "@preview/tiptoe:0.3.1": *

#let document-version = [version 2025-08-02]

// -------------------------------------------------------------------------------
// END of COMMON
// -------------------------------------------------------------------------------
#title-page(
  title-text: [
    CP/M® Dynamic Debugging Tool (DDT) \
    _User's Guide_
  ],
  version: document-version
)

#pagebreak()
#credits-page(
  copyright: [
Copyright ©1976, 1978 by Digital Research. All rights reserved. No part of this publication may be reproduced, transmitted, transcribed, stored in a retrieval system, or translated into any language or computer language, in any form or by any means, electronic, mechanical, magnetic, optical, chemical, manual or otherwise, without the prior written permission of \
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
#counter(page).update(0)
#pagebreak()
#set page(numbering: "1")
#set heading(numbering: "1.", supplement: [Section])
= Introduction

The DDT program allows dynamic interactive testing and debugging
of programs generated in the CP/M environment. Invoke the
debugger with a command of one of the following forms:

#cmd-line[`DDT`]

#cmd-line[`DDT `_filename_`.HEX`]

#cmd-line[`DDT `_filename_`.COM`]

where _filename_ is the name of the program to be loaded and
tested. In both cases, the `DDT` program is brought into main
memory in place of the Console Command Processor (CCP) and
resides directly below the Basic Disk Operating System (BDOS)
portion of CP/M. Refer to Section 5 for standard memory
organization. The BDOS starting address, located in the address
field of the `JMP` instruction at location `0005H`, is altered to
reflect the reduced Transient Program Area (TPA) size.

The second and third forms of the `DDT` command perform the same
actions as the first, except there is a subsequent automatic load
of the specified `HEX` or `COM` file. The action is identical to the
following sequence of commands:

#cmd-line[`DDT`]
#cmd-line[`I`_filename_`.HEX`  or `I`_filename_`.COM`]
#cmd-line[`R`]

where the `I` and `R` commands set up and read the specified program
to test. See the explanation of the `I` and `R` commands below for
exact details.

Upon initiation, `DDT` prints a sign-on message in the form:

#cmd-line[_nn_`K` `DDT-`_S_ `VER `_m_`.`_m_]

where _nn_ is the memory size (which much match the CP/M system being used),
_S_ is the hardware system which is assumed, corresponding to the codes

/ D : Digital Research standard version
/ M : MDS version
/ I : IMSAI standard version
/ O : Omron systems
/ S : Digital Systems standard version

and _m.m_ is the revision number.

Following the sign-on message, `DDT` prompts the operator with the hyphen
character, `-`, and waits for input commands from the console.  The operator
can type any of several single character commands, terminated by a
carriage return to execute the command. Each line of input can be
line-edited using the following standard CP/M controls:

#figure(
  table(
    columns: (auto, 1fr),
    inset: 10pt,
    align: (center, left),
    table.header([Character], [Meaning]),
    [rubout/DEL], [remove the last character typed],
    [CTRL-U], [remove the entire line, ready for re-typing],
    [CTRL-C], [system reboot],
  ),
  caption: [`DDT` Line-editing Controls],
)

Any command can be up to 32 characters in length (an automatic
carriage return is inserted as character 33), where the first
character determines the command type. @DDTCommands describes `DDT`
commands.

#figure(
  table(
    columns: (auto, 1fr),
    inset: 10pt,
    align: (center, left),
    table.header([Character], [Result]),
    [`A`], [enters assembly-language mnemonics with operands.],
    [`D`], [displays memory in hexadecimal and ASCII.],
    [`F`], [fills memory with constant data.],
    [`G`], [begins execution with optional breakpoints.],
    [`I`], [sets up a standard input File Control Block.],
    [`L`], [lists memory using assembler mnemonics.],
    [`M`], [moves a memory segment from source to destination.],
    [`R`], [reads a program for subsequent testing.],
    [`S`], [substitutes memory values.],
    [`T`], [traces program execution.],
    [`U`], [untraced program monitoring.],
    [`X`], [examines and optionally alters the CPU state.],
  ),
  caption: [`DDT` Commands],
) <DDTCommands>

The command character, in some cases, is followed by zero, one,
two, or three hexadecimal values, which are separated by commas
or single blank characters. All `DDT` numeric output is in
hexadecimal form. The commands are not executed until the
carriage return is typed at the end of the command.

At any point in the debug run, you can stop execution of DDT by
using either a CTRL-C or `G0` (jump to location `0000H`) and save the
current memory image by using a `SAVE` command of the form:

#cmd-line[`SAVE` _n_ _filename_`.COM`]

where n is the number of pages (256 byte blocks) to be saved on
disk. The number of blocks is determined by taking the high-order
byte of the address in the TPA and converting this number to
decimal. For example, if the highest address in the TPA is `134H`,
the number of pages is `12H` or `18` in decimal. You could type a
CTRL-C during the debug run, returning to the CCP level, followed
by

#cmd-line[`SAVE 18 X.COM`]

The memory image is saved as `X.COM` on the disk and can be
directly executed by typing the name `X`. If further testing is
required, the memory image can be recalled by typing

#cmd-line[`DDT X.COM`]

which reloads the previously saved program from location `100H`
through page 18, `23FFH`. The CPU state is not a part of the COM
file; thus, the program must be restarted from the beginning to
test it properly.

= DDT Commands

The individual commands are detailed below. In each case, the
operator must wait for the hyphen prompt character before
entering the command. If control is passed to a program under
test, and the program has not reached a breakpoint, control can
be returned to `DDT` by executing a `RST 7` from the front panel.  In
the explanation of each command, the command letter is shown in
some cases with numbers separated by commas, the numbers are
represented by lower-case letters. These numbers are always
assumed to be in a hexadecimal radix and from one to four digits
in length. Longer numbers are automatically truncated on the
right.

Many of the commands operate upon a "CPU state" that corresponds to
the program under test. The CPU state holds the registers of the
program being debugged and initially contains zeros for all
registers and flags except for the program counter, `P`, and stack
pointer, `S`, which default to `100H`. The program counter is
subsequently set to the starting address given in the last record
of a HEX file if a file of this form is loaded, see the `I` and `R`
commands.

== The A (Assembly) Command

`DDT` allows in-line assembly language to be inserted into the
current memory image using the A command, which takes the form:

#cmd-line[`A`_s_]

where _s_ is the hexadecimal starting address for the in-line
assembly. `DDT` prompts the console with the address of the next
instruction to fill and reads the console, looking for assembly-
language mnemonics followed by register references and operands
in absolute hexadecimal form. See the Intel 8080 Assembly
Language Reference Card for a list of mnemonics. Each successive
load address is printed before reading the console.  The `A`
command terminates when the first empty line is input from the
console.

Upon completion of assembly language input, you can review the
memory segment using the `DDT` disassembler (see the `L` command).

Note that the assembler/disassembler portion of `DDT` can be
overlaid by the transient program being tested, in which case the
`DDT` program responds with an error condition when the `A` and `L`
commands are used.

== The D (Display) Command

The `D` command allows you to view the contents of memory in
hexadecimal and ASCII formats. The `D` command takes the forms:

#cmd-line[`D`]

#cmd-line[`D`_s_]

#cmd-line[`D`_s_`,`_f_]

In the first form, memory is displayed from the current display
address, initially 100H, and continues for 16 display lines.
Each display line takes the following form:

```
aaaa bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb cccccccccccccccc
```

where _aaaa_ is the display address in hexadecimal and _bb_
represents data present in memory starting at _aaaa_. The ASCII
characters starting at _aaaa_ are to the right (represented by the
sequence of character _c_) where non-graphic characters are printed
as a period. You should note that both upper- and lower-case
alphabetic characters are displayed, and will appear as upper-case symbols
on a console device that supports only upper-case. Each display
line gives the values of 16 bytes of data, with the first line
truncated so that the next line begins at an address that is a
multiple of 16.

The second form of the `D` command is similar to the first, except
that the display address is first set to address _s_.

The third form causes the display to continue from address _s_
through address _f_. In all cases, the display address is set to
the first address not displayed in this command, so that a
continuing display can be accomplished by issuing successive `D`
commands with no explicit addresses.

Excessively long displays can be aborted by pressing the return
key.

== The F (Fill) Command

The `F` command takes the form:

#cmd-line[`F`_s_`,`_f_`,`_c_]

where _s_ is the starting address, _f_ is the final address, and _c_ is
a hexadecimal byte constant. `DDT` stores the constant _c_ at address
_s_, increments the value of _s_ and test against _f_. If _s_ exceeds _f_,
the operation terminates, otherwise the operation is repeated.
Thus, the fill command can be used to set a memory block to a
specific constant value.

== The G (Go) Command

A program is executed using the `G` command, with up to two
optional breakpoint addresses. The `G` command takes the forms:

#cmd-line[`G`]

#cmd-line[`G`_s_]

#cmd-line[`G`_s_`,`_b_]

#cmd-line[`G`_s_`,`_b_`,`_c_]

#cmd-line[`G,`_b_]

#cmd-line[`G,`_b_`,`_c_]

The first form executes the program at the current value of the
program counter in the current machine state, with no breakpoints
set. The only way to regain control in DDT is through a `RST 7`
execution. The current program counter can be viewed by typing an
`X` or `XP` command.

The second form is similar to the first, except that the program
counter in the current machine state is set to address _s_ before
execution begins.

The third form is the same as the second, except that program
execution stops when address _b_ is encountered (_b_ must be in the
area of the program under test). The instruction at location _b_ is
not executed when the breakpoint is encountered.

The fourth form is identical to the third, except that two
breakpoints are specified, one at _b_ and the other at _c_.
Encountering either breakpoint causes execution to stop and both
breakpoints are cleared. The last two forms take the program
counter from the current machine state and set one and two
breakpoints, respectively.

Execution continues from the starting address in real-time to the
next breakpoint. There is no intervention between the starting
address and the break address by `DDT`. If the program under test
does not reach a breakpoint, control cannot return to DDT without
executing a `RST 7` instruction. Upon encountering a breakpoint,
DDT stops execution and types

#cmd-line[`*`_d_]

where _d_ is the stop address. The machine state can be examined at
this point using the `X` (Examine) command. You must specify
breakpoints that differ from the program counter address at the
beginning of the `G` command. Thus, if the current program counter
is `1234H`, then the following commands:

#cmd-line[`G,1234`]

and

#cmd-line[`G400,400`]

both produce an immediate breakpoint without executing any
instructions.

== The I (Input) Command

The `I` command allows you to insert a filename into the default
File Control Block (FCB) at `5CH`. The FCB created by CP/M for
transient programs is placed at this location (see the CP/M Interface Guide).
The default FCB can be used by the program under test as if it
had been passed by the CP/M Console Processor. Note that this
filename is also used by `DDT` for reading additional `HEX` and `COM`
files. The `I` command takes the forms:

#cmd-line[`I`_filename_]

or

#cmd-line[`I`_filename_`.`_filetype_]

If the second form is used and the filetype is either `HEX` or `COM`,
subsequent `R` commands can be used to read the pure binary or hex
format machine code. @ReadCommand gives further details.

== The L (List) Command

The `L` command is used to list assembly-language mnemonics in a
particular program region. The `L` command takes the forms:

#cmd-line[`L`]

#cmd-line[`L`_s_]

#cmd-line[`L`_s_`,`_f_]

The first form lists twelve lines of disassembled machine code
from the current list address. The second form sets the list
address to _s_ and then lists twelve lines of code. The last form
lists disassembled code from _s_ through address _f_. In all three
cases, the list address is set to the next unlisted location in
preparation for a subsequent `L` command. Upon encountering an
execution breakpoint, the list address is set to the current
value of the program counter (`G` and `T` commands). Again, long
type-outs can be aborted by pressing RETURN during the list
process.

== The M (Move) Command

The `M` command allows block movement of program or data areas from
one location to another in memory. The `M` command takes the form:

#cmd-line[`M`_s_`,`_f_`,`_d_]

where _s_ is the start address of the move, _f_ is the final address,
and _d_ is the destination address. Data is first removed from _s_ to
_d_, and both addresses are incremented. If _s_ exceeds _f_, the move
operation stops; otherwise, the move operation is repeated.

== The R (Read) Command <ReadCommand>

The `R` command is used in conjunction with the `I` command to read
`COM` and `HEX` files from the disk into the transient program area
in preparation for the debug run. The `R` command takes the forms:

#cmd-line[`R`]

#cmd-line[`R`_b_]

where _b_ is an optional bias address that is added to each program
or data address as it is loaded. The load operation must not
overwrite any of the system parameters from `000H` through `0FFH`
(that is, the first page of memory). If _b_ is omitted, then $b =
0000$ is assumed. The `R` command requires a previous `I` command,
specifying the name of a `HEX` or `COM` file.  The load address for
each record is obtained from each individual `HEX` record, while an
assumed load address of `100H` is used for `COM` files. Note that any
number of `R` commands can be issued following the `I` command to
reread the program under test, assuming the tested program does
not destroy the default area at `5CH`. Any file specified with the
filetype `COM` is assumed to contain machine code in pure binary
form (created with the `LOAD` or `SAVE` command), and all others are
assumed to contain machine code in Intel hex format (produced,
for example, with the `ASM` command).

Recall that the command,

#cmd-line[`DDT ` _filename_`.`_typ_]

which initiates the `DDT` program, equals to the following
commands:

#cmd-line[`DDT`]

#cmd-line[`-`_filename.typ_]
#cmd-line[`-R`]

Whenever the `R` command is issued, `DDT` responds with either the
error indicator `?` (file cannot be opened, or a checksum error
occurred in a `HEX` file) or with a load message. The load message
takes the form:

#cmd-line[`NEXT PC`]

#cmd-line[_nnnn_ _pppp_]

where _nnnn_ is the next address following the loaded program and
_pppp_ is the assumed program counter (`100H` for `COM` files, or taken
from the last record if a `HEX` file is specified).

== The S (Set) Command

The `S` command allows memory locations to be examined and
optionally altered. The `S` command takes the form:

#cmd-line[`S`_s_]

where s is the hexadecimal starting address for examination and
alteration of memory. `DDT` responds with a numeric prompt, giving
the memory location, along with the data currently held in
memory. If you type a carriage return, the data is not altered.
If a byte value is typed, the value is stored at the prompted
address. In either case, `DDT` continues to prompt with successive
addresses and values until you type either a period or an invalid
input value is detected.

== The T (Trace) Command

The `T` command allows selective tracing of program execution for `1`
to `65535` program steps. The `T` command takes the forms:

#cmd-line[`T`]

#cmd-line[`T`_n_]

In the first form, the CPU state is displayed and the next
program step is executed. The program terminates immediately,
with the termination address displayed as

#cmd-line[`*`_hhhh_]

where _hhhh_ is the next address to execute. The display address
(used in the `D` command) is set to the value of `H` and `L`, and the
list address (used in the `L` command) is set to _hhhh_. The CPU
state at program termination can then be examined using the `X`
command.

The second form of the `T` command is similar to the first, except
that execution is traced for _n_ steps (_n_ is a hexadecimal value)
before a program breakpoint occurs. A breakpoint can be forced in
the trace mode by typing a rubout character. The CPU state is
displayed before each program step is taken in trace mode. The
format of the display is the same as described in the `X` command.

You should note that program tracing is discontinued at the CP/M
interface and resumes after return from CP/M to the program under
test. Thus, CP/M functions that access I/O devices, such as the
disk drive, run in real-time, avoiding I/O timing problems.
Programs running in trace mode execute approximately 500 times
slower than real-time because `DDT` gets control after each user
instruction is executed. Interrupt processing routines can be
traced, but commands that use the breakpoint facility (`G`, `T`, and
`U`) accomplish the break using an `RST 7` instruction, which means
that the tested program cannot use this interrupt location.
Further, the trace mode always runs the tested program with
interrupts enabled, which may cause problems if asynchronous
interrupts are received during tracing.

To get control back to `DDT` during trace, press RETURN rather than
executing an `RST 7`. This ensures that the trace for current
instruction is completed before interruption.

== The U (Untrace) Command

The `U` command is identical to the `T` command, except that
intermediate program steps are not displayed. The untrace mode
allows from `1` to `65535` (`0FFFFH`) steps to be executed in monitored
mode and is used principally to retain control of an executing
program while it reaches steady state conditions. All conditions
of the `T` command apply to the `U` command.

== The X (Examine) Command

The `X` command allows selective display and alteration of the
current CPU state for the program under test. The `X` command takes
the forms:

#cmd-line[`X`]

#cmd-line[`X`_r_]

where _r_ is one of the 8080 CPU registers listed in @CPURegisters.

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 10pt,
    align: (center, center, center),
    table.header([Register], [Meaning], [Value]),
    [`C`], [Carry flag], [`0` or `1`],
    [`Z`], [Zero flag], [`0` or `1`],
    [`M`], [Minus flag], [`0` or `1`],
    [`E`], [Even parity flag], [`0` or `1`],
    [`I`], [Half-carry], [`0` or `1`],
    [`A`], [Accumulator], [`0` … `FF`],
    [`B`], [BC register pair], [`0` … `FFFF`],
    [`D`], [DE register pair], [`0` … `FFFF`],
    [`H`], [HL register pair], [`0` … `FFFF`],
    [`S`], [Stack pointer], [`0` … `FFFF`],
    [`P`], [Program counter], [`0` … `FFFF`],
  ),
  caption: [CPU Registers],
) <CPURegisters>

#block(breakable: false)[
In the first case, the CPU register state is displayed in the
format:

#text(kerning: false, tracking: 0.5pt, spacing: 100% + 1pt)[*`C`*_f_ *`Z`*_f_ *`M`*_f_ *`E`*_f_ *`I`*_f_*` A=`*_bb_*` B=`*_dddd_*` D=`*_dddd_*` H=`*_dddd_*` S=`*_dddd_*` P=`*_dddd_ _`inst`_]

where _f_ is a `0` or `1` flag value, _bb_ is a byte value, and _dddd_ is a
double-byte quantity corresponding to the register pair. The _`inst`_
field contains the disassembled instruction, that occurs at the
location addressed by the CPU state's program counter.
]

The second form allows display and optional alteration of
register values, where r is one of the registers given above (`C`,
`Z`, `M`, `E`, `I`, `A`, `B`, `D`, `H`, `S`, or `P`). In each case, the flag or
register value is first displayed at the console. The `DDT` program
then accepts input from the console. If a carriage return is
typed, the flag or register value is not altered. If a value in
the proper range is typed, the flag or register value is altered.
You should note that `BC`, `DE`, and `HL` are displayed as register
pairs. Thus, you must type the entire register pair when `B`, `C`, or
the `BC` pair is altered.

= Implementation Notes

The organization of `DDT` allows certain nonessential portions to
be overlaid to gain a larger transient program area for debugging
large programs. The `DDT` program consists of two parts: the `DDT`
nucleus and the assembler/disassembler module.  The `DDT` nucleus
is loaded over the CCP and, although loaded with the `DDT` nucleus,
the assembler/disassembler can be overlaid unless used to assemble
or disassemble.

In particular, the BDOS address at location `0006H` (address field of
the `JMP` instruction at location `0005H`) is modified by `DDT` to address
the base location of the `DDT` nucleus, which, in turn, contains a
`JMP` instruction to the BDOS. Thus, programs that use this address
field to size memory see the logical end of memory at the base of
the `DDT` nucleus rather than the base of the BDOS.

The assembler/disassembler module resides directly below the `DDT`
nucleus in the transient program area. If the `A`, `L`, `T`, or `X`
commands are used during the debugging process, the `DDT` program
again alters the address field at `0006H` to include this module,
further reducing the logical end of memory. If a program loads
beyond the beginning of the assembler/disassembler module, the `A`
and `L` commands are lost (their use produces a ? in response) and
the trace and display (`T` and `X`) commands list the inst field of
the display in hexadecimal, rather than as a decoded instruction.

= An Example

The following example shows an edit, assemble, and debug for a
simple program that reads a set of data values and determines the
largest value in the set. The largest value is taken from the
vector and stored into `LARGE` at the termination of the program.


#block(breakable: false, below: 2em)[
In the example:
/ output text : `is in a monospace font`
/ input text : #text(fill: ui-fill)[`is in `#raw(ui-fill-name)]
/ carriage-return : is displayed as #text(fill: ui-fill)[↵]
/ rubout/DEL key : is displayed as #text(fill: ui-fill)[⌫]
/ tab key : is displayed as #text(fill: ui-fill)[⇥]
/ CTRL-Z : #text(fill: ui-fill)[^Z]
/ comments : #text(font: cursive-font)[are displayed in #cursive-font-name].
]

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 0pt,
      line(start: (232pt, 20pt), end: (252pt, 37pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 220pt,
      dy: 8pt,
      [rubout]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (262pt, 20pt), end: (258pt, 35pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 260pt,
      dy: 8pt,
      [rubout echo]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (140pt, 20pt), end: (112pt, 36pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 8pt,
      [tab character]
    )
    #place(
      top + left,
      dx: 360pt,
      dy: 150pt,
      block(width: 10em)[
        #align(center)[Create Source Program.
        #ui-fill-name characters are typed by programmer. \
        "↵" represents carriage return ]]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (32pt, 350pt), end: (12pt, 350pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 40pt,
      dy: 345pt,
      [CTRL-Z]
    )
  ],
)[
`A>`#text(fill: ui-fill)[`ED SCAN.ASM↵`] \
`NEW FILE` \
`     : *`#text(fill: ui-fill)[`I↵`] \
#text(fill: ui-fill)[`                ORG⇥        100H           L⌫L;START OF TRANSIENT↵
                                            ;AREA↵
                MVI          B, LEN         ;LENGTH OF VECTOR TO SCAN↵
                MVI          C, 0           ;LARGER_RST VALUE SO FAR↵
                LXI          H, VECT        ;BASE OF VECTOR↵
LOOP:           MOV          A, M           ;GET VALUE↵
                SUB          C              ;LARGER VALUE IN C?↵
                JNC          NFOUND         ;JUMP IF LARGER VALUE NOT↵
                                            ;FOUND↵
;               NEW LARGEST VALUE, STORE IT TO C↵
                MOV          C, A↵
NFOUND          INX          H              ;TO NEXT ELEMENT↵
                DCR          B              ;MORE TO SCAN?↵
                JNZ          LOOP           ;FOR ANOTHER↵
;↵
;               END OF SCAN, STORE C↵
                MOV          A, C           ;GET LARGEST VALUE↵
                STA          LARGE↵
                JMP          0              ;REBOOT↵
;↵
;               TEST DATA↵
VECT:           DB           2,0,4,3,5,6,1,5↵
LEN             EQU          $-VECT         ;LENGTH↵
LARGE:          DS           1              ;LARGEST VALUE ON EXIT↵
                END↵
^Z`]
]


#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 0pt,
      line(start: (85pt, 290pt), end: (65pt, 292pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 90pt,
      dy: 288pt,
      [End of Edit]
    )
    #place(
      top + left,
      dx: 100pt,
      dy: 315pt,
      [Start Assembler]
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 375pt,
      [Assembly Complete -- Look at Program Listing]
    )
  ],
)[
`     : *`#text(fill: ui-fill)[`B0P`↵]
`
    1:                  ORG          100H           ;START OF TRANSIENT
    2:                                              ;AREA
    3:                  MVI          B, LEN         ;LENGTH OF VECTOR TO SCAN
    4:                  MVI          C, 0           ;LARGER_RST VALUE SO FAR
    5:                  LXI          H, VECT        ;BASE OF VECTOR
    6:  LOOP:           MOV          A, M           ;GET VALUE
    7:                  SUB          C              ;LARGER VALUE IN C?
    8:                  JNC          NFOUND         ;JUMP IF LARGER VALUE NOT
    9:                                              ;FOUND
   10:  ;               NEW LARGEST VALUE, STORE IT TO C
   11:                  MOV          C, A
   12:  NFOUND          INX          H              ;TO NEXT ELEMENT
   13:                  DCR          B              ;MORE TO SCAN?
   14:                  JNZ          LOOP           ;FOR ANOTHER
   15:  ;
   16:  ;               END OF SCAN, STORE C
   17:                  MOV          A, C           ;GET LARGEST VALUE
   18:                  STA          LARGE
   19:                  JMP          0              ;REBOOT
   20:  ;
   21:  ;               TEST DATA
   22:  VECT:           DB           2,0,4,3,5,6,1,5
   23:  LEN             EQU          $-VECT         ;LENGTH
    1: *`#text(fill: ui-fill)[`E`↵] \
\
`A>`#text(fill: ui-fill)[`ASM SCAN`↵]
`
CP/M ASSEMBLER - VER 1.0

0122
002H USE FACTOR
END OF ASSEMBLY

`  
]


#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 120pt,
      dy: -5pt,
      [Look at Program Listing]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (65pt, 20pt), end: (25pt, 28pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 70pt,
      dy: 15pt,
      [Code Address]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (65pt, 40pt), end: (52pt, 52pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 70pt,
      dy: 35pt,
      [Machine Code]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (145pt, 22pt), end: (160pt, 27pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 140pt,
      dy: 10pt,
      [Source Program]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (65pt, 250pt), end: (75pt, 260pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 8pt,
      dy: 239pt,
      align(center)[Code/Data listing \ truncated]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (35pt, 300pt), end: (25pt, 282pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 38pt,
      dy: 299pt,
      align(center)[value of Equate]
    )
  ],
)[
`A>`#text(fill: ui-fill)[`TYPE SCAN.PRN`↵]
#text(size: 10pt)[`

 0100                           ORG          100H           ;START OF TRANSIENT
                                                            ;AREA
 0100 0608                      MVI          B, LEN         ;LENGTH OF VECTOR TO SCAN
 0102 0E00                      MVI          C, 0           ;LARGER_RST VALUE SO FAR
 0104 211901                    LXI          H, VECT        ;BASE OF VECTOR
 0107 7E        LOOP:           MOV          A, M           ;GET VALUE
 0108 91                        SUB          C              ;LARGER VALUE IN C?
 0109 D20D01                    JNC          NFOUND         ;JUMP IF LARGER VALUE NOT
                                                            ;FOUND
                ;               NEW LARGEST VALUE, STORE IT TO C
 010C 4F                        MOV          C, A
 010D 23        NFOUND          INX          H              ;TO NEXT ELEMENT
 010E 05                        DCR          B              ;MORE TO SCAN?
 010F C20701                    JNZ          LOOP           ;FOR ANOTHER
                ;
                ;               END OF SCAN, STORE C
 0112 79                        MOV          A, C           ;GET LARGEST VALUE
 0113 322101                    STA          LARGE
 0116 C30000                    JMP          0              ;REBOOT
                ;
                ;               TEST DATA
 0119 0200040305VECT:           DB           2,0,4,3,5,6,1,5
 0008 =         LEN             EQU          $-VECT         ;LENGTH
 0121           LARGE:          DS           1              ;LARGEST VALUE ON EXIT
 0122                           END


`]
]

#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 120pt,
      dy: -2pt,
      [Start Debugger with hex format machine code]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (50pt, 65pt), end: (21pt, 54pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 52pt,
      dy: 60pt,
      [last load address + 1]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (175pt, 105pt), end: (200pt, 95pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 40pt,
      dy: 97pt,
      [examine registers before debug run]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (275pt, 62pt), end: (290pt, 86pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 270pt,
      dy: 50pt,
      align(center)[next instruction to execute \ at PC = 0]
    )
    #place(
      top + left,
      dx: 78pt,
      dy: 118pt,
      [change PC to 100]
    )
    #place(
      top + left,
      dx: 38pt,
      dy: 140pt,
      [look at registers again]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (235pt, 165pt), end: (265pt, 175pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 188pt,
      dy: 160pt,
      [PC changed]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (290pt, 200pt), end: (295pt, 185pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 285pt,
      dy: 190pt,
      align(center)[next instruction \ to execute at PC=100]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (135pt, 227pt), end: (135pt, 360pt), tip: bar, toe: bar)
    )
    #place(
      top + left,
      dx: 138pt,
      dy: 275pt,
      block(width: 10em)[
        #align(center)[Diassembled machine code \
      at 100H \
      (See source listing \
    for comparison)]
      ]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (135pt, 385pt), end: (135pt, 510pt), tip: bar, toe: bar)
    )
    #place(
      top + left,
      dx: 138pt,
      dy: 400pt,
      block(width: 10em)[
        #align(center)[A little more \
        machine code \
      (note that program \
      ends at location 116 \
      with a JMP to 0000)]
      ]
    )
  ],
)[
`A>`#text(fill: ui-fill)[`DDT SCAN.HEX`↵] \
`
16K DDT VERS 1.0
NEXT PC
0121 0000
-`#text(fill: ui-fill)[`X`↵] \
`
C0Z0M0E0I0 A=00 B=0000 D=0000 H=0000 S=0100 P=0000 JMP  FA03

-`#text(fill: ui-fill)[`XP`↵] \
`P=0000 `#text(fill: ui-fill)[`100`↵] \
`-`#text(fill: ui-fill)[`X`↵] \
`

C0Z0M0E0I0 A=00 B=0000 D=0000 H=0000 S=0100 P=0100 MVI B,08

-`#text(fill: ui-fill)[`L100`↵] \
`
  0100  MVI  B,08
  0102  MVI  C,00
  0104  LXI  H,0119
  0107  MOV  A,M
  0108  SUB  C
  0109  JNC  010D
  010C  MOV  C,A
  010D  INX  H
  010E  DCR  B
  010F  JNZ  0107
  0112  MOV  A,C
-`#text(fill: ui-fill)[`L`↵] \
`
  0113  STA  0121
  0116  JMP  0000
  0119  STAX B
  011A  NOP
  011B  INR  B
  011C  INX  B
  011D  DCR  B
  011E  MVI  B,01
  0120  DCR  B
  0121  ??=  20
  0122  MOV  D,D
`  
]


#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 100pt,
      dy: -2pt,
      [enter inline assembly mode to change the JMP to 0000 
    into a RST 7, which will \
    cause the program under test to return to DDT if 116H is ever executed \
    (single carriage return stops assemble mode)]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (108pt, 65pt), end: (83pt, 85pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 110pt,
      dy: 55pt,
      [list code at 113H to check that RST 7 was properly inserted \ in place of JMP]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 200pt,
      [look at registers]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 248pt,
      [execute program for one step]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (275pt, 262pt), end: (290pt, 270pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 270pt,
      dy: 248pt,
      [initial CPU state, before instruction is executed]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 298pt,
      [trace one step again (note 08H in B)]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (305pt, 295pt), end: (332pt, 282pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 270pt,
      dy: 298pt,
      [automatic breakpoint]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 345pt,
      [trace again (register C is cleared)]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 395pt,
      [trace three steps]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (315pt, 465pt), end: (332pt, 457pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 200pt,
      dy: 460pt,
      [automatic breakpoint at 10DH]
    )
  ],
)[
`-`#text(fill: ui-fill)[`A116`↵] \
`0116 `#text(fill: ui-fill)[`RST 7`↵] \
`0117 `#text(fill: ui-fill)[↵] \
`-`#text(fill: ui-fill)[`L113`↵] \
`
  0113  STA  0121
  0116  RST  07
  0117  NOP
  0118  NOP
  0119  STAX B
  011A  NOP
  011B  INR  B
  011C  INX  B
  011D  DCR  B
  011E  MVI  B,01
  0120  DCR  B
-`#text(fill: ui-fill)[`X`↵] \
`
C0Z0M0E0I0 A=00 B=0000 D=0000 H=0000 S=0100 P=0100 MVI B,08

-`#text(fill: ui-fill)[`T`↵] \
`
C0Z0M0E0I0 A=00 B=0000 D=0000 H=0000 S=0100 P=0100 MVI B,08*0102

-`#text(fill: ui-fill)[`T`↵] \
`
C0Z0M0E0I0 A=00 B=0800 D=0000 H=0000 S=0100 P=0102 MVI C,00*0104

-`#text(fill: ui-fill)[`T`↵] \
`
C0Z0M0E0I0 A=00 B=0800 D=0000 H=0000 S=0100 P=0104 LXI H,0119*0107

-`#text(fill: ui-fill)[`T3`↵] \
`
C0Z0M0E0I0 A=00 B=0800 D=0000 H=0119 S=0100 P=0107 MOV A,M
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=0108 SUB C
C0Z0M0E0I1 A=02 B=0800 D=0000 H=0119 S=0100 P=0109 JNC 010D*010D

`
]

#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 50pt,
      dy: 0pt,
      [display memory starting at 119H]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 20pt,
      [program data]
    )
    #place(
      top + left,
      dx: 25pt,
      dy: 36pt,
      rect(height: 11pt, width: 115pt)
    )
    #place(
      top + left,
      dx: 25pt,
      dy: 47pt,
      rect(height: 11pt, width: 17pt)
    )
    #place(
      top + left,
      dx: 258pt,
      dy: 47pt,
      rect(height: 11pt, width: 17pt)
    )
    #place(
      top + left,
      dx: 0pt,
      dy: 0pt,
      path(
        tip: stealth,
        toe: stealth,
        (265pt, 47pt),
        ((315pt, 32pt), (-20pt, -2pt), (20pt, -2pt)),
        (372pt, 47pt),
      )
    )
    #place(
      top + left,
      dx: 372pt,
      dy: 47pt,
      rect(height: 11pt, width: 7pt)
    )
    #place(
      top + left,
      dx: 315pt,
      dy: 20pt,
      [lowercase x]
    )
    #place(
      top + left,
      dx: 355pt,
      dy: 80pt,
      align(center)[Data is displayed \ in ASCII with a "." \
      in the position of \
      non-graphic \
      characters]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 190pt,
      [current CPU state]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 240pt,
      [trace 5 steps from current CPU state]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (360pt, 335pt), end: (332pt, 325pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 370pt,
      dy: 328pt,
      [automatic breakpoint]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 330pt,
      [trace without listing intermediate states]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 365pt,
      [CPU state at end of U5]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 415pt,
      [run program from current PC until completion (in real-time)]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 435pt,
      [breakpoint at 116H, caused by executing RST 7 in machine code]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 450pt,
      [CPU state at end of program]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 495pt,
      [examine and change program counter]
    )
  ],
)[
`-`#text(fill: ui-fill)[`D119`↵] \
`

0119 02 00 04 03 05 06 01 .......
0120 05 11 00 22 21 00 02 7E EB 77 13 23 EB 0B 78 B1 ..."!..~.W.#..X.
0130 C2 27 01 C3 03 29 00 00 00 00 00 00 00 00 00 00 .'.....)........
0140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0150 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0170 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0180 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0190 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
01A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
01B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
01C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................

-`#text(fill: ui-fill)[`X`↵] \
`
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=010D INX  H

-`#text(fill: ui-fill)[`T5`↵] \
`
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=010D INX  H
C0Z0M0E0I0 A=02 B=0800 D=0000 H=011A S=0100 P=010E DCR  B
C0Z0M0E0I0 A=02 B=0700 D=0000 H=011A S=0100 P=010F JNZ  0107
C0Z0M0E0I0 A=02 B=0700 D=0000 H=011A S=0100 P=0107 MOV  A,M
C0Z0M0E0I0 A=00 B=0700 D=0000 H=011A S=0100 P=0108 SUB  C*0109
-`#text(fill: ui-fill)[`U5`↵] \
`
C0Z1M0E0I0 A=00 B=0700 D=0000 H=011A S=0100 P=0109 JNC  010D*0108
-`#text(fill: ui-fill)[`X`↵] \
`
C0Z0M0E0I0 A=04 B=0600 D=0000 H=011B S=0100 P=0108 SUB  C

-`#text(fill: ui-fill)[`G`↵] \

`*0116
-`#text(fill: ui-fill)[`X`↵] \
`
C0Z1M0E0I0 A=00 B=0000 D=0000 H=0121 S=0100 P=0116 RST  07

-`#text(fill: ui-fill)[`XP`↵] \
`P=0116 `#text(fill: ui-fill)[`100`↵] \
`-`#text(fill: ui-fill)[`X`↵] \
`
C0Z1M0E0I0 A=00 B=0000 D=0000 H=0121 S=0100 P=0100 MVI  B,08

`
]
#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 50pt,
      dy: -2pt,
      [trace 10 (hexadecimal) steps]
    )
    #place(
      top + left,
      dx: 72pt,
      dy: 71pt,
      rect(height: 11pt, width: 12pt)
    )
    #place(
      top + left,
      dx: 111pt,
      dy: 71pt,
      rect(height: 11pt, width: 12pt)
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (89pt, 22pt), end: (84pt, 71pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 70pt,
      dy: 12pt,
      [first data element]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (170pt, 22pt), end: (123pt, 71pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 170pt,
      dy: 12pt,
      [current largest value]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (370pt, 52pt), end: (318pt, 77pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 350pt,
      dy: 42pt,
      align(center)[subtract for comparison \ A < C]
    )
    #place(
      top + left,
      dx: 0pt,
      [
        #line(start: (370pt, 95pt), end: (318pt, 95pt), tip: stealth)
        #line(start: (370pt, 125pt), end: (370pt, -6pt))
        #line(start: (-80pt, 0pt), end: (80pt, 0pt), tip: bar, toe: bar)
      ]
    )
    #place(
      top + left,
      dx: 305pt,
      dy: 230pt,
      block(width: 140pt)[
        Program should have moved the value from A into C since A > C. Since this
        case was not executed, it appears that the JNC should have been a JC
        instruction
      ]
    )
    #place(
      top + left,
      dx: 75pt,
      dy: 225pt,
      block(width: 140pt)[
        Insert a "hot patch" into the machine code to change the JNC to JC
      ]
    )
    #place(
      top + left,
      dx: 55pt,
      dy: 255pt,
      block(width: 140pt)[
        stop DDT so that a version of the patched program can be saved
      ]
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 284pt,
      [program resides on first page, so save 1 page]
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 300pt,
      [restart DDT with the saved memory image \ to continue testing]
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 370pt,
      [list some code]
    )
    #place(
      top + left,
      dx: 150pt,
      dy: 440pt,
      [previous patch is present in SCAN.COM]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (145pt, 447pt), end: (95pt, 460pt), tip: stealth)
    )
  ],
)[
`-`#text(fill: ui-fill)[`T10`↵] \
`
C0Z1M0E0I0 A=00 B=0000 D=0000 H=0121 S=0100 P=0100 MVI  B,08
C0Z1M0E0I0 A=00 B=0800 D=0000 H=0121 S=0100 P=0102 MVI  C,00
C0Z1M0E0I0 A=00 B=0800 D=0000 H=0121 S=0100 P=0104 LXI  H,0119
C0Z1M0E0I0 A=00 B=0800 D=0000 H=0119 S=0100 P=0107 MOV  A,M
C0Z1M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=0108 SUB  C
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=0109 JNC  010D
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=010D INX  H
C0Z0M0E0I0 A=02 B=0800 D=0000 H=011A S=0100 P=010E DCR  B
C0Z0M0E0I0 A=02 B=0700 D=0000 H=011A S=0100 P=010F JNZ  0107
C0Z0M0E0I0 A=02 B=0700 D=0000 H=011A S=0100 P=0107 MOV  A,M
C0Z0M0E0I0 A=00 B=0700 D=0000 H=011A S=0100 P=0108 SUB  C
C0Z1M0E0I0 A=00 B=0700 D=0000 H=011A S=0100 P=0109 JNC  010D
C0Z1M0E0I0 A=00 B=0700 D=0000 H=011A S=0100 P=010D INX  H
C0Z1M0E0I0 A=00 B=0700 D=0000 H=011B S=0100 P=010E DCR  B
C0Z0M0E0I0 A=00 B=0600 D=0000 H=011B S=0100 P=010F JNZ  0107
C0Z0M0E0I0 A=00 B=0600 D=0000 H=011B S=0100 P=0107 MOV  A,M*0108

`
`-`#text(fill: ui-fill)[`A109`↵] \
`-`#text(fill: ui-fill)[`JC 10D`↵] \
`010C`#text(fill: ui-fill)[↵] \
`-`#text(fill: ui-fill)[`G0`↵] \
`A>`#text(fill: ui-fill)[`SAVE 1 SCAN.COM`↵] \
`A>`#text(fill: ui-fill)[`DDT SCAN.COM`↵] \
`
DDT VERS 2.2
NEXT PC
0200 0100

-`#text(fill: ui-fill)[`L100`↵] \
`
  0100  MVI  B,08
  0102  MVI  C,00
  0104  LXI  H,0119
  0107  MOV  A,M
  0108  SUB  C
  0109  JC   010D
  010C  MOV  C,A
  010D  INX  H
  010E  DCR  B
  010F  JNZ  0107
  0112  MOV  A,C

`
`-`#text(fill: ui-fill)[`XP`↵] \
`P=0100 `#text(fill: ui-fill)[↵] \

]

#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 50pt,
      dy: -2pt,
      [trace to see how patched version operates]
    )
    #place(
      top + left,
      dx: 72pt,
      dy: 71pt,
      rect(height: 11pt, width: 12pt)
    )
    #place(
      top + left,
      dx: 111pt,
      dy: 107pt,
      rect(height: 11pt, width: 12pt)
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (80pt, 82pt), end: (110pt, 107pt), tip: triangle, stroke: 2pt)
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (170pt, 22pt), end: (123pt, 107pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 170pt,
      dy: 12pt,
      [data is moved from A to C]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (305pt, 220pt), end: (332pt, 212pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 210pt,
      dy: 215pt,
      [breakpoint after 16 steps]
    )
    #place(
      top + left,
      dx: 50pt,
      dy: 265pt,
      [run from current PC and breakpoint at 108H]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (78pt, 290pt), end: (80pt, 305pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 285pt,
      [next data item]
    )
    #place(
      top + left,
      dx: 110pt,
      dy: 325pt,
      [single step for a few cycles]
    )
    #place(
      top + left,
      dx: 40pt,
      dy: 442pt,
      [run to completion]
    )
    #place(
      top + left,
      dx: 60pt,
      dy: 505pt,
      [look at the value of "LARGE"]
    )
    #place(
      top + left,
      dx: 100pt,
      dy: 520pt,
      [Wrong value!]
    )
  ],
)[
`-`#text(fill: ui-fill)[`T10`↵] \
`
C0Z0M0E0I0 A=00 B=0000 D=0000 H=0000 S=0100 P=0100 MVI B,08
C0Z0M0E0I0 A=00 B=0800 D=0000 H=0000 S=0100 P=0102 MVI C,00
C0Z0M0E0I0 A=00 B=0800 D=0000 H=0000 S=0100 P=0104 LXI H,0119
C0Z0M0E0I0 A=00 B=0800 D=0000 H=0119 S=0100 P=0107 MOV A,M
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=0108 SUB C
C0Z0M0E0I1 A=02 B=0800 D=0000 H=0119 S=0100 P=0109 JC  010D
C0Z0M0E0I1 A=02 B=0800 D=0000 H=0119 S=0100 P=010C MOV C,A
C0Z0M0E0I1 A=02 B=0802 D=0000 H=0119 S=0100 P=010D INX H
C0Z0M0E0I1 A=02 B=0802 D=0000 H=011A S=0100 P=010E DCR B
C0Z0M0E0I1 A=02 B=0702 D=0000 H=011A S=0100 P=010F JNZ 0107
C0Z0M0E0I1 A=02 B=0702 D=0000 H=011A S=0100 P=0107 MOV A,M
C0Z0M0E0I1 A=00 B=0702 D=0000 H=011A S=0100 P=0108 SUB C
C1Z0M1E0I0 A=FE B=0702 D=0000 H=011A S=0100 P=0109 JC  010D
C1Z0M1E0I0 A=FE B=0702 D=0000 H=011A S=0100 P=010D INX H
C1Z0M1E0I0 A=FE B=0702 D=0000 H=011B S=0100 P=010E DCR B
C1Z0M0E1I1 A=FE B=0602 D=0000 H=011B S=0100 P=010F JNZ 0107*0107

-`#text(fill: ui-fill)[`X`↵] \
`C1Z0M0E1I1 A=FE B=0602 D=0000 H=011B S=0100 P=0107 MOV A,M

-`#text(fill: ui-fill)[`G,108`↵] \
`*0108` \
`-`#text(fill: ui-fill)[`X`↵] \
`C1Z0M0E1I1 A=04 B=0602 D=0000 H=011B S=0100 P=0108 SUB C

-`#text(fill: ui-fill)[`T`↵] \
`C1Z0M0E1I1 A=04 B=0602 D=0000 H=011B S=0100 P=0108 SUB C*0109

-`#text(fill: ui-fill)[`T`↵] \
`C0Z0M0E0I1 A=02 B=0602 D=0000 H=011B S=0100 P=0109 JC 010D*010C

-`#text(fill: ui-fill)[`X`↵] \
`C0Z0M0E0I1 A=02 B=0602 D=0000 H=011B S=0100 P=010C MOV C,A

-`#text(fill: ui-fill)[`G`↵] \
`*0116` \
`-`#text(fill: ui-fill)[`X`↵] \
`C0Z1M0E1I1 A=03 B=0003 D=0000 H=0121 S=0100 P=0116 RST 07

-`#text(fill: ui-fill)[`S121`↵] \
` 0121   03  `#text(fill: ui-fill)[↵] \
` 0122   52  `#text(fill: ui-fill)[`.`↵] \

]
#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 150pt,
      dy: 145pt,
      [Review the code]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (135pt, 20pt), end: (135pt, 310pt), tip: bar, toe: bar)
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 330pt,
      [reset the PC]
    )
    #place(
      top + left,
      dx: 40pt,
      dy: 352pt,
      [single step, and watch data values]
    )
    #place(
      top + left,
      dx: 60pt,
      dy: 400pt,
      [count set]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (90pt, 410pt), end: (105pt, 428pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 122pt,
      dy: 440pt,
      ["largest" set]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (123pt, 448pt), end: (115pt, 465pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 200pt,
      dy: 480pt,
      [base address of data set]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (198pt, 487pt), end: (185pt, 505pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 100pt,
      dy: 520pt,
      [first data item brought to A]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (118pt, 531pt), end: (82pt, 542pt), tip: stealth)
    )
  ],
)[
`-`#text(fill: ui-fill)[`L100`↵] \
`
  0100  MVI  B,08
  0102  MVI  C,00
  0104  LXI  H,0119
  0107  MOV  A,M
  0108  SUB  C
  0109  JC   010D
  010C  MOV  C,A
  010D  INX  H
  010E  DCR  B
  010F  JNZ  0107
  0112  MOV  A,C
-`#text(fill: ui-fill)[`L`↵] \
`
  0113  STA  0121
  0116  RST  07
  0117  NOP
  0118  NOP
  0119  STAX B
  011A  NOP
  011B  INR  B
  011C  INX  B
  011D  DCR  B
  011E  MVI  B,01
  0120  DCR  B
-`#text(fill: ui-fill)[`XP`↵] \
`
P=0116 `#text(fill: ui-fill)[`100`↵] \
`-`#text(fill: ui-fill)[`T`↵] \
`
C0Z1M0E1I1 A=03 B=0003 D=0000 H=0121 S=0100 P=0100 MVI B,08*0102

-`#text(fill: ui-fill)[`T`↵] \
`
C0Z1M0E1I1 A=03 B=0803 D=0000 H=0121 S=0100 P=0102 MVI C,00*0104
-`#text(fill: ui-fill)[`T`↵] \
`
C0Z1M0E1I1 A=03 B=0800 D=0000 H=0121 S=0100 P=0104 LXI H,0119*0107
-`#text(fill: ui-fill)[`T`↵] \
`
C0Z1M0E1I1 A=03 B=0800 D=0000 H=0119 S=0100 P=0107 MOV A,M*0108
-`#text(fill: ui-fill)[`T`↵] \
`
C0Z1M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=0108 SUB  C*0109`
]

#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 150pt,
      dy: 75pt,
      [first data item moved to C correctly]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (145pt, 80pt), end: (115pt, 100pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 235pt,
      [second data item brought to A]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (115pt, 240pt), end: (78pt, 260pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 280pt,
      [subtract destroys data value which was loaded!]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (115pt, 285pt), end: (78pt, 300pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 180pt,
      dy: 425pt,
      [This should have been a CMP so that register A \ would not be changed]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (175pt, 430pt), end: (120pt, 430pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 90pt,
      dy: 522pt,
      [hot patch at 108H changes SUB to CMP]
    )
    #place(
      top + left,
      dx: 90pt,
      dy: 547pt,
      [stop DDT for Save]
    )
    #place(
      top + left,
      dx: 120pt,
      dy: 565pt,
      [save memory image]
    )
  ],
)[
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=0109 JC   010D*010C
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I0 A=02 B=0800 D=0000 H=0119 S=0100 P=010C MOV  C,A*010D
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I1 A=02 B=0802 D=0000 H=0119 S=0100 P=010D INX H*010E
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I1 A=02 B=0802 D=0000 H=011A S=0100 P=010E DCR B*010F
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I1 A=02 B=0702 D=0000 H=011A S=0100 P=010F JNZ 0107*0107
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I1 A=02 B=0702 D=0000 H=011A S=0100 P=0107 MOV A,M*0108
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C0Z0M0E0I1 A=00 B=0702 D=0000 H=011A S=0100 P=0108 SUB C*0109
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C1Z0M1E0I0 A=FE B=0702 D=0000 H=011A S=0100 P=0109 JC 010D*010D
```
`-`#text(fill: ui-fill)[`T`↵] \
```
C1Z0M1E0I0 A=FE B=0702 D=0000 H=011A S=0100 P=010D INX H*010E
```
`-`#text(fill: ui-fill)[`L100`↵] \
```
 0100   MVI        B,08
 0102   MVI        C,00
 0104   LXI        H,0119
 0107   MOV        A,M
 0108   SUB        C
 0109   JC         010D
 010C   MOV        C,A
 010D   INX        H
 010E   DCR        B
 010F   JNZ        0107
 0112   MOV        A,C
```
`-`#text(fill: ui-fill)[`A108`↵] \
`0108 `#text(fill: ui-fill)[`CMP C`↵] \
`0109 `#text(fill: ui-fill)[↵] \
`-`#text(fill: ui-fill)[`G0`↵] \
`A>`#text(fill: ui-fill)[`SAVE 1 SCAN.COM`↵] \
]

#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 100pt,
      dy: 0pt,
      [restart DDT]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (145pt, 100pt), end: (145pt, 170pt), tip: bar, toe: bar)
    )
    #place(
      top + left,
      dx: 160pt,
      dy: 115pt,
      align(center)[look at code to see if it was properly loaded \ 
      (long typeout aborted with rubout)]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 185pt,
      [run from 100H to completion]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 235pt,
      [look at Carry (accidental typo)]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 265pt,
      [look at CPU state]
    )
    #place(
      top + left,
      dx: 90pt,
      dy: 305pt,
      [look at "LARGE" -- it appears to be correct]
    )
    #place(
      top + left,
      dx: 90pt,
      dy: 360pt,
      [stop DDT]
    )
    #place(
      top + left,
      dx: 140pt,
      dy: 370pt,
      [Re-edit the source program, and make both changes]
    )
    #place(
      top + left,
      dx: 96pt,
      dy: 428pt,
      rect(height: 13pt, width: 13pt, radius: 6pt)
    )
    #place(
      top + left,
      dx: 66pt,
      dy: 428pt,
      rect(height: 13pt, width: 13pt, radius: 6pt)
    )
    #place(
      top + left,
      dx: 81pt,
      dy: 479pt,
      rect(height: 13pt, width: 10pt, radius: 6pt)
    )
    #place(
      top + left,
      dx: 62pt,
      dy: 479pt,
      rect(height: 13pt, width: 10pt, radius: 6pt)
    )
    #place(
      top + left,
      dx: 100pt,
      dy: 400pt,
      [CTRL-Z]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (110pt, 410pt), end: (102pt, 428pt), tip: stealth)
    )
  ],
)[
`A>`#text(fill: ui-fill)[`DDT SCAN.COM`↵] \
```
DDT VERS 2.2
NEXT PC
0200 0100
```
`-`#text(fill: ui-fill)[`XP`↵] \
`P=0100 `#text(fill: ui-fill)[↵] \
`-`#text(fill: ui-fill)[`L116`↵] \
```
 0116   RST        07
 0117   NOP
 0118   NOP
 0119   STAX       B
 011A   NOP
```
#text(fill: ui-fill)[⌫] \
`-`#text(fill: ui-fill)[`G,116`↵] \
```

*0116
```
`-`#text(fill: ui-fill)[`XC`↵] \
`C1 `#text(fill: ui-fill)[↵] \
`-`#text(fill: ui-fill)[`X`↵] \
```
C1Z1M0E1I1 A=06 B=0006 D=0000 H=0121 S=0100 P=0116 RST 07
```
`-`#text(fill: ui-fill)[`S121`↵] \
` 0121   06  `#text(fill: ui-fill)[↵] \
` 0122   00  `#text(fill: ui-fill)[↵] \
` 0123   22  `#text(fill: ui-fill)[`.`↵] \
`-`#text(fill: ui-fill)[`G0`↵] \
`A>`#text(fill: ui-fill)[`ED SCAN.ASM`↵] \
`     : *`#text(fill: ui-fill)[`NSUB`↵] \
`    7: *`#text(fill: ui-fill)[`0LT`↵] \
`    7:                   SUB     C           ;LARGER VALUE IN C?` \
`    7: *`#text(fill: ui-fill)[`SSUB`^Z`CMP`^Z`0LT`↵] \
`    7:                   CMP     C           ;LARGER VALUE IN C?` \
`    7: *`#text(fill: ui-fill)[↵] \
`    8:                   JNC     NFOUND      ;JUMP IF LARGER VALUE NOT FOUND` \
`    8: *`#text(fill: ui-fill)[`SNC`^Z`C`^Z`0LT`↵] \
`    8:                   JC      NFOUND      ;JUMP IF LARGER VALUE NOT FOUND` \
`    8: *`#text(fill: ui-fill)[`E`↵] \
\
]



#pagebreak()

#sample-stack(
  commentary: [
    #place(
      top + left,
      dx: 180pt,
      dy: 0pt,
      align(center)[Re-assemble. Selection source from disk A \ hex to disk A \ print to Z (selects no file)]
    )
    #place(
      top + left,
      dx: 180pt,
      dy: 70pt,
      [Re-run debugger to check changes]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 140pt,
      [check to ensure end is still at 116H]
    )
    #place(
      top + left,
      dx: 20pt,
      dy: 215pt,
      [(rubout)]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 230pt,
      [Go from beginning with breakpoint at end]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 250pt,
      [breakpoint reached]
    )
    #place(
      top + left,
      dx: 80pt,
      dy: 267pt,
      [look at "LARGE"]
    )
    #place(
      top + left,
      dx: 26pt,
      dy: 289pt,
      rect(height: 13pt, width: 14pt, radius: 6pt)
    )
    #place(
      top + left,
      dx: 40pt,
      dy: 328pt,
      [(rubout) abort long typeout]
    )
    #place(
      top + left,
      dx: 70pt,
      dy: 278pt,
      [correct value computed]
    )
    #place(
      top + left,
      dx: 0pt,
      line(start: (68pt, 285pt), end: (35pt, 289pt), tip: stealth)
    )
    #place(
      top + left,
      dx: 40pt,
      dy: 345pt,
      [stop DDT, debug session complete]
    )
  ],
)[
`A>`#text(fill: ui-fill)[`ASM SCAN.AAZ`↵] \
```
CP/M ASSEMBLER - VER 2.0
0122
002H USE FACTOR
END OF ASSEMBLY

```
`A>`#text(fill: ui-fill)[`DDT SCAN.HEX`↵] \
```

DDT VERS 2.2
NEXT PC
0121 0000

```
`-`#text(fill: ui-fill)[`L116`↵] \
```
 0116   JMP        0000
 0119   STAX       B
 011A   NOP
 011B   INR        B
```
#text(fill: ui-fill)[⌫] \
`-`#text(fill: ui-fill)[`G100,116`↵] \
```
*0116
```
`-`#text(fill: ui-fill)[`D121`↵] \
```
0121 06 00 22 21 00 02 7E EB 77 13 23 EB 0B 78 B1 .. '!... W .#..X.
0130 C2 27 01 C3 03 29 00 00 00 00 00 00 00 00 00 00 .'...)........
0140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ..............
```
#text(fill: ui-fill)[⌫] \
`-`#text(fill: ui-fill)[`G0`↵] \
\
]


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

- #link("http://cpm.z80.de/randyfiles/DRI/DDT.pdf")[_CP/M Dynamic Debugging Tool (DDT) User's Guide_ (pdf)]

The contents of the manual were edited using the #link("https://Typst.app/")[Typst.app] site.


== License

The source documentation is under a license granted by the owner
of the Digital Research intellectual property 
in an email available at #link("http://cpm.z80.de/license.html").

The #zcim-project edition is under the Creative Commons Attribution 4.0 International license. #link("https://creativecommons.org/licenses/by/4.0/")[*CC BY 4.0*].


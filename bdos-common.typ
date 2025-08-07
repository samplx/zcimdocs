
#let default-caption-location = bottom
#let bdos-entry-caption-location = top

// list of all possible flavors (CP/M versions)
#let all-flavors = ("1975", "1.3", "1.4", "2.0", "2.2", "3.0", "3.0nb", "3.0b")
// list of flavors for the "supported" format
#let supported-flavors = ("1975", "1.3", "1.4", "2.0", "2.2", "3.0nb", "3.0b")

#let all-versions = (name: "All versions", members: all-flavors)
#let cpm1975-only = (name: "CP/M 1975 version only", members: ("1975"))
#let cpm1-only = (name: "CP/M 1 only", members: ("1", "1975", "1.3", "1.4"))
#let cpm1x-only = (name: "CP/M 1.x only", members: ("1", "1.3", "1.4"))
#let cpm1x-and-later = (name: "CP/M 1.3 and later", members: ("1", "1.3", "1.4", "2.0", "2.2", "3.0", "3.0b", "3.0nb"))
#let cpm2-only = (name: "CP/M 2 only", members: ("2", "2.0", "2.2"))
#let cpm2-and-later = (name: "CP/M 2 and later", members: ("2", "2.0", "2.2", "3.0", "3.0b", "3.0nb"))
#let cpm22-and-before = (name: "CP/M 1 and CP/M 2", members: ("2.0", "2.2", "1975", "1.3", "1.4"))
#let cpm22-and-later = (name: "CP/M 2.2 and later", members: ("2.2", "3.0", "3.0nb", "3.0b"))
#let cpm3-only = (name: "CP/M 3 only", members: ("3.0", "3.0nb", "3.0b"))
#let cpm3-banked-only = (name: "CP/M 3 banked only", members: ("3.0", "3.0b"))
#let cpm-post-1975 = (name: "CP/M 1, 2 or 3, but not 1975", members: ("1.3", "1.4", "2.0", "2.2", "3.0", "3.0nb", "3.0b"))
#let error-color = red
#let default-depth = 2
#let default-format = "standard"
#let include-tests = true

#let cpm-version-name(flavor) = {
  if flavor == "1975" {
    [CP/M from 1975]
  } else if flavor == "1.3" {
    [CP/M 1.3]
  } else if flavor == "1.4" {
    [CP/M 1.4]
  } else if flavor == "1" {
    [CP/M 1.4]
  } else if flavor == "2" {
    [CP/M 2]
  } else if flavor == "2.0" {
    [CP/M 2.0]
  } else if flavor == "2.2" {
    [CP/M 2.2]
  } else if flavor == "3.0nb" {
    [CP/M 3 (CP/M Plus) non-banked memory system]
  } else if flavor == "3.0" {
    [CP/M 3 (CP/M Plus)]
  } else if flavor == "3.0b" {
    [CP/M 3 (CP/M Plus) banked memory system]
  } else {
    ["unexpected version: " #flavor]
  }
}

// formats: basic, detailed, standard, summary
//    basic: just the caption in a table row
//    supported-basic: like basic, but only if supported
//    detailed: all of the information available
//    standard: most of the information in a table with a caption
//    summary: func#, args, return value in a table row
//    supported: func#, caption, checkboxes in a table
//    supported-summary: like summary, but only if supported

#let create-bdos-entry(
  c,
  caption,
  flavor,
  e: none,
  de: none,
  return-a: none,
  return-hl: none,
  return-other: none,
  return-h: none,
  plm: none,
  perFlavor: (),
  globals: (),
  supported: all-versions,
  format: default-format,
  depth: default-depth,
  content
) = {
  let c_str = str(c)
  let c_hex = upper(str(c, base: 16))
  if c_hex.len() < 2 {
    c_hex = "0" + c_hex
  }
  c_hex = c_hex + "H"
  let prefix = "Function " + c_str
  let children = ()
  let is_supported = (flavor == "spec") or supported.members.contains(flavor)
  if (format == "detailed") or (is_supported and format == "standard") {
    if not is_supported {
      children.push(table.cell(align: left)[*Warning:*])
      children.push(text(fill: error-color)[*Not* supported on #cpm-version-name(flavor)])
    }
    children.push(table.cell(align: left)[*Entry Parameters:*])
    children.push([])
    children.push([Register `C`:])
    children.push([#raw(c_str) = #raw(c_hex)])
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
    if plm != none and cpm1-only.members.contains(flavor) {
      children.push(table.cell(align: left)[*Typical PL/M Call:*])
      children.push([#plm])
    }
  } else if format == "basic" or format == "supported-basic" {
    if is_supported {
      children.push(raw(c_str))
      children.push(caption)
    } else if format == "basic" {
      children.push(raw(c_str))
      children.push([
        #text(fill: error-color, caption)†
      ])
    }
  } else if format == "summary" or format == "supported-summary" {
    if is_supported {
      children.push(raw(c_str))
      children.push(caption)
      let param = []
      if e != none {
        param = [*`E`*: #e]
      } else if de != none {
        param = [*`DE`*: #de]
      } else {
        param = [*none*]
      }
      let result = none
      if return-a != none {
        result = [*`A`*: #return-a]
        if return-h != none and flavor == "3.0" {
          result += [ \ *`H`*: #return-h]
        }
      } else if return-hl != none {
        result = [*`HL`*: #return-hl]
      }
      if return-other != none and result == none {
        result = return-other
      }
      if result == none {
        result = [*none*]
      }
      children.push(param)
      children.push(result)
    } else if format != "supported-summary" {
      children.push(raw(c_str))
      children.push(caption)
      children.push(table.cell(colspan: 2)[
        *Function is not supported*
      ])
    }
  } else if format == "supported" {
    children.push(raw(c_str))
    children.push(caption)
    for f in supported-flavors {
      if f in supported.members {
        children.push([✅])
      } else {
        children.push([🚫])
      }
    }
  }
  let flavorDetails = []
  if flavor in perFlavor {
    flavorDetails = block[
      In this *version*: #perFlavor.at(flavor)
    ]
    if flavor == "3.0" {
      if "3.0nb" not in supported {
        flavorDetails = block[
          Available in the *banked memory version only*.
        ] + flavorDetails
      } else if "3.0nb" in perFlavor {
        flavorDetails += block[
          In the *non-banked memory* version: #perFlavor.at("3.0nb")
        ]
      }
      if "3.0b" in perFlavor {
        flavorDetails += block[
          In the *banked memory* version: #perFlavor.at("3.0b")
        ]
      }
    }
  }
  if format == "detailed" {
    if plm != none and not cpm1-only.members.contains(flavor) {
      children.push(table.cell(align: left)[*Typical PL/M Call:*])
      children.push([#plm])
    }
    if globals.len() > 0 {
      children.push(table.cell(align: left)[*Global State:*])
      children.push([])
      for (v, s) in globals {
        children.push(raw(v))
        children.push(s)
      }
    }
  }
  if format == "detailed" or (format == "standard" and flavor == "spec") {
    flavorDetails = []
    children.push(table.cell(align: left)[*Versions supported:*])
    children.push([#supported.name])
    if perFlavor.len() > 0 {
      children.push(table.cell(align: left)[*Version Specific:*])
      children.push([])
      for (f, t) in perFlavor {
        children.push(cpm-version-name(f))
        children.push(t)
      }
    }
  }
  if format == "detailed" or format == "standard" {
    if children.len() > 0 {
      heading(depth: depth)[#caption]
      show figure.where(
        kind: table
      ): set figure.caption(position: bdos-entry-caption-location)
      align(center)[
        #figure(
          table(
            columns: (1fr, 2fr),
            align: (right, left),
            inset: 5pt,
            stroke: 0.1pt,
            ..children,        
          ),
          caption: [#text(weight: "bold", prefix): #caption],
          numbering: none
        )
      ]
      [
        #content
        #flavorDetails
      ]
      show figure.where(
        kind: table
      ): set figure.caption(position: default-caption-location)
    }
  } else if format == "basic" or format == "supported-basic" {
    if children.len() > 0 {
      box(
        table(
          columns: (25pt, 1fr),
          align: (right, left),
          inset: 4pt,
          stroke: none,
          ..children,        
        )
      )
    }
  } else if format == "summary" or format == "supported-summary" {
    if children.len() > 0 {
      box(
        table(
          columns: (25pt, 1fr, 2fr, 2fr),
          align: (center, left, left, left),
          inset: 4pt,
          stroke: 0.1pt,
          ..children,        
        )
      )
    }
  } else if format == "supported" {
    if children.len() > 0 {
      box(
        table(
          columns: (25pt, 4fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
          align: (center, left, center, center, center, center, center, center, center),
          inset: 5pt,
          stroke: 0.1pt,
          ..children,
        )
      )
    }
  } else {
    [no recognized format named: #format]
  }
}



#let bdos-function-00(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    0,
    [System Reset],
    flavor,
    format: format,
    depth: depth,
    return-other: [*Does not return*],
    plm: [`CALL MON1(0, 0)`],
    [
      The *System Reset* function returns control to the CP/M operating
      system at the CCP level.  The CCP re-initializes the disk
      subsystem by selecting and logging-in disk drive `A`.  This
      function has exactly the same effect as a jump to location `0000H` (`BOOT`).
    ]
  )
}


#let bdos-function-01(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    1,
    [Console Input],
    flavor,
    format: format,
    depth: depth,
    return-a: [ASCII Character],
    plm: [`I = MON2(1,O)`],
    [
      The *Console Input* function reads the next console character to
      register `A`.  Graphic characters, along with carriage return, line-feed,
      and back space (CTRL-H) are echoed to the console.  Tab
      characters, CTRL-I, move the cursor to the next tab stop.  A check
      is made for start/stop scroll, CTRL-S, and start/stop printer echo,
      CTRL-P.  The FDOS does not return to the calling program until a
      character has been typed, thus suspending execution if a
      character is not ready.
    ]
  )
}

#let bdos-function-02(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    2,
    [Console Output],
    flavor,
    format: format,
    depth: depth,
    e: [ASCII character to output],
    perFlavor: (
      "3.0": [Now with console redirection instead of IOBYTE],
    ),
    globals: (
      "console-column": "updated",
      "MultipleCommandBufferPage": "really long name"
    ),
    plm: [`CALL MON1(2, 'A')`],
    [
      The *Console Output* function sends the ASCII character from register `E`
      to the console device.  As in Function 1, tabs are expanded and checks are made
      for start/stop scroll and printer echo.      
    ]
  )
}

#let bdos-function-03(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    3,
    [Reader Input],
    flavor,
    format: format,
    depth: depth,
    return-a: [ASCII Character],
    plm: [`I = MON2(3, 0)`],
    [
      The *Reader Input* function reads the next character from the
      logical reader into register `A`.
      Control does not return until the character has been read.
    ]
  )
}

#let bdos-function-04(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    4,
    [Punch Output],
    flavor,
    format: format,
    depth: depth,
    e: [ASCII Character],
    plm: [`CALL MON1(4, 'B')`],
    [
      The *Punch Output* function sends the character from register `E` to
      the logical punch device.
    ]
  )
}

#let bdos-function-05(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    5,
    [List Output],
    flavor,
    format: format,
    depth: depth,
    e: [ASCII Character],
    plm: [`CALL MON1(5, 'C')`],
    [
      The *List Output* function sends the ASCII character in register `E`
      to the logical listing device.
    ]
  )
}

#let bdos-function-06-memory-size(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    6,
    [Memory Size],
    flavor,
    format: format,
    depth: depth,
    supported: cpm1-only,
    return-hl: [Base Address of the CCP],
    plm: [`A = MON3(6, 0)`],
    [
      The *Memory Size* function returns the base address of the
      Console Command Processor (CCP) in `HL`.
    ]
  )
}

#let bdos-function-06-console-io(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    6,
    [Direct Console #box[I/O]],
    flavor,
    format: format,
    depth: depth,
    supported: cpm2-and-later,
    e: [`0FFH` (input) or char (output)],
    return-a: [character or status],
    [
      *Direct Console I/O* is supported under CP/M for those specialized
      applications where basic console input and output are required.
      Use of this function should, in general, be avoided since it
      bypasses all of the CP/M normal control character functions (for example,
      CTRL-S and CTRL-P).  Programs that perform direct I/O
      through the BIOS under previous releases of CP/M, however, should
      be changed to use direct I/O under BDOS so that they can be fully
      supported under future releases of MP/M and CP/M.
      
      Upon entry to Function 6, register `E` either contains hexadecimal
      `0FFH`, denoting a console input request, or an ASCII character.  If
      the input value is `0FFH`, Function 6 returns `A` = `00` if no character
      is ready, otherwise `A` contains the next console input character.
      
      If the input value in `E` is not `0FFH`, Function 6 assumes that `E`
      contains a valid ASCII character that is sent to the console.
      
    ]
  )
}

#let bdos-function-07-iobyte(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    7,
    [Get IOBYTE],
    flavor,
    format: format,
    depth: depth,
    return-a: [IOBYTE value],
    supported: cpm22-and-before,
    plm: [`IOSTAT = MON2(7, 0)`],
    [
      The *Get IOBYTE* function returns the current value of IOBYTE in
      register `A`.
    ]
  )
}

#let bdos-function-07-auxin-status(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    7,
    [Auxiliary Input Status],
    flavor,
    format: format,
    depth: depth,
    return-a: [`0FFH` if a character is ready,\ `0` if not],
    supported: cpm3-only,
    [
      
    ]
  )
}

#let bdos-function-08-iobyte(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    8,
    [Set IOBYTE],
    flavor,
    format: format,
    depth: depth,
    supported: cpm22-and-before,
    e: [IOBYTE value],
    plm: [`CALL MON1(8, IOSTAT)`],
    [
      The *Set IOBYTE* function changes the IOBYTE value to that given
      in register `E`.
    ]
  )
}


#let bdos-function-08-auxout-status(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    8,
    [Auxiliary Output Status],
    flavor,
    format: format,
    depth: depth,
    return-a: [`0FFH` if a character is ready,\ `0` if not],
    supported: cpm3-only,
    [
      
    ]
  )
}


#let bdos-function-09(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    9,
    [Print String],
    flavor,
    format: format,
    depth: depth,
    de: [String Address],
    plm: [`CALL MON1(9, .'PRINT THIS$')`],
    [
      The *Print String* function sends the character string stored in
      memory at the location given by `DE` to the console device, until a
      '`$`' (`24H`) is encountered in the string.  Tabs are expanded as in Function
      2, and checks are made for start/stop scroll and printer echo.
    ]
  )
}

#let bdos-function-10(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    10,
    [Read Console Buffer],
    flavor,
    format: format,
    depth: depth,
    de: [Buffer Address],
    return-other: [Characters input are in the Buffer],
    plm: [`CALL MON1(10, .RDBUFF)`],
    [
      The *Read Buffer* functions reads a line of edited console input
      into a buffer addressed by registers `DE`.  Console input is
      terminated when either input buffer overflows or a carriage return
      or line-feed is typed.  The Read Buffer takes the form:
      #align(center)[
        #table(
          columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
          align: center,
          [`DE`:],
          [`+0`],
          [`+1`],
          [`+2`],
          [`+3`],
          [`+4`],
          [`+5`],
          [`+6`],
          [`+7`],
          [`+8`],
          […],
          [`+n`],
          [],
          [*mx*],
          [*nc*],
          [_c1_],
          [_c2_],
          [_c3_],
          [_c4_],
          [_c5_],
          [_c6_],
          [_c7_],
          […],
          [??],
        )
      ]
      
      where *m* is the maximum number of characters that the buffer will
      hold, 1 to 255, and *nc* is the number of characters read (set by
      FDOS upon return) followed by the characters read from the
      console.  If *$"nc" < "mx" $*, then uninitialized positions follow the
      last character, denoted by ?? in the above figure.  A number of
      control functions, summarized in @EditControlCharacters, are recognized during
      line editing.
      
      #figure(
        table(
          columns: (auto, auto),
          inset: 10pt,
          align: (center, left),
          table.header([*Character*], [*Meaning*]),
          [CTRL-C], [reboots when at beginning of line],
          [CTRL-E], [causes physical end of line],
          [CTRL-H], [backspaces one character position],
          [CTRL-J], [(line-feed) terminates input line],
          [CTRL-M], [(carriage return) terminates input line],
          [CTRL-R], [retypes the current line after new line],
          [CTRL-U], [removes current line],
          [CTRL-X], [Same as CTRL-U.],
          [#smallcaps[rubout/del]], [Deletes and echoes the last character typed at the console.]
        ),
        caption: [Edit Control Characters]
      ) <EditControlCharacters>
      
      
      The user should also note that certain functions that return the
      carriage to the leftmost position (for example, CTRL-X) do so only to the
      column position where the prompt ended.  In earlier releases, the
      carriage returned to the extreme left margin.  This convention
      makes operator data input and line correction more legible.      
    ]
  )
}

#let bdos-function-11(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    11,
    [Get Console Status],
    flavor,
    format: format,
    depth: depth,
    return-a: [`0FFH` if a character is ready, \ `0` if not],
    plm: [`I = MON2(11, 0)`],
    [
      The *Console Status* function checks to see if a character has been
      typed at the console.  If a character is ready, the value `0FFH` is
      returned in register `A`.  Otherwise a `00H` value is returned.
    ]
  )
}


#let bdos-function-12-lift-head(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    12,
    [Lift Head],
    flavor,
    format: format,
    depth: depth,
    return-a: [`00H`],
    return-hl: [`FCBDSK` variable address or `0`],
    supported: cpm1-only,
    plm: [`CALL MON2(12, 0)`],
    [
      
    ]
  )
}

#let bdos-function-12-version(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    12,
    [Version Number],
    flavor,
    format: format,
    depth: depth,
    return-hl: [Version Number],
    supported: cpm2-and-later,
    [
      Function 12 provides information that allows version independent
      programming.  A two-byte value is returned, with `H` = `00H`
      designating the CP/M release (`H` = `01` for MP/M) and `L` = `00` for
      all releases previous to 2.0.  CP/M 2.0 returns a hexadecimal `20`
      in register `L`, with subsequent version 2 releases in the
      hexadecimal range `21`, `22`, through `2F`.  Using Function 12, for
      example, the user can write application programs that provide
      both sequential and random access functions.
    ]
  )
}


#let bdos-function-13(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    13,
    [Reset Disk System],
    flavor,
    format: format,
    depth: depth,
    return-a: [`0FFH` if `$` file present, \ `0` if not],
    plm: [`CALL MON1(13, 0)`],
    [
      The *Reset Disk* function is used to programmatically restore the
      file system to a reset state where all disks are set to
      Read-Write.  See functions 28 and 29, only disk drive `A` is
      selected, and the default `DMA` address is reset to `BOOT+0080H`.
      This function can be used, for example, by an application program
      that requires a disk change without a system reboot.
      
      This function is normally called by the CCP after the system reset
      and before any other activity. If the CCP is not executed, this
      function must be called by what replaced it.
      
      In 1.x and 2.x version the return value depends upon the presence of a file
      with a name starting with a dollar-sign (`$`) on drive `A`.
      If such a file is present, a `0FFH` value is returned,
      otherwise a zero is returned. 
    ]
  )
}


#let bdos-function-14(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    14,
    [Select Disk],
    flavor,
    format: format,
    depth: depth,
    e: [Drive number: `0` for `A`, `1` for `B`, ... ],
    return-a: [`0` if successful, `0FFH` on error],
    plm: [`CALL MON1(14, 1)`],
    [
      The *Select Disk* function designates the disk drive named in register
      E as the default disk for subsequent file operations, with `E` = `0`
      for drive `A`, 1 for drive `B`, and so on through 15, corresponding to drive
      `P` in a full 16 drive system.  The drive is placed in an on-line
      status, which activates its directory until the next cold start,
      warm start, or disk system reset operation.  If the disk medium
      is changed while it is on-line, the drive automatically goes to
      a Read-Only status in a standard CP/M environment, see Function 28.
      FCBs that specify drive code zero (*DR* = `00H`) automatically reference the currently selected default drive.  Drive code
      values between 1 and 16 ignore the selected default
      drive and directly reference drives `A` through `P`.
    ]
  )
}


#let bdos-function-15(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    15,
    [Open File],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    globals: ("dirbuf": "contents updated"),
    plm: [`I = MON2(15, .FCB)`],
    [
      The *Open* File operation is used to activate a file that currently
      exists in the disk directory for the currently active user
      number.  The FDOS scans the referenced disk directory for a match
      in positions 1 through 14 of the FCB referenced by `DE` (byte *S1* is
      automatically zeroed) where an ASCII question mark '`?`' (`3FH`) matches
      any directory character in any of these positions.  Normally, no
      question marks are included, and bytes *EX* and *S2* of the FCB are
      zero.
      
      If a directory element is matched, the relevant directory
      information is copied into bytes *D0* through *Dn* of FCB, thus
      allowing access to the files through subsequent read and write
      operations.  The user should note that an existing file must not
      be accessed until a successful open operation is completed.  Upon
      return, the open function returns a directory code with the value
      `0` through `3` if the open was successful or `0FFH` (`255` decimal) if
      the file cannot be found.  If question marks occur in the FCB,
      the first matching FCB is activated.  Note that the current
      record, (*CR*) must be zeroed by the program if the file is to be
      accessed sequentially from the first record.
    ]
  )
}

#let bdos-function-16(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    16,
    [Close File],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    plm: [`I = MON2(16, .FCB)`],
    [
      The *Close* File function performs the inverse of the *Open* File
      function.  Given that the FCB addressed by `DE` has been previously
      activated through an *Open* or *Make* function,  the *Close* function
      permanently records the new FCB in the reference disk directory
      see functions 15 and 22.  The FCB matching process for the close
      is identical to the open function.  The directory code returned
      for a successful close operation is `0`, `1`, `2`, or `3`, while a `0FFH`
      (`255` decimal) is returned if the filename cannot be found in the
      directory.  A file need not be closed if only read operations
      have taken place.  If write operations have occurred, the close
      operation is necessary to record the new directory information
      permanently.
    ]
  )
}

#let bdos-function-17(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    17,
    [Search for First],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    plm: [`I = MON2(17, .FCB)`],
    [
      *Search for First* scans the directory for a match with the file given
      by the FCB addressed by `DE`.  The value `255` (hexadecimal `0FFH`) is
      returned if the file is not found; otherwise, `0`, `1`, `2`, or `3` is
      returned indicating the file is present.  When the file is found,
      the current DMA address is filled with the record containing the
      directory entry, and the relative starting position is $A *32$
      (that is, rotate the `A` register left 5 bits, or `ADD A` five times).
      Although not normally required for application programs, the
      directory information can be extracted from the buffer at this
      position.
      
      An ASCII question mark '`?`' (`63` decimal, `3F` hexadecimal) in any
      position from *F1* through *EX* matches the corresponding field of
      any directory entry on the default or auto-selected disk drive.
      If the *DR* field contains an ASCII question mark, the auto disk
      select function is disabled and the default disk is searched,
      with the search function returning any matched entry, allocated
      or free, belonging to any user number.  This latter function is
      not normally used by application programs, but it allows complete
      flexibility to scan all current directory values.  If the *DR*
      field is not a question mark, the *S2* byte is automatically zeroed.
    ]
  )
}

#let bdos-function-18(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    18,
    [Search for Next],
    flavor,
    format: format,
    depth: depth,
    return-a: [Directory Code],
    plm: [`I = MON2(18, .FCB)`],
    [
      The *Search for Next* function is similar to the *Search for First* function, except
      that the directory scan continues from the last matched entry.
      Similar to Function 17, Function 18 returns the decimal value `255`
      in `A` when no more directory items match.
    ]
  )
}

#let bdos-function-19(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    19,
    [Delete File],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    plm: [`I = MON2(19, .FCB)`],
    [
      The *Delete* File function removes files that match the FCB
      addressed by `DE`.  The filename and type may contain ambiguous
      references (that is, question marks in various positions), but the
      drive select code (*DR*) cannot be ambiguous, as in the *Search for First* and
      *Search for Next* functions.
      
      Function 19 returns a decimal `255` if the referenced file or files
      cannot be found; otherwise, a value in the range `0` to `3` returned.
    ]
  )
}

#let bdos-function-20(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    20,
    [Read Sequential],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    plm: [`I = MON2(20, .FCB)`],
    [
      Given that the FCB addressed by `DE` has been activated through an
      *Open* or *Make* function, the *Read Sequential* function reads the
      next 128-byte record from the file into memory at the current DMA
      address.  The record is read from position *CR* of the extent, and
      the *CR* field is automatically incremented to the next record
      position.  If the *CR* field overflows, the next logical extent is
      automatically opened and the *CR* field is reset to zero in
      preparation for the next read operation.  The value `00H` is
      returned in the `A` register if the read operation was successful,
      while a nonzero value is returned if no data exist at the next
      record position (for example, end-of-file occurs).
    ]
  )
}

#let bdos-function-21(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    21,
    [Write Sequential],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    plm: [`I = MON2(21, .FCB)`],
    [
      Given that the FCB addressed by `DE` has been activated through an
      *Open* or *Make* function, the *Write Sequential*
      function writes the 128-byte data record at the current DMA
      address to the file named by the FCB.  The record is placed at
      position *CR* of the file, and the *CR* field is automatically
      incremented to the next record position.  If the *CR* field
      overflows, the next logical extent is automatically opened and
      the *CR* field is reset to zero in preparation for the next write
      operation.  Write operations can take place into an existing
      file, in which case, newly written records overlay those that
      already exist in the file.  Register `A` = `00H` upon return from a
      successful write operation, while a nonzero value indicates an
      unsuccessful write caused by a full disk.
    ]
  )
}

#let bdos-function-22(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    22,
    [Make File],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    plm: [`I = MON2(22, .FCB)`],
    [
      The *Make* File operation is similar to the *Open* File operation
      except that the FCB must name a file that does not exist in the
      currently referenced disk directory (that is, the one named
      explicitly by a nonzero *DR* code or the default disk if *DR* is
      zero).  The FDOS creates the file and initializes both the
      directory and main memory value to an empty file.  The programmer
      must ensure that no duplicate filenames occur, and a preceding
      delete operation is sufficient if there is any possibility of
      duplication.  Upon return, register `A` = `0`, `1`, `2`, or `3` if the
      operation was successful and `0FFH` (`255` decimal) if no more
      directory space is available.  The Make function has the side
      effect of activating the FCB and thus a subsequent open is not
      necessary.
    ]
  )
}

#let bdos-function-23(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    23,
    [Rename File],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    perFlavor: (
      "3.0": [`H` with be `0` if the file was not found, a non-zero
      value indicates a hardware error code.]
    ),
    plm: [`I = MON2(23, .FCB)`],
    [
      The *Rename* function uses the FCB addressed by `DE` to change all
      occurrences of the file named in the first 16 bytes to the file
      named in the second 16 bytes.  The drive code *DR* at position 0 is
      used to select the drive, while the drive code for the new
      filename at position 16 of the FCB is assumed to be zero.  Upon
      return, register `A` is set to a value between `0` and `3` if the
      rename was successful and `0FFH` (`255` decimal) if the first
      filename could not be found in the directory scan.
    ]
  )
}

#let bdos-function-24(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    24,
    [Return Login Vector],
    flavor,
    format: format,
    depth: depth,
    return-hl: [Log-in Vector],
    plm: [`I = MON2(24, 0)`],
    [
      The log-in vector value returned by CP/M is a 16-bit value in `HL`, where the
      least significant bit of L corresponds to the first drive `A` and
      the high-order bit of `H` corresponds to the sixteenth drive,
      labeled `P`.  A `0` bit indicates that the drive is not on-line,
      while a `1` bit marks a drive that is actively on-line as a result
      of an explicit disk drive selection or an implicit drive select
      caused by a file operation that specified a nonzero *DR* field.
      The user should note that compatibility is maintained with
      earlier releases, because registers `A` and `L` contain the same values
      upon return.
    ]
  )
}

#let bdos-function-25(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    25,
    [Return Current Disk],
    flavor,
    format: format,
    depth: depth,
    return-a: [Current Disk. `0` for `A`, ... `15` for `P`],
    plm: [`I = MON2(25, 0))`],
    [
      Function 25 returns the currently selected default disk number in
      register `A`.  The disk numbers range from `0` through `15`
      corresponding to drives `A` through `P`.
    ]
  )
}

#let bdos-function-26(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    26,
    [Set DMA Address],
    flavor,
    format: format,
    depth: depth,
    de: [DMA Address],
    plm: [`CALL MON1(26, 2000H)`],
    [
      DMA is an acronym for Direct Memory Address, which is often used
      in connection with disk controllers that directly access the
      memory of the mainframe computer to transfer data to and from the
      disk subsystem.  Although many computer systems use non-DMA
      access (that is, the data is transferred through programmed I/O
      operations), the DMA address has, in CP/M, come to mean the
      address at which the 128-byte data record resides before a disk
      write and after a disk read.  Upon cold start, warm start, or
      disk system reset, the DMA address is automatically set to
      `BOOT+0080H`.  The *Set DMA* function can be used to change
      this default value to address another area of memory where the
      data records reside.  Thus, the DMA address becomes the value
      specified by `DE` until it is changed by a subsequent *Set DMA*
      function, cold start, warm start, or disk system reset.
    ]
  )
}

#let bdos-function-27(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    27,
    [Get Addr(`ALLOC`)],
    flavor,
    format: format,
    depth: depth,
    return-hl: [`ALLOC` Address],
    plm: [`A = MON3(27, 0)`],
    [
      An allocation vector (`ALLOC`) is maintained in main memory for each
      on-line disk drive.  Various system programs use the information
      provided by the allocation vector to determine the amount of
      remaining storage (see the `STAT` program).  Function 27 returns
      the base address of the allocation vector for the currently
      selected disk drive.  However, the allocation information might be
      invalid if the selected disk has been marked Read-Only.  
      This function is not normally used by application programs.
    ]
  )
}

#let bdos-function-28(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    28,
    [Write Protect Disk],
    flavor,
    format: format,
    depth: depth,
    plm: [`CALL MON1(28, 0)`],
    supported: cpm1x-and-later,
    [
      The Write Protect Disk function provides temporary write
      protection for the currently selected disk.  Any attempt to write
      to the disk before the next cold or warm start operation produces
      the message:
      
      #pad(y: 2em)[`BDOS Err On `_d_`:R/O`]
    ]
  )
}

#let bdos-function-29(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    29,
    [Get R/O Vector],
    flavor,
    format: format,
    depth: depth,
    return-hl: [R/O Vector Value],
    plm: [`A = MON3(29, 0)`],
    supported: cpm1x-and-later,
    [
      Function 29 returns a bit vector in register pair `HL`, which
      indicates drives that have the temporary Read-Only bit set.  As
      in Function 24, the least significant bit corresponds to drive `A`,
      while the most significant bit corresponds to drive `P`.  The `R/O`
      bit is set either by an explicit call to Function 28 or by the
      automatic software mechanisms within CP/M that detect changed
      disks.
    ]
  )
}

#let bdos-function-30-echo(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    30,
    [Set Echo Mode],
    flavor,
    format: format,
    depth: depth,
    e: [0 for no echo, otherwise echo],
    supported: cpm1975-only,
    [
      This function is used to alter the behavior of function 1. When the echo flag
      is set, characters input will be echoed to the console.
    ]
  )
}


#let bdos-function-30-set-dir-dma(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    30,
    [Set DMA Address for Directory Operations],
    flavor,
    format: format,
    depth: depth,
    de: [DMA Address],
    plm: [`CALL MON1(30, 1000H)`],
    supported: cpm1x-only,
    [
      This function is used to change the DMA address used for directory operations.
    ]
  )
}

#let bdos-function-30-set-file-attr(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    30,
    [Set File Attributes],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    supported: cpm2-and-later,
    [
      The Set File Attributes function allows programmatic manipulation
      of permanent indicators attached to files.  In particular, the `R/O`
      and System attributes (`t1'` and `t2'`) can be set or reset.  The `DE`
      pair addresses an unambiguous filename with the appropriate
      attributes set or reset.  Function 30 searches for a match and
      changes the matched directory entry to contain the selected
      indicators.  Indicators `f1'` through `f4'` are not currently used,
      but may be useful for applications programs, since they are not
      involved in the matching process during file open and close
      operations.  Indicators `f5'` through `f8'` and `t3'` are reserved for
      future system expansion.
    ]
  )
}

#let bdos-function-31(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    31,
    [Get Addr(Disk Parameter Block)],
    flavor,
    format: format,
    depth: depth,
    return-hl: [*DPB* Address],
    supported: cpm2-and-later,
    [
      The address of the BIOS resident disk parameter block (*DPB*) is returned
      in `HL` as a result of this function call.  This address can be
      used for either of two purposes.  First, the disk parameter
      values can be extracted for display and space computation
      purposes, or transient programs can dynamically change the values
      of current disk parameters when the disk environment changes, if
      required.  Normally, application programs will not require this
      facility.
    ]
  )
}

#let bdos-function-32(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    32,
    [Set/Get User Code],
    flavor,
    format: format,
    depth: depth,
    e: [`0FFH` (get) or _User Code_ (set)],
    return-a: [Current code (get) or none (set)],
    supported: cpm2-and-later,
    [
      An application program can change or interrogate the currently
      active user number by calling Function 32.  If register `E` = `0FFH`,
      the value of the current user number is returned in register `A`,
      where the value is in the range of `0` to `15`.  If register `E` is not
      `0FFH`, the current user number is changed to the value of `E`,
      modulo 16.
    ]
  )
}

#let bdos-function-33(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    33,
    [Read Random],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Return code (see details)],
    return-h: [Hardware error code],
    supported: cpm2-and-later,
    [
      The *Read Random* function is similar to the sequential file read
      operation of previous releases, except that the read operation
      takes place at a particular record number, selected by the 24-bit
      value constructed from the 3-byte field following the FCB (byte
      positions *R0* at 33, *R1* at 34, and *R3* at 35).  The user should
      note that the sequence of 24 bits is stored with least
      significant byte first (*R0*), middle byte next (*R1*), and high byte
      last (*R2*).  CP/M does not reference byte *R2*, except in computing
      the size of a file (Function 35).  Byte *R2* must be zero, however,
      since a nonzero value indicates overflow past the end of file.
      
      Thus, the *R0*, *R1* byte pair is treated as a double-byte, or word
      value, that contains the record to read.  This value ranges from
      `0` to `65535`, providing access to any particular record of the 8-
      megabyte file.  To process a file using random access, the base
      extent (extent `0`) must first be opened.  Although the base extent
      might or might not contain any allocated data, this ensures that the
      file is properly recorded in the directory and is visible in `DIR`
      requests.  The selected record number is then stored in the
      random record field (*R0*, *R1*), and the BDOS is called to read the
      record.
      
      Upon return from the call, register `A` either contains an error
      code, as listed below, or the value `00`, indicating the operation
      was successful.  In the latter case, the current DMA address
      contains the randomly accessed record.  Note that
      contrary to the sequential read operation, the record number is
      not advanced.  Thus, subsequent random read operations continue
      to read the same record.
      
      Upon each random read operation, the logical extent and current
      record values are automatically set.  Thus, the file can be
      sequentially read or written, starting from the current randomly
      accessed position.  However, note that, in this
      case, the last randomly read record will be reread as one
      switches from random mode to sequential read and the last record
      will be rewritten as one switches to a sequential write operation.
      The user can simply advance the random record
      position following each random read or write to obtain the effect
      of sequential I/O operation.
      
      Error codes returned in register `A` following a random read are
      listed below.
      
      / `01` : reading unwritten data
      
      / `02` : (not returned in random mode)
      
      / `03` : cannot close current extent
      
      / `04` : seek to unwritten extent
      
      / `05` : (not returned in read mode)
      
      / `06` : seek past physical end of disk
      
      / `09` : invalid FCB
      
      / `10` : media changed
      
      / `0FFH` : hardware error (on 3.x)
      
      Error codes `01` and `04` occur when a random read operation accesses
      a data block that has not been previously written or an extent
      that has not been created, which are equivalent conditions.
      Error code `03` does not normally occur under proper system
      operation.  If it does, it can be cleared by simply rereading or
      reopening extent zero as long as the disk is not physically write
      protected.  Error code `06` occurs whenever byte *R2* is nonzero
      under the current 2.0 release.  Normally, nonzero return codes
      can be treated as missing data, with zero return codes indicating
      operation complete.
    ]
  )
}

#let bdos-function-34(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    34,
    [Write Random],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Return code (see details)],
    return-h: [Hardware error code],
    supported: cpm2-and-later,
    [
      The *Write Random* operation is initiated similarly to the Read
      Random call, except that data is written to the disk from the
      current DMA address.  Further, if the disk extent or data block
      that is the target of the write has not yet been allocated, the
      allocation is performed before the write operation continues.  As
      in the Read Random operation, the random record number is not
      changed as a result of the write.  The logical extent number and
      current record positions of the FCB are set to correspond to the
      random record that is being written.  Again, sequential read or
      write operations can begin following a random write, with the
      notation that the currently addressed record is either read or
      rewritten again as the sequential operation begins.  You can
      also simply advance the random record position following each
      write to get the effect of a sequential write operation.
      Note that reading or writing the last record of an extent in
      random mode does not cause an automatic extent switch as it does
      in sequential mode.
      
      The error codes returned by a random write are identical to the
      random read operation with the addition of error code `05`, which
      indicates that a new extent cannot be created as a result of
      directory overflow.
    ]
  )
}

#let bdos-function-35(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    35,
    [Compute File Size],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-other: [Random Record Field Set in FCB],
    supported: cpm2-and-later,
    [
      When computing the size of a file, the `DE` register pair addresses
      an FCB in random mode format (bytes *R0*, *R1*, and *R2* are present).
      The FCB contains an unambiguous filename that is used in the
      directory scan.  Upon return, the random record bytes contain the
      virtual file size, which is, in effect, the record address of
      the record following the end of the file.  Following a call to
      Function 35, if the high record byte *R2* is `01`, the file contains
      the maximum record count `65536`.  Otherwise, bytes *R0* and *R1*
      constitute a 16-bit value as before (*R0* is the least significant byte),
      which is the file size.
      
      Data can be appended to the end of an existing file by simply
      calling Function 35 to set the random record position to the end
      of file and then performing a sequence of random writes starting
      at the preset record address.
      
      The virtual size of a file corresponds to the physical size when
      the file is written sequentially.  If the file was created in
      random mode and holes exist in the allocation, the file might
      contain fewer records than the size indicates.  For example,
      if only the last record of an 8-megabyte file is written in
      random mode (that is, record number `65535`), the virtual size is
      `65536` records, although only one block of data is actually
      allocated.
    ]
  )
}

#let bdos-function-36(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    36,
    [Set Random Record],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-other: [Random Record Field Set in FCB],
    supported: cpm2-and-later,
    [
      The Set Random Record function causes the BDOS automatically
      to produce the random record position from a file that has been
      read or written sequentially to a particular point.  The function
      can be useful in two ways.
      
      First, it is often necessary initially to read and scan a
      sequential file to extract the positions of various key fields.
      As each key is encountered, Function 36 is called to compute the
      random record position for the data corresponding to this key.  If
      the data unit size is 128 bytes, the resulting record position is
      placed into a table with the key for later retrieval.  After
      scanning the entire file and tabulating the keys and their record
      numbers, the user can move instantly to a particular keyed record
      by performing a random read, using the corresponding random
      record number that was saved earlier.  The scheme is easily
      generalized for variable record lengths, because the program need
      only store the buffer-relative byte position along with the key
      and record number to find the exact starting position of the
      keyed data at a later time.
      
      A second use of Function 36 occurs when switching from a
      sequential read or write over to random read or write.  A file is
      sequentially accessed to a particular point in the file, Function
      36 is called, which sets the record number, and subsequent random
      read and write operations continue from the selected point in the
      file.
    ]
  )
}


#let bdos-function-37(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    37,
    [Reset Drives],
    flavor,
    format: format,
    depth: depth,
    de: [Drive Vector],
    return-a: [`00H`],
    supported: cpm22-and-later,
    [
      The Reset Drive function allows resetting of specified drives.
      The passed parameter is a 16-bit vector of drives to be reset;
      the least significant bit is drive `A`.
      
      To maintain compatibility with MP/M, CP/M returns a zero value.
    ]
  )
}

#let bdos-function-38(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    38,
    [Access Drive],
    flavor,
    format: format,
    depth: depth,
    return-a: [`00H`],
    supported: cpm22-and-later,
    [
      This is an MP/M function that is not supported under CP/M. If called, the file system returns a zero In register A indicating that the access request is successful.
    ]
  )
}

#let bdos-function-39(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    39,
    [Free Drive],
    flavor,
    format: format,
    depth: depth,
    return-a: [`00H`],
    supported: cpm22-and-later,
    [
      This is an MP/M function that is not supported under CP/M. If called, the file system returns a zero In register A indicating that the free request is successful.
    ]
  )
}

#let bdos-function-40(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    40,
    [Write Random with Zero Fill],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Return code],
    return-h: [Hardware Error],
    supported: cpm22-and-later,
    [
      The Write With Zero Fill operation is similar to Function 34,
      with the exception that a previously unallocated block is filled
      with zeros before the data is written.      
    ]
  )
}

#let bdos-function-41(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    41,
    [Test and Write Record],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Error Code (`0FFH`)],
    return-h: [Hardware Error Code (`0`)],
    supported: cpm3-only,
    [
      The Test and Write Record function is an MP/M II function that is not supported under CP/M 3.
      If called, Function 41 returns with register `A` set to `0FFH` and register `H` set to zero.
    ]
  )
}

#let bdos-function-42(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    42,
    [Lock Record],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Error Code (`00H`)],
    supported: cpm3-only,
    [
      The Lock Record function is an MP/M II function that is supported under CP/M 3 only to provide compatibility between CP/M 3 and MP/M.
      It is intended for use in situations where more than one running program has Read-Write access to a common file.
      Because CP/M 3 is a single-user operating system in which only one program can run at a time, this situation cannot occur.
      Thus, under CP/M 3, Function 42 performs no action except to return the value 00H in register A indicating that the record lock operation is successful.
    ]
  )
}

#let bdos-function-43(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    43,
    [Unlock Record],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [`00H`],
    supported: cpm3-only,
    [
      The Unlock Record function is an MP/M II function that is supported under
      CP/M 3 only to provide compatibility between CP/M 3 and MP/M.
      It is intended for use in situations where more than one running program has Read-Write access to a common file.
      Because CP/M 3 is a single-user operating system in which only one program can run at a time, this situation cannot occur.
      Thus, under CP/M 3, Function 43 performs no action except to return the value `00H` in register `A` indicating that the record unlock operation is successful.
    ]
  )
}

#let bdos-function-44(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    44,
    [Set Multi-Sector Count],
    flavor,
    format: format,
    depth: depth,
    e: [Number of Sectors],
    return-a: [Return Code],
    supported: cpm3-only,
    [
      The Set Multi-Sector Count function provides logical record blocking under CP/M 3.
      It enables a program to read and write from 1 to 128 records of 128 bytes at a time during subsequent BDOS Read and Write functions.
      
      Function 44 sets the Multi-Sector Count value for the calling program to the value passed in register `E`.
      Once set, the specified Multi-Sector Count remains in effect until the calling program makes another Set Multi-Sector Count function call and changes the value.
      Note that the CCP sets the Multi-Sector Count to one (`1`) when it initiates a transient program.
      
      The Multi-Sector Count affects BDOS error reporting for the BDOS Read and
      Write functions. If an error interrupts these functions when the Multi-Sector is greater than one, they return the number of records successfully read or written in register
      `H` for all errors except for physical errors (`A` = `255` = `0FFH`).
      
      Upon return, register `A` is set to zero (`0`) if the specified value is in the range of `1` to `128`. Otherwise, register `A` is set to `0FFH`.
    ]
  )
}


#let bdos-function-45(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    45,
    [Set BDOS Error Mode],
    flavor,
    format: format,
    depth: depth,
    e: [BDOS Error Mode],
    supported: cpm3-only,
    [
      Function 45 sets the BDOS error mode for the calling program to the mode specified in register `E`. If register `E` is set to `0FFH`, `255` decimal, the error mode is set to Return Error mode. If register `E` is set to `0FEH`, `254` decimal, the error mode is set to Return and Display mode. If register `E` is set to any other value, the error mode is set to the default mode.
      
      The SET BDOS Error Mode function determines how physical and extended errors are handled for a program. The Error Mode can exist in three modes: the *default* mode, *Return Error* mode, and *Return and Display Error* mode.
      In the *default* mode, the BDOS displays a system message at the console that identifies the error and terminates the calling program.
      In the *Return Error* and *Display and Return Error* modes, the BDOS sets register `A` to `0FFH`, `255` decimal, places an error code that identifies the physical or extended error in register `H` and returns to the calling program.
      In *Return and Display* mode, the BDOS displays the system message before returning to the calling program. No system messages are displayed, however, when the BDOS is in *Return Error* mode.
    ]
  )
}

#let bdos-function-46(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    46,
    [Get Disk Free Space],
    flavor,
    format: format,
    depth: depth,
    e: [Drive ID],
    return-a: [Error Flag],
    return-h: [Hardware Error],
    return-other: [First 3 bytes of DMA buffer],
    supported: cpm3-only,
    [
      The Get Disk Free Space function determines the number of free sectors, 128 byte records, on the specified drive.
      The calling program passes the drive number in register `E`, with `0` for drive `A`, `1` for `B`, and so on, through `15` for drive `P` in a full 16-drive system.
      Function 46 returns a binary number in the first 3 bytes of the current DMA buffer. This number is returned in the following format:
      
      / +0 : low byte
      / +1 : middle byte
      / +2 : high byte
      
      
      Note that the returned free space value might be inaccurate if the drive has been marked Read-Only.
      
      Upon return, register `A` is set to zero if the function is successful. However, if the BDOS Error Mode is one of the return modes (see Function 45), and a physical error is encountered, register `A` is set to `0FFH`, `255` decimal, and register `H` is set to one of the following values:
      / 01 : Disk I/O error
      / 04 : Invalid drive error
    ]
  )
}

#let bdos-function-47(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    47,
    [Chain to Program],
    flavor,
    format: format,
    depth: depth,
    e: [Chain Flag],
    return-other: [*Does not return* to calling program],
    supported: cpm3-only,
    [
      The Chain To Program function provides a means of chaining from one program
      to the next without operator intervention. The calling program must place a command line terminated by a null byte, `00H`, in the default DMA buffer. If register `E` is set to `0FFH`, the CCP initializes the default drive and user number to the current program values when it passes control to the specified transient program. Otherwise, these parameters are set to the default CCP values. Note that Function 108, Get/Set Program Return Code, can be used to pass a two byte value to the chained program.
      
      Function 47 does not return any values to the calling program and any encountered errors are handled by the CCP.
    ]
  )
}


#let bdos-function-48(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    48,
    [Flush Buffers],
    flavor,
    format: format,
    depth: depth,
    e: [Purge Flag],
    return-a: [Error Flag],
    return-h: [Hardware Error Flag],
    supported: cpm3-only,
    [
      The Flush Buffers function forces the write of any write-pending records contained
      in internal blocking/deblocking buffers. If register `E` is set to `0FFH`, this function also purges all active data buffers.
      Programs that provide write with read verify support need to purge internal buffers to ensure that verifying reads actually access the disk instead of returning data that is resident in internal data buffers.
      The CP/M 3 PIP utility is an example of such a program.
      
      Upon return, register `A` is set to zero if the flush operation is successful. If a physical error is encountered, the Flush Buffers function performs different actions depending on the BDOS error mode (see Function 45). If the BDOS error mode is in the default mode, a message identifying the error is displayed at the console and the calling program is terminated. Otherwise, the Flush Buffers function returns to the calling program with register `A` set to `0FFH` and register `H` set to the following physical error code:
      
      / 01 : Disk I/O error
      / 02 : Read/only disk
      / 04 : Invalid drive error
    ]
  )
}

#let bdos-function-49(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    49,
    [Set/Get System Control Block],
    flavor,
    format: format,
    depth: depth,
    de: [SCB PB Address],
    return-a: [returned byte],
    return-hl: [returned word],
    supported: cpm3-only,
    [
      Function 49 allows access to parameters located in the CP/M 3 System Control Block (SCB). The SCB is a 100-byte data structure residing within the BDOS that contains flags and data used by the BDOS, CCP and other system components.
      Note that Function 49 is a CP/M 3 specific function.
      Programs intended for both MP/M II and CP/M 3 should either avoid the use of this function or isolate calls to this function in CP/M 3 version-dependent sections.
      To use Function 49, the calling program passes the address of a data structure called the SCB parameter block in register pair `DE`. This data structure identifies the byte or word of the SCB to be updated or returned. The SCB parameter block is defined as:
      
      ```
      SCBPB:
                DB OFFSET     ;   Offset within SCB
                DB SET        ; `0FFH` if setting a byte
                              ; `0FEH` if setting a word
                              ; `01H` - `0FDH` are reserved 
                              ; `00H` if a get operation
                DW VALUE      ; Byte or word value to be set
      ```
      
      The `OFFSET` parameter identifies the offset of the field within the SCB to be updated or accessed.
      The `SET` parameter determines whether Function 49 is to set a byte or word value in the SCB or if it is to return a byte from the SCB.
      The `VALUE` parameter is used only in set calls. In addition, only the first byte of `VALUE` is referenced in set byte calls.
      
      If Function 49 is called with the `OFFSET` parameter of the SCB parameter block greater than `63H`, the function performs no action but returns with registers `A` and `HL` set to zero.
      
      
      Use caution when you set SCB fields. Some of these parameters reflect the current state of the operating system. If they are set to invalid values, software errors can result. In general, do not use Function 49 to set a system parameter if another BDOS function can achieve the same result. For example, Function 49 can be called to update the Current DMA Address field within the SCB. This is not equivalent to making a Function 26, Set DMA Address call, and updating the SCB Current DMA field in this way would result in system errors. However, you can use Function 49 to return the Current DMA address.
      
      The System Control Block is summarized in the following table. Each of these fields is documented in detail in Appendix A.
    ]
  )
}


#let bdos-function-50(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    50,
    [Direct BIOS Calls],
    flavor,
    format: format,
    depth: depth,
    de: [BIOS PB Address],
    return-other: [BIOS Return Value],
    supported: cpm3-only,
    [
      Function 50 provides a direct BIOS call through the BDOS to the BIOS. The
      calling program passes the address of a data structure called the BIOS Parameter
      Block (BIOSPB) in register pair DE. The BIOSPB contains the BIOS function number and register contents as shown below:
      
      ```
      BIOSPB: DB  FUNC        ; BIOS function no.
              DB  AREG        ; A register contents
              DW  BCREG       ; BC register contents
              DW  DEREG       ; DE register contents
              DW  HLREG       ; HL register contents
      ```
      
      System Reset (Function 0) is equivalent to Function 50 with a BIOS function number of 1.
      Note that the register pair `BIOSPB` fields (`BCREG`, `DEREG`, `HLREG`) arc defined in low byte, high byte order. For example, in the `BCREG` field, the first byte contains the `C` register value, the second byte contains the `B` register value.
      Under CP/M 3, direct BIOS calls via the BIOS jump vector are only supported for the BIOS Console I/O and List functions. You must use Function 50 to call any other BIOS functions. In addition, Function 50 intercepts BIOS Function 27 (Select Memory) calls and returns with register `A` set to zero. Refer to the CP/M Plus (CP/M Version 3) Operating System System Guide for the definition of the BIOS functions and their register passing and return conventions.
    ]
  )
}

#let bdos-function-59(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    59,
    [Load Overlay],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Error Code],
    return-h: [Hardware Error Code],
    supported: cpm3-only,
    [
      Only transient programs with an RSX header can use the Load Overlay function because BDOS Function 59 is supported by the LOADER module. The calling program must have a header to force the LOADER to remain resident after the program is loaded (see Section 1.3).
      
      
      Function 59 loads either an absolute or relocatable module. Relocatable modules are identified by a filetype of `PRL`. Function 59 does not call the loaded module.
      
      The referenced FCB must be successfully opened before Function 59 is called. The load address is specified in the first two random record bytes of the FCB, *RO* and *R1*. The LOADER returns an error if the load address is less than `0100H`, or if performing the requested load operation would overlay the LOADER, or any other Resident System Extensions that have been previously loaded.
      
      When loading relocatable files, the LOADER requires enough room at the load address for the complete `PRL` file including the header and bit map (see Appendix B). Otherwise an error is returned. Function 59 also returns an error on `PRL` file load requests if the specified load address is not on a page boundary.
      
      Upon return, Function 59 sets register `A` to zero if the load operation is successful. If the LOADER RSX is not resident in memory because the calling program did not have a RSX header, the BDOS returns with register `A` set to `0FFH` and register `H` set to zero. If the LOADER detects an invalid load address, or if insufficient memory is available to load the overlay, Function 59 returns with register `A` set to `0FEH`. All other error returns are consistent with the error codes returned by BDOS Function 20, Read Sequential.
    ]
  )
}


#let bdos-function-60(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    60,
    [Call Resident System Extension],
    flavor,
    format: format,
    depth: depth,
    de: [RSX PB Address],
    return-a: [Error Code],
    return-h: [Hardware Error Code],
    supported: cpm3-only,
    [
      Function 60 is a special BDOS function that you use when you call Resident System Extensions. The RSX sub-function is specified in a structure called the RSX Parameter Block, defined as follows:
      
      ```
      RSXPB:  DB  FUNC      ; RSX Function number
              DB  NUMPARMS  ; Number of word Parameters
              DW  PARMETER1 ; Parameter 1
              DW  PARMETER2 ; Parameter 2
              ...
              DW  PARMETERN ; Parameter n
      ```
      
      RSX modules filter all BDOS calls and capture RSX function calls that they can handle. If there is no RSX module present in memory that can handle a specific RSX function call, the call is not trapped, and the BDOS returns `0FFH` in registers `A` and `L`. RSX function numbers from `0` to `127` are available for CP/M 3 compatible software use. RSX function numbers `128` to `255` are reserved for system use.
    ]
  )
}


#let bdos-function-98(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    98,
    [Free Blocks],
    flavor,
    format: format,
    depth: depth,
    return-a: [Error Flag],
    return-h: [Hardware Error Flag],
    supported: cpm3-only,
    [
      The Free Blocks function scans all the currently logged-in drives, and for each drive returns to free space all temporarily-allocated data blocks.
      A temporarily allocated data block is a block that has been allocated to a file by a BDOS write operation but has not been permanently recorded in the directory by a BDOS close operation. The CCP calls Function 98 when it receives control following a system warm start. Be sure to close your file, particularly any file you have written to, prior to calling Function 98.
      
      In the nonbanked version of CP/M 3, Function 98 frees only temporarily allocated blocks for systems that request double allocation vectors in GENCPM.
      
      Upon return, register `A` is set to zero if Function 98 is successful. If a physical
      error is encountered, the Free Blocks function performs different actions depending on the BDOS error mode (see Function 45). If the BDOS error mode is in the default mode, a message identifying the error is displayed at the console and the calling program is terminated. Otherwise, the Free Blocks function returns to the calling program with register `A` set to `0FFH` and register `H` set to the following physical error code:
      
      / 04 : Invalid drive error
    ]
  )
}

#let bdos-function-99(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    99,
    [Truncate File],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    return-h: [Hardware Error Code],
    supported: cpm3-only,
    [
      The Truncate File function sets the last record of a file to the random record number contained in the referenced FCB. The calling program passes the address of the FCB in register pair DE, with byte 0 of the FCB specifying the drive, bytes 1 through 11 specifying the filename and filetype, and bytes 33 through 35, rO, rl, and r2, specifying the last record number of the file. The last record number is a 24 bit value, stored with the least significant byte first, rO, the middle byte next, rl, and the high byte last, r2. This value can range from 0 to 262,143, which corresponds to a maximum value of 3 in byte r2.
      
      If the file specified by the referenced FCB is password protected, the correct pass- word must be placed in the first eight bytes of the current DMA buffer, or have been previously established as the default password (see Function 106).
      
      Function 99 requires that the file specified by the FCB not be open, particularly if the file has been written to. In addition, any activated FCBs naming the file are not valid after Function 99 is called. Close your file before calling Function 99, and then reopen it after the call to continue processing on the file.
      
      Function 99 also requires that the random record number field of the referenced FCB specify a value less than the current file size. In addition, if the file is sparse, the random record field must specify a record in a region of the file where data exists.
      
      Upon return, the Truncate function returns a Directory Code in register `A` with the value `0` if the Truncate function is successful, or `0FFH`, `255` decimal, if the file is not found or the record number is invalid. Register `H` is set to zero in both of these cases. If a physical or extended error is encountered, the Truncate function performs different actions depending on the BDOS error mode (see Function 45). If the BDOS error mode is in the default mode, a message identifying the error is displayed at the console and the program is terminated. Otherwise, the Truncate function returns to the calling program with register A set to `0FFH` and register `H` set to one of the following physical or extended error codes:
      
      / 01 : Disk I/O error
      / 02 : Read-Only disk
      / 03 : Read-Only file
      / 04 : Invalid drive error
      / 07 : File password error
      / 09 : `?` in filename or filetype field
    ]
  )
}


#let bdos-function-100(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    100,
    [Set Directory Label],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    return-h: [Hardware Error Code],
    supported: cpm3-only,
    [
      The Set Directory Label function creates a directory label, or updates the existing directory label for the specified drive. The calling program passes in register pair `DE` the address of an FCB containing the name, type, and extent fields to be assigned to the directory label.
      The name and type fields of the referenced FCB are not used to locate the directory label in the directory; they are simply copied into the updated or created directory label.
      The extent field of the FCB, byte 12, contains the user's specification of the directory label data byte. The definition of the directory label
      data byte:
      
      / bit 7 : Require passwords for password-protected files (Not supported in nonbanked CP/M 3 systems)
      / bit 6 : Perform access date and time stamping
      / bit 5 : Perform update date and time stamping
      / bit 4 : Perform create date and time stamping
      / bit 0 : Assign a new password to the directory label
      
      If the current directory label is password protected, the correct password must be placed in the first eight bytes of the current DMA, or have been previously established as the default password (see Function 106). If bit 0, the low-order bit, of byte 12 of the FCB is set to 1, it indicates that a new password for the directory label has been placed in the second eight bytes of the current DMA.
      
      Note that Function 100 is implemented as an RSX, `DIRLBL.RSX`, in nonbanked
      CP/M 3 systems. If Function 100 is called in nonbanked systems when the `DIRLBL.RSX` is not resident an error code of `0FFH` is returned.
      
      Function 100 also requires that the referenced directory contain SFCBs to activate date and time stamping on the drive. If an attempt is made to activate date and time stamping when no SFCBs exist, Function 100 returns an error code of `0FFH` in register `A` and performs no action. The CP/M 3 `INITDIR` utility initializes a directory for date and time stamping by placing an SFCB record in every fourth entry of the directory.
      
      Function 100 returns a Directory Code in register `A` with the value `0` if the directory label create or update is successful, or `0FFH`, `255` decimal, if no space exists in the referenced directory to create a directory label, or if date and time stamping was requested and the referenced directory did not contain SFCBS. Register `H` is set to zero in both of these cases. If a physical error or extended error is encountered, Function 100 performs different actions depending on the BDOS error mode (see Function 45). If the BDOS error mode is the default mode, a message identifying the error is displayed at the console and the calling program is terminated. Otherwise, Function 100 returns to the calling program with register `A` set to `0FFH` and register `H` set to one of the following physical or extended error codes:
      
      / 01 : Disk I/O error
      / 02 : Read-only disk
      / 04 : Invalid drive error
      / 07 : File password error
    ]
  )
}


#let bdos-function-101(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    101,
    [Return Directory Label Data],
    flavor,
    format: format,
    depth: depth,
    e: [Drive ID],
    return-a: [Directory Label Data Byte],
    return-h: [Hardware Error Code],
    supported: cpm3-only,
    [
      The Return Directory Label Data function returns the data byte of the directory label for the specified drive. The calling program passes the drive number in register `E` with `0` for drive `A`, `1` for drive `B`, and so on through `15` for drive `P` in a full sixteen drive system.
      The format of the directory label data byte is shown below:
      
      / bit 7 : Require passwords for password protected files
      / bit 6 : Perform access date and time stamping
      / bit 5 : Perform update date and time stamping
      / bit 4 : Perform create date and time stamping
      / bit 0 : Directory label exists on drive
      
      Function 101 returns the directory label data byte to the calling program in register `A`. Register `A` equal to zero indicates that no directory label exists on the specified drive. If a physical error is encountered by Function 101 when the BDOS Error mode is in one of the return modes (see Function 45), this function returns with register `A` set to `0FFH`, `25S` decimal, and register `H` set to one of the following:
      
      / 01 : Disk I/O error
      / 04 : Invalid drive error
    ]
  )
}


#let bdos-function-102(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    102,
    [Read File Date Stamps and Password Mode],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    return-h: [Hardware Error Code],
    return-other: [fields in FCB are updated],
    supported: cpm3-only,
    [
      Function 102 returns the date and time stamp information and password mode for the specified file in byte 12 and bytes 24 through 32 of the specified FCB. The calling program passes in register pair DE, the address of an FCB in which the drive, file- name, and filetype fields have been defined.
      
      If Function 102 is successful, it sets the following fields in the referenced FCB:
      
      - byte 12 : Password mode field
        / bit 7 : Read mode
        / bit 6 : Write mode
        / bit 4 : Delete mode
        
      Byte 12 equal to zero indicates the file has not been assigned a password.
      In nonbanked systems, byte 12 is always set to zero.
      
      - byte 24 - 27 Create or Access time stamp field
      - byte 28 - 31 Update time stamp field
      
      The date stamp fields are set to binary zeros if a stamp has not been made. The format of the time stamp fields is the same as the format of the date and time structure described in Function 104.
      
      Upon return, Function 102 returns a Directory Code in register `A` with the value zero if the function is successful, or `0FFH`, `255` decimal, if the specified file is not
      found. Register `H` is set to zero in both of these cases. If a physical or extended error is encountered, Function 102 performs different actions depending on the BDOS error mode (see Function 45). If the BDOS error mode is in the default mode, a message identifying the error is displayed at the console and the calling program is terminated. Otherwise, Function 102 returns to the calling program with register `A` set to `0FFH` and register `H` set to one of the following physical or extended error codes:
      
      / 01 : Disk I/O error
      / 04 : Invalid drive error
      / 09 : `?` in filename or filetype field
    ]
  )
}


#let bdos-function-103(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    103,
    [Write File XFCB],
    flavor,
    format: format,
    depth: depth,
    de: [FCB Address],
    return-a: [Directory Code],
    return-h: [Hardware Error Code],
    return-other: [XFCB fields updated],
    supported: cpm3-only,
    [
      The Write File XFCB function creates a new XFCB or updates the existing XFCB
      for the specified file. The calling program passes in register pair `DE` the address of an FCB in which the drive, name, type, and extent fields have been defined.
      The extent field specifies the password mode and whether a new password is to be assigned to the file. The format of the extent byte is shown below:
      
      - FCB byte 12 (ex) : XFCB password mode
      / bit 7 : Read mode
      / bit 6 : Write mode
      / bit 5 : Delete mode
      / bit 0 : Assign new password to the file
      
      If the specified file is currently password protected, the correct password must reside in the first eight bytes of the current DMA, or have been previously established as the default password (see Function 106). If bit `0` is set to 1, the new password must reside in the second eight bytes of the current DMA.
      
      
      Upon return, Function 103 returns a Directory Code in register `A` with the value
      zero if the XFCB create or update is successful, or `0FFH`, `255` decimal, if no directory label exists on the specified drive, or the file named in the FCB is not found, or no space exists in the directory to create an XFCB. Function 103 also returns with `0FFH` in register `A` if passwords are not enabled by the referenced directory's label.
      On nonbanked systems, this function always returns with register `A` = `0FFH` because passwords are not supported. Register `H` is set to zero in all of these cases.
      If a physical or extended error is encountered, Function 103 performs different actions depending on the BDOS error mode (see Function 45). If the BDOS error mode is
      the default mode, a message identifying the error is displayed at the console and the calling program is terminated. Otherwise, Function 103 returns to the calling program with register `A` set to `0FFH` and register `H` set to one of the following physical or extended error codes:
      
      / 01 : Disk I/O error
      / 02 : Read-Only disk
      / 04 : Invalid drive error
      / 07 : File password error
      / 09 : `?` in filename or filetype field
    ]
  )
}

#let bdos-function-104(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    104,
    [Set Date and Time],
    flavor,
    format: format,
    depth: depth,
    de: [DAT Address],
    supported: cpm3-only,
    [
      The Set Date and Time function sets the system internal date and time. The calling program passes the address of a 4-byte structure containing the date and time specification in the register pair `DE`. The format of the date and time (`DAT`) data structure is:
      
      ```
      DAT:    DW    DATE        ; Days since January 1, 1978
              DB    HOUR        ; Hour field (2-BCD digits)
              DB    MINUTE      ; Minute field (2-BCD digits)
      ```
      
      The date is represented as a 16-bit integer with day 1 corresponding to January 1, 1978. The time is represented as two bytes: hours and minutes are stored as two BCD digits.
      This function also sets the seconds field of the system date and time to zero.
    ]
  )
}

#let bdos-function-105(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    105,
    [Get Date and Time],
    flavor,
    format: format,
    depth: depth,
    de: [DAT Address],
    return-a: [seconds (two-digit BCD value)],
    return-other: [DAT structure is updated],
    supported: cpm3-only,
    [
      The Get Date and Time function obtains the system internal date and time. The calling program passes in register pair `DE`, the address of a 4-byte data structure which receives the date and time values. The format of the date and time, `DAT`, data structure is the same as the format described in Function 104. Function 105 also returns the seconds field of the system date and time in register `A` as a two digit BCD value.
      
      The format of the date and time (`DAT`) data structure is:
      ```
      DAT:    DW    DATE        ; Days since January 1, 1978
              DB    HOUR        ; Hour field (2-BCD digits)
              DB    MINUTE      ; Minute field (2-BCD digits)
      ```
    ]
  )
}


#let bdos-function-106(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    106,
    [Set Default Password],
    flavor,
    format: format,
    depth: depth,
    de: [Password Address],
    supported: cpm3-banked-only,
    [
      The Set Default Password function allows a program to specify a password value before a file protected by the password is accessed. When the file system accesses a password-protected file, it checks the current DMA, and the default password for the correct value. If either value matches the file's password, full access to the file is allowed. Note that this function performs no action in nonbanked CP/M 3 systems because file passwords are not supported.
      
      To make a Function 106 call, the calling program sets register pair `DE` to the address of an 8-byte field containing the password.
    ]
  )
}

#let bdos-function-107(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    107,
    [Return Serial Number],
    flavor,
    format: format,
    depth: depth,
    de: [Serial Number Field],
    return-other: [Serial Number Field is set],
    supported: cpm3-only,
    [
      Function 107 returns the CP/M 3 serial number to the 6-byte field addressed by register pair `DE`.
    ]
  )
}

#let bdos-function-108(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    108,
    [Set/Get Program Return Code],
    flavor,
    format: format,
    depth: depth,
    de: [`0FFFFH` (Get) or \ Program Return Code (Set)],
    return-hl: [Program Return Code or (none)],
    supported: cpm3-only,
    [
      CP/M 3 allows programs to set a return code before terminating. This provides a mechanism for programs to pass an error code or value to a following job step in batch environments. For example, Program Return Codes are used by the CCP in CP/M 3's conditional command line batch facility. Conditional command lines are command lines that begin with a colon, :. The execution of a conditional command depends on the successful execution of the preceding command. The CCP tests the return code of a terminating program to determine whether it successfully completed or terminated in error. Program return codes can also be used by programs to pass an error code or value to a chained program (see Function 47, Chain To Program).
      
      A program can set or interrogate the Program Return Code by calling Function
      108. If rester pair `DE` = `0FFFFH`, then the current Program Return Code is returned in register
      pair `HL`. Otherwise, Function 108 sets the Program Return Code to the value contained in register pair `DE`. Program Return Codes are defined in the table below.
      
      #table(
        columns: (auto, 1fr),
        align: (center, left),
        table.header([*Code*], [*Meaning*]),
        [`0000` ... `FEFF`], [Successful Return],
        [`FF00` ... `FFFE`], [Unsuccessful Return],
        [`0000`], [The CCP initializes the Program Return Code to zero unless the program is loaded as the result of program chain.],
        [`FF80` ... `FFFC`], [Reserved],
        [`FFFD`], [The program is terminated because of a fatal BDOS error.],
        [`FFFE`], [The program is terminated by the BDOS because the user typed a CTRL-C.]
      )
    ]
  )
}

#let bdos-function-109(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    109,
    [Set/Get Console Mode],
    flavor,
    format: format,
    depth: depth,
    de: [`0FFFFH` (Get) or \ Console Mode (Set)],
    return-hl: [Console Mode or (none)],
    supported: cpm3-only,
    [
      A program can set or interrogate the Console Mode by calling Function 109.
      If register pair `DE` = `0FFFFH`, then the current Console Mode is returned in register `HL`. Otherwise, Function 109 sets the Console Mode to the value contained in register pair `DE`.
      The Console Mode is a 16-bit system parameter that determines the action of certain BDOS Console I/O functions. The definition of the Console Mode is:
      
      
      - bit 0 = 
        / 0 : Normal status for Function 11.
        / 1 : CTRL-C only status for Function 11.
      
      - bit 1 =
        / 0 : Enable Stop Scroll, Start Scroll supported.
        / 1 : Disable Stop Scroll, CTRL-S, Start Scroll, CTRL-Q Support.
        
      - bit 2 =
        / 0 : Normal console output mode.
        / 1 : Raw console output mode. Disables tab expansion for Functions 2, 9 and 111. Also disables printer echo, CTRL-P support.
        
      - bit 3 =
        / 0 : Enable CTRL-C program termination.
        / 1 : Disable CTRL-C program termination.
      
      - bits 8, 9 =
        / 00 : conditional status
        / 01 : false status
        / 10 : true status
        / 11 : bypass redirection
      
      Note that the Console Mode bits are numbered from right to left. Bit 0 is the least significant bit.
      
      The CCP initializes the Console Mode to zero when it loads a program unless the program has an RSX that overrides the default value. 
      Refer to Section 2.2.1 for detailed information on Console Mode.
    ]
  )
}


#let bdos-function-110(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    110,
    [Set/Get Output Delimiter],
    flavor,
    format: format,
    depth: depth,
    de: [`0FFFFH` (Get)],
    e: [Output Delimiter (Set) or],
    return-a: [Output Delimiter or (none)],
    supported: cpm3-only,
    [
      A program can set or interrogate the current Output Delimiter by calling Function 110. If register pair `DE` = `0FFFFH`, then the current Output Delimiter is returned in register `A`. Otherwise, Function 110 sets the Output Delimiter to the value contained in register `E`.
      
      Function 110 sets the string delimiter for Function 9, Print String. The default delimiter value is a dollar sign, `$`. The CCP restores the Output Delimiter to the default value when a transient program is loaded.
    ]
  )
}


#let bdos-function-111(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    111,
    [Print Block],
    flavor,
    format: format,
    depth: depth,
    de: [CCB Address],
    supported: cpm3-only,
    [
      The Print Block function sends the character string located by the Character Control Block, `CCB`, addressed in register pair `DE`, to the logical console, `CONOUT:`.
      If the Console Mode is in the default state (see Section 2.2.1), Function 111 expands tab characters, CTRL-I, in columns of eight characters.
      It also checks for stop scroll, CTRL-S, start scroll, CTRL-Q, and echoes to the logical list device, `LST:`, if printer echo, CTRL-P, has been invoked.
      
      The `CCB` format is:
      
      ```
      CCB:    DW    STR         ; Address of ASCII string
              DW    LENGTH      ; Length of character string
      ```
    ]
  )
}

#let bdos-function-112(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    112,
    [List Block],
    flavor,
    format: format,
    depth: depth,
    de: [CCB Address],
    supported: cpm3-only,
    [
      The List Block function sends the character string located by the Character Control Block, `CCB`, addressed in register pair `DE`, to the logical list device, `LST:`.
      
      The `CCB` format is:
      
      ```
      CCB:    DW    STR         ; Address of ASCII string
              DW    LENGTH      ; Length of character string
      ```
    ]
  )
}


#let bdos-function-152(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  create-bdos-entry(
    152,
    [Parse Filename],
    flavor,
    format: format,
    depth: depth,
    de: [PFCB Address],
    return-hl: [Return Code],
    return-other: [Parsed File Control Block (FCB)],
    supported: cpm3-only,
    [
      The Parse Filename function parses an ASCII file specification and prepares a File Control Block, `FCB`. The calling program passes the address of a data structure called the Parse Filename Control Block, `PFCB`, in register pair `DE`. The `PFCB` contains the address of the input ASCII filename string followed by the address of the target `FCB` as shown below:
      
      ```
      PFCB:   DW    INPUT     ; Address of input ASCII string
              DW    FCB       ; Address of target FCB
      ```
      
      The maximum length of the input ASCII string to be parsed is 128 bytes. The target `FCB` must be 36 bytes in length.
      
      Function 152 assumes the input string contains file specifications in the following form:
      
      #pad(left: 5em)[{_d_`:`}_filename_{`.`_typ_}{`;`_password_}]
      
      where items enclosed in curly brackets are optional. Function 152 also accepts isolated drive specifications _d_`:` in the input string. When it encounters one, it sets the filename, filetype, and password fields in the `FCB` to blank.
      
      The Parse Filename function parses the first file specification it finds in the input string. The function first eliminates leading blanks and tabs. The function then assumes that the file specification ends on the first delimiter it encounters that is out of
      context with the specific field it is parsing. For instance, if it finds a colon, and it is
      not the second character of the file specification, the colon delimits the entire file specification.
      
      
      Function 152 recognizes the following characters as delimiters:
      
      - space
      - tab
      - return
      - CTRL-J
      - `;` (semicolon) -- except before password field.
      - `=` (equal)
      - `<` (less than)
      - `>` (greater than)
      - `.` (period) -- except after filename and before filetype
      - `:` (colon) -- except before filename and after drive.
      - `,` (comma)
      - `|` (vertical bar)
      - `[` (left square bracket)
      - `]` (right square bracket)
      
      
      If Function 152 encounters a non-graphic character in the range 1 through 31 not listed above, it treats the character as an error. The Parse Filename function initializes the specified `FCB` shown in the table below.
      
      #table(
        columns: (auto, 1fr),
        align: (left, left),
        table.header([*Location*], [*Contents*]),
        inset: 10pt,
        [byte 0], [The drive field is set to the specified drive. If the drive is not specified, the default drive code is used. `0` = default, `1` = `A`, `2` = `B`, ... `15` = `P`.],
        [bytes 1-8], [
      The name is set to the specified filename. All letters are converted to upper-case. If the name is not eight characters long, the remaining bytes in the filename field are padded with blanks. If the filename has an asterisk, `*`, all remaining bytes in the filename field are filled in with question marks, `?`. An error occurs if the filename is more than eight bytes long.],
        [bytes 9-11], [The type is set to the specified filetype. If no filetype is specified, the type field is initialized to blanks. All letters are converted to upper-case. If the type is not three characters long, the remaining bytes in the filetype field are padded with blanks. If an asterisk, `*`, occurs, all remaining bytes are filled in with question marks, `?`. An error occurs if the type field is more than three bytes long.],
        [bytes 12-15], [Filled in with zeros],
        [bytes 16-23], [
      The password field is set to the specified password. If no password is specified, it is initialized to blanks. If the password is less than eight characters long, remaining bytes are padded
      with blanks. All letters are converted to upper-case. If the password field is more than eight bytes long, an error occurs. Note that a blank in the first position of the password field implies
      no password was specified.],
        [bytes 24-31], [Reserved for system use.],
      )
      
      If an error occurs, Function 152 returns an `0FFFFH` in register pair `HL`.
      
      On a successful parse, the Parse Filename function checks the next item in the input string. It skips over trailing blanks and tabs and looks at the next character. If the character is a null or carriage return, it returns a `0` indicating the end of the input string. If the character is a delimiter, it returns the address of the delimiter. If the character is not a delimiter, it returns the address of the first trailing blank or tab.
      
      If the first non-blank or non-tab character in the input string is a null, `0`, or carriage return, the Parse Filename function returns a zero indicating the end of string.
      
      If the Parse Filename function is to be used to parse a subsequent file specification in the input string, the returned address must be advanced over the delimiter before placing it in the `PFCB`.
    ]
  )
}


#let all-bdos-children(
  flavor,
  format: default-format,
  depth: default-depth,
) = {
  let children = ()
  let result
  result = bdos-function-00(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-01(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-02(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-03(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-04(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-05(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-06-console-io(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-06-memory-size(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-07-auxin-status(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-07-iobyte(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-08-auxout-status(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-08-iobyte(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-09(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-10(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-11(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-12-lift-head(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-12-version(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-13(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-14(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-15(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-16(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-17(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-18(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-19(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-20(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-21(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-22(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-23(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-24(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-25(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-26(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-27(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-28(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-29(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-30-echo(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-30-set-dir-dma(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-30-set-file-attr(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-31(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-32(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-33(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-34(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-35(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-36(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-37(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-38(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-39(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-40(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-41(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-42(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-43(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-44(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-45(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-46(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-47(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-48(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-49(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-50(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-59(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-60(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-98(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-99(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-100(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-101(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-102(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-103(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-104(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-105(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-106(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-107(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-108(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-109(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-110(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-111(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-112(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }
  result = bdos-function-152(flavor, format: format, depth: depth)
  if result != none {
    children.push(result)
  }

  return children
}

#let bdos-function-summary-table(
  flavor,
  caption: none,
  numbering: none,
  only-supported: true,
) = {
  let format = "supported-summary"
  if not only-supported {
    format = "summary"
  }
  let children = all-bdos-children(flavor, format: format)
  figure(
    table(
      columns: (1fr),
      stroke: none,
      inset: 0pt,
      table.header(
        box(
          table(
            columns: (25pt, 1fr, 2fr, 2fr),
            align: (center, left, left, left),
            inset: 4pt,
            stroke: 0.1pt,
            [\#], [*Name*], [*Parameters*], [*Results*],
          )
        )
      ),
      ..children
    ),
    caption: caption,
    numbering: numbering
  )
}

#let column-major-order(
  ar
) = {
  let chunk-size = calc.floor((ar.len() + 1) / 2)
  let chunks = ar.chunks(chunk-size)
  let column-major = ()
  let n = 0
  while n < chunks.at(0).len() {
    column-major.push(chunks.at(0).at(n))
    if n < chunks.at(1).len() {
      column-major.push(chunks.at(1).at(n))
    }
    n += 1
  }
  return column-major
}

#let bdos-function-table(
  flavor,
  caption: none,
  numbering: none,
  only-supported: true,
) = {
  let format = "supported-basic"
  if not only-supported {
    format = "basic"
  }
  let children = column-major-order(all-bdos-children(flavor, format: format))
  if not only-supported {
      if calc.odd(children.len()) {
        children.push([])
      }
      children.push(table.cell(colspan: 2)[
        †Indicates that the function is *not supported* in this version.
      ])
  }
  figure(
    table(
      columns: (auto, auto),
          inset: 4pt,
          stroke: 0.1pt,
      ..children
    ),
    caption: caption,
    numbering: numbering
  )
}

#let bdos-function-support-table(
  caption: none,
  numbering: none,
) = {
  let children = all-bdos-children("spec", format: "supported")
  figure(
    table(
      columns: (1fr),
      stroke: none,
      inset: 0pt,
      table.header(
        box(
          table(
            columns: (25pt, 4fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
            align: (center, left, center, center, center, center, center, center, center),
            inset: 4pt,
            stroke: 0.1pt,
            table.cell(colspan: 2, stroke: none)[],
            table.cell(colspan: 7, align: center, stroke: none)[*CP/M Version*],
            [\#], [*Function Name*], [*1975*], [*1.3*], [*1.4*], [*2.0*], [*2.2*], [*3.0 \ non-banked*], [*3.0 \ banked*],
          )
        )
      ),
      ..children
    ),
    caption: caption,
    numbering: numbering
  )
}

#let bdos-system-call-sections(
  flavor,
  depth: default-depth,
) = {
  let sections = all-bdos-children(flavor, depth: depth)
  for section in sections {
    [#section]
  }
}

#let bdos-system-call-spec(
  depth: default-depth
) = {
  let sections = all-bdos-children("spec", format: "detailed", depth: depth)
  for section in sections {
    [#section]
  }
}


#if include-tests [
#set heading(numbering: "1.", supplement: [Section])
= Tests
#show figure: set block(breakable: true)
#bdos-function-02("3.0", format: "supported")
#bdos-function-06-memory-size("spec", format: "supported")

#bdos-function-01("3.0", format: "standard")  

#bdos-function-02("spec", format: "detailed")  

#bdos-function-table("2.0", caption: [BDOS 2.0 functions])

#bdos-function-table("3.0", caption: [BDOS 3.0 functions], only-supported: true)

#bdos-function-summary-table("3.0", caption: [CP/M 3.0 BDOS Function Summary])
#bdos-function-summary-table("1.4", caption: [CP/M 1.4 BDOS Function Summary], only-supported: true)

#bdos-function-support-table(caption: [CP/M Supported Functions])
]


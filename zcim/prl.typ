#show "MPM" : smallcaps[mp/m]

#set page(margin: (x: 8em))

#pad(left: -2em)[*NAME*]
`.prl` - "Page relocatable" Format

#pad(left: -2em)[*DESCRIPTION*]

`.prl` ("Page relocatable") is a file format for relocatable object code
    defined in the MPM users manual. It begins with a 256 byte header:

#figure(
  table(
    columns: (auto, 1fr),
    inset: 10pt,
    align: (center, left),
    table.header([*Offset*], [*Contents*]),
    [`0`], [Octal 375. (Not documented by MPM)],
    [`1`, `2`], [Program size (least significant byte first)],
    [`3`], [Not documented by MPM],
    [`4`, `5`], [Size of any required buffer space (least significant byte first)],
    [`6` to `255`], [Currently unused, reserved by MPM],
  ),
  caption: [`.prl` Header Format]
)

Next comes "program-size" bytes of binary object code assembled at address 0.

Finally comes a "bit map", one bit for each byte of code, beginning
with the most significant bit of the map's first byte. A `1` bit
indicates that the corresponding byte of code should be relocated by
adding to it the most significant byte of the load address.

The usual way to create a `.prl` file is to assemble the source code twice,
once at `0` and once at `100` hex. Then build the map by comparing the
bytes one-for-one, setting the corresponding bit to the difference.
If two bytes differ by more than `1`, then some non-relocatable
construct has been used.

#pad(left: -2em)[*BUGS*]

The load address must be on a page boundary (multiple of 256).

#pagebreak()

#pad(left: -2em)[*NAME*]

`MAKEPRL` - make a `.prl` file from absolute hex files

#pad(left: -2em)[*SYNOPSIS*]

`MAKEPRL` \[ -s _hex-number_ \[ -o _output-file_ \] \] _hex1_ _hex2_

#pad(left: 2em)[*DESCRIPTION*]

#pad(left: 2em)[*EXAMPLES*]

To create a `.prl` file of the hard disk I/O drivers,
begin with the assembly language source. Assemble the 


```
          mac hd+dj
          ren hd+dj.hx0=hd+dj.hex
          mac hd+dj $+r
          ren hd+dj.hx1=hd+dj.hex
          makeprl -o hd+dj.prl hd+dj.hx0 hd+dj.hx1
```

In the `MAKEPRL` command-line it is not required that
you specify the output or add type extensions because the program
uses defaults. The line could have been written:

```
          makeprl hd+dj hd+dj
```

This form does the same as the first, but is easier to type.

The specification for the `-s` option must be a four digit hex number.

#pad(left: -2em)[*FILES*]
- `MAKEPRL.COM`



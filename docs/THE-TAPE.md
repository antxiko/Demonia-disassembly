# The tape

[Getting started](GETTING-STARTED.html) · [The game](THE-GAME.html) · [The code](THE-CODE.html) · [Findings](FINDINGS.html) · [Open questions](OPEN-QUESTIONS.html)

Demonia does not come on a cartridge: it comes on a 58,334-byte tape, and
almost everything odd about this game starts there.

## Thirteen blocks and three files with the same name

A `.cas` is a list of blocks, each preceded by eight sentinel bytes. There are
**thirteen** here, and among them **three named files**. All three are called
`DEMON`:

| file | type | loads at | size |
|---|---|---|---:|
| `DEMON` | ASCII | — | the BASIC loader |
| `DEMON` | BIN | `0x8180` | 249 bytes |
| `DEMON` | BIN | `0x8000` | 24,576 bytes |

Between the two BINs go **seven headerless blocks**, which cannot be loaded
from BASIC because they carry no name: the program in the second file reads
them.

The three sharing a name is not an oversight. Line 50 of the BASIC loader is:

    BLOAD"CAS:DEMON",R:RUN

Since tape is sequential, the first time that line runs the head is before the
small BIN and finds **that one**. The `,R` starts it; when that program is
done it returns to BASIC, the `:RUN` restarts the loader and line 50 runs
again. But the tape is now past the seven blocks, so this second time it finds
**the big BIN**, which is the game.

Two files with the same name, and a `RUN` to choose between them.

## The seven chunks, and the table that declares them

The small BIN is the real loader. At `0x8180` it carries a table of seven
eight-byte entries, each holding three addresses and a sentinel:

    defw 0a000h,0a618h,0a600h,0ffffh   ; load, end, execute, FFFF
    defw 0ad00h,0c07fh,0c050h,0ffffh
    defw 0a000h,0b531h,0b468h,0ffffh
    defw 0a000h,0bf57h,0bf32h,0ffffh
    defw 0a000h,0bbbbh,0bb96h,0ffffh
    defw 0afd0h,0bfffh,0afe0h,0ffffh
    defw 09000h,0971fh,096f8h,0ffffh

The loop at `0x8208` walks the whole thing and **stops at `0x81B8`**, which is
what the `ld de,0x81B8` at `0x8236` says. Eight bytes per entry, from `0x8180`
to `0x81B8`: seven.

For each chunk the loader takes the load address (bytes 0 and 1) and the end
(bytes 2 and 3) out of the table, works out the length by subtracting and
adding one, reads the block off the tape and **jumps to the execution address**
(bytes 4 and 5). So each chunk runs the moment it is read, before the next one
is.

Notice that four of the seven load at `0xA000` but execute much higher up. That
is because what runs is not the whole chunk but the tail glued to it.

## Twenty-six kilobytes underneath the BASIC ROM

An MSX booted into BASIC sees ROM in pages 0 and 1, and RAM only in pages 2 and
3. That is 32 KB, and this game does not fit.

What it does is look for a 64 KB slot and **put 26 KB underneath the ROM**. The
tail glued to each chunk is always the same idea: switch the slot so the page
in question is RAM, do an `LDIR` copying the chunk to its final home, and put
the slot back as it was.

That is why the disassembly has **thirteen listings and not seven**: the chunk
has to be disassembled as it lands off the tape *and* as memory ends up once
everything has moved.

| listing | org | bytes |
|---|---|---:|
| `arranque` | `0x8180` | 249 |
| `bajo0000` | `0x0000` | 15,048 |
| `bajo4000` | `0x4000` | 5,224 |
| `bajo6000` | `0x6000` | 4,096 |
| `bajo7900` | `0x7900` | 1,768 |
| `carga1` | `0xA000` | 1,561 |
| `carga2` | `0xAD00` | 4,992 |
| `carga3cola` | `0xB468` | 202 |
| `carga4cola` | `0xBF32` | 38 |
| `carga5cola` | `0xBB96` | 38 |
| `carga6cab` | `0xAFD0` | 48 |
| `carga7cola` | `0x96E8` | 56 |
| `juego` | `0x8000` | 24,576 |

The five hidden chunks were checked **byte for byte** against the RAM of a
running openMSX, and also against the RAM snapshots inside a replay recorded on
a different machine. Two independent measurements that agree.

## The budget: not one byte unexplained

```
whole tape                  58,334 bytes
  traced code               20,299
  named data                37,597
  tape wrapper                 438
  unexplained                    0   ->  100.00%
```

The 438 bytes of wrapper break down like this, and none of it is a mystery:

| what | bytes |
|---|---:|
| block sentinels | 104 (13 blocks × 8) |
| file headers | 48 (3 files × 16) |
| BIN header | 12 (2 files × 6) |
| BASIC loader | 256 |
| alignment padding | 18 |

**What the tape spends on being a tape is 18 bytes.** A block has to start on a
multiple of eight, so up to seven padding bytes can follow each one; here only
five of the thirteen need any.

The BASIC loader, on the other hand, is nearly empty: its two lines take 93
bytes and the other 163 are the `0x1A` the MSX pads the 256-byte chunk with.
**64% of the tape's first file is padding.**

## And that is why verify takes two steps

`make verify` cannot just reassemble and compare, the way it would for a
cartridge. Here it does two things:

1. reassembles each of the thirteen listings and checks that exactly the right
   piece of memory comes out;
2. **rebuilds the whole `.cas`** — all thirteen blocks, with their sentinels,
   their headers, the BASIC loader and the padding — and checks it gives the
   same sha256 as the original tape.

If both steps pass, the disassembly has invented nothing.

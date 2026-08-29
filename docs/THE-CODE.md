# The code

[Getting started](GETTING-STARTED.html) · [The game](THE-GAME.html) · [The tape](THE-TAPE.html) · [Findings](FINDINGS.html) · [Open questions](OPEN-QUESTIONS.html)

## The memory map, once loaded

When the seven chunks have finished moving, the MSX's memory looks like this.
That is **50,712 bytes occupied out of 65,536**, 77.4% of the map:

| address | bytes | what is there | from which chunk |
|---|---:|---|---|
| `0x0000-0x1F31` | 7,986 | first sprite bank: 242 records of 33 bytes | chunk 4 |
| `0x1F32-0x3AC7` | 7,062 | second bank: 214 records | chunk 5 |
| `0x4000-0x5467` | 5,224 | the 26 compressed screen maps | chunk 3 |
| `0x6000-0x6FFF` | 4,096 | the scenery: 2,048 of pattern and 2,048 of colour | chunk 6 |
| `0x7900-0x7FE7` | 1,768 | the music | chunk 7 |
| `0x8000-0xDFFF` | 24,576 | the whole game | the big BIN |

The first four rows and the fifth are **underneath the BASIC ROM**: they are
pages 0 and 1, which on a normally booted MSX are not RAM at all. Only the
block at `0x8000` lives where you can see it.

And `0x5480`, immediately after the compressed maps, is where the decompressor
leaves the current screen's map: 640 uncompressed tiles.

## The three tables that run the game

They sit together at the end of the game block:

| address | size | what it is |
|---|---|---|
| `0xD000` | 24 × 2 | pointer to each screen's compressed map |
| `0xD030` | 24 × 4 pointers | each screen's behaviour |
| `0xD0C0` | 24 × 88 bytes | each screen's record |

The **behaviour table** is this game's nearest thing to a script: every screen
declares up to four routines, and the ones it does not use are not left at zero
but point at `0xFD9A`, the sound vector. It is a cheap way of saying "nothing
to do here" without having to test for anything.

The **records** were delimited by a marker they all carry at byte 84:
`FF <screen number in ASCII> FF`. The first lands at `0xD114` and the last at
`0xD8FC`, always 88 bytes apart; that made it possible to separate them one by
one without assuming anything.

## Code that writes over itself

This game modifies itself in several places, and it is worth knowing before
reading the listing:

- `0xABB3` writes into `0xAB1A`, which is **the operand of a `ld c,n`**, to
  switch sprite bank.
- `0x864E` and `0x8653` patch two operands, those of `0x8603` and `0x8623`.
- And inside the Loriciels monitor, `0xC645` writes the return address over the
  operand of the `jp` at `0xC65E`.

Operands double as variables: the tape loader keeps the pointer to the entry it
is reading in `0x81F8` and the chunk's execution address in `0x81FA`, and it
writes both before reading them, so the values shipped on the tape do not
matter.

## How the listing was made

It is not a linear disassembly. The real control flow is traced from the entry
points and only what is reached gets marked as code; the rest stays as data and
has to be explained.

- **55 entry points**, and every one carries, in `src/imagen.entries`, **why**
  it is an entry point: a pushed return address, a jump table, a self-modified
  operand. A test fails if any of them is left without a justification.
- **277 `D` directives** delimit the data ranges, each with its name and the
  width of its structure.
- `make sanity` crosses the two: no range declared as data may come out as
  code, and no entry point may land inside a data range.

The trace was also validated against the emulator: the program counter was
sampled over 200 seconds of real play on a Philips VG-8020 and 1,357 distinct
addresses turned up. **All 1,357 fall inside what the tracer marks as code, not
one outside.**

(The reverse does not hold: that sampling takes the PC every 0.5 ms and sees a
tiny fraction of what runs, so it says nothing about which code is dead. That
is measured a different way, in [Findings](FINDINGS.html).)

## The comments, measured

A complete listing is not much use if it says nothing. The series applies a
double yardstick:

    make densidad

    TOTAL             9790    3230     33.0%     1308       0

Nine thousand seven hundred and ninety instructions, three thousand two hundred
and thirty of them carrying a line comment: **33.0% density**. And the second
figure, which is the expensive one: **zero routines below 10%**, out of 1,308.

The series bar is 22% density and no weak routine. This is one of the densest
of the published disassemblies.

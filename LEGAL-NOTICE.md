# Legal notice and attribution

*(También disponible [en castellano](AVISO-LEGAL.md).)*

## Who owns what

**The game is not ours.** *Demonia* is a 1986 MSX game. Its own title screen,
which lives in the compressed map at `0x4281` and is read by decompressing it,
spells DEMONIA in large letters and is signed `(C) 1986 PAR SABLATOU CLAUDE`.
That **Microids** published it comes from the catalogue and not from the
binary, and it is said that way here. All rights in the game remain with their
holders.

The tape also carries a **machine code monitor** signed
`Copyright (C) 1984 LORICIELS` and `Auteur:Claude SABLATOU`, in the texts at
`0xD948`. It is documented here because it is part of what the tape contains,
and its rights likewise remain with their holders.

**What is ours** are the tools in this repository, the comments in the listing,
the analysis and the documentation. Those are released under `LICENSE`.

## What is in this repository

The thirteen `src/demonia_*.asm` files are the commented disassembly of the
tape. They are published for the **preservation, study and documentation** of a
title that is part of MSX software history.

The tape (`.cas`) is **not** distributed here. Anyone wanting to rebuild the
listings has to supply their own, and the `Makefile` checks its sha256 before
doing anything.

The pictures produced by `tools/mapas.py` are not artwork brought in from
elsewhere, nor emulator screenshots: they are the game's own screen,
reconstructed by replaying its decompressor over the compressed maps — the same
addresses and the same order that are in the listing — and developing each tile
the way the VDP would, using the patterns at `0x6000` and the colours at
`0x6800`. They are part of the proof that the binary has been read correctly:
if it had not, they would come out as noise.

## What it leans on

Nobody else's work. Everything asserted here comes from reading this binary,
and every claim carries its evidence beside it: the instruction that reads a
datum, the chain of twenty-six maps that ends exactly where it has to end, or
the sum that comes out on its own. What is not settled is said not to be, and
has its place on the open questions page.

## If you are one of the authors

If you worked on *Demonia* or hold rights in the game, and would rather this
material were not published, **say so and it comes down, no argument**. The
intent of this work is the opposite of harming you: it is to put on record how
it was made.

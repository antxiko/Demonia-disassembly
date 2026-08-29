# Getting started

This repository holds a **commented disassembly** of Demonia for the MSX
(Microids, 1986, cassette). Everything here comes out of the binary and can be
generated from it again.

## What you need

- **Python 3** (no third-party packages)
- **pasmo**, to reassemble
- **z80dasm**, used only for the mnemonics
- the tape, which this repository **does not distribute**

The tape goes in the root, named `demonia.cas`. It is exactly 58,334 bytes:

    sha256  69031ee25099df0703332ca74a64b52e6dd9909e4cfded4c3699be153adc5fc9

The `Makefile` asks for it by that sha256 and warns if it does not match.

## The test that matters

    make verify

This reassembles the thirteen listings with pasmo and compares the result
against the original `.cas`, byte for byte. Here that takes one step more than
a cartridge would: first every listing is checked on its own, and then the
chunks are glued back together in the order the tape carries them, with their
sentinels, their headers and their padding. If it prints `OK`, the disassembly
has invented nothing: it is the same tape written differently.

## Everything else you can run

    make            # the whole cycle: extract, trace, list, verify
    make listados   # regenerates the thirteen src/demonia_*.asm
    make sanity     # the checks reassembly does NOT cover
    make test       # the tests
    make densidad   # how many comments each routine carries
    make sobra      # the accounting for what the game carries and never uses
    make imagenes   # redraws the PNGs in docs/imagenes from the tape
    make web        # regenerates this site

`make sanity` is the one that watches for what a correct reassembly can hide:
data being read as code. The bytes come out the same either way, because they
do not change; the only thing that changes is what we say about them.

## The tests run without the tape

The nineteen tests in `tests/` **need neither the tape nor `make`**: they read
the thirteen published listings, which is where every byte lives — the `defb`
rows carry the data with its address, and the instructions carry theirs in the
generated comment.

That was deliberate. A test that skips itself when a file is missing is a place
to hide a check that never actually runs; and besides, what gets published is
the listing, so the listing is what needs watching. If someone hand-edits a
`defb`, the tests notice. No rigour is lost, because `make verify` already
proves that assembling those listings gives the tape back exactly.

## Where to go next

- [The game](THE-GAME.html) — what Demonia is and how it is put together
- [The tape](THE-TAPE.html) — thirteen blocks, three files sharing one name and
  26 KB hidden underneath the ROM
- [The code](THE-CODE.html) — the memory map, the tables and the stowaway
- [Findings](FINDINGS.html) — what turned up when we took it apart
- [Open questions](OPEN-QUESTIONS.html) — what could not be closed

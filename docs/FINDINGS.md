# Findings: what Demonia carries and never uses

[Getting started](GETTING-STARTED.html) · [The game](THE-GAME.html) · [The tape](THE-TAPE.html) · [The code](THE-CODE.html) · [Open questions](OPEN-QUESTIONS.html)

A complete disassembly does not only say what a game does: it also lays bare
what it carries and never uses. There is a fair amount of that on this tape,
and one thing that is not an ordinary leftover.

The figures come from `make sobra` (`tools/lo_que_sobra.py`), and each one says
which measurement it comes from. What is MEASURED and what is ASSUMED are kept
apart and labelled.

## The accounting, top to bottom

| what | bytes | % of tape |
|---|---:|---:|
| **the Loriciels monitor**, entire | **4,377** | **7.5%** |
| ...of which, code nothing reaches | 2,094 | 3.6% |
| padding and scraps of a byte or three | 455 | 0.8% |
| NOPs, repeated instructions and RETs that never run | 61 | 0.1% |
| declared data nothing points at | 314 | 0.5% |
| tape alignment padding | 18 | 0.03% |

Whole tape: 58,334 bytes.

---

## 1. The stowaway: a 1984 machine code monitor

Inside the game block, from `0xC000` onwards, travels **a complete machine code
monitor**. Not a leftover routine or two: a program with its command
interpreter, its disassembler, its single-step, its register dump and its error
messages in French.

He signs it, in the texts at `0xD948`-`0xD988`:

```
D948  Auteur:Claude SABLATOU
D95F  MONITEUR MSX
D96C  Copyright (C) 1984 LORICIELS
```

And the game's title screen, which lives in the compressed map at `0x4281` and
is read by decompressing it, says:

```
row 17            L'INTRUSION
row 19   (C) 1986 PAR SABLATOU CLAUDE
```

So **the game's author left his own working tool inside it**. A 1984 Loriciels
monitor riding along in a 1986 Microids game, because the same man wrote both.

(Careful with those two rows: they are the only ones that read back if the map
is dumped as text, because the title itself is made of graphic tiles, not
ASCII. Drawn with its patterns, the screen spells **DEMONIA** in huge letters
across the first eight rows, with `L'INTRUSION` small underneath as a
subtitle.)

### What is left of it, measured

| range | bytes | what it is |
|---|---:|---|
| `0xC076-0xC24C` | 471 | its variables and its stack (ends at `0xC0FF`) |
| `0xC24D-0xCFD3` | 3,406 | its code: command interpreter, disassembler, single-step |
| `0xCFD4-0xCFFF` | 44 | what survives of the disassembler's tables |
| `0xD900-0xDAC7` | 456 | its texts |

Two texts the game never uses have survived inside its variables:
`Press any key for retry` at `0xC085` and `MSXDOS  SYS` at `0xC0A0`.

### And it is still wired up

The monitor's entry point, **`0xC924`**, really is called from the game's own
code. At `0x9C6D`:

```
9C6D  3A 9B FC    ld a,(0xFC9B)     ; INTFLG
9C70  FE 03       cp 3
9C72  CC 24 C9    call z,0xC924     ; and into the monitor
```

`0xFC9B` is INTFLG, the variable where the BIOS records that STOP has been
pressed; the value 3 is CTRL+STOP according to the MSX documentation. **It is
the programmer's back door**: stop the game and drop into the monitor.

*(MEASURED: the bytes and the meaning of `0xFC9B`. ASSUMED: that this was the
intent rather than something else; the binary says what the code does, not
why.)*

### But its commands no longer answer

And here is the good part. The monitor recognises its commands by looking the
typed initial up in a table of 15 three-byte entries. The loop is at
`0xC28D`-`0xC299` and leaves no room for doubt:

```
C288  4E          ld c,(hl)        ; the typed character
C289  CB A9       res 5,c          ; to upper case
C28D  21 C6 D5    ld hl,0xD5C6     ; the command table
C290  06 0F       ld b,15          ; fifteen commands
C292  7E          ld a,(hl)        ; this command's initial
C293  B9          cp c
C294  28 25       jr z,0xC2BB      ; found: jump to its handler
C296  23 23 23    inc hl x3        ; three bytes per entry
C299  10 F7       djnz 0xC292
```

**There is no table at `0xD5C6`.** The game's 24 screen records run from
`0xD0C0` to `0xD8FF`, 88 bytes each, and `0xD5C6` lands on byte 54 of record
number 14 (`0xD590`-`0xD5E7`). The 45 bytes the loop walks, `0xD5C6` to
`0xD5F2`, are the end of that record and the start of the next: seventeen zeros
and then screen data. The game's data was written straight over the monitor's
command table.

And not only over that one: the monitor's disassembler reads its mnemonics from
`0xD64A`, `0xD652` and `0xD662` (instructions at `0xCFC0`-`0xCFE0`), and those
three places are also zeroed, covered by screen records 16 and 17.

**Measured consequence:** with all fifteen keys at zero, the `cp c` at `0xC293`
can only match if the typed character, with bit 5 cleared, is 0 — and then it
jumps to a handler whose pointer is `0x0000`. Any other key walks the fifteen
entries in vain, prints `Commande illegale` (`0xD98D`) and asks again. **The
monitor boots, paints the registers and obeys nothing.**

Hence the **2,094 bytes of code nothing reaches**, which are almost all of its
command handlers:

```
0xBDC3..0xBDFE    60      0xCAB0..0xCAEE    63      0xCDE8..0xCDED     6
0xC33F..0xC567   553      0xCAF5..0xCB06    18      0xCE0B..0xCE15    11
0xC5B6..0xC63E   137      0xCB10..0xCB15     6      0xCF51..0xCF8D    61
0xC661..0xC747   231      0xCC63..0xCC73    17      0xCF93..0xCF9A     8
0xC756..0xC923   462      0xCC78..0xCCEF   120      0xCFA3..0xCFD3    49
0xC97A..0xCA63   234      0xCD84..0xCDB7    52      0xDAC8..0xDACD     6
```

They are whole, well-formed routines. `0xC33F` asks whether a character is a
digit; `0xCD84` prints a number in decimal by subtracting 10000, 1000, 100 and
10; `0xC5B6` writes `Resultat= `. None has run since the tape was recorded.

### The fossil

The monitor single-steps by copying the stopped program's instruction into a
four-byte buffer at `0xCC5F` and running it there. `0xCBB9` zeroes those four
bytes before every step, so what is recorded on the tape is **the last
instruction that monitor ever single-stepped before someone did the BSAVE**:

```
CC5F  2A 78 80 00      ld hl,(0x8078)
```

And `0x8078` is inside this very game's variable page.

*(MEASURED: the four bytes, that `0xCBB9` clears them and `0xCBDB` fills them,
and that `0x8078` falls in `0x8000`-`0x80FF`. ASSUMED: that the session was a
debugging session on this game. It fits, but the binary does not say so.)*

---

## 2. Branches that cannot execute: none

The classic pattern was searched for — a comparison deciding another
comparison, the `cp 9` case from Konami's Mahjong — with
`tools/ramas_imposibles.py`, in both its forms:

1. `cp N1` + `jr nz`, and later `cp N2` with N2 different, with A unchanged and
   nobody branching in between;
2. A loaded with a constant (`ld a,N` or `xor a`) and compared against another.

**Result: neither turns up anywhere on the tape.** That is a negative result and
it is reported as one. The only thing of that family here is of another kind and
it is above: not a badly written comparison, but an erased comparison table.

---

## 3. Scraps of a byte and of three: 455 bytes

Labelled by their CONTENT, not by eye (`tools/rellena_huecos.py` looks at the
bytes and the label says which measurement it comes from):

| class | ranges | bytes |
|---|---:|---:|
| padding at 0x00 or 0xFF | 137 | 367 |
| loose RETs, alone or with zeros behind | 41 | 60 |
| orphaned jumps | 3 | 11 |
| a gutted slot switcher | 1 | 8 |
| `jr $`, that is a hang, that nobody reaches | 2 | 4 |
| a call to the monitor nobody reaches | 1 | 3 |
| an orphaned `or a / ret z` | 1 | 2 |

The good ones:

- **`0x8148`, eight bytes.** Read as code they are `di / jp 0xA0F0` and, glued
  behind, `ld (0xFFFF),a / ret`, which are the last two instructions of a slot
  restore exactly like the one at `0x8139` and the one at `0x8126`. It is the
  corpse of a third switcher that somebody put a jump through the middle of.
  Nobody calls it.

- **`0xAA95`, three bytes: `call 0xC924`.** Another call to the monitor, this
  one with no branch reaching it at all. Somebody had more than one back door.

- **`0x8F0B: jp 0x8A85`** and **`0xA634: jp 0xDAD0`**, two loose jumps between
  routines. The second points at the game's restart routine, which is alive and
  reached by six conditional jumps from elsewhere.

- **`0x85CA: ld hl,0x0000`.** It is the third variant of the vector load at
  `0x804E`: the other two, `0x85C0` and `0x85C5`, load `0x85E3` and `0x8638`.
  This one would load "no routine at all". Nobody uses it.

- **Forty-one loose RETs.** Routines reduced to nothing that still take up their
  byte.

---

## 3b. What turned up while commenting the listing

These come from no tool: they came out of reading the code instruction by
instruction in order to write the comments. Each carries its address, which is
what lets anyone check it.

- **`0x9134`: the same instruction written twice.**

  ```
  9134  21 58 80    ld hl,0x8058
  9137  21 58 80    ld hl,0x8058
  913A  35          dec (hl)
  ```

  Three bytes that do nothing. The second load overwrites the first with the
  same value.

- **Five `RET NC` and `RET NZ` that cannot execute.** When two returns with the
  same condition follow each other, the first has already gone and the second
  never gets to run:

  ```
  823A  D0 D0 D0    ret nc / ret nc / ret nc   (in the tape loader)
  8C3E  C0 C0       ret nz / ret nz
  BFE3  C0 C0 C0    ret nz / ret nz / ret nz
  ```

  Eight bytes in all that have sat there since 1986 without executing once.

- **Fifty bytes of NOP inside live code**, in eleven runs of three to six:

  ```
  A401 (4)  A640 (5)  A65D (6)  A67B (6)  A701 (5)  A746 (3)
  A947 (3)  B14E (3)  DC01 (6)  DC12 (6)  DE2C (3)
  ```

  The two runs of six at `0xDC01` and `0xDC12` sit immediately before and
  immediately after an LDIR that copies the screen tables into the hidden RAM,
  that is, exactly where a slot switch would go: somebody removed it and left
  the hole. And the one at `0xA640` follows a `cp 0` that runs after an `or a`
  which has already decided the same thing.

- **`0xC3FE`, inside the monitor**: on the "Debordement" path there are two
  consecutive HL loads, `ld hl,(0xD3DA)` and `ld hl,(0x1103)`, and two NOPs.
  The first is useless because the second overwrites it, and `0x1103` falls
  inside the BASIC ROM.

- **Code that writes over itself**, which is not waste but is worth seeing:
  `0xABB3` writes into `0xAB1A`, the operand of a `ld c,n`, to switch sprite
  bank; `0x864E` and `0x8653` patch two operands, of `0x8603` and `0x8623`; and
  `0xC645`, inside the monitor, writes the return address over the operand of
  the `jp` at `0xC65E`.

---

## 4. Data nothing points at: 314 bytes

CANDIDATES, not dead code: the cross-check only sees addresses that appear as
an immediate in a traced instruction or inside a declared pointer table. An HL
that gets there by adding is invisible from here.

| range | bytes | what it looks like |
|---|---:|---|
| `0xD030-0xD0BF` | 144 | the behaviour table for the 24 screens. `0xDC07` reads it starting from `0xD000` and adding, which is why it never appears as a target |
| `0xCFD4-0xCFFF` | 44 | what survives of the monitor disassembler's tables |
| `0x944A`, `0x9D95`, `0xA0EF`, `0xA37F`, `0xBDB1`, `0xDFC1` | 126 | six short ranges between routines |

---

## 5. What the tape spends on being a tape: 18 bytes

Surprisingly little. A `.cas` block has to start on a multiple of eight, so up
to seven padding bytes can follow each one. On this tape only five of the
thirteen blocks need any, and they add up to 18 bytes. (The 104 sentinel bytes,
the 48 of file header and the 12 of BIN header are not padding: they are the
format.)

The 256 bytes of BASIC loader, on the other hand, go nearly empty: the two
lines take 93 bytes and the other 163 are the `0x1A` padding the MSX writes to
fill the 256-byte chunk. **64% of the tape's first file is padding.**

---

## 6. What did not run, and why it does not count

The program counter was sampled over 200 seconds of play on a Philips VG-8020,
with the tape really loaded: 398,593 samples, 1,357 distinct addresses inside
the game. Of the 17,676 bytes of reachable code, 1,357 were seen executing.

**That 7.7% does not measure dead code and is not used as such here.** The
sampling takes the PC every 0.5 ms and sees a tiny fraction of what runs; and
the window was the presentation screen, not a whole game.

What is worth something is the other way round: **of the 1,357 addresses seen
executing, all 1,357 fall inside what the tracer marks as code.** Not one
outside. That validates the trace, which is what the measurement was for.

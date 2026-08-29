# Open questions

[Getting started](GETTING-STARTED.html) · [The game](THE-GAME.html) · [The tape](THE-TAPE.html) · [The code](THE-CODE.html) · [Findings](FINDINGS.html)

What is still open, keeping MEASURED and ASSUMED apart. What is measured
carries its measurement; what is assumed is labelled as such and has not been
written into the listing as if it were a fact.

---

## MEASURED

### The tape

- Thirteen blocks. Three named files, all called `DEMON`: an ASCII one (the
  BASIC loader), a 249-byte BIN at `0x8180` and a 24,576-byte BIN at `0x8000`.
  Between the two BINs go seven headerless blocks.
- Line 50 of the BASIC loader is `BLOAD"CAS:DEMON",R:RUN`. Since tape is
  sequential, the first pass finds the small BIN and the second — after the
  `RUN` — the big one. They share a name on purpose.
- `make verify` rebuilds the whole `.cas`, sha256
  `69031ee25099df0703332ca74a64b52e6dd9909e4cfded4c3699be153adc5fc9`.

### The layout in memory

- The table at `0x8180` declares the seven chunks. `tools/cuerpos.py` checks
  that every entry matches the size of its block and aborts if it does not.
- The five chunks hidden under the ROM match the RAM of a running openMSX
  **byte for byte** (`tools/coteja_ram.py`), and also the RAM snapshots inside
  a replay recorded on a different machine (a Sony HB-20P). Two independent
  measurements.
- The game block differs from the tape by 83 bytes the moment it starts, all
  within `0x8000`-`0x80FF`. Over 200 seconds of play 134 bytes change, 133 of
  them on that same page and the other one being `0x8C5E`.

### Geometries

- **Sprites**: 33-byte records (32 of 16×16 pattern + 1 of colour), in two
  banks, 242 records at `0x0000` and 214 at `0x1F32`. It comes from the routine
  at `0x8292` and both counts come out exact.
- **Screen maps**: 26 maps compressed with `0xFF <tile> <how many>`.
  Decompressed they give 640 tiles (32×20) each and end exactly where the next
  begins. The decompressor is `0x819D`.
- **Scenery**: 2,048 bytes of pattern at `0x6000` and 2,048 of colour at
  `0x6800`, uploaded to all THREE thirds of the screen (`0x8150`). The three
  thirds share their artwork.
- **Music**: four-byte steps (coarse and fine tone for channel B, and for
  channel C). The pointer starts at `0x7900` and on reaching `0xFF` rewinds to
  `0x79C8`, not to the beginning.

### The title

The game is called **DEMONIA**, and its own title screen says so: the
compressed map at `0x4281`, decompressed and drawn with its patterns
(`tools/mapas.py`, PNG in `docs/imagenes/portada-titulo.png`), carries DEMONIA
in huge letters across the first eight rows. Underneath, in small letters,
`L'INTRUSION` on row 17 and `(C) 1986 PAR SABLATOU CLAUDE` on row 19.

Those two bottom rows are the only ones that read back if the map is dumped as
TEXT, because the title is made of graphic tiles and not of ASCII. A dump like
that fooled us once, and that is where the idea that the game was called
`L'INTRUSION` came from: it is the subtitle. The tape is called DEMONIA too.

---

## ASSUMED (labelled as such, and not written into the listing as fact)

- **That `0x9C72` is a debugging back door.** What is measured is that it reads
  INTFLG (`0xFC9B`), compares against 3 and calls the monitor's entry point.
  That the intent was to leave a door open is a reading, not a datum.
- **That the `ld hl,(0x8078)` in the single-step buffer at `0xCC5F` is the
  fossil of a debugging session on this game.** What is measured are the four
  bytes and that `0x8078` falls in the variable page. It fits, but the binary
  does not say so.
- **That the monitor's command table was erased by the author himself when he
  built the game on top.** What is measured is that there are screen records at
  `0xD5C6` and not a table. Who did it and when, no.
- **The loader's two initial values (`0x81F8` = `0x8188`, `0x81FA` = `0xC050`)**
  are consistent with a photograph of memory taken while chunk 2 was running.
  That is all that can be said: the code writes both before reading them, so
  they do not matter.

---

## OPEN: what could not be closed

### 1. The user's replay cannot be reproduced here

`Demonia.omr` was recorded on a **Sony HB-20P** and openMSX asks for its ROM by
sha1 (`63050d2d21214a721cc55f152c22b7be8061ac33`). That ROM is not on this
machine and cannot be downloaded.

Three attempts were made:

1. Repointing the tape reference to the local copy with
   `tools/prepara_replay.py`. The path is corrected (24 references), but the
   failure was elsewhere.
2. Putting a substitute MSX1 ROM under that name into a private `filepool`,
   without touching the user's installation. openMSX resolves system ROMs **by
   sha1**, not by name, and rejects it.
3. Rewriting the sha1 inside the `.omr` to point at the substitute. **The
   replay loads and runs its 926 seconds**, but with a different ROM the tape
   load desynchronises: 100% of the 1,854,327 PC samples land in the BIOS
   cassette routines (`0x046F`, `0x047B`, `0x1B2A`…) and the game never gets
   going. The measurement is worthless and has not been used.

**What the replay did give up, without an emulator**: opening it with gzip and
decompressing its twelve RAM snapshots. From the fourth on (t=256 s) the game
block matches the tape 99.5%, and the five chunks hidden under the ROM match
100%. So in a real game the memory layout is exactly the one this project
describes.

**To close it you need**: the file `hb-20p_basic-bios1.rom` with that sha1 in
openMSX's `systemroms`. With that, `tools/omsx_replay.tcl` gives the PC
sampling for a whole game and section 6 of [Findings](FINDINGS.html) stops
being a weak datum.

### 2. What the game does, played

No play session has been documented. What is known about the game comes from
the code and its data: 24 screens with their 88-byte record and their four
behaviour routines, a twelve-opcode script interpreter, a scoreboard with
`SCORE=`, `RECORD=` and `FORCE=`, and a `GAME OVER`. Tying each screen to what
is actually seen is still to do, and the right road for that is the replay in
point 1.

### 3. The screen records, inside

We know they are 24 records of 88 bytes at `0xD0C0`-`0xD8FF` and that byte 84
of each carries the marker `FF <screen number in ASCII> FF`. The remaining 88
bytes have **not** been broken down field by field. There are visibly groups of
three bytes starting with `0x06`, `0x0E`, `0x15` and `0x1B` — numbers that grow
and that could be positions — but that is an impression, not a measurement, and
so it is not in the listing.

### 4. The short unidentified tables

Twelve data ranges are left with a name but no explained use, because we know
WHO reads them but not WHAT FOR: `0x89F1`, `0x8C58`, `0x9B47`, `0xA5E4`,
`0xA7FF`, `0xB4F0`, `0xB540`, `0xBA64`, `0xBDB1`, `0xDAD7` and the two tile
tables `0xA830` and `0xDAA3`. In the listing they carry the address of the
instruction that loads them, which is what is known.

`0xB4F0` we do know the shape of: seven ten-byte records, with fields advancing
in a fixed step from one record to the next (+0x18 in the third byte, +0x300 in
the following pair, +1 in the eighth). It looks like a table of seven identical
things laid out in a row; what things, has not been measured.

### 5. The music's tempo

The player at `0x7F90` changes note every 14 calls (`0x7F9B`). **How many calls
a second that is has not been measured**, so no tempo in notes per minute can
be given, nor whether it depends on PAL or NTSC. What is measured are the PSG
periods: the first step gives 679 on channel B and 339 on C, that is 329.5 Hz
and 659.1 Hz with the MSX clock (3,579,545/16), the same note an octave apart.

### 6. The three RET NC in the loader

At `0x823A` there are three `RET NC` in a row where one would do: the first has
already returned. No explanation has been found. It could be a relative jump
that was changed to a RET and left two bytes behind, but that is a guess.

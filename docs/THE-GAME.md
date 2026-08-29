# The game

[Getting started](GETTING-STARTED.html) · [The tape](THE-TAPE.html) · [The code](THE-CODE.html) · [Findings](FINDINGS.html) · [Open questions](OPEN-QUESTIONS.html)

Demonia is a single-screen platform and exploration game. You start in a
graveyard, out in the open — stars, grass, headstones and red earth — and go
down into brick galleries with ladders, water and doors.

Everything below is **measured against the binary**. Anything that is a reading
rather than a fact is said to be one.

## Twenty-four screens and twenty-three maps

The table at `0xD000` has twenty-four entries, one per screen, each pointing at
a compressed map in the hidden page. But the distinct maps are
**twenty-three**: entries 13 and 14 both point at the same one, at `0x4D44`.

Each map is stored with a run-length scheme that takes one line to read:

    0xFF <tile> <how many>     repeat that tile that many times
    any other byte             one tile

and decompressed it yields **640 tiles, that is 32 columns by 20 rows**, which
is the game screen. The decompressor is the routine at `0x819D` and it leaves
the map at `0x5480`. From there, working out a cell is always the same:

    0x5480 + row*32 + column

That twelve-instruction block turns up again and again throughout the listing.
The five `add hl,hl` are the multiply by 32.

The maps run from `0x43DE` to `0x5468` and **chain with no byte of gap or
overlap**: each one ends exactly where the next begins. That is what proves the
format has been read correctly, and there is a test for it.

The most expensive is screen 15's, at 347 compressed bytes; the cheapest is
screen 2's, at 81. The more a tile repeats, the less the map costs.

## Each screen's record

Behind the map table there are two more, and they are what makes each screen
behave differently:

| address | what it is |
|---|---|
| `0xD000` | twenty-four pointers to each screen's compressed map |
| `0xD030` | the **behaviour table**: twenty-four rows of four routine pointers |
| `0xD0C0` | the **records**: twenty-four 88-byte records, one per screen |

The behaviour table is this game's nearest thing to a script: up to four things
that can happen on a screen. Unused slots are not left at zero, they are filled
with `0xFD9A`, the sound vector; that is, "nothing to do here" is written as a
call to something harmless.

The records are recognisable because **every one carries the marker
`FF <screen number in ASCII> FF` at byte 84**: the first at `0xD114` and the
last at `0xD8FC`, always 88 bytes apart. That marker is what made it possible
to delimit them one by one.

And there sits one of the good things about this tape: **the Loriciels
monitor's command table and its mnemonic tables ended up buried underneath
those records**. That is in [Findings](FINDINGS.html).

## What moves

The player lives in three bytes of the variable page: `0x8049` and `0x804A` are
X and Y, and `0x804B` is the frame to draw.

Facing them are two kinds of enemy, and the code treats them separately:

- **The chaser** (`0x9E88`) heads straight for the player and **speeds up every
  four steps**. `0x9638` compares the two positions with a thirty-two pixel
  window and, if they meet, wakes it up.
- **The creature**, which has numbered states and moves between them (`0x9975`,
  `0x99C9`, `0xADD8`). In state 1, if it is not busy, it checks whether the
  player is within reach.

Then there is what falls (`0xB61A`), what enters from the side of the screen
(`0x9518`, with a draw at `0x9E30`) and the objects, which are drawn two cells
by two (`0xA60A`).

## The sprites

Sprite artwork is not stored loose: it goes in **33-byte records**, 32 bytes of
16×16 pattern plus one of colour. The 33 is not a disassembler's choice, it
comes from the `ld de,0x0021` at `0x82A9`; and the `ld bc,0x0042` at `0x82AF`
says **two records are read at a time**.

There are two banks, and both counts come out exact: **242 records** at
`0x0000` and **214** at `0x1F32`. The game switches bank by writing over
itself: `0xABB3` writes into `0xAB1A`, which is the operand of a `ld c,n`.

## Screen and sound

The MSX1 cannot scroll in hardware, so the game does it by hand and carries
**one routine per direction** (`0x81CF` onwards): drop a column, shift the
rows, and the same the other way.

The scenery is 2,048 bytes of patterns at `0x6000` and another 2,048 of colour
at `0x6800`. The routine at `0x8164` uploads them **to all three thirds of the
screen** — it saves HL with a `push` and restores it each time round — so tile
N has the same artwork at the top, in the middle and at the bottom.

The music is four-byte steps: coarse and fine tone for channel B, and the same
for channel C. The pointer starts at `0x7900` and, on reaching the `0xFF`,
**rewinds to `0x79C8` and not to the beginning**: the intro plays once and
never comes back.

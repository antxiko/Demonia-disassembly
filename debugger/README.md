# The Loriciels monitor, reconstructed / El monitor de Loriciels, reconstruido

Inside Demonia's tape travels a 1984 machine-code monitor (a **debugger**) by
Claude Sablatou for Loriciels. On this tape it is **mute**: the game recorded its
screen data over the monitor's own data section (`0xD000`-`0xD8FF`), erasing its
command table, its disassembler tables and about a dozen helper routines. This
folder is the work of bringing it back.

> **This is a reconstruction, NOT a recovery. We do not have 100% of Sablatou's
> code.** About 40% of the monitor — the part the game erased — no longer exists
> and has been rebuilt as a *functional equivalent*: new code and data that meet
> the same contracts the surviving 60% expects. It is not the original.
>
> **Esto es una RECONSTRUCCIÓN, NO una recuperación. No tenemos el 100% del
> código de Sablatou.** Cerca del 40% del monitor — lo que el juego borró — ya no
> existe y se ha rehecho como *equivalente funcional*. No es el original.

Full story with screenshots: **[The debugger](../docs/THE-DEBUGGER.md)** ·
Historia completa: **[El debugger](../docs/es/EL-DEBUGGER.md)**.

## What is here

| file | what it is |
|---|---|
| `CONTRATOS.md` | the reverse-engineering notes: every lost piece and the contract it must meet |
| `gen_disasm.py` | generator of the equivalent Z80 disassembler (emits `disasm.asm`) |
| `helpers_arranque.asm` | the rebuilt boot helpers (`0xD20B` INITXT, `0xD272` CHGET, screen clears) |
| `lanzador.asm` | a small launcher that calls the monitor entry `0xC924` with recognisable registers |
| `driver.asm` | a harness that disassembles a byte range to prove the disassembler (38/38 checked) |
| `omsx_*.tcl` | openMSX scripts that boot the monitor and captured the screenshots |
| `capturas/` | the raw emulator frames used on the web page |

## What was rebuilt, and where it lives in memory

- **The disassembler** (`gen_disasm.py` → `disasm.bin`) is a self-contained Z80
  disassembler covering the whole instruction set (unprefixed, CB, ED, DD/FD,
  DDCB/FDCB). It loads at **`0xA000`** (out of the way of the BIOS system RAM at
  `0xF000+`, which corrupted an earlier placement) and the monitor's single call
  site at `0xC575` is repointed to it. Contract: `IX` = address in, mnemonic text
  to `0xC1E4` and length to `0xC1E3` — exactly what the surviving display code
  wants.
- **The boot helpers** (`helpers_arranque.asm`) fill the erased `0xD200`-`0xD2E8`
  slots at their exact addresses.
- **The command table** at `0xD5C6` is rebuilt entry by entry; the handlers are
  the surviving orphan routines. Wired and proven: `G` → `0xC5D3` (Go) and `L` →
  `0xC535` (list/disassemble). Numbers use a trailing `H` for hex (`L7FE0H,7FE6H`).

## How it was validated

Everything was run on a real MSX1 (openMSX `-machine Philips_VG_8020`): the
monitor boots and paints the twelve registers; typing the author's fossil command
`G7FE0H` jumps to the sound routine (breakpoint confirmed); and the disassembler
was checked **38 of 38** instructions correct with `driver.asm`, then shown on
screen disassembling the monitor's own entry code. No mock-ups — every screenshot
is a raw emulator frame.

## Rebuilding it

Requires your own copy of the tape (see the project root) so `make` can produce
`work/imagen64k.bin`, the surviving monitor image. Then:

```
python3 gen_disasm.py disasm.asm && pasmo disasm.asm disasm.bin
pasmo helpers_arranque.asm helpers_arranque.bin
pasmo lanzador.asm lanzador.bin
```

The monitor image is `work/imagen64k.bin[0xC000..0xDAC7]` with the boot helpers
patched in at `0xD20B`, the command table at `0xD5C6` given `G`/`L`, and the call
at `0xC575` repointed to `0xA000`. Load that plus `disasm.bin` at `0xA000` and
`lanzador.bin` at `0xE000`, then run — see the `omsx_*.tcl` scripts for the exact
steps that produced the screenshots.

# ReNFS hybrid core for MiSTer (Need for Speed SE)

@hybrid/CLAUDE.md

## This core

- Name everywhere: `ReNFS` (the engine: core, folders `games/dnk/ReNFS/` and `logs/dnk/ReNFS/`, `_Other/dnk/dnk-ReNFS_*.rbf`, release), `renfs` (game submodule, binary in `build/`, log, lock). The games and their menu entries (`_Other/dnk-<title>.mgl`): `package/games.txt` (in the zip as `games/dnk/ReNFS/games.txt`, from which the database's build makes the launcher's catalogue).
- The game is the `renfs/` submodule, branch `mister`. Its MiSTer code is behind the `MISTER_HYBRID` build option.
- Build: `./build.sh` (game), `./core/build_core.sh` (FPGA), `./package.sh` (zip in `dist/`), `MISTER=root@<address> tools/deploy.sh`.
- Release: the zip in `releases/`. Players get it once it is published to the database, only when Danik asks: `hybrid/launcher/distribution.py publish ~/dnk_Distribution_MiSTer releases/ReNFS_YYYYMMDD.zip` (the rule in `hybrid/CLAUDE.md`).
- Try a build on the MiSTer without installing it: `MISTER=root@<address> tools/test_on_mister.sh <id>|list|nodata|log|stop` (the rule in `hybrid/CLAUDE.md`).
- Lines marked `GAME:` in the scripts and `TODO` in the READMEs are the places the template left for this game.

<!-- Notes that are only true for this game go below. -->

## This game

- The game's own repository is `~/renfs` (to become `ItsDanik/renfs`, branch `main`, the PC version; ask Danik before creating it on GitHub). Its `CLAUDE.md` is the summary of the reverse engineering, `docs/NOTES.md` the full record, **`docs/HANDOVER.md` where the work stands**. The submodule here will be its branch `mister`, kept equal to `main`; it is not added yet.
- The game is a hand-written reimplementation of `NFS_DOS.EXE` (Watcom, DOS/4GW), as OpenScreamer is of Screamer (`~/MiSTer-openscreamer`, the model for this core).
- The player copies the CD's files only (the ISO extracted, `NFSSE/`): no installed copy is needed.
- Video: races at 320x200 (and 640x480 in the game's high detail); **the front end exists only at 640x480**. The menus stay 640x480 on the MiSTer, interlaced on a 15 kHz screen (Danik, 2026-10-18).

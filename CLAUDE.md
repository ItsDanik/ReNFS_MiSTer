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

- The game's own repository is `~/renfs` (`github.com/ItsDanik/ReNFS`, public, GPL-3; branch `main` is the PC version, 0.6.0b released). Its `CLAUDE.md` is the summary of the reverse engineering, `docs/NOTES.md` the full record, **`docs/HANDOVER.md` where the work stands**. The submodule here is its branch `mister`: `main` merged in, plus the MiSTer code behind `MISTER_HYBRID`.
- The game is a hand-written reimplementation of `NFS_DOS.EXE` (Watcom, DOS/4GW), as OpenScreamer is of Screamer (`~/MiSTer-openscreamer`, the model for this core).
- The player copies the CD's files only (the ISO extracted): **the whole CD into `games/dnk/ReNFS/NFSSE/`** (as on the PC, the folder beside the program); settings, records, saved games, replays and the joystick's calibration in `games/dnk/ReNFS/saves/` (Danik, 2026-10-21).
- Video: **the front end exists only at 640x480**; the menus stay 640x480 on the MiSTer, interlaced on a 15 kHz screen (Danik, 2026-10-18).

### Decisions from the interview (Danik, 2026-10-21)

- **Resolution**: an OSD line (races at 320x200, 320x240, 640x480), and the game's own row in the graphics screen follows it. Whether 640x480 races stay on the list is **decided after measuring** on the MiSTer.
- **Smooth motion** (the port's in-between pictures, F11 on the PC): an OSD line, on by default if the MiSTer is fast enough (measured).
- **The OSD open in a race pauses the race.**
- **Buttons**: `J1,Accelerate,Brake,Gear Up,Gear Down,Camera,Handbrake,Map,Pause,Menu OK,Menu Back` with `jn,A,B,R,L,X,Y,Select,Start`; R2 / L2 accelerate and brake too, analogue (`MH_ReadTriggers()`); **L3 the horn, R3 the nitro** (`MH_ReadStickButtons()`); Start the pause menu (Esc).
- **Analogue on the MiSTer is automatic**: a pad's stick and triggers steer and drive progressively from the start (on the PC they need Joystick in Options -> Controls, as the original; that rule stays on the PC).
- **Rumble**: an OSD line Off / On / Strong, **On** by default.
- **Force feedback for wheels**: added to the framework (`hybrid/hps`, Linux FF constant force and periodic effects), written blind (nobody here has a wheel), tested with a virtual device; a tester with a wheel confirms later.
- **Cheats**: an OSD page with On/Off lines, remembered, each doing what typing its code does: Mirrored Tracks (SKCART), Rally Tracks (EARALLYE), Lost Vegas (CASINOVILLE), Warrior Car (CONCEPTCAR), Rocky Road (ROCKYROAD), Turbo (TURBO), Nitro (NITRO), Explode (EXPLODE), No Mercy (End held as a head to head starts). A keyboard still types them as in the original.
- **English only** on the MiSTer (no language line).
- **Names typed with the pad**: up / down change the letter under the cursor, right the next letter, left back, Menu OK confirms; a keyboard types as before.
- **GitHub**: `ItsDanik/ReNFS_MiSTer` public and the `mister` branch of `ItsDanik/ReNFS` pushed **once it runs on the MiSTer and Danik has tried it**. Local until then.
- **Screenshots** in `docs/screenshots/` of both repositories, as OpenScreamer (made by a script from the PC build).
- **The actual MiSTer is shared with other agents: ask Danik before every use of it** (tests, benchmarks, `tools/test_on_mister.sh`).

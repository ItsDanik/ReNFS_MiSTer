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
- **After measuring (Danik, 2026-10-21)**: 640x480 races stay, **Smooth Motion greyed out while
  640x480 is chosen** (33 pictures a second there); 640x480 is 480i on a 15 kHz screen and progressive
  on 31 kHz / HDMI. **Defaults: 320x200, Smooth On.** **Races at 320x240, and also 640x200 and
  640x240** (as OpenScreamer's modes): the Resolution line has all five. Written 2026-10-21
  (renfs NOTES §4.27): 640x240 / 640x200 the 640x480 race with only the shown rows painted;
  320x240 the 320x200 screen stretched with the 3D view at 240 rows of its own (`tall.c`; the
  cockpit's frame rules out moving the dashboard apart as OpenScreamer did). **Measured
  2026-10-21** (Replay 1, `RENFS_PERF=1 MISTER_HYBRID_PACE=1`, drawing ahead, every 5 s;
  pictures a second, ms a picture, pictures of 300 shown a field late): 320x200 smooth 59.5 to
  59.7, 6 to 8 ms, 0 to 1; 320x240 smooth 58.2 to 59.7, 7.4 to 10.1 ms, 0 to 7; 640x200 smooth
  59.2 to 59.7, 9.4 to 13.1 ms, 0 to 3; 640x240 smooth 57.2 to 59.7, 10.3 to 14.7 ms, 0 to 32
  (the night's busy stretch); 640x240 without smooth 33.3 steady. So Smooth Motion stays
  allowed at all four (greyed only at 640x480). The core's screenshots: 320x240 and 640x240
  pictures as the PC's.
- **HUD (Bottom), 0 by default; HUD (Top) always greyed** (Danik, 2026-10-22, after the
  replay's bar was hidden by his CRT): lifts the replay's / watching bar and, from outside,
  the small rev counter and the map (renfs NOTES §4.27); the line's entries 0..24 in order
  (not the framework's 10 first), read by `mister_hud_bottom()`, greyed at 200 lines.
- **The movies' corrupt field** (Danik, 2026-10-22): a palette change went out a field before
  its picture drawn ahead; pictures with new colours are now sent at once.
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

### Measured on the MiSTer (2026-10-21, Replay 1: eight cars in the desert)

`RENFS_PERF=1` (the game's speed lines) and `MISTER_HYBRID_PACE=1`, the replay started by
`RENFS_REPLAY=REPLAY1.RPL` in `TEST_ENV`; `RENFS_RES=320|640`, `RENFS_SMOOTH=0|1` override the OSD.
The race's steps cost 0.1-0.3 ms a picture: the time is the drawing.

| Setting | A picture | Pictures a second | Shown twice / never, in 300 fields |
|---|---|---|---|
| 320x200, smooth, at once (`MISTER_HYBRID_AHEAD=0`) | 6-10 ms | 59.6 | up to 41 |
| 320x200, smooth, drawn ahead | 6-10 ms | 59.6 | 0 |
| 640x480, smooth or not, a picture every field | 13-24 ms | 37-59 | up to 177 |
| 640x480, no smooth, a picture a step | 13-24 ms | 33.3 (every step) | (the same picture sent again) |

Decisions: **drawing ahead kept** (`mister_present_at()`, `MH_PresentAtField(F + 2)`: it takes the
320x200 stutter from 41 to 0). Without smooth motion the MiSTer draws a race picture only for a
new step (`race.c`): at 640x480 every step is shown, 33.3 a second, as the original. 640x480 cannot
draw 60 pictures a second here, so smooth motion there gains nothing.

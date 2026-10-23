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
  the small rev counter and the map (renfs NOTES §4.27); `mister_hud_bottom()` reads it with
  `MH_HudMargins()` (since host version 16 the framework's entries are 0..24 in order too),
  greyed at 200 lines (menu mask bit 0); HUD (Top) greyed by the core's `HUD_EDGES` 2'b10.
- **The movies' corrupt field** (Danik, 2026-10-22): a palette change went out a field before
  its picture drawn ahead; pictures with new colours are now sent at once.
- **The OSD open in a race does not pause it** (Danik, 2026-10-22, changed from the interview's "pauses"): as on all his cores, and HUD (Bottom) is seen moving as it is changed. The framework gives the game no input meanwhile, so the car rolls on.
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

### The painters made faster (2026-10-22)

The heaviest scene (Danik): REPLAY.RPL (alpine) from the SKY camera, which the replay switches
to by itself from about 25 s, at 640x240 with smooth motion. The painters were made faster with
every picture the same (renfs NOTES §4.28, `RENFS_SHOTSUMS`): measured on the MiSTer from 30 s on,

| Build | A picture (avg / worst 5 s / slowest) | Pictures a second (avg / min) | Fields without a new picture |
|---|---|---|---|
| before | 14.0 / 16.7 / 22.7 ms | 56.3 / 51.2 | 605 of 9000 |
| after | 8.4 / 9.7 / 17.3 ms | 59.6 / 59.1 | 6 of 9000 |

Danik: "performance is great". **Possible future optimizations (not now, Danik 2026-10-22):**
640x480 measured again (smooth motion there may now pay; Smooth Motion is greyed there); the
painting split over the ARM's two cores (the second only copies the pictures to the core).

### Host version 17 (2026-10-23)

- Built against Hybrid_MiSTer 68871f4: the game's logo at its start (`package/logos/SE.png`,
  Danik's, 440x200, reduced to 255 colours by `make_logo.py`) in the start order of hybrid
  5186586; *Save Diagnostic Report* and the info texts; the HUD lines of host version 16
  (entry n n pixels, 0 the default, `HUD_EDGES` 2'b10: HUD (Top) greyed); the MT32-pi's
  ports; `MIDI_SYNTH` 0 (Danik: the music is EA's streams; no synthesizer, no SoundFont, no
  *Music* / *SoundFont* / MT32-pi lines). The CD's files are looked for before the pick
  (`game_missing()` in `mister.c`): one missing, its message under the MiSTer logo, no game
  logo. No "Loading" message of the port's own: `MH_PickGame()`'s. Cheats looked for again:
  none beyond the page's nine (Danik: unchanged). `build_core.sh` the template's (`job.sh`).
- Core: 31% of the logic, 25% of the RAM blocks, 71% of the DSP blocks, worst slack +0.246 ns.
- Tried on the PC with `fakecore` (the menu entry: the two lines 24 fields apart from field
  300, the handover at 348, "Loading Need for Speed SE..." 32 fields after, the first frame
  at 605, 2 s after the logo was in; a file missing; no data, from the menu entry and the
  core itself; *Save Diagnostic Report*: the zip, info text 17, read with `diag_read.py`).
- On the MiSTer with `tools/test_on_mister.sh` (2026-10-23): the menu entry (Danik saw the
  logo, then the game); `list` (one game there: started at once; quitting by Exit to system ?
  -> Yes back to the MiSTer menu, as it should with no list); `nodata`; two CD files taken out
  of the test's copy (`FRONTEND/ART/TRACKSEL/COASTSEL.QFS`, `SIMDATA/CARSPECS/ANSX.PBS`: both
  named under the MiSTer logo, no game logo, from the menu entry and from the core itself);
  `TEST_USB=1` SE (runs, writes `saves/` there) and `nodata` (`usb0/games/dnk/.ReNFS_empty/`).
- **Drawing ahead benchmarked again, kept** (the rule in `hybrid/CLAUDE.md`): REPLAY.RPL from
  the SKY camera at 640x240 with smooth motion (`RENFS_PERF=1 MISTER_HYBRID_PACE=1`), three runs
  of 180 s each way in turns, counted from 30 s of the race on (25 times 300 frames a run):
  drawn ahead 8.6-8.7 ms a picture (slowest 17.0-21.1), 59.6 a second, 2 to 3 pictures shown a
  field late in 7,500 (0.03-0.04%, at most 1 in 300); `MISTER_HYBRID_AHEAD=0` the same speed
  but 102 to 141 late (1.4-1.9%, up to 14 in 300).

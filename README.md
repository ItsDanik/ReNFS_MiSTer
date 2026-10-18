# ReNFS for MiSTer

Need for Speed SE on [MiSTer FPGA](https://github.com/MiSTer-devel/Main_MiSTer/wiki) as a hybrid port.

TODO: one paragraph: which source port the game is and where it comes from. It runs on the MiSTer's ARM CPU. The ReNFS FPGA core provides native 15kHz video (CRT, VGA and HDMI) at 320x200, 44.1kHz audio and keyboard, mouse and gamepad input. The two halves talk through shared DDR3 memory.

> **Beta.** Expect rough edges and please report problems in the issues.

Disclaimer: AI is being used to speed up development of this project.

## Requirements

- **danik_hybrid_ports**, the launcher (`Scripts/danik_hybrid_ports.sh`): run it **once** from the MiSTer's `Scripts` menu. It starts the game whenever its menu entry is loaded, keeps running after a reboot, and serves all our hybrid ports; its screen picks which ports and games to have, and can keep them up to date through `update_all`. It replaces `danik_hybrid_cores`, the launcher before it, and moves ports installed the old way into the new folders by itself. Without it the core says "Game not running".
- **Game data**, which is not included: TODO which copy of the game.

## Installation

With `update_all` (Downloader 2.4 or newer, which update_all keeps up to date):

1. Copy [`downloader_danik_hybrid_ports.ini`](https://raw.githubusercontent.com/ItsDanik/Hybrid_MiSTer/main/launcher/downloader_danik_hybrid_ports.ini) to the root of your SD card (`/media/fat`).
2. Run `update_all`. That installs the launcher, **danik_hybrid_ports**, in `Scripts`.
3. Run **danik_hybrid_ports** from the `Scripts` menu, tick the games you want and press *X: Apply*. They are installed, and update_all keeps them up to date.

By hand:

1. Download the newest `ReNFS_YYYYMMDD.zip` from [releases](releases/) and extract it to the root of your SD card (`/media/fat`). That gives you:
   - `_Other/dnk-Need for Speed SE.mgl`, the game's entry in the `Other` menu
   - `_Other/dnk/dnk-ReNFS_YYYYMMDD.rbf`, the FPGA core
   - `games/dnk/ReNFS/`, the game binary and its launch script
   - `Scripts/danik_hybrid_ports.sh`, the launcher (from [Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer))
   - `downloader_danik_hybrid_ports.ini`, with which `update_all` keeps the ports up to date from then on
2. Copy the game data to `/media/fat/games/dnk/ReNFS/`: TODO which folders, copied whole (everything in the game's folder; never files that can be left out: `hybrid/README.md`, "Conventions").
3. Run **danik_hybrid_ports** from the `Scripts` menu, if you have not done so before (see Requirements).
4. Load **dnk-Need for Speed SE** from the `Other` menu.

The game data can go on a USB drive instead, into the same folder there (`/media/usb0/games/dnk/ReNFS/`): the game looks for it there first, and then keeps its settings and saved games there as well. Everything else stays on the SD card.

The game's log is in `/media/fat/logs/dnk/ReNFS/renfs.log`. TODO: where settings and saved games are.

## OSD options

| Option | |
|---|---|
| Aspect ratio, Scale, Scandoubler Fx, Stereo Mix | as in other cores |
| FPS Counter | shows the pictures per second in the top left corner |
| HDMI Only | **Yes** if no CRT is connected: resolutions of 640x400 and more are then progressive instead of interlaced, and the analog output is switched off while one is shown, so that a 15kHz screen can never get such a signal. Nothing changes at lower resolutions. Not needed with `forced_scandoubler=1` (VGA monitor); not there with `direct_video=1` |
| CRT Options | for a 15kHz screen: *Horizontal Size*, *Horizontal Pos* and *Vertical Pos* fit the picture to it. The pixels stay as they are; HDMI is not affected. The size is for the game's picture: the core's own, with its messages, keeps its width. Not there with `forced_scandoubler=1` |
| TODO game options | |

## Controls

- **Keyboard and mouse:**

| Key | Action |
|---|---|
| TODO | |

- **Gamepad** (default mapping):

| Button | Action |
|---|---|
| Left stick | TODO |
| D-pad | TODO |
| A (Xbox B / PlayStation Circle) | TODO |
| B (Xbox A / PlayStation Cross) | TODO |
| X (Xbox Y / PlayStation Triangle) | TODO |
| Y (Xbox X / PlayStation Square) | TODO |
| L (LB / L1) | TODO |
| R (RB / R1) | TODO |
| Select | TODO |
| Start | Menu |

In the game's menus the buttons that confirm and go back are the ones of your MiSTer menu, whatever they do in the game: its *Menu OK* / *Menu Back* if you set them in *Define joystick buttons*, else its A / B. A controller never set up in MiSTer confirms and goes back as on its console: Cross / Circle on PlayStation, A / B on Xbox and on Nintendo.

Change the buttons in the OSD under *Define ReNFS buttons*. *Menu OK* and *Menu Back* there are only needed for a spare button without a game function. While the OSD is open, the game gets no input.

## Building

Everything builds in Docker on a Linux PC.

```sh
git clone --recursive https://github.com/ItsDanik/ReNFS_MiSTer.git
cd ReNFS_MiSTer
./build.sh              # ARM game binary  -> build/mister/renfs
./core/build_core.sh    # FPGA core (Quartus Lite 17.0.2) -> core/output_files/ReNFS.rbf
./package.sh            # release zip      -> dist/ReNFS_YYYYMMDD.zip
```

The toolchain image (Debian bullseye, glibc 2.31 to match the MiSTer) is built from `hybrid/toolchain/` on first use. The first build also downloads and builds SDL2, SDL2_mixer and SDL2_net.

### Repository layout

| Path | |
|---|---|
| `hybrid/` | submodule: [ItsDanik/Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), what all our hybrid ports share: the FPGA host module, the ARM side library, SDL2 drivers, the launcher (`danik_hybrid_ports.sh`), toolchain and conventions. See its README. |
| `core/` | FPGA core, based on [Template_MiSTer](https://github.com/MiSTer-devel/Template_MiSTer): `ReNFS.sv` (OSD and button names) around `hybrid/rtl/hybrid_host.sv` |
| `renfs/` | submodule: the game, branch `mister`, with the MiSTer changes |
| `package/` | files shipped in the release next to the binary (`danik_hybrid_launch.sh`, README), and `games.txt`: the games and their menu entries |
| `releases/` | release packages |

### Development notes

- `./build.sh host` builds the same game for the PC. It runs against `hybrid/tools/fakecore`, a stand-in for the FPGA core that takes scripted input and saves screenshots and audio:
  ```sh
  gcc -O2 -o build/host/fakecore hybrid/tools/fakecore.c
  build/host/fakecore /tmp/shm script.txt audio.raw &
  cd <data folder> && MISTER_HYBRID_SHM=/tmp/shm <repository>/build/host/renfs
  ```
- `MISTER=root@<address> tools/test_on_mister.sh <id>` tries the build on a MiSTer next to what is installed there, without installing it: from `/tmp`, with the installed game's folder mirrored there (what the game writes stays in `/tmp`) and its own OSD settings. `list` and `nodata` for the core started by itself and without data, `log` for the game's log, `stop` to remove all of it again.
- `touch /tmp/renfs_nolaunch` on the MiSTer keeps the core loaded without starting the game, so you can start a development binary by hand (set `MISTER_HYBRID_CORE=ReNFS`, and `MISTER_HYBRID_SET` for a game's set name). `/tmp/danik_hybrid_ports.log` shows what the launcher daemon did.

## Support

If you enjoy this project, you can support my work on [Patreon](https://www.patreon.com/itsdanik).

## Credits

- **TODO the game / source port** by its authors.
- **[SDL](https://libsdl.org)** by Sam Lantinga and contributors.
- **[MiSTer](https://github.com/MiSTer-devel)** by Sorgelig and the MiSTer-devel contributors: the framework and Template_MiSTer.
- **[MiSTer Frontier](https://github.com/MiSTerOrganize/MiSTer_Frontier)** by MiSTer Organize: thank you for the inspiration. Hybrid cores on the MiSTer, and the way their game is launched (a daemon that watches the loaded core and runs a script from its games folder), come from MiSTer Frontier. Our launcher is a separate implementation and does not need MiSTer Frontier installed.

This project and its maintainers are in no way associated with or endorsed by TODO the rights holders. It does not include any game data.

## License

The top-level scripts, tools and documentation are licensed under the [GPL-3.0](LICENSE). The components keep their own licenses: the shared framework in `hybrid/` is GPL-3.0 except where its files say otherwise, TODO the game's license, SDL and the SDL drivers in `hybrid/sdl2` are zlib, the FPGA core and the MiSTer framework are GPL-2.0 (`core/LICENSE`, with the core's own sources GPL-2.0-or-later).

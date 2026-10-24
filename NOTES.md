# ReNFS for MiSTer: notes

How the port works and how it is built. For playing it, see the [README](README.md).

## Screenshots

The races in each resolution, and the menus.

![The title screen (640x480)](docs/screenshots/title_640x480.png)

| | |
|---|---|
| ![Alpine at evening, a race at 640x480](docs/screenshots/race_alpine_evening_640x480.png) | ![The desert from behind the car, 320x200](docs/screenshots/race_desert_320x200.png) |
| ![The city at 640x480](docs/screenshots/race_city_640x480.png) | ![A circuit from the driver's seat, 320x200](docs/screenshots/race_circuit_320x200.png) |
| ![Control Central, the main menu (640x480)](docs/screenshots/menu_control_central_640x480.png) | ![The cars' showcase (640x480)](docs/screenshots/menu_showcase_640x480.png) |
| ![The city at 320x240: the 3D view drawn with all 240 lines](docs/screenshots/race_city_320x240.png) | ![Alpine at evening, 640x240 (shown at 4:3)](docs/screenshots/race_alpine_evening_640x240.png) |
| ![The desert at 640x200 (shown at 4:3)](docs/screenshots/race_desert_640x200.png) | ![A replay at 320x240 with HUD (Bottom) at 12: the bar lifted off the screen's bottom edge](docs/screenshots/replay_hud_bottom_320x240.png) |

## Building

Everything builds in Docker on a Linux PC.

```sh
git clone --recursive https://github.com/ItsDanik/ReNFS_MiSTer.git
cd ReNFS_MiSTer
./build.sh              # ARM game binary  -> build/mister/renfs
./core/build_core.sh    # FPGA core (Quartus Lite 17.0.2) -> core/output_files/ReNFS.rbf
./package.sh            # release zip      -> dist/ReNFS_YYYYMMDD.zip
```

The toolchain image (Debian bullseye, glibc 2.31 to match the MiSTer) is built from `hybrid/toolchain/` on first use. The first build also downloads and builds SDL2.

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

ReNFS for MiSTer - Need for Speed SE as a hybrid port
====================================================

The game (TODO which source port) runs on the MiSTer's ARM CPU; the ReNFS
FPGA core provides native 15kHz video (CRT, VGA and HDMI) at 320x200, audio
and input.

Disclaimer: AI is being used to speed up development of this project.

Requirements
  - danik_hybrid_ports, the launcher that comes with this release
    (Scripts/danik_hybrid_ports.sh): run it ONCE from the MiSTer's Scripts
    menu. It starts the game whenever its menu entry is loaded, keeps
    running after a reboot, and serves all our hybrid ports; its screen
    picks which ports and games to have, and can keep them up to date
    through update_all. It replaces danik_hybrid_cores, the launcher before
    it, and moves ports installed the old way into the new folders by
    itself. Without it the core says "Game not running".
  - Game data. It is not included: TODO which copy of the game.

Install
  With update_all (Downloader 2.4 or newer): copy
  downloader_danik_hybrid_ports.ini to /media/fat/, run update_all, run
  danik_hybrid_ports from the Scripts menu, tick the games, X: Apply.
  By hand:
  1. Extract the zip to the root of the SD card (/media/fat): _Other/,
     games/dnk/ReNFS/, Scripts/ and downloader_danik_hybrid_ports.ini
     (with which update_all keeps the ports up to date from then on).
  2. Copy the game data to /media/fat/games/dnk/ReNFS/
       TODO which folders, copied whole (everything in the game's folder;
       never files that can be left out)
  3. Run danik_hybrid_ports from the Scripts menu, if you have not done so
     before (see Requirements).
  4. Load dnk-Need for Speed SE from the Other menu.
  The game data can go on a USB drive instead, into the same folder there
  (/media/usb0/games/dnk/ReNFS/): the game looks for it there first, and
  then keeps its settings and saved games there as well. Everything else
  stays on the SD card.

OSD options
  Aspect ratio, Scale, Scandoubler Fx, Stereo Mix as in other cores.
  FPS Counter   shows the pictures per second in the top left corner.
  HDMI Only     Yes if no CRT is connected: resolutions of 640x400 and
                more are then progressive instead of interlaced, and the
                analog output is switched off while one is shown, so that a
                15kHz screen can never get such a signal. Nothing changes
                at lower resolutions. Not needed with forced_scandoubler=1
                (VGA monitor); not there with direct_video=1.
  CRT Options   for a 15kHz screen: Horizontal Size, Horizontal Pos and
                Vertical Pos fit the picture to it. The pixels stay as they
                are; HDMI is not affected. The size is for the game's
                picture: the core's own, with its messages, keeps its
                width. Not there with forced_scandoubler=1.
  TODO game options

Controls
  Keyboard and mouse:
    TODO
  Gamepad (default mapping):
    Left stick                          TODO
    D-pad                               TODO
    A (Xbox B / PlayStation Circle)     TODO
    B (Xbox A / PlayStation Cross)      TODO
    X (Xbox Y / PlayStation Triangle)   TODO
    Y (Xbox X / PlayStation Square)     TODO
    L (LB / L1)                         TODO
    R (RB / R1)                         TODO
    Select                              TODO
    Start                               Menu
  In the game's menus the buttons that confirm and go back are the ones of
  your MiSTer menu, whatever they do in the game: its Menu OK / Menu Back if
  you set them in "Define joystick buttons", else its A / B. A controller
  never set up in MiSTer confirms and goes back as on its console: Cross /
  Circle on PlayStation, A / B on Xbox and on Nintendo.
  Change the buttons in the OSD under "Define ReNFS buttons". "Menu OK" and
  "Menu Back" there are only needed for a spare button without a game
  function. While the OSD is open, the game gets no input.

Files
  TODO settings and saved games
  /media/fat/logs/dnk/ReNFS/renfs.log   the game's log

Credits
  TODO the game / source port by its authors.
  SDL by Sam Lantinga and contributors.
  MiSTer by Sorgelig and the MiSTer-devel contributors.
  MiSTer Frontier by MiSTer Organize
  (https://github.com/MiSTerOrganize/MiSTer_Frontier): thank you for the
  inspiration. Hybrid cores on the MiSTer, and the way their game is
  launched, come from MiSTer Frontier. Our launcher is a separate
  implementation and does not need MiSTer Frontier installed.

License
  TODO the game: its license (LICENSE-renfs.txt)
  SDL: zlib (LICENSE-sdl.txt)
  The launcher scripts: GPL-3.0 (LICENSE-gpl3.txt)
  The FPGA core: GPL-2.0
  Source: https://github.com/ItsDanik/ReNFS_MiSTer
          https://github.com/ItsDanik/Hybrid_MiSTer (launcher, framework)

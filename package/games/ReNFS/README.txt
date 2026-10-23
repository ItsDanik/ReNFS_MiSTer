ReNFS for MiSTer - Need for Speed SE as a hybrid port
====================================================

The Need for Speed Special Edition (Electronic Arts Canada, 1996, MS-DOS)
through ReNFS, the game's program written again by hand from the original
(https://github.com/ItsDanik/ReNFS). The whole single-player game. It runs
on the MiSTer's ARM CPU; the ReNFS FPGA core provides native 15kHz video
(CRT, VGA and HDMI): the menus at 640x480 as in the original, the races at
320x200, 320x240, 640x200, 640x240 or 640x480; audio, and input with
rumble.

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
  - The game's CD, which is not included: The Need for Speed Special
    Edition for DOS / Windows 95 (1996), every file on it.

Install
  With update_all (Downloader 2.4 or newer): copy
  downloader_danik_hybrid_ports.ini to /media/fat/, run update_all, run
  danik_hybrid_ports from the Scripts menu, tick the games, X: Apply.
  By hand:
  1. Extract the zip to the root of the SD card (/media/fat): _Other/,
     games/dnk/ReNFS/, Scripts/ and downloader_danik_hybrid_ports.ini
     (with which update_all keeps the ports up to date from then on).
  2. Copy everything on the game's CD, all its files and folders as they
     are, into /media/fat/games/dnk/ReNFS/NFSSE/
       games/dnk/ReNFS/NFSSE/NFS_DOS.EXE
       games/dnk/ReNFS/NFSSE/FRONTEND/ ...
     Upper or lower case does not matter. If files are missing, the core
     says which.
  3. Run danik_hybrid_ports from the Scripts menu, if you have not done so
     before (see Requirements).
  4. Load dnk-Need for Speed SE from the Other menu.
  The game data can go on a USB drive instead, into the same folder there
  (/media/usb0/games/dnk/ReNFS/NFSSE/): the game looks for it there first, and
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
                width. HUD (Bottom) lifts the replay's bar and, from
                outside the car, the small rev counter and the map by that
                many lines, for a screen that hides its bottom edge (0 by
                default; at 320x240, 640x240 and 640x480). HUD (Top) is
                greyed: the status bar stays where the game has it. Not
                there with forced_scandoubler=1.
  Resolution    the races' picture: 320x200 as the original's low
                resolution; 320x240 the same picture filling a 15kHz
                screen's 240 lines, the road and the cars drawn with all of
                them; 640x200 and 640x240 the original's high resolution
                with 200 or 240 of its lines (at 15kHz without
                interlacing); 640x480 as the original's high resolution
                (interlaced on a 15kHz screen). The menus are 640x480
                always. Options, Graphics in the game shows the choice.
                From the next race.
  Smooth Motion On: a new picture at every field, the cars and the camera
                moved on between the game's 33 steps a second. Off: a new
                picture only at each step, as the original. Greyed out at
                640x480, which the MiSTer cannot draw 60 times a second.
  Rumble        the original's force-feedback effects on the pad: On,
                Strong or Off. A force-feedback wheel gets its forces.
  Cheats        the original's codes as switches, each doing what typing
                it in Control Central does while it is on (not in a
                tournament): Mirrored Tracks (SKCART), Rally Tracks
                (EARALLYE), Lost Vegas (CASINOVILLE), Warrior Car
                (CONCEPTCAR), Unlock All (ROCKYROAD, kept once used), Turbo
                (a faster game), Nitro (R3: full revs), Explode (the horn
                throws the cars near you into the air), No Mercy (head to
                head without police and traffic).
  Save Diagnostic Report
                the last line: see "If something is wrong" below.

Controls
  Keyboard and mouse:
    Arrows, Enter, Esc, mouse   the menus
    Left / Right, Up / Down     steer, accelerate / brake
    A / Z                       gear up / down (one up from neutral)
    Space, H, C, M              handbrake, horn, next camera, map
    Esc, P                      the pause menu, pause
    F1 .. F9                    view size, detail, road distance, sky,
                                sound, markers, top bar, bumper view
    Shift+End                   give up
    Ctrl+Alt+1..8               watch another car
  Gamepad (default mapping):
    Left stick                          steer (analogue); the menus
    D-pad                               steer; the menus
    A (Xbox B / PlayStation Circle)     accelerate
    B (Xbox A / PlayStation Cross)      brake
    R2 / L2 (RT / LT)                   accelerate / brake, analogue
    R (RB / R1)                         gear up (one up from neutral)
    L (LB / L1)                         gear down
    X (Xbox Y / PlayStation Triangle)   next camera
    Y (Xbox X / PlayStation Square)     handbrake
    Select                              map
    L3 / R3 (stick clicks)              horn / nitro (with its cheat)
    Start                               the pause menu
  Names are typed with the d-pad: up and down change the last letter,
  right adds one, left takes one away.
  In the game's menus the buttons that confirm and go back are the ones of
  your MiSTer menu, whatever they do in the game: its Menu OK / Menu Back if
  you set them in "Define joystick buttons", else its A / B. A controller
  never set up in MiSTer confirms and goes back as on its console: Cross /
  Circle on PlayStation, A / B on Xbox and on Nintendo.
  Change the buttons in the OSD under "Define ReNFS buttons". "Menu OK" and
  "Menu Back" there are only needed for a spare button without a game
  function. While the OSD is open, the game gets no input; a race goes on
  behind it (press Start for the pause menu first if you want it held).

If something is wrong
  If the game stutters, the sound breaks up or something else is wrong,
  open the OSD while it happens and pick Save Diagnostic Report, the last
  line of the menu. The game keeps running; MiSTer's info box says the
  report is saved in games/dnk/diagnostics/ on the SD card. Send that file
  (ReNFS_<date>_<time>.zip) with a few words on what went wrong. The
  report has the setup (versions, the video and audio lines of MiSTer.ini,
  the OSD settings), how the last 60 seconds went, the game's log and a
  screenshot. Nothing else: no network settings, addresses, saved games or
  lists of your files.

Files
  games/dnk/ReNFS/saves/                the game's settings, records,
                                        saved tournaments and replays
  /media/fat/logs/dnk/ReNFS/renfs.log   the game's log

Credits
  The Need for Speed SE by Electronic Arts Canada (1996); ReNFS, its
  program written again. Not associated with or endorsed by Electronic
  Arts; The Need for Speed is a trademark of Electronic Arts.
  SDL by Sam Lantinga and contributors.
  MiSTer by Sorgelig and the MiSTer-devel contributors.
  MiSTer Frontier by MiSTer Organize
  (https://github.com/MiSTerOrganize/MiSTer_Frontier): thank you for the
  inspiration. Hybrid cores on the MiSTer, and the way their game is
  launched, come from MiSTer Frontier. Our launcher is a separate
  implementation and does not need MiSTer Frontier installed.

License
  ReNFS: GPL-3.0 (LICENSE-renfs.txt)
  SDL: zlib (LICENSE-sdl.txt)
  The launcher scripts: GPL-3.0 (LICENSE-gpl3.txt)
  The FPGA core: GPL-2.0
  Source: https://github.com/ItsDanik/ReNFS_MiSTer
          https://github.com/ItsDanik/Hybrid_MiSTer (launcher, framework)

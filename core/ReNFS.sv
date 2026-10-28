//============================================================================
//
//  ReNFS (Need for Speed SE) hybrid core for MiSTer
//
//  The game itself runs on the HPS. This core scans the game's
//  framebuffer out of DDR3 with native 15kHz timings, plays its audio and
//  hands input to the HPS. See ../hybrid/rtl/hybrid_host.sv for the shared
//  memory layout and ../hybrid/README.md for what all hybrid cores share.
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//============================================================================

module emu
(
	`include "sys/emu_ports.vh"
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;

assign VGA_SCALER  = 0;
assign HDMI_FREEZE = 0;
assign HDMI_BLACKOUT = 0;
assign HDMI_BOB_DEINT = 0;

assign AUDIO_S = 1;
assign AUDIO_MIX = status[6:5];

assign LED_DISK = 0;
assign LED_POWER = 0;
assign LED_USER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

// Status bits [127:0] are forwarded to the HPS side. Bits [23:0] mean the same
// in every hybrid core (MH_OSD_* in hybrid/hps/mister_hybrid.h), game options
// start at bit 24 (decoded in the game's MiSTer source file). Defaults are 0.
// The order of the options is the one in hybrid/README.md, "OSD".
`include "build_id.v"
localparam CONF_STR = {
	"ReNFS;;",
	"-;",
	"O[122:121],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"O[125:123],Scale,Normal,V-Integer,Narrower HV-Integer,Wider HV-Integer,HV-Integer;",
	"O[4:2],Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	// Not with direct_video (the HDMI output is the analog one then), and
	// the CRT options not with forced_scandoubler: a VGA monitor has its own
	// bit 1: bit 0 is the reset Main_MiSTer holds while it loads the core and
	// clears after, so an option there was never kept (up to host version 12)
	"H5O[1],HDMI Only,No,Yes;",
	"H4P1,CRT Options;",
	"P1-;",
	// Horizontal Size: entries 0..7 are 0..+7, entries 8..31 are -24..-1
	"P1O[68:64],Horizontal Size,0,+1,+2,+3,+4,+5,+6,+7,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1;",
	"P1O[72:69],Horizontal Pos,0,+1,+2,+3,+4,+5,+6,+7,-8,-7,-6,-5,-4,-3,-2,-1;",
	"P1O[76:73],Vertical Pos,0,+1,+2,+3,+4,+5,+6,+7,-8,-7,-6,-5,-4,-3,-2,-1;",
	// the flicker filter of an interlaced picture (host version 18,
	// hybrid/README.md "Video modes"): hidden in a core without it (FLICKER 0,
	// menu mask bit 9), greyed out while the picture is not interlaced (bit 10)
	"H9P1-;",
	"H9DAP1O[106:105],Flicker Filter,Strong,Light,Off;",
	// The HUD margins (MH_HudMargins(), hybrid/README.md "HUD margins"),
	// 0 the default (host version 16; up to 15 entry 0 was 10). ReNFS keeps
	// its status bar where the game has it (HUD (Top) always greyed:
	// HUD_EDGES below) and lifts its bottom HUD (the replay's bar, from
	// outside the small rev counter and the map) by HUD (Bottom)'s lines of
	// a 240-line screen, twice in 480 lines (Danik, 2026-10-22); greyed
	// while the races have 200 lines (menu mask bit 0), read in
	// renfs/port/src/mister.c (mister_hud_bottom).
	"P1-;",
	"D0D7P1O[81:77],HUD (Top),0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24;",
	"D0D8P1O[86:82],HUD (Bottom),0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24;",
	"O[6:5],Stereo Mix,None,25%,50%,100%;",
	// drawn by the hybrid library over the game's frames (MH_OSD_FPS)
	"O[15],FPS Counter,Off,On;",
	"-;",
	// A game can hide or grey out lines with MH_SetMenuMask(): "H0".."H3" and
	// "D0".."D3" in front of a line (hidden / greyed while the bit is set,
	// "h" and "d" while it is not).
	// Sound Volume / Music Volume (bits 10:7 and 14:11) are not here: the
	// game has its own (Options, Audio). The game's options from bit 24 up,
	// read in renfs/port/src/mister.c; the first entry of an option is its
	// default. Resolution is the races' (the menus are 640x480 always); the
	// game's own line in Options, Graphics follows it. Smooth Motion is
	// greyed while the races are 640x480 (mask bit 1: too slow for 60 there).
	"O[26:24],Resolution,320x200,320x240,640x200,640x240,640x480;",
	"D1O[27],Smooth Motion,On,Off;",
	"O[29:28],Rumble,On,Strong,Off;",
	// Cheats: each line does what typing its code in Control Central does
	// (renfs/port/src/mainmenu.c), while it is on; not in a tournament, as
	// the original. No Mercy: as End held when a head to head starts.
	"P2,Cheats;",
	"P2-;",
	"P2O[30],Mirrored Tracks,Off,On;",
	"P2O[31],Rally Tracks,Off,On;",
	"P2O[32],Lost Vegas,Off,On;",
	"P2O[33],Warrior Car,Off,On;",
	"P2O[34],Unlock All,Off,On;",
	"P2O[35],Turbo,Off,On;",
	"P2O[36],Nitro (R3),Off,On;",
	"P2O[37],Explode (Horn),Off,On;",
	"P2O[38],No Mercy,Off,On;",
	"-;",
	// Bits 16..23 were Menu OK / Menu Back up to host version 13 (a saved
	// setting may still have them set): 16 is Save Diagnostic Report's since
	// host version 16 (a trigger, which the core flips), 17..23 unused.
	// The game's reset, as in every other MiSTer core (host version 18; the
	// USER button does the same): hybrid_host shows its picture at once and
	// the library ends the game, which the launch script starts again. Bit 0
	// is Main_MiSTer's reset (R0); hybrid_host takes it from the status.
	"R0,Reset;",
	// The last line of every core's menu (host version 16, hybrid/docs/diagnostics.md):
	// the library saves a report of the setup and the last 60 seconds in
	// games/dnk/diagnostics/ (bit 16, flipped by hybrid_host at each pulse)
	"T[16],Save Diagnostic Report;",
	// MiSTer's default map only knows the SNES-style pad. Main refuses to map a
	// button twice, so Menu OK/Back here are for spare buttons without a game
	// function and unmapped by default; menus also confirm and go back with
	// the MiSTer menu's own OK / Back (MH_MenuButtons()). J1 has the game's
	// eight most important actions, the last one opens the game's menu; jn
	// gives each of them a button of the default pad, Start for the menu. The
	// game knows this list as buttons 0..9 of the SDL joystick (the horn and
	// the nitro are the sticks' clicks, L3 and R3, which the library reads),
	// the launcher repeats "jn" as MISTER_HYBRID_JN
	// (package/games/ReNFS/danik_hybrid_launch.sh).
	"J1,Accelerate,Brake,Gear Up,Gear Down,Camera,Handbrake,Map,Pause,Menu OK,Menu Back;",
	"jn,A,B,R,L,X,Y,Select,Start;",
	// Main_MiSTer's info box shows text n when hybrid_host asks for it
	// (`info`): 1..13 the MT32-pi's synth, 14..16 the SoundFont's errors
	// (MH_INFO_*), 17 and 18 the diagnostic report's, then empty ones up to
	// 23; a game's own texts follow from 24. In every core (the report's
	// texts; the MIDI ones are not asked for in a core without MIDI). It
	// stays after the last line of the OSD's main page
	// (hybrid/template/core/@NAME@.sv).
	"I,MT32-pi: SoundFont 0,MT32-pi: SoundFont 1,MT32-pi: SoundFont 2,MT32-pi: SoundFont 3,",
	"MT32-pi: SoundFont 4,MT32-pi: SoundFont 5,MT32-pi: SoundFont 6,MT32-pi: SoundFont 7,",
	"MT32-pi: MT-32 v1,MT32-pi: MT-32 v2,MT32-pi: CM-32L,MT32-pi: unknown synth,",
	"MT32-pi: SoundFont 8 or later,",
	"No SoundFont found\nFM music instead\nCopy GeneralUser-GS.sf2 to\ngames/dnk/SoundFonts/,",
	"The SoundFont is damaged\nor no SoundFont 2 file\nFM music instead,",
	"The SoundFont is too big\n(over 64 MB)\nFM music instead,",
	"Diagnostic report saved\nin games/dnk/diagnostics/,",
	"Diagnostic report not saved\n(no space or the folder\ncannot be written),,,,,;",
	"V,v",`BUILD_DATE
};

// The edges the game has a HUD at, bit 0 the top, bit 1 the bottom: the
// other's HUD line is greyed out (menu mask bits 7 and 8). The bottom only:
// the status bar at the top stays where the game has it (Danik, 2026-10-22).
localparam [1:0] HUD_EDGES = 2'b10;

// No MIDI synthesizer: the game's music is EA's streams (.ASF), played as
// sound (Danik, 2026-10-23)
localparam MIDI_SYNTH = 0;

// 1 in every core: the core's intro when it starts, which the game waits
// for, and its picture fading out before the game's first frame (0 only in
// a frontend, hybrid/docs/dnklauncher.md).
localparam INTRO = 1;
// 1 in a core with a 640x400 or 640x480 mode (interlaced at 15kHz): the
// OSD's Flicker Filter line (host version 18). It costs two more line
// buffers and two more copies of the palette, 12 M10K blocks; 0 hides the line.
// 2: Strong the default, the line's entries "Strong,Light,Off" (Danik,
// 2026-10-28: "the default value of the flicker filter should be strong")
localparam FLICKER = 2;

wire         forced_scandoubler;
wire         direct_video;
wire   [3:0] menumask;
wire         lace;
wire [127:0] status_in;
wire         status_set;
wire         mt32_on;
wire         info_req;
wire   [7:0] info;
wire   [1:0] buttons;
wire [127:0] status;
wire  [10:0] ps2_key;
wire  [24:0] ps2_mouse;
wire  [15:0] ps2_mouse_ext;
wire  [31:0] joystick_0, joystick_1;
wire  [15:0] joy_l_analog_0, joy_r_analog_0, joy_l_analog_1, joy_r_analog_1;
wire  [21:0] gamma_bus;

hps_io #(.CONF_STR(CONF_STR)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(gamma_bus),

	.forced_scandoubler(forced_scandoubler),
	.direct_video(direct_video),

	.buttons(buttons),
	.status(status),
	// the program sets the OSD's Flicker Filter line (MH_SetFlickerFilter())
	.status_in(status_in),
	.status_set(status_set),
	// bit 6: an MT32-pi is connected (no lines of its own here); 7 and 8: no
	// HUD at the top / the bottom ("D7", "D8": its line greyed out); 9: no
	// flicker filter ("H9"), 10: the picture is not interlaced ("DA": its
	// line greyed out)
	.status_menumask({5'd0, ~lace, FLICKER == 0, ~HUD_EDGES[1], ~HUD_EDGES[0], mt32_on, direct_video, forced_scandoubler, menumask}),
	.info_req(info_req),
	.info(info),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joystick_l_analog_0(joy_l_analog_0),
	.joystick_r_analog_0(joy_r_analog_0),
	.joystick_l_analog_1(joy_l_analog_1),
	.joystick_r_analog_1(joy_r_analog_1),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.ps2_mouse_ext(ps2_mouse_ext)
);

///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys)
);

wire reset = RESET | buttons[1];

//////////////////////////////////////////////////////////////////

// The video modes of 640x400 and 640x480 have two forms (hybrid_host.sv):
// interlaced at 15kHz for a 15kHz screen, progressive at 31kHz for
// everything else, the core's own picture without a game as well. A 15kHz
// screen must never get the second, so it takes the player to say that none
// is there: forced_scandoubler=1 in MiSTer.ini (the analog output is a VGA
// monitor) or the option "HDMI Only", with which the analog output is
// switched off for as long as such a signal is on it. Modes of 15kHz still
// go to the analog output with "HDMI Only", and so does the OSD over them.
// With direct_video the HDMI output feeds an analog screen: no "HDMI Only".
wire       hdmi_only = status[1] & ~direct_video;
wire       vga31 = forced_scandoubler | hdmi_only;

wire       clk_vid;
wire       ce_pix;
wire [7:0] r, g, b;
wire       hsync, vsync, hblank, vblank;
wire       hires, fast, f1;

// `fast` follows vga31, and falls only after the output has gone quiet
assign VGA_DISABLE = fast & ~forced_scandoubler;

hybrid_host #(.MIDI_SYNTH(MIDI_SYNTH), .INTRO(INTRO), .FLICKER(FLICKER)) host
(
	.clk(clk_sys),
	.reset(reset),
	.refclk(CLK_50M),

	.ddr_busy(DDRAM_BUSY),
	.ddr_burstcnt(DDRAM_BURSTCNT),
	.ddr_addr(DDRAM_ADDR),
	.ddr_dout(DDRAM_DOUT),
	.ddr_dout_ready(DDRAM_DOUT_READY),
	.ddr_rd(DDRAM_RD),
	.ddr_din(DDRAM_DIN),
	.ddr_be(DDRAM_BE),
	.ddr_we(DDRAM_WE),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joy_l_analog_0(joy_l_analog_0),
	.joy_r_analog_0(joy_r_analog_0),
	.joy_l_analog_1(joy_l_analog_1),
	.joy_r_analog_1(joy_r_analog_1),
	.osd_status(status),
	.osd_open(OSD_STATUS),
	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.ps2_mouse_ext(ps2_mouse_ext),

	.clk_vid(clk_vid),
	.ce_pix(ce_pix),
	.r(r),
	.g(g),
	.b(b),
	.hsync(hsync),
	.vsync(vsync),
	.hblank(hblank),
	.vblank(vblank),
	.vga31(vga31),
	// CRT options: for 15kHz screens
	.crt_hsize(forced_scandoubler ? 6'd0 : {|status[68:67], status[68:64]}),
	.crt_hpos(forced_scandoubler ? 4'd0 : status[72:69]),
	.crt_vpos(forced_scandoubler ? 4'd0 : status[76:73]),
	.hires(hires),
	.fast(fast),
	.f1(f1),
	.menumask(menumask),
	.lace(lace),
	.status_out(status_in),
	.status_set(status_set),

	.audio_l(AUDIO_L),
	.audio_r(AUDIO_R),

	// an MT32-pi on the user port (MIDI music, host version 15)
	.clk_audio(CLK_AUDIO),
	.user_in(USER_IN),
	.user_out(USER_OUT),
	.mt32_on(mt32_on),
	.info_req(info_req),
	.info(info)
);

assign DDRAM_CLK = clk_sys;

//////////////////////////////////////////////////////////////////
// Video output, on hybrid_host's video clock. The native signal is 15kHz, in
// the video mode the game set (320x200 unless it asks hybrid_host for
// another); video_mixer scandoubles it for VGA monitors (forced_scandoubler)
// or when a scandoubler effect is selected, which is why its line buffer has
// room for the 640 pixels of the widest 15kHz mode. Analog output is
// untouched otherwise so CRTs get the real 15kHz signal. HDMI goes through
// the framework's scaler; video_freak gives it the aspect ratio and the
// integer scaling modes. The modes of 640x400 and above are not scandoubled
// (hires): interlaced, the scaler weaves the two fields (VGA_F1).

wire [1:0] ar = status[122:121];
wire [2:0] scale = status[4:2];
wire [2:0] sl = scale ? scale - 1'd1 : 3'd0;
wire       vga_de;

assign CLK_VIDEO = clk_vid;
assign VGA_SL = sl[1:0];
assign VGA_F1 = f1;

video_mixer #(.LINE_LENGTH(640), .HALF_DEPTH(0), .GAMMA(1)) video_mixer
(
	.CLK_VIDEO(CLK_VIDEO),
	.CE_PIXEL(CE_PIXEL),
	.ce_pix(ce_pix),

	.scandoubler(~hires & (scale || forced_scandoubler)),
	.hq2x(scale == 1),
	.gamma_bus(gamma_bus),

	.R(r),
	.G(g),
	.B(b),

	.HSync(hsync),
	.VSync(vsync),
	.HBlank(hblank),
	.VBlank(vblank),

	.HDMI_FREEZE(HDMI_FREEZE),
	.freeze_sync(),

	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_VS(VGA_VS),
	.VGA_HS(VGA_HS),
	.VGA_DE(vga_de)
);

video_freak video_freak
(
	.CLK_VIDEO(CLK_VIDEO),
	.CE_PIXEL(CE_PIXEL),
	.VGA_VS(VGA_VS),
	.HDMI_WIDTH(HDMI_WIDTH),
	.HDMI_HEIGHT(HDMI_HEIGHT),
	.VGA_DE(VGA_DE),
	.VIDEO_ARX(VIDEO_ARX),
	.VIDEO_ARY(VIDEO_ARY),

	.VGA_DE_IN(vga_de),
	.ARX((!ar) ? 12'd4 : (ar - 1'd1)),
	.ARY((!ar) ? 12'd3 : 12'd0),
	.CROP_SIZE(0),
	.CROP_OFF(0),
	.SCALE(status[125:123])
);

endmodule

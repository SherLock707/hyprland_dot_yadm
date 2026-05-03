--  ▗▖ ▗▖▗▄▄▄▖▗▖  ▗▖▗▄▄▖ ▗▄▄▄▖▗▖  ▗▖▗▄▄▄ ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖ ▗▄▄▖
--  ▐▌▗▞▘▐▌    ▝▚▞▘ ▐▌ ▐▌  █  ▐▛▚▖▐▌▐▌  █  █  ▐▛▚▖▐▌▐▌   ▐▌
--  ▐▛▚▖ ▐▛▀▀▘  ▐▌  ▐▛▀▚▖  █  ▐▌ ▝▜▌▐▌  █  █  ▐▌ ▝▜▌▐▌▝▜▌ ▝▀▚▖
--  ▐▌ ▐▌▐▙▄▄▖  ▐▌  ▐▙▄▞▘▗▄█▄▖▐▌  ▐▌▐▙▄▄▀▗▄█▄▖▐▌  ▐▌▝▚▄▞▘▗▄▄▞▘

-- ---------------- Variables ----------------

local mainMod = "SUPER"
local home    = os.getenv("HOME")

local terminal     = "foot"
local termSec      = "kitty"
local files_main   = "dolphin"
local files_sec    = "thunar"
local browser      = "brave"
local scriptsDir   = home .. "/.config/hypr/scripts"
local noti_icon    = home .. "/.config/swaync/assets"
local ani_cli_cmd  = "ani-cli-mpv"

-- Script shortcuts
local AirplaneMode = scriptsDir .. "/AirplaneMode.sh"
local Media        = scriptsDir .. "/MediaCtrl.sh"
local screenshot   = scriptsDir .. "/ScreenShot.sh"
local volume       = scriptsDir .. "/Volume.sh"
local drop_down    = scriptsDir .. "/Dropterminal_adv.sh"
local drop_cmd     = "foot -e zellij attach --create scratchpad"
local brightness   = home .. "/.config/hypr/scripts/Brightness.sh"

-- ---------------- System Controls ----------------

-- Power
hl.bind(", xf86poweroff",         hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh --suspend"), { description = "Suspend System" })
hl.bind("CTRL ALT, Delete",       hl.dsp.exit(),                                              { description = "Exit Hyprland" })
hl.bind("CTRL ALT, P",            hl.dsp.exec_cmd(scriptsDir .. "/RofiPower.sh"),             { description = "Power Menu" })
hl.bind(", xf86mail",             hl.dsp.exec_cmd(scriptsDir .. "/RofiPower.sh"),             { description = "Power Menu Alt (F12)" })
hl.bind("CTRL ALT, L",            hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"),            { description = "Lock Screen" })
hl.bind(", xf86Sleep",            hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"),            { description = "Sleep Lock (FN+F11)" })

-- Hyprland
hl.bind(mainMod .. " SHIFT, C",   hl.dsp.exec_cmd("hyprctl reload"),                         { description = "Reload Config" })
hl.bind(mainMod .. " SHIFT, Q",   hl.dsp.exec_cmd("hyprctl kill"),                           { description = "Kill Window (picker)" })
hl.bind(mainMod .. ", Escape",    hl.dsp.exec_cmd("hyprctl kill"),                           { description = "Kill Window Alt" })

-- Wayland / Waybar
hl.bind("CTRL SHIFT, W",          hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"),               { description = "Refresh Wayland" })
hl.bind("CTRL ALT, W",            hl.dsp.exec_cmd(scriptsDir .. "/Refresh_with_waybar.sh"),   { description = "Refresh with Waybar" })
hl.bind("CTRL, W",                hl.dsp.exec_cmd(scriptsDir .. "/WaybarStyles.sh"),          { description = "Waybar Styles" })
hl.bind(mainMod .. ", W",         hl.dsp.exec_cmd("pkill waypaper || true && waypaper"),      { description = "Waypaper" })
hl.bind(mainMod .. " SHIFT, W",   hl.dsp.exec_cmd(scriptsDir .. "/WallpaperSelect.sh"),       { description = "Wallpaper Select" })
hl.bind("ALT, W",                 hl.dsp.exec_cmd(scriptsDir .. "/WaybarLayout.sh"),          { description = "Waybar Layout" })

-- ---------------- App Launchers ----------------

-- Rofi (release bind for tap detection)
hl.bind(mainMod .. ", " .. mainMod .. "_L",
    hl.dsp.exec_cmd("pkill rofi || rofi -matching fuzzy -show drun -modi drun,filebrowser,run,window"),
    { release = true, description = "App Launcher" })
hl.bind(mainMod .. ", E",         hl.dsp.exec_cmd(scriptsDir .. "/RofiSearch.sh"),            { description = "Google Search (Rofi)" })
hl.bind(mainMod .. " CTRL, S",    hl.dsp.exec_cmd(scriptsDir .. "/RofiBeats.sh"),             { description = "Lofi Beats" })
hl.bind(mainMod .. " ALT, E",     hl.dsp.exec_cmd(scriptsDir .. "/RofiEmoji.sh"),             { description = "Emoji Picker" })
hl.bind(mainMod .. ", H",         hl.dsp.exec_cmd(scriptsDir .. "/KeyHints.sh"),              { description = "Key Hints" })

-- Apps
hl.bind(mainMod .. ", Return",          hl.dsp.exec_cmd(terminal),                            { description = "Primary Terminal" })
hl.bind(mainMod .. " SHIFT, Return",    hl.dsp.exec_cmd(termSec),                             { description = "Secondary Terminal" })
hl.bind(mainMod .. ", D",              hl.dsp.exec_cmd(files_main),                           { description = "Dolphin File Manager" })
hl.bind(mainMod .. ", T",              hl.dsp.exec_cmd(files_sec),                            { description = "Thunar File Manager" })
hl.bind(mainMod .. ", B",              hl.dsp.exec_cmd(browser),                              { description = "Browser" })
hl.bind(", xf86calculator",            hl.dsp.exec_cmd("qalculate-qt"),                       { description = "Calculator (F3)" })

-- Ani-cli
hl.bind(", xf86explorer",  hl.dsp.exec_cmd(ani_cli_cmd .. " -q 1080p --dub --rofi"),          { description = "Ani-cli Dub (F1)" })
hl.bind(", xf86homepage",  hl.dsp.exec_cmd(ani_cli_cmd .. " -q 1080p --rofi"),                { description = "Ani-cli Sub (F2)" })
hl.bind(", xf86tools",     hl.dsp.exec_cmd(ani_cli_cmd .. " -c --rofi"),                      { description = "Ani-cli Continue (F4)" })

-- ---------------- Window Management ----------------

-- Window States
hl.bind(mainMod .. " SHIFT, F",  hl.dsp.window.float({ action = "toggle" }),    { description = "Toggle Float" })
hl.bind(mainMod .. " ALT, F",    hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"), { description = "All Float" })
hl.bind(mainMod .. ", F",        hl.dsp.window.fullscreen(),                    { description = "Fullscreen" })
hl.bind(mainMod .. ", Q",        hl.dsp.window.close(),                         { description = "Close Window" })
hl.bind(mainMod .. ", P",        hl.dsp.window.pin(),                           { description = "Pin Window" })

-- Layout
hl.bind(mainMod .. " CTRL, D",   hl.dsp.layout("removemaster"),                { description = "Remove Master" })
hl.bind(mainMod .. ", X",        hl.dsp.window.fullscreen({ mode = 1 }),        { description = "Maximize" })
hl.bind(mainMod .. ", F11",      hl.dsp.window.fullscreenstate({ client = -1, internal = 2 }), { description = "Fullscreen Toggle" })
hl.bind(mainMod .. ", I",        hl.dsp.layout("addmaster"),                   { description = "Add Master" })
hl.bind(mainMod .. ", J",        hl.dsp.layout("cyclenext"),                   { description = "Cycle Next" })
hl.bind(mainMod .. ", K",        hl.dsp.layout("cycleprev"),                   { description = "Cycle Previous" })
hl.bind(mainMod .. ", M",        hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3"),   { description = "Split Ratio 0.3" })
hl.bind(mainMod .. " SHIFT, M",  hl.dsp.exec_cmd("hyprctl dispatch splitratio -0.3"), { description = "Split Ratio -0.3" })
hl.bind(mainMod .. " CTRL, Return", hl.dsp.layout("swapwithmaster"),           { description = "Swap with Master" })
hl.bind(mainMod .. ", Space",    hl.dsp.exec_cmd(scriptsDir .. "/ChangeLayout.sh"), { description = "Change Layout" })
hl.bind(mainMod .. " SHIFT, X",  hl.dsp.layout("swapsplit"),                   { description = "Swap Split" })

-- Scrolling layout column navigation
hl.bind(mainMod .. ", bracketright",  hl.dsp.layout("move +col"),  { description = "Scroll Col Right" })
hl.bind(mainMod .. ", bracketleft",   hl.dsp.layout("move -col"),  { description = "Scroll Col Left" })

-- Grouping
hl.bind(mainMod .. ", G",           hl.dsp.window.togglegroup(),                { description = "Toggle Group" })
hl.bind(mainMod .. " CTRL, tab",    hl.dsp.window.changegroupactive(),          { description = "Change Group Focus" })
hl.bind(mainMod .. " CTRL, R",      hl.dsp.window.moveoutofgroup(),             { description = "Move Out of Group" })

-- Resize (symmetrical, anchor-preserving)
hl.bind(mainMod .. " SHIFT, right",  hl.dsp.exec_cmd('hyprctl --batch "dispatch resizeactive 50 0 ; dispatch moveactive 25 0"'),  { repeating = true, description = "Resize Width +" })
hl.bind(mainMod .. " SHIFT, left",   hl.dsp.exec_cmd('hyprctl --batch "dispatch resizeactive -50 0 ; dispatch moveactive -25 0"'), { repeating = true, description = "Resize Width -" })
hl.bind(mainMod .. " SHIFT, down",   hl.dsp.exec_cmd('hyprctl --batch "dispatch resizeactive 0 50 ; dispatch moveactive 0 25"'),   { repeating = true, description = "Resize Height +" })
hl.bind(mainMod .. " SHIFT, up",     hl.dsp.exec_cmd('hyprctl --batch "dispatch resizeactive 0 -50 ; dispatch moveactive 0 -25"'), { repeating = true, description = "Resize Height -" })

-- Move/Resize with Mouse
hl.bind(mainMod .. ", mouse:272",  hl.dsp.window.drag(),   { mouse = true, description = "Move Window" })
hl.bind(mainMod .. ", mouse:273",  hl.dsp.window.resize(), { mouse = true, description = "Resize Window" })

-- HyprTasking / Navigation
hl.bind(mainMod .. ", I",     hl.dsp.exec_cmd("hyprtasking:toggle cursor"),  { description = "Tasking Toggle" })
hl.bind(mainMod .. ", left",  hl.dsp.exec_cmd("hyprtasking:move left"),      { description = "Tasking Left" })
hl.bind(mainMod .. ", down",  hl.dsp.exec_cmd("hyprtasking:move down"),      { description = "Tasking Down" })
hl.bind(mainMod .. ", up",    hl.dsp.exec_cmd("hyprtasking:move up"),        { description = "Tasking Up" })
hl.bind(mainMod .. ", right", hl.dsp.exec_cmd("hyprtasking:move right"),     { description = "Tasking Right" })

-- ---------------- Workspace Management ----------------

-- Special Workspace
hl.bind(mainMod .. " SHIFT, U",  hl.dsp.window.move({ workspace = "special" }),  { description = "Move to Special" })
hl.bind(mainMod .. ", U",        hl.dsp.workspace.toggle_special(),               { description = "Toggle Special" })

-- Switch Workspaces 1-10
for i = 1, 10 do
    local key = i % 10  -- 10 → key "0"
    hl.bind(mainMod .. ", " .. key,                  hl.dsp.focus({ workspace = i }),                     { description = "Workspace " .. i })
    hl.bind(mainMod .. " CTRL, " .. key,             hl.dsp.window.move({ workspace = i }),               { description = "Move to WS " .. i })
    hl.bind(mainMod .. " SHIFT, " .. key,            hl.dsp.window.move({ workspace = i, silent = true }), { description = "Move Silent WS " .. i })
end

-- Workspace navigation
hl.bind(mainMod .. ", mouse_down",       hl.dsp.focus({ workspace = "e+1" }),  { description = "Next Workspace" })
hl.bind(mainMod .. ", mouse_up",         hl.dsp.focus({ workspace = "e-1" }),  { description = "Prev Workspace" })
hl.bind(mainMod .. ", period",           hl.dsp.focus({ workspace = "e+1" }),  { description = "Next Workspace Alt" })
hl.bind(mainMod .. ", comma",            hl.dsp.focus({ workspace = "e-1" }),  { description = "Prev Workspace Alt" })
hl.bind(mainMod .. " CTRL, bracketleft",  hl.dsp.window.move({ workspace = "-1" }),               { description = "Move to Prev WS" })
hl.bind(mainMod .. " CTRL, bracketright", hl.dsp.window.move({ workspace = "+1" }),               { description = "Move to Next WS" })
hl.bind(mainMod .. " SHIFT, bracketleft",  hl.dsp.window.move({ workspace = "-1", silent = true }), { description = "Move Silent Prev" })
hl.bind(mainMod .. " SHIFT, bracketright", hl.dsp.window.move({ workspace = "+1", silent = true }), { description = "Move Silent Next" })

-- Razer mouse side buttons
hl.bind(", mouse:275",  hl.dsp.focus({ workspace = "e-1" }),  { description = "Prev WS Mouse" })
hl.bind(", mouse:276",  hl.dsp.focus({ workspace = "e+1" }),  { description = "Next WS Mouse" })

-- ---------------- Multimedia Controls ----------------

-- Volume
hl.bind(", xf86audioraisevolume",  hl.dsp.exec_cmd(volume .. " --inc"),          { description = "Volume Up" })
hl.bind(", xf86audiolowervolume",  hl.dsp.exec_cmd(volume .. " --dec"),          { description = "Volume Down" })
hl.bind(", xf86AudioMicMute",     hl.dsp.exec_cmd(volume .. " --toggle-mic"),   { description = "Toggle Mic" })
hl.bind(", xf86audiomute",        hl.dsp.exec_cmd(volume .. " --toggle"),       { description = "Toggle Mute (FN+F1)" })

-- Brightness
hl.bind(", XF86MonBrightnessUp",          hl.dsp.exec_cmd(brightness .. " --inc"), { description = "Brightness Up" })
hl.bind(", XF86MonBrightnessDown",        hl.dsp.exec_cmd(brightness .. " --dec"), { description = "Brightness Down" })
hl.bind(", SCROLL_LOCK",                  hl.dsp.exec_cmd(brightness .. " --dec"), { description = "Brightness Down Alt" })
hl.bind(", PAUSE",                        hl.dsp.exec_cmd(brightness .. " --inc"), { description = "Brightness Up Alt" })
hl.bind("CTRL, xf86audioraisevolume",     hl.dsp.exec_cmd(brightness .. " --inc"), { description = "Brightness Up Ctrl" })
hl.bind("CTRL, xf86audiolowervolume",     hl.dsp.exec_cmd(brightness .. " --dec"), { description = "Brightness Down Ctrl" })

-- Media
hl.bind(", xf86AudioPlayPause",  hl.dsp.exec_cmd(Media .. " --pause"),  { description = "Play/Pause" })
hl.bind(", xf86AudioPause",      hl.dsp.exec_cmd(Media .. " --pause"),  { description = "Pause" })
hl.bind(", xf86AudioPlay",       hl.dsp.exec_cmd(Media .. " --pause"),  { description = "Play" })
hl.bind(", xf86AudioNext",       hl.dsp.exec_cmd(Media .. " --nxt"),    { description = "Next Track" })
hl.bind(", xf86AudioPrev",       hl.dsp.exec_cmd(Media .. " --prv"),    { description = "Previous Track" })
hl.bind(", xf86audiostop",       hl.dsp.exec_cmd(Media .. " --stop"),   { description = "Stop Media" })

-- Hyprsunset (colour temperature)
hl.bind("ALT, xf86audioraisevolume",  hl.dsp.exec_cmd("hyprctl hyprsunset temperature +400"),   { description = "Warmer Screen" })
hl.bind("ALT, xf86audiolowervolume",  hl.dsp.exec_cmd("hyprctl hyprsunset temperature -400"),   { description = "Cooler Screen" })
hl.bind("ALT, xf86audiomute",
    hl.dsp.exec_cmd("hyprctl hyprsunset temperature $([ $(hyprctl hyprsunset temperature) = 6500 ] && echo 3500 || echo 6500)"),
    { description = "Toggle Night Light" })

-- ---------------- Screenshot ----------------

hl.bind(", Print",                   hl.dsp.exec_cmd(screenshot .. " --now"),   { description = "Screenshot Now" })
hl.bind("ALT, Print",                hl.dsp.exec_cmd(screenshot .. " --hush"),  { description = "Screenshot Hush" })
hl.bind(mainMod .. " CTRL, Print",   hl.dsp.exec_cmd(screenshot .. " --in5"),   { description = "Screenshot 5s" })
hl.bind(mainMod .. " ALT, Print",    hl.dsp.exec_cmd(screenshot .. " --in10"),  { description = "Screenshot 10s" })
hl.bind("CTRL, Print",               hl.dsp.exec_cmd(screenshot .. " --win"),   { description = "Screenshot Window" })
hl.bind("SHIFT, Print",              hl.dsp.exec_cmd(screenshot .. " --area"),  { description = "Screenshot Area" })
hl.bind(mainMod .. " SHIFT, Print",  hl.dsp.exec_cmd(screenshot .. " --area"),  { description = "Screenshot Area Alt" })

-- Satty annotate
hl.bind(mainMod .. " SHIFT, S",
    hl.dsp.exec_cmd('grim -g "$(slurp)" -t ppm - | satty -f - --output-filename ~/Pictures/Screenshots/satty-$(date \'+%Y-%m-%d_%H%M%S\').png'),
    { description = "Satty Annotate" })

-- ---------------- Misc ----------------

-- Dropdown terminal
hl.bind(mainMod .. ", S",  hl.dsp.exec_cmd(drop_down .. ' "' .. drop_cmd .. '"'),   { description = "Dropdown Terminal" })
hl.bind(", Insert",        hl.dsp.exec_cmd(drop_down .. ' "' .. drop_cmd .. '"'),   { description = "Dropdown Terminal Alt" })

-- Overview (quickshell)
hl.bind(mainMod .. ", Tab",  hl.dsp.global("quickshell:overviewToggle"),  { description = "Toggle Overview" })

-- Clipboard Manager
hl.bind(mainMod .. ", V",  hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"),  { description = "Clipboard Manager" })

-- System
hl.bind(", xf86Rfkill",  hl.dsp.exec_cmd(AirplaneMode),  { description = "Airplane Mode (FN+F12)" })

-- Window Effects
hl.bind(mainMod .. " SHIFT, B",  hl.dsp.exec_cmd(scriptsDir .. "/ChangeBlur.sh"),  { description = "Toggle Blur" })
hl.bind(mainMod .. " SHIFT, G",  hl.dsp.exec_cmd(scriptsDir .. "/GameMode.sh"),    { description = "Game Mode" })
hl.bind(mainMod .. ", L",        hl.dsp.exec_cmd(scriptsDir .. "/hyprshade.sh"),   { description = "Hyprshade" })

-- Window Opacity
hl.bind(mainMod .. " ALT, O",  hl.dsp.exec_cmd("hyprctl setprop active opaque toggle"),  { description = "Toggle Opacity" })

-- Cursor Zoom
hl.bind(mainMod .. " CTRL, mouse_down",
    hl.dsp.exec_cmd('hyprctl keyword cursor:zoom_factor $(awk "BEGIN {print $(hyprctl getoption cursor:zoom_factor | grep \'float:\' | awk \'{print $2}\') + 0.7}")'),
    { description = "Zoom Out" })
hl.bind(mainMod .. " CTRL, mouse_up",
    hl.dsp.exec_cmd('hyprctl keyword cursor:zoom_factor $(awk "BEGIN {print $(hyprctl getoption cursor:zoom_factor | grep \'float:\' | awk \'{print $2}\') - 0.7}")'),
    { description = "Zoom In" })

-- YTDL-MPV
hl.bind(mainMod .. ", Y",      hl.dsp.exec_cmd("ytdl-mpv"),  { description = "YTDL MPV" })

-- MPV from clipboard
hl.bind(mainMod .. " ALT, M",
    hl.dsp.exec_cmd('notify-send -t 3000 -i ~/.config/swaync/assets/play-circle.png "MPV" "Loading video..." && mpv "$(wl-paste)"'),
    { description = "MPV Clipboard" })

-- Swaync
hl.bind(mainMod .. ", N",  hl.dsp.exec_cmd("swaync-client -t -sw"),  { description = "Notification Center" })

-- Window Cycle
hl.bind("ALT, tab",  hl.dsp.window.cyclenext(),         { description = "Cycle Windows" })
hl.bind("ALT, tab",  hl.dsp.window.bringactivetotop(),  { description = "Bring to Top" })

-- Search Keybinds
hl.bind(mainMod .. ", K",  hl.dsp.exec_cmd(scriptsDir .. "/Key-bind.sh"),  { description = "Search Keybinds" })

-- Mouse scroll tilt (horizontal scroll → alt+arrow)
hl.bind(", mouse_left",   hl.dsp.exec_cmd("wtype -M alt -k left -m alt"),   { description = "Scroll Tilt Left" })
hl.bind(", mouse_right",  hl.dsp.exec_cmd("wtype -M alt -k right -m alt"),  { description = "Scroll Tilt Right" })

-- OCR (Tesseract)
hl.bind(mainMod .. ", O",
    hl.dsp.exec_cmd('sh -c \'text=$(slurp | grim -g - - | tesseract stdin stdout -l eng); printf "%s" "$text" | wl-copy; notify-send -i "' .. noti_icon .. '/clipboard.png" "Text Copied" "$text"\''),
    { description = "OCR Selection" })
hl.bind(mainMod .. " SHIFT, O",
    hl.dsp.exec_cmd('sh -c \'text=$(grim - | tesseract stdin stdout -l eng); printf "%s" "$text" | wl-copy; notify-send -i "' .. noti_icon .. '/clipboard.png" "Text Copied" "$text"\''),
    { description = "OCR Fullscreen" })

-- ---------------- VM Passthrough Submap ----------------
-- Enter passthrough mode (all keys passed to VM), escape with SUPER+Escape+P

hl.bind(mainMod .. " ALT, P",  hl.dsp.submap("passthru"),  { description = "Enable Passthrough" })

hl.submap("passthru", function()
    hl.bind(mainMod .. " Escape, P",  hl.dsp.submap("reset"),  { description = "Disable Passthrough" })
end)

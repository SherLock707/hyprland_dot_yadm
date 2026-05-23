--[[
██╗  ██╗███████╗██╗   ██╗██████╗ ██╗███╗   ██╗██████╗ 
██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔══██╗██║████╗  ██║██╔══██╗
█████╔╝ █████╗   ╚████╔╝ ██████╔╝██║██╔██╗ ██║██║  ██║
██╔═██╗ ██╔══╝    ╚██╔╝  ██╔══██╗██║██║╚██╗██║██║  ██║
██║  ██╗███████╗   ██║   ██████╔╝██║██║ ╚████║██████╔╝
╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝╚═╝  ╚═══╝╚═════╝ 
--]]
-- See: https://wiki.hypr.land/Configuring/Basics/Binds/

-- ---------------- Variables ----------------

local home    = os.getenv("HOME")

local terminal    = "foot"
local termSec     = "kitty"
local files_main  = "dolphin"
local files_sec   = "thunar"
local browser     = "brave"
local scriptsDir  = home .. "/.config/hypr/scripts"
local noti_icon   = home .. "/.config/swaync/assets"
local ani_cli_cmd = "ani-cli-mpv"

-- Script shortcuts
local AirplaneMode = scriptsDir .. "/AirplaneMode.sh"
local Media        = scriptsDir .. "/MediaCtrl.sh"
local screenshot   = scriptsDir .. "/ScreenShot.sh"
local volume       = scriptsDir .. "/Volume.sh"
local drop_down    = scriptsDir .. "/Dropterminal_adv.sh"
local drop_cmd     = "foot -e zellij attach --create scratchpad"
local brightness   = scriptsDir .. "/Brightness.sh"

-- ---------------- System Controls ----------------

-- Power
hl.bind("XF86poweroff",           hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh --suspend"), { description = "Suspend System" })
hl.bind("CTRL + ALT + Delete",    hl.dsp.exec_cmd("hyprshutdown"),                            { description = "Exit Hyprland" })
hl.bind("CTRL + ALT + P",         hl.dsp.exec_cmd(scriptsDir .. "/RofiPower.sh"),             { description = "Power Menu" })
hl.bind("XF86mail",               hl.dsp.exec_cmd(scriptsDir .. "/RofiPower.sh"),             { description = "Power Menu Alt (F12)" })
hl.bind("CTRL + ALT + L",         hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"),            { description = "Lock Screen" })
hl.bind("XF86Sleep",              hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"),            { description = "Sleep Lock (FN+F11)" })

-- Hyprland
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"),    { description = "Reload Config" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("hyprctl kill"),      { description = "Kill Window (picker)" })
hl.bind("SUPER + Escape",    hl.dsp.exec_cmd("hyprctl kill"),      { description = "Kill Window Alt" })

-- Wayland / Waybar
hl.bind("CTRL + SHIFT + W",  hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"),              { description = "Refresh Wayland" })
hl.bind("CTRL + ALT + W",    hl.dsp.exec_cmd(scriptsDir .. "/Refresh_with_waybar.sh"),  { description = "Refresh with Waybar" })
hl.bind("CTRL + W",          hl.dsp.exec_cmd(scriptsDir .. "/WaybarStyles.sh"),         { description = "Waybar Styles" })
hl.bind("SUPER + W",   hl.dsp.exec_cmd("pkill waypaper || true && waypaper"),     { description = "Waypaper" })
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(scriptsDir .. "/WallpaperSelect.sh"), { description = "Wallpaper Select" })
hl.bind("ALT + W",           hl.dsp.exec_cmd(scriptsDir .. "/WaybarLayout.sh"),         { description = "Waybar Layout" })

-- ---------------- App Launchers ----------------

-- Rofi (release bind for tap detection)
hl.bind("SUPER + SUPER_L",
    hl.dsp.exec_cmd("pkill rofi || rofi -matching fuzzy -show drun -modi drun,filebrowser,run,window"),
    { release = true, description = "App Launcher" })
hl.bind("SUPER + E",        hl.dsp.exec_cmd(scriptsDir .. "/RofiSearch.sh"),  { description = "Google Search (Rofi)" })
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd(scriptsDir .. "/RofiBeats.sh"),  { description = "Lofi Beats" })
hl.bind("SUPER + ALT + E",  hl.dsp.exec_cmd(scriptsDir .. "/RofiEmoji.sh"),  { description = "Emoji Picker" })
hl.bind("SUPER + H",        hl.dsp.exec_cmd(scriptsDir .. "/KeyHints.sh"),   { description = "Key Hints" })

-- Apps
hl.bind("SUPER + Return",         hl.dsp.exec_cmd(terminal),          { description = "Primary Terminal" })
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd(termSec),           { description = "Secondary Terminal" })
hl.bind("SUPER + D",             hl.dsp.exec_cmd(files_main),         { description = "Dolphin File Manager" })
hl.bind("SUPER + T",             hl.dsp.exec_cmd(files_sec),          { description = "Thunar File Manager" })
hl.bind("SUPER + B",             hl.dsp.exec_cmd(browser),            { description = "Browser" })
hl.bind("XF86calculator",              hl.dsp.exec_cmd("qalculate-qt"),     { description = "Calculator (F3)" })

-- Ani-cli
hl.bind("XF86explorer", hl.dsp.exec_cmd(ani_cli_cmd .. " -q 1080p --dub --rofi"), { description = "Ani-cli Dub (F1)" })
hl.bind("XF86homepage", hl.dsp.exec_cmd(ani_cli_cmd .. " -q 1080p --rofi"),       { description = "Ani-cli Sub (F2)" })
hl.bind("XF86tools",    hl.dsp.exec_cmd(ani_cli_cmd .. " -c --rofi"),             { description = "Ani-cli Continue (F4)" })

-- ---------------- Window Management ----------------

-- Window States
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }),                              { description = "Toggle Float" })
hl.bind("SUPER + ALT + F",   hl.dsp.layout("workspaceopt allfloat"),               { description = "All Float" })
hl.bind("SUPER + F",         hl.dsp.window.fullscreen(),                                              { description = "Fullscreen" })
hl.bind("SUPER + Q",         hl.dsp.window.close(),                                                   { description = "Close Window" })
hl.bind("SUPER + P",         hl.dsp.window.pin(),                                                     { description = "Pin Window" })

-- Layout
hl.bind("SUPER + CTRL + D",    hl.dsp.layout("removemaster"),                                        { description = "Remove Master" })
hl.bind("SUPER + X",           hl.dsp.window.fullscreen({ mode = "maximized" }),               { description = "Maximize" })
hl.bind("SUPER + F11",         hl.dsp.window.fullscreen_state({ internal = 2, client = -1, action = "toggle" }),{ description = "Fullscreen Toggle" })
hl.bind("SUPER + I",           hl.dsp.layout("addmaster"),                                           { description = "Add Master" })
hl.bind("SUPER + J",           hl.dsp.layout("cyclenext"),                                           { description = "Cycle Next" })
hl.bind("SUPER + CTRL + J",    hl.dsp.layout("cycleprev"),                                           { description = "Cycle Previous" })
hl.bind("SUPER + M",           hl.dsp.layout("splitratio 0.3"),                   { description = "Split Ratio 0.3" })
hl.bind("SUPER + SHIFT + M",   hl.dsp.layout("splitratio -0.3"),                  { description = "Split Ratio -0.3" })
hl.bind("SUPER + CTRL + Return", hl.dsp.layout("swapwithmaster"),                                    { description = "Swap with Master" })
hl.bind("SUPER + Space",       hl.dsp.exec_cmd(scriptsDir .. "/ChangeLayout.sh"),                    { description = "Change Layout" })
hl.bind("SUPER + SHIFT + X",   hl.dsp.layout("swapsplit"),                                           { description = "Swap Split" })

-- Scrolling layout column navigation
hl.bind("SUPER + bracketright", hl.dsp.layout("move +col"), { description = "Scroll Col Right" })
hl.bind("SUPER + bracketleft",  hl.dsp.layout("move -col"), { description = "Scroll Col Left" })

-- Grouping
hl.bind("SUPER + G",          hl.dsp.group.toggle(),                        { description = "Toggle Group" })
hl.bind("SUPER + CTRL + Tab", hl.dsp.group.next(),                          { description = "Change Group Focus" })
hl.bind("SUPER + CTRL + R",   hl.dsp.window.move({ out_of_group = true }),  { description = "Move Out of Group" })

-- Resize (symmetrical, anchor-preserving)
hl.bind("SUPER + SHIFT + right", function()
    hl.dispatch(hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
    hl.dispatch(hl.dsp.window.move({ x = 25, y = 0, relative = true }))
end, { repeating = true, description = "Resize Width +" })

hl.bind("SUPER + SHIFT + left", function()
    hl.dispatch(hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
    hl.dispatch(hl.dsp.window.move({ x = -25, y = 0, relative = true }))
end, { repeating = true, description = "Resize Width -" })

hl.bind("SUPER + SHIFT + down", function()
    hl.dispatch(hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
    hl.dispatch(hl.dsp.window.move({ x = 0, y = 25, relative = true }))
end, { repeating = true, description = "Resize Height +" })

hl.bind("SUPER + SHIFT + up", function()
    hl.dispatch(hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
    hl.dispatch(hl.dsp.window.move({ x = 0, y = -25, relative = true }))
end, { repeating = true, description = "Resize Height -" })

-- Move/Resize with Mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move Window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize Window" })

-- HyprTasking / Navigation
-- hl.bind("SUPER + I",     hl.dsp.exec_cmd("hyprtasking:toggle cursor"), { description = "Tasking Toggle" })
-- hl.bind("SUPER + left",  hl.dsp.exec_cmd("hyprtasking:move left"),     { description = "Tasking Left" })
-- hl.bind("SUPER + down",  hl.dsp.exec_cmd("hyprtasking:move down"),     { description = "Tasking Down" })
-- hl.bind("SUPER + up",    hl.dsp.exec_cmd("hyprtasking:move up"),       { description = "Tasking Up" })
-- hl.bind("SUPER + right", hl.dsp.exec_cmd("hyprtasking:move right"),    { description = "Tasking Right" })

-- ---------------- Workspace Management ----------------

-- Special Workspace
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "special" }), { description = "Move to Special" })
hl.bind("SUPER + U",         hl.dsp.workspace.toggle_special(),              { description = "Toggle Special" })

-- Switch / move to workspaces 1–10
for i = 1, 10 do
    local key = i % 10  -- 10 → key "0"
    hl.bind("SUPER + " .. key,                hl.dsp.focus({ workspace = i }),                       { description = "Workspace " .. i })
    hl.bind("SUPER + CTRL + " .. key,         hl.dsp.window.move({ workspace = i }),                 { description = "Move to WS " .. i })
    hl.bind("SUPER + SHIFT + " .. key,        hl.dsp.window.move({ workspace = i, follow = false}),  { description = "Move Silent WS " .. i })
end

-- Workspace navigation
hl.bind("SUPER + mouse_down",        hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind("SUPER + mouse_up",          hl.dsp.focus({ workspace = "e-1" }), { description = "Prev Workspace" })
hl.bind("SUPER + period",            hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace Alt" })
hl.bind("SUPER + comma",             hl.dsp.focus({ workspace = "e-1" }), { description = "Prev Workspace Alt" })
hl.bind("SUPER + CTRL + bracketleft",    hl.dsp.window.move({ workspace = "-1" }),              { description = "Move to Prev WS" })
hl.bind("SUPER + CTRL + bracketright",   hl.dsp.window.move({ workspace = "+1" }),              { description = "Move to Next WS" })
hl.bind("SUPER + SHIFT + bracketleft",   hl.dsp.window.move({ workspace = "-1", follow = false }), { description = "Move Silent Prev" })
hl.bind("SUPER + SHIFT + bracketright",  hl.dsp.window.move({ workspace = "+1", follow = false }), { description = "Move Silent Next" })

-- Razer mouse side buttons
hl.bind("mouse:275", hl.dsp.focus({ workspace = "e-1" }), { description = "Prev WS Mouse" })
hl.bind("mouse:276", hl.dsp.focus({ workspace = "e+1" }), { description = "Next WS Mouse" })

-- ---------------- Multimedia Controls ----------------

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume .. " --inc"),        { description = "Volume Up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volume .. " --dec"),        { description = "Volume Down" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(volume .. " --toggle-mic"), { description = "Toggle Mic" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(volume .. " --toggle"),     { description = "Toggle Mute (FN+F1)" })

-- Brightness
hl.bind("XF86MonBrightnessUp",              hl.dsp.exec_cmd(brightness .. " --inc"), { description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown",            hl.dsp.exec_cmd(brightness .. " --dec"), { description = "Brightness Down" })
hl.bind("SCROLL_LOCK",                      hl.dsp.exec_cmd(brightness .. " --dec"), { description = "Brightness Down Alt" })
hl.bind("PAUSE",                            hl.dsp.exec_cmd(brightness .. " --inc"), { description = "Brightness Up Alt" })
hl.bind("CTRL + XF86AudioRaiseVolume",      hl.dsp.exec_cmd(brightness .. " --inc"), { description = "Brightness Up Ctrl" })
hl.bind("CTRL + XF86AudioLowerVolume",      hl.dsp.exec_cmd(brightness .. " --dec"), { description = "Brightness Down Ctrl" })

-- Media
hl.bind("XF86MediaPlayPause", hl.dsp.exec_cmd(Media .. " --pause"), { description = "Play/Pause" })
hl.bind("XF86AudioPause",     hl.dsp.exec_cmd(Media .. " --pause"), { description = "Pause" })
hl.bind("XF86AudioPlay",      hl.dsp.exec_cmd(Media .. " --pause"), { description = "Play" })
hl.bind("XF86AudioNext",      hl.dsp.exec_cmd(Media .. " --nxt"),   { description = "Next Track" })
hl.bind("XF86AudioPrev",      hl.dsp.exec_cmd(Media .. " --prv"),   { description = "Previous Track" })
hl.bind("XF86AudioStop",      hl.dsp.exec_cmd(Media .. " --stop"),  { description = "Stop Media" })

-- Hyprsunset (colour temperature)
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("hyprctl hyprsunset temperature +400"), { description = "Warmer Screen" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("hyprctl hyprsunset temperature -400"), { description = "Cooler Screen" })
hl.bind("ALT + XF86AudioMute",
    hl.dsp.exec_cmd("hyprctl hyprsunset temperature $([ $(hyprctl hyprsunset temperature) = 6500 ] && echo 3500 || echo 6500)"),
    { description = "Toggle Night Light" })

-- ---------------- Screenshot ----------------

hl.bind("Print",                          hl.dsp.exec_cmd(screenshot .. " --now"),  { description = "Screenshot Now" })
hl.bind("ALT + Print",                    hl.dsp.exec_cmd(screenshot .. " --hush"), { description = "Screenshot Hush" })
hl.bind("SUPER + CTRL + Print",     hl.dsp.exec_cmd(screenshot .. " --in5"),  { description = "Screenshot 5s" })
hl.bind("SUPER + ALT + Print",      hl.dsp.exec_cmd(screenshot .. " --in10"), { description = "Screenshot 10s" })
hl.bind("CTRL + Print",                   hl.dsp.exec_cmd(screenshot .. " --win"),  { description = "Screenshot Window" })
hl.bind("SHIFT + Print",                  hl.dsp.exec_cmd(screenshot .. " --area"), { description = "Screenshot Area" })
hl.bind("SUPER + SHIFT + Print",    hl.dsp.exec_cmd(screenshot .. " --area"), { description = "Screenshot Area Alt" })

-- Satty annotate
hl.bind("SUPER + SHIFT + S",
    hl.dsp.exec_cmd('grim -g "$(slurp)" -t ppm - | satty -f - --output-filename ~/Pictures/Screenshots/satty-$(date \'+%Y-%m-%d_%H%M%S\').png'),
    { description = "Satty Annotate" })

-- ---------------- Misc ----------------

-- Dropdown terminal
-- hl.bind("SUPER + S", hl.dsp.exec_cmd(drop_down .. ' "' .. drop_cmd .. '"'), { description = "Dropdown Terminal" })
require("conf.extra.scratchpad")
-- hl.bind("Insert",          hl.dsp.exec_cmd(drop_down .. ' "' .. drop_cmd .. '"'), { description = "Dropdown Terminal Alt" })

-- Overview (quickshell)
hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewToggle"), { description = "Toggle Overview" })

-- Clipboard Manager
hl.bind("SUPER + V", hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"), { description = "Clipboard Manager" })

-- System
hl.bind("XF86Rfkill", hl.dsp.exec_cmd(AirplaneMode), { description = "Airplane Mode (FN+F12)" })

-- Window Effects
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(scriptsDir .. "/ChangeBlur.sh"), { description = "Toggle Blur" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd(scriptsDir .. "/GameMode.sh"),   { description = "Game Mode" })
-- hl.bind("SUPER + L",         hl.dsp.exec_cmd(scriptsDir .. "/hyprshade.sh"),  { description = "Hyprshade" })

-- Window Opacity
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd("hyprctl setprop active opaque toggle"), { description = "Toggle Opacity" })

-- Cursor Zoom
-- hl.bind("SUPER + CTRL + mouse_down",
--     hl.dsp.exec_cmd('hyprctl keyword cursor:zoom_factor $(awk "BEGIN {print $(hyprctl getoption cursor:zoom_factor | grep \'float:\' | awk \'{print $2}\') + 0.7}")'),
--     { description = "Zoom Out" })
-- hl.bind("SUPER + CTRL + mouse_up",
--     hl.dsp.exec_cmd('hyprctl keyword cursor:zoom_factor $(awk "BEGIN {print $(hyprctl getoption cursor:zoom_factor | grep \'float:\' | awk \'{print $2}\') - 0.7}")'),
--     { description = "Zoom In" })

local zoom = dofile(os.getenv("HOME") .. "/.config/hypr/conf/extra/zoom.lua")
hl.bind("SUPER + CTRL + mouse_down", function()
  zoom.zoom_in()
end)
hl.bind("SUPER + CTRL + mouse_up", function()
  zoom.zoom_out()
end)

-- YTDL-MPV
hl.bind("SUPER + Y", hl.dsp.exec_cmd("ytdl-mpv"), { description = "YTDL MPV" })

-- MPV from clipboard
hl.bind("SUPER + ALT + M",
    hl.dsp.exec_cmd('notify-send -t 3000 -i ~/.config/swaync/assets/play-circle.png "MPV" "Loading video..." && mpv "$(wl-paste)"'),
    { description = "MPV Clipboard" })

-- Swaync
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "Notification Center" })

-- Window Cycle
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())   -- wiki: cycle_next (snake_case)
    hl.dispatch(hl.dsp.window.bring_to_top()) -- wiki: bring_to_top (snake_case)
end, { description = "Cycle Windows" })

-- Search Keybinds
hl.bind("SUPER + K", hl.dsp.exec_cmd(scriptsDir .. "/Key-bind.sh"), { description = "Search Keybinds" })

-- Mouse scroll tilt (horizontal scroll → alt+arrow)
hl.bind("mouse_left",  hl.dsp.exec_cmd("wtype -M alt -k left -m alt"),  { description = "Scroll Tilt Left" })
hl.bind("mouse_right", hl.dsp.exec_cmd("wtype -M alt -k right -m alt"), { description = "Scroll Tilt Right" })

-- OCR (Tesseract)
hl.bind("SUPER + O",
    hl.dsp.exec_cmd('sh -c \'text=$(slurp | grim -g - - | tesseract stdin stdout -l eng); printf "%s" "$text" | wl-copy; notify-send -i "' .. noti_icon .. '/clipboard.png" "Text Copied" "$text"\''),
    { description = "OCR Selection" })
hl.bind("SUPER + SHIFT + O",
    hl.dsp.exec_cmd('sh -c \'text=$(grim - | tesseract stdin stdout -l eng); printf "%s" "$text" | wl-copy; notify-send -i "' .. noti_icon .. '/clipboard.png" "Text Copied" "$text"\''),
    { description = "OCR Fullscreen" })

-- ---------------- VM Passthrough Submap ----------------
-- Enter passthrough mode (all keys forwarded to VM); exit with SUPER + Escape + P.

-- hl.bind("SUPER + ALT + P", hl.dsp.submap("passthru"), { description = "Enable Passthrough" })

-- hl.define_submap("passthru", function()
--     hl.bind("SUPER + Escape + P", hl.dsp.submap("reset"), { description = "Disable Passthrough" })
-- end)

-- ---------------- EXPERIMENTAL ---------------------------
-- hl.bind("SUPER + P",   hl.dsp.layout("promote"))
-- hl.bind("SUPER + V",   hl.dsp.layout("splitv"))
-- hl.bind("SUPER + H",   hl.dsp.layout("splith"))
-- hl.bind("SUPER + R",   hl.dsp.layout("rotate"))
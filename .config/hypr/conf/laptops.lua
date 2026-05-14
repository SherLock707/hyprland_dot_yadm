--  ██╗      █████╗ ██████╗ ████████╗ ██████╗ ██████╗
--  ██║     ██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
--  ██║     ███████║██████╔╝   ██║   ██║   ██║██████╔╝
--  ██║     ██╔══██║██╔═══╝    ██║   ██║   ██║██╔═══╝
--  ███████╗██║  ██║██║        ██║   ╚██████╔╝██║
--  ╚══════╝╚═╝  ╚═╝╚═╝        ╚═╝    ╚═════╝ ╚═╝

-- ---------------- Laptop-Specific Binds ----------------
-- This file is an addendum to keybinds.lua, intended for laptop hardware.
-- Uncomment and adjust as needed for your specific laptop model.
-- Remember to uncomment require("conf.laptops") in hyprland.lua.

-- local home       = os.getenv("HOME")  -- use os.getenv(), NOT "$HOME" ($ not expanded in Lua strings)
-- local scriptsDir = home .. "/.config/hypr/scripts"
-- local backlight  = scriptsDir .. "/Brightness.sh"
-- local kbacklight = scriptsDir .. "/BrightnessKbd.sh"
-- local touchpad   = scriptsDir .. "/TouchPad.sh"

-- Keyboard backlight (FN+F2 / FN+F3)
-- No-mod keys: bare key string only — no leading ", " (that was old hyprlang syntax)
-- hl.bind("XF86KbdBrightnessDown",  hl.dsp.exec_cmd(kbacklight .. " --dec"),  { description = "Kbd Brightness Down (FN+F2)" })
-- hl.bind("XF86KbdBrightnessUp",    hl.dsp.exec_cmd(kbacklight .. " --inc"),  { description = "Kbd Brightness Up (FN+F3)" })

-- ASUS-specific (ROG / Armory Crate)
-- hl.bind("XF86Launch1",  hl.dsp.exec_cmd("rog-control-center"),           { description = "ASUS Armory Crate" })
-- hl.bind("XF86Launch3",  hl.dsp.exec_cmd("asusctl led-mode -n"),          { description = "Switch Keyboard RGB (FN+F4)" })
-- hl.bind("XF86Launch4",  hl.dsp.exec_cmd("asusctl profile -n"),           { description = "Fan Profile (FN+F5)" })

-- Monitor brightness (FN+F7 / FN+F8)
-- hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd(backlight .. " --dec"),  { description = "Brightness Down (FN+F7)" })
-- hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd(backlight .. " --inc"),  { description = "Brightness Up (FN+F8)" })

-- Touchpad toggle (FN+F10)
-- hl.bind("XF86TouchpadToggle",  hl.dsp.exec_cmd(touchpad),  { description = "Toggle Touchpad (FN+F10)" })

-- Lid Switch — disable laptop panel when lid closed with external monitor connected
-- Switch bind syntax: bare "switch:on:..." — NO leading ", " (old hyprlang)
-- hl.bind("switch:off:Lid Switch",  hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, preferred, auto, 1"'), { locked = true })
-- hl.bind("switch:on:Lid Switch",   hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable"'),           { locked = true })

-- Screenshot binds for laptops without PrintScr (e.g. ASUS G15 — FN+F6)
-- Key syntax: "SUPER + F6" with + separator — NOT "SUPER, F6" (old hyprlang)
-- hl.bind("SUPER + F6",                hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"),   { description = "Screenshot Now" })
-- hl.bind("SUPER + SHIFT + F6",        hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"),  { description = "Screenshot Area" })
-- hl.bind("SUPER + CTRL + SHIFT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"),   { description = "Screenshot 5s" })
-- hl.bind("SUPER + ALT + F6",          hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"),  { description = "Screenshot 10s" })

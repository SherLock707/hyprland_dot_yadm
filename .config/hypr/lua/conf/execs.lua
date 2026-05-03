--   ▗▄▄▖▗▄▄▄▖▗▄▖ ▗▄▄▖▗▄▄▄▖▗▖ ▗▖▗▄▄▖
--  ▐▌     █ ▐▌ ▐▌▐▌ ▐▌ █  ▐▌ ▐▌▐▌ ▐▌
--   ▝▀▚▖  █ ▐▛▀▜▌▐▛▀▚▖ █  ▐▌ ▐▌▐▛▀▘
--  ▗▄▄▞▘  █ ▐▌ ▐▌▐▌ ▐▌ █  ▝▚▄▞▘▐▌

-- ---------------- Path Helpers ----------------

local home            = os.getenv("HOME")
local scriptsDir      = home .. "/.config/hypr/scripts"
local personalScripts = home .. "/.config/waybar/custom_modules"

-- ---------------- Wallpaper ----------------

hl.exec_once("awww-daemon --format xrgb")

-- ---------------- System Environment ----------------

hl.exec_once("dbus-update-activation-environment --systemd --all")
hl.exec_once("systemctl --user import-environment QT_QPA_PLATFORMTHEME")

-- ---------------- System Services ----------------

-- hl.exec_once(scriptsDir .. "/Polkit.sh")
hl.exec_once("systemctl --user start hyprpolkitagent")
hl.exec_once(scriptsDir .. "/PortalHyprland.sh")

-- ---------------- Startup Applications ----------------

hl.exec_once("pkill kde6")

hl.exec_once("waybar")
hl.exec_once("swaync")
hl.exec_once("qs")
hl.exec_once("nm-applet --indicator")
hl.exec_once("(sleep 5 && openrgb --server --startminimized -p ~/.config/OpenRGB/GPU_match_dim.orp)")
hl.exec_once("corectrl --minimize-systray")
hl.exec_once("opensnitch-ui")
hl.exec_once("/usr/bin/kdeconnectd")
-- hl.exec_once("input-remapper-control --command autoload &")
hl.exec_once("kdeconnect-indicator")
hl.exec_once("wl-paste --watch cliphist store")
hl.exec_once("hypridle -q")
hl.exec_once("hyprsunset")
-- hl.exec_once("hyprpm reload -nn")
-- hl.exec_once("hyprswitch init -q --custom-css ~/.config/hyprswitch/style.css --size-factor 4.5 --workspaces-per-row 5 &")
hl.exec_once("python3 " .. personalScripts .. "/power_check.py")
hl.exec_once("hyprctl setcursor Bibata-Modern-Ice 24")
hl.exec_once("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
hl.exec_once("zellij delete-all-sessions -y")

-- ---------------- Workspace Workflow (SetWorkflow) ----------------
-- Launch apps silently into their designated workspaces on startup.

-- Workspace 1: browser, file manager, system monitor
hl.exec_once("[workspace 1 silent] brave --restore-last-session &")
hl.exec_once("[workspace 1 silent] (sleep 2 && dolphin) &")
hl.exec_once('[workspace 1 silent] (sleep 4 && foot -e sh -c "zellij -l gotop_cava attach --create gotop_cava; exec fish") &')

-- Workspace 2: gaming / entertainment
hl.exec_once("[workspace 2 silent] lutris &")
-- hl.exec_once('[workspace 2 silent] brave --profile-directory=Default --app="https://app.tvtime.com/shows/watchlist" &')

-- Workspace 3: Steam
hl.exec_once("[workspace 3 silent] steam &")

-- Workspace 4: editor (uncomment as needed)
-- hl.exec_once("[workspace 4 silent] codium &")
-- hl.exec_once('[workspace 4 silent] codium "/home/itachi/.config" &')

-- Workspace 5 (unused)
-- hl.exec_once('[workspace 5 silent] codium "/run/media/itachi/DATA_SATA/Downloads" &')

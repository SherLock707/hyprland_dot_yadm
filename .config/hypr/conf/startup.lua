--[[
███████╗████████╗ █████╗ ██████╗ ████████╗██╗   ██╗██████╗ 
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██║   ██║██╔══██╗
███████╗   ██║   ███████║██████╔╝   ██║   ██║   ██║██████╔╝
╚════██║   ██║   ██╔══██║██╔══██╗   ██║   ██║   ██║██╔═══╝ 
███████║   ██║   ██║  ██║██║  ██║   ██║   ╚██████╔╝██║     
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝     
--]]
-- ---------------- Path Helpers ----------------

local home            = os.getenv("HOME")
local scriptsDir      = home .. "/.config/hypr/scripts"
local personalScripts = home .. "/.config/waybar/custom_modules"

-- ---------------- Autostart ----------------
-- hl.on("hyprland.start") fires exactly once when the compositor starts.
-- It does NOT re-run on config reload, so apps won't be relaunched on save.

hl.on("hyprland.start", function()

    -- Wallpaper daemon
    hl.exec_cmd("awww-daemon --format xrgb")

    -- System environment
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME")

    -- System services
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd(scriptsDir .. "/PortalHyprland.sh")


    -- Status bar / notification / shell
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("qs")

    -- Tray applets
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("/usr/bin/kdeconnectd")

    -- Hardware / RGB
    hl.exec_cmd("sh -c 'sleep 5 && openrgb --server --startminimized -p ~/.config/OpenRGB/GPU_match_dim.orp'")
    hl.exec_cmd("sh -c 'sleep 5 && corectrl --minimize-systray'")

    -- Firewall / security
    hl.exec_cmd("sh -c 'sleep 5 && opensnitch-ui --background'")

    -- Clipboard / idle / sunset
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hypridle -q")
    hl.exec_cmd("hyprsunset")

    -- Personal scripts
    hl.exec_cmd("python3 " .. personalScripts .. "/power_check.py")

    -- Cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")

    -- Zellij session cleanup
    hl.exec_cmd("zellij delete-all-sessions -y")

    -- ---------------- Workspace 1 Workflow ----------------
    -- Handled by conf/extra/setupworkspace.lua
    require("conf.extra.setupworkspace")
    
    -- local ws1 = { workspace = "1 silent" }
    local ws2 = { workspace = "2 silent" }
    local ws3 = { workspace = "3 silent" }
    -- local ws4 = { workspace = "4 silent" }

    -- hl.exec_cmd("brave --restore-last-session", ws1)
    -- hl.exec_cmd("sh -c 'sleep 1 && dolphin'",   ws1)
    -- hl.exec_cmd([[sh -c 'sleep 3 && foot -e sh -c "zellij -l gotop_cava attach --create gotop_cava; exec fish"']], ws1)

    hl.exec_cmd("lutris", ws2)
    hl.exec_cmd("steam", ws3)
    -- hl.exec_cmd("codium", ws4)

    -- Kill leftover kde processes from previous session
    hl.exec_cmd("sh -c 'sleep 5 && pkill kde6'")

end)
--  ▗▖ ▗▖▗▄▄▄▖▗▖  ▗▖▗▄▄▄  ▗▄▖ ▗▖ ▗▖    ▗▄▄▖ ▗▖ ▗▖▗▖   ▗▄▄▄▖ ▗▄▄▖
--  ▐▌ ▐▌  █  ▐▛▚▖▐▌▐▌  █▐▌ ▐▌▐▌ ▐▌    ▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌
--  ▐▌ ▐▌  █  ▐▌ ▝▜▌▐▌  █▐▌ ▐▌▐▌ ▐▌    ▐▛▀▚▖▐▌ ▐▌▐▌   ▐▛▀▀▘ ▝▀▚▖
--  ▐▙█▟▌▗▄█▄▖▐▌  ▐▌▐▙▄▄▀▝▚▄▞▘▐▙█▟▌    ▐▌ ▐▌▝▚▄▞▘▐▙▄▄▖▐▙▄▄▖▗▄▄▞▘

-- See: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- ================================================================
-- App-Specific Float Rules — System Utilities
-- ================================================================

hl.window_rule({
    name   = "float-system-utilities",
    match  = { class = "^(nm-connection-editor|blueman-manager|pavucontrol|corectrl|nwg-look|qt[56]ct|yad|gnome-system-monitor|opensnitch|org.kde.keditfiletype|org.kde.kdeconnect.(handler|daemon)|steam|script-fu-interpreter|com.gabm.satty|script-fu)$" },
    float  = true,
})

hl.window_rule({
    name   = "float-opensnitch-rule",
    match  = { class = "^(opensnitch_ui)$", title = "^(Rule)$" },
    float  = true,
})

hl.window_rule({
    name   = "float-portal",
    match  = { class = "^(xdg-desktop-portal-gtk|org.freedesktop.impl.portal.desktop.kde)$" },
    float  = true,
    size   = { width = "monitor_w*0.40", height = "monitor_h*0.50" },
    center = true,
})

-- ================================================================
-- App-Specific Float Rules — Media & UI
-- ================================================================

hl.window_rule({
    name  = "float-media-ui",
    match = { class = "^(mpv|eog|org.gnome.eog|qalculate-(qt|gtk)|io.github.Qalculate.qalculate-qt|com.rafaelmardojai.Blanket|com.github.neithern.g4music)$" },
    float = true,
})

-- ================================================================
-- App-Specific Float Rules — Gaming & Launchers
-- ================================================================

hl.window_rule({
    name  = "float-gaming",
    match = { class = "^([Ss]team|net.lutris.Lutris|ProtonUp-Qt|zenity)$" },
    float = true,
})

-- ================================================================
-- File & Image Dialogs
-- ================================================================

hl.window_rule({
    name  = "float-file-dialogs",
    match = { class = "^(file-roller|file-.*|script-fu.*)$", title = "^(Open File|Save File|Extract archive|Export.*|Choose Application — Dolphin|Extract — Dolphin)$" },
    float = true,
})

hl.window_rule({ name = "float-branchdialog", match = { title = "^(branchdialog)$" }, float = true })
hl.window_rule({ name = "float-brave",        match = { class = "^(brave)$" },        float = true })

-- ================================================================
-- Editors & Terminals
-- ================================================================

hl.window_rule({ name = "float-editors-terms", match = { class = "^(mousepad|foot-dropterm|kew_player)$" }, float = true })

hl.window_rule({
    name  = "kew-player-position",
    match = { class = "^(kew_player)$" },
    size  = { width = "monitor_w*0.12", height = "monitor_h*0.40" },
    move  = { x = "monitor_w*0.87",    y = "monitor_h*0.40" },
    pin   = true,
})

-- ================================================================
-- KDE / Garuda Apps
-- ================================================================

hl.window_rule({
    name  = "float-kde-garuda",
    match = { class = "^([Gg]aruda.*|octopi|kdeconnect.*|org.kde.gwenview|[Yy]akuake)$" },
    float = true,
})

-- ================================================================
-- Generic Dialog Classes
-- ================================================================

hl.window_rule({
    name  = "float-generic-dialogs",
    match = { class = "^(file_progress|confirm|dialog|download|notification|error|splash|confirmreset)$" },
    float = true,
})

-- ================================================================
-- General Window Rules
-- ================================================================

hl.window_rule({
    name             = "focus-on-activate-apps",
    match            = { class = "^(brave-browser|codium|org.kde.dolphin|foot)$" },
    focus_on_activate = true,
})

-- Octopi
hl.window_rule({
    name   = "octopi-size",
    match  = { class = "^(octopi)$", title = "^(Octopi)$" },
    size   = { width = "monitor_w*0.41", height = "monitor_h*0.69" },
    center = true,
})

-- File Operations
hl.window_rule({
    name  = "float-thunar-ops",
    match = { class = "^(thunar)$", title = "^(File Operation Progress|Confirm to replace files|Rename.*)$" },
    float = true,
})

-- Music Utilities
hl.window_rule({
    name  = "float-music-utils",
    match = { class = "^(io.bassi.Amberol|net.davidotek.pupgui2)$" },
    float = true,
})

-- ================================================================
-- Web Apps (Brave PWAs)
-- ================================================================

hl.window_rule({
    name  = "float-brave-webapps",
    match = { class = "^(brave-(chat.openai.com|gemini.google.com|music.youtube.com|app.tvtime.com).*)$" },
    float = true,
})

hl.window_rule({
    name  = "size-brave-ai-music",
    match = { class = "^(brave-(chat.openai.com|gemini.google.com|music.youtube.com).*)$" },
    size  = { width = "monitor_w*0.30", height = "monitor_h*0.50" },
    move  = { x = "monitor_w*0.02",    y = "monitor_h*0.05" },
})

hl.window_rule({
    name  = "size-brave-tvtime",
    match = { class = "^(brave-(app.tvtime.com).*)$" },
    size  = { width = "monitor_w*0.15", height = "monitor_h*0.50" },
    move  = { x = "monitor_w*0.10",    y = "monitor_h*0.05" },
})

-- ================================================================
-- Lutris
-- ================================================================

hl.window_rule({
    name   = "lutris-size",
    match  = { class = "^(net.lutris.Lutris.*)$", title = "^(Lutris)$" },
    size   = { width = "monitor_w*0.67", height = "monitor_h*0.72" },
    center = true,
})

-- ================================================================
-- Steam
-- ================================================================

hl.window_rule({
    name   = "steam-size",
    match  = { class = "^(steam.*)$", title = "^(steam)$" },
    size   = { width = "monitor_w*0.60", height = "monitor_h*0.72" },
    center = true,
})

-- ================================================================
-- Control Panel & Config Tools
-- ================================================================

hl.window_rule({
    name   = "float-control-tools",
    match  = { class = "^(waypaper|control.exe|qt[56]ct)$" },
    float  = true,
    center = true,
})

hl.window_rule({ name = "size-control-exe", match = { class = "^(control.exe)$" }, size = { width = "monitor_w*0.45", height = "monitor_h*0.70" } })
hl.window_rule({ name = "size-waypaper",    match = { class = "^(waypaper)$" },    size = { width = "monitor_w*0.48", height = "monitor_h*0.70" } })
hl.window_rule({ name = "size-qtct",        match = { class = "^(qt[56]ct)$" },    size = { width = "monitor_w*0.23", height = "monitor_h*0.35" } })

-- ================================================================
-- Dolphin Dialogs
-- ================================================================

hl.window_rule({
    name  = "float-dolphin-ops",
    match = { class = "^(org.kde.dolphin)$", title = "^(Compressing.*|Extracting.*|File Already Exists.*)$" },
    float = true,
})

-- ================================================================
-- System Monitor
-- ================================================================

hl.window_rule({
    name   = "float-system-monitor",
    match  = { class = "^(org.gnome.SystemMonitor)$", title = "^(System Monitor)$" },
    float  = true,
    center = true,
})

-- ================================================================
-- Picture-in-Picture
-- ================================================================

local pip_match = { title = "^(Picture-in-picture)$" }
hl.window_rule({ name = "pip-float",  match = pip_match, float           = true })
hl.window_rule({ name = "pip-pin",    match = pip_match, pin             = true })
hl.window_rule({ name = "pip-aspect", match = pip_match, keep_aspect_ratio = true })
hl.window_rule({ name = "pip-nodim",  match = pip_match, no_dim          = true })
hl.window_rule({ name = "pip-opaque", match = pip_match, opaque          = true })
hl.window_rule({
    name  = "pip-geometry",
    match = pip_match,
    size  = { width = "monitor_w*0.30", height = "monitor_h*0.40" },
    move  = { x = "monitor_w*0.69",    y = "monitor_h*0.05" },
})

-- Chrome extension popups (_crx_*)
local crx_match = { title = "^(_crx_.*)" }
hl.window_rule({ name = "crx-float",  match = crx_match, float           = true })
hl.window_rule({ name = "crx-pin",    match = crx_match, pin             = true })
hl.window_rule({ name = "crx-aspect", match = crx_match, keep_aspect_ratio = true })
hl.window_rule({ name = "crx-nodim",  match = crx_match, no_dim          = true })
hl.window_rule({ name = "crx-opaque", match = crx_match, opaque          = true })
hl.window_rule({
    name  = "crx-geometry",
    match = crx_match,
    size  = { width = "monitor_w*0.30", height = "monitor_h*0.40" },
    move  = { x = "monitor_w*0.69",    y = "monitor_h*0.05" },
})

-- ================================================================
-- Workspace Assignments
-- ================================================================

hl.window_rule({ name = "ws-brave",  match = { class = "^(Brave-browser)$" },      workspace = "1" })
hl.window_rule({ name = "ws-lutris", match = { class = "^(net.lutris.Lutris)$" },  workspace = "2 silent" })
hl.window_rule({ name = "ws-tvtime", match = { class = "brave-app.tvtime.*" },      workspace = "2 silent" })
hl.window_rule({ name = "ws-steam",  match = { class = "^(steam)$" },             workspace = "3 silent" })
hl.window_rule({ name = "ws-gimp",   match = { class = "^(gimp.*)$" },            workspace = "6" })
-- hl.window_rule({ name = "ws-codium", match = { initial_title = "VSCodium" },     workspace = "4 silent" })

-- ================================================================
-- Window Opacity
-- ================================================================

hl.window_rule({ name = "opacity-rofi-brave",  match = { class = "^([Rr]ofi|Brave-browser|codium-url-handler)$" }, opacity = { active = 0.9, inactive = 0.6 } })
hl.window_rule({ name = "opacity-thunar",       match = { class = "^(thunar)$" },                                   opacity = { active = 0.9, inactive = 0.9 } })
hl.window_rule({ name = "opacity-dolphin-code", match = { class = "^(org.kde.dolphin|gedit|VSCodium)$" },           opacity = { active = 0.9, inactive = 0.8 } })
hl.window_rule({ name = "opacity-terminals",    match = { class = "^(kitty|mousepad|foot|foot-dropterm)$" },        opacity = { active = 0.9, inactive = 0.7 } })
hl.window_rule({ name = "opacity-gaming",       match = { class = "^(steam|net.lutris.Lutris)$" },                  opacity = { active = 0.8, inactive = 0.7 } })
hl.window_rule({ name = "opacity-gimp",         match = { class = "^(gimp)$" },                                     opacity = { active = 1.0, inactive = 1.0 } })

-- ================================================================
-- Browser Popups
-- ================================================================

hl.window_rule({
    name  = "float-browser-popups",
    match = { class = "^(brave|librewolf|chromium)$", title = "^(Save File|Open File|.*Popup.*)$" },
    float = true,
})

-- ================================================================
-- Experimental / Special
-- ================================================================

-- hl.window_rule({ name = "fullscreen-matrix", match = { class = "^(matrix)$" }, fullscreen = true })

hl.window_rule({
    name     = "no-focus-swaync",
    match    = { class = "^(swaync-notification-window)$" },
    no_focus = true,
})

-- ================================================================
-- Layer Rules
-- ================================================================

hl.layer_rule({
    name  = "blur-bars-overlays",
    match = { namespace = "^(waybar|overview|fabric|hyprswitch|swaync-(control-center|notification-window)|quickshell:(overview|palette)|ironbar)$" },
    blur  = true,
})

hl.layer_rule({
    name          = "alpha-bars",
    match         = { namespace = "^(waybar|overview|fabric|swaync-notification-window)$" },
    ignore_alpha  = 0,
})

hl.layer_rule({
    name          = "alpha-overlays",
    match         = { namespace = "^(swaync-control-center|quickshell:(overview|palette))$" },
    ignore_alpha  = 0.5,
})

hl.layer_rule({ name = "anim-selection",   match = { namespace = "selection" }, animation = "fade" })
hl.layer_rule({ name = "noanim-selection", match = { namespace = "selection" }, no_anim = true })

hl.layer_rule({ name = "anim-kwybars",   match = { namespace = "kwybars" }, animation = "fade" })
hl.layer_rule({ name = "noanim-kwybars", match = { namespace = "kwybars" }, no_anim = true })

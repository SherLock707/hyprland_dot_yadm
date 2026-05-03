--  ▗▄▄▄▖▗▖  ▗▖▗▖  ▗▖▗▄▄▄▖▗▄▄▖  ▗▄▖ ▗▖  ▗▖▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖▗▄▄▄▖
--  ▐▌   ▐▛▚▖▐▌▐▌  ▐▌  █  ▐▌ ▐▌▐▌ ▐▌▐▛▚▖▐▌▐▛▚▞▜▌▐▌   ▐▛▚▖▐▌  █
--  ▐▛▀▀▘▐▌ ▝▜▌▐▌  ▐▌  █  ▐▛▀▚▖▐▌ ▐▌▐▌ ▝▜▌▐▌  ▐▌▐▛▀▀▘▐▌ ▝▜▌  █
--  ▐▙▄▄▖▐▌  ▐▌ ▝▚▞▘ ▗▄█▄▖▐▌ ▐▌▝▚▄▞▘▐▌  ▐▌▐▌  ▐▌▐▙▄▄▖▐▌  ▐▌  █

-- ---------------- Environment Variables ----------------

-- General
hl.env("CLUTTER_BACKEND",      "wayland")
hl.env("GDK_BACKEND",          "wayland,x11")
hl.env("XDG_CURRENT_DESKTOP",  "Hyprland")
hl.env("XDG_SESSION_DESKTOP",  "Hyprland")
hl.env("XDG_SESSION_TYPE",     "wayland")
hl.env("XDG_MENU_PREFIX",      "plasma-")
hl.env("GTK_USE_PORTAL",       "1")
hl.env("PATH",                 "$PATH:$HOME/.local/bin/scripts/")
hl.env("EDITOR",               "nvim")

-- Qt
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",      "1")
hl.env("QT_QPA_PLATFORM",                  "wayland;xcb")   -- hyprqt6engine
hl.env("QT_QPA_PLATFORMTHEME",             "kde")
hl.env("QT_SCALE_FACTOR",                  "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QUICK_CONTROLS_STYLE",          "org.hyprland.style")
hl.env("QT_STYLE_OVERRIDE",                "kvantum-dark")   -- qt6ct-style

-- Vulkan (uncomment if using Vulkan renderer)
-- hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/radeon_icd.i686.json:/usr/share/vulkan/icd.d/radeon_icd.x86_64.json")
-- hl.env("WLR_RENDERER", "vulkan")

-- XWayland
hl.env("GDK_SCALE", "1")

-- Cursor
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",  "24")

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Electron
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- VM (uncomment for software rendering in VMs)
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

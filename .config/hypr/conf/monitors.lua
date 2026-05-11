--[[
███╗   ███╗ ██████╗ ███╗   ██╗██╗████████╗ ██████╗ ██████╗ 
████╗ ████║██╔═══██╗████╗  ██║██║╚══██╔══╝██╔═══██╗██╔══██╗
██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝
██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
--]]
-- ---------------- Monitor Configuration ----------------
-- See: https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Run `hyprctl monitors` to list connected displays.

-- Primary monitor: ultrawide at 3440×1440
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "3440x1440@60Hz",
    position = "auto",
    scale    = 1,
})

-- Fallback: preferred mode for any unmatched monitor
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- High refresh rate (all monitors)
-- hl.monitor({ output = "", mode = "highrr", position = "auto", scale = "auto" })

-- QEMU / VirtualBox
-- hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "auto", scale = 1 })

-- Disable a monitor
-- hl.monitor({ output = "name", mode = "disable" })

-- Mirror example
-- hl.monitor({ output = "DP-3", mode = "1920x1080@60", position = "0x0", scale = 1, mirror = "DP-2" })

-- ---------------- Workspace Assignments ----------------
-- Persistent workspaces pinned to the primary monitor.

for i = 1, 6 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = "HDMI-A-1",
        persistent = true,
    })
end

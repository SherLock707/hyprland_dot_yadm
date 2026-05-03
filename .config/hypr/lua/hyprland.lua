--  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗
--  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
--  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
--  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
--  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
--  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
--
-- Entry point. All modules live in ~/.config/hypr/conf/
-- Colours are in conf/colors/wallust.lua (wallust-generated palette).
-- To use a different palette, swap the require() inside settings.lua and windowrules.lua.
--
-- Load order matters:
--   1. envvars   — env vars must be set before anything reads them
--   2. monitors  — display + workspace topology established early
--   3. settings  — visual config (reads colors module internally)
--   4. windowrules
--   5. keybinds
--   6. execs     — autostart last, so env + rules are ready

require("conf.envvars")
require("conf.execs")
require("conf.monitors")
require("conf.settings")
require("conf.windowrules")
require("conf.keybinds")

-- Laptop-specific binds (uncomment if on a laptop)
-- require("conf.laptops")

--[[
███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ 
██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ 
███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗
╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║
███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝
╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
--]]
-- See: https://wiki.hypr.land/Configuring/Basics/Variables/

-- Pull colors for use in borders, groups, and plugins.
local C = dofile(os.getenv("HOME") .. "/.cache/hellwal/colors-hyprland.lua")

-- ---------------- General ----------------

hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 8,
        border_size      = 2,
        resize_on_border = true,
        col = {
            active_border   = C.color7,
            inactive_border = C.color5,
        },
        layout = "dwindle",
    },
})

-- ---------------- Dwindle Layout ----------------
-- See: https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/

hl.config({
    dwindle = {
        preserve_split       = true,
        special_scale_factor = 0.8,
        default_split_ratio  = 1.3,
    },
})

-- ---------------- Master Layout ----------------
-- See: https://wiki.hypr.land/Configuring/Layouts/Master-Layout/

hl.config({
    master = {
        new_status = "slave",
        new_on_top = false,
        mfact      = 0.65,
    },
})

-- ---------------- Scrolling Layout ----------------
-- See: https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/

hl.config({
    scrolling = {
        direction                = "down",
        column_width             = 1.0,
        fullscreen_on_one_column = true,
        follow_focus             = true,
        follow_min_visible       = 0.25,
        focus_fit_method         = 1,
    },
})

-- ---------------- Custom Layout ----------------
-- See: https://wiki.hypr.land/Configuring/Layouts/Custom-Layouts/

--  Use as lua:columns
hl.layout.register("columns", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        for i, target in ipairs(ctx.targets) do
            target:place(ctx:column(i, n))
        end
    end,
})

--  Use as lua:grid
hl.layout.register("grid", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        local cols = math.ceil(math.sqrt(n))

        for i, target in ipairs(ctx.targets) do
            target:place(ctx:grid_cell(i, cols))
        end
    end,
})

-- ---------------- Group Settings ----------------

hl.config({
    group = {
        col = {
            border_active = {
                colors = { C.color4, C.color6, C.color7, C.color13, C.color15 },
                angle  = 40,
            },
        },
        groupbar = {
            col = {
                active   = C.color7,
                inactive = C.color2,
            },
            gradients                 = true,
            gaps_in                   = 5,
            gaps_out                  = 2,
            height                    = 12,
            indicator_height          = 0,
            font_size                 = 9,
            stacked                   = false,
            rounding                  = 2,
            gradient_rounding         = 6,
            gradient_round_only_edges = true,
        },
    },
})

-- ---------------- Decoration ----------------

hl.config({
    decoration = {
        rounding           = 8,
        active_opacity     = 1.0,
        inactive_opacity   = 0.9,
        fullscreen_opacity  = 1.0,
        dim_inactive       = true,
        dim_strength       = 0.1,
        dim_special        = 0.8,

        shadow = {
            enabled        = true,
            range          = 6,
            render_power   = 2,
            -- color          = "rgba(31, 32, 44, 0.6)",
            color          = "rgba(1f202c99)",
            -- color_inactive = "rgba(31, 32, 44, 0.3)",
            color_inactive = "rgba(1f202c4d)",
            offset         = { 4, 4 },
        },

        blur = {
            enabled           = true,
            size              = 5,
            passes            = 3,
            ignore_opacity    = true,
            new_optimizations = true,
            xray              = false,
            special           = true,
            noise             = 0.0117,
            vibrancy          = 0.1696,
        },
    },
})

-- ---------------- Animations ----------------
-- See: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.config({ animations = { enabled = true } })

-- Bezier curves
hl.curve("myBezier",   { type = "bezier", points = { { 0.05, 0.9  }, { 0.1,  1.05  } } })
hl.curve("linear",     { type = "bezier", points = { { 0.0,  0.0  }, { 1.0,  1.0   } } })
hl.curve("wind",       { type = "bezier", points = { { 0.05, 0.9  }, { 0.1,  1.05  } } })
hl.curve("winIn",      { type = "bezier", points = { { 0.1,  1.1  }, { 0.1,  1.1   } } })
hl.curve("winOut",     { type = "bezier", points = { { 0.3,  -0.3 }, { 0,    1     } } })
hl.curve("slow",       { type = "bezier", points = { { 0,    0.85 }, { 0.3,  1     } } })
hl.curve("overshot",   { type = "bezier", points = { { 0.7,  0.6  }, { 0.1,  1.1   } } })
hl.curve("bounce",     { type = "bezier", points = { { 1.1,  1.6  }, { 0.1,  0.85  } } })
hl.curve("slingshot",  { type = "bezier", points = { { 1,    -1   }, { 0.15, 1.25  } } })
hl.curve("smoothOut",  { type = "bezier", points = { { 0.36, 0    }, { 0.66, -0.56 } } })
hl.curve("smoothIn",   { type = "bezier", points = { { 0.25, 1    }, { 0.5,  1     } } })
hl.curve("easeInSine", { type = "bezier", points = { { 0.005, 0.89 }, { 0.09, 0.91 } } })
hl.curve("rofi_curve", { type = "bezier", points = { { 0.34, -0.09 }, { 0,   0.96  } } })

-- Animations
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 5,   bezier = "winIn",   style = "gnomed"      }) --popin
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 5,   bezier = "winOut",  style = "gnomed"      }) --popin
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 5,   bezier = "wind",    style = "slide"      })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "linear"                        })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 100, bezier = "linear",  style = "loop"       })
hl.animation({ leaf = "fade",             enabled = true, speed = 5,   bezier = "overshot"                      })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5,   bezier = "wind"                          })
hl.animation({ leaf = "windows",          enabled = true, speed = 5,   bezier = "bounce",  style = "popin"      })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 3,   bezier = "smoothIn", style = "slide top" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 3,   bezier = "wind",     style = "slide top" })

-- ---------------- Input ----------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",
        repeat_rate  = 50,
        repeat_delay = 300,
        numlock_by_default          = false,
        left_handed                 = false,
        follow_mouse                = 1,    -- int: 0=none,1=always,2=detached,3=separate
        float_switch_override_focus = 0,    -- int: 0=off,1=on,2=on+float-to-float
        accel_profile               = "flat",

        -- touchpad = {
        --     disable_while_typing    = true,
        --     natural_scroll          = false,
        --     clickfinger_behavior    = false,
        --     middle_button_emulation = true,
        --     ["tap-to-click"]        = true,
        --     drag_lock               = false,
        -- },
    },
})

-- Gestures (uncomment to enable 3-finger swipe)
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ---------------- Miscellaneous ----------------

hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms  = true,
        vrr                      = 0,    -- int: 0=off,1=on,2=fullscreen-only,3=fullscreen+game
        enable_swallow           = false,
        focus_on_activate        = false,
        render_unfocused_fps     = 30,
    },
})

-- ---------------- Bind Settings ----------------

hl.config({
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },
})

-- ---------------- Cursor ----------------

hl.config({
    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors  = 1,    -- int: 0=use if possible,1=never,2=auto
        enable_hyprcursor    = true,
        no_warps             = true,
    },
})

-- ---------------- XWayland ----------------

hl.config({
    xwayland = {
        enabled            = true,
        force_zero_scaling = true,
    },
})

-- ---------------- Render ----------------

hl.config({
    render = {
        direct_scanout = 0,    -- int: 0=off,1=on,2=auto(game content)
    },
})

-- ---------------- Plugin Settings ----------------

-- hl.config({
--     plugin = {
--         hyprexpo = {
--             columns          = 3,
--             gap_size         = 5,
--             bg_col           = C.color7,
--             workspace_method = "center current",
--         },
--         hyprtasking = {
--             layout          = "grid",
--             gap_size        = 15,
--             bg_color        = C.color7,
--             border_size     = 4,
--             exit_on_hovered = false,
--             grid = {
--                 rows                  = 3,
--                 cols                  = 3,
--                 loop                  = false,
--                 gaps_use_aspect_ratio = true,
--             },
--             linear = {
--                 height       = 500,
--                 scroll_speed = 1.0,
--                 blur         = 5,
--             },
--         },
--     },
-- })

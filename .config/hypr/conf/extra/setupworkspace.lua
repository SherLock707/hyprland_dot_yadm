-- conf/extra/setupworkspace.lua
-- Premium Workspace Orchestrator (Consolidated)

local CONFIG = {
    target_ws    = "1",
    master_ratio = 1.1,    -- Perfect for Brave
    slave_ratio  = 1.0,    -- 50/50 for Dolphin/Foot
    settle_delay = 800,    -- Slightly longer for heavy apps like Brave
    step_delay   = 60,
    debug        = false,
    silent       = false,
    on_done      = "Workspace 1 Setup Complete",
    apps = {
        { cmd = "brave --restore-last-session" },
        { cmd = "dolphin" },
        { cmd = [[foot -e sh -c "zellij -l gotop_cava attach --create gotop_cava; exec fish"]] }
    }
}

local state = {
    active = false,
    index  = 1,
    addrs  = {}
}

local function notify(text, icon, is_debug)
    if CONFIG.silent then return end
    if is_debug and not CONFIG.debug then return end
    hl.notification.create({ text = text, icon = icon or "info", timeout = 3000 })
end

local function run_sequence(steps, delay)
    local i = 1
    local function next_step()
        if steps[i] then
            steps[i]()
            i = i + 1
            hl.timer(next_step, { timeout = delay, type = "oneshot" })
        end
    end
    next_step()
end

-- Listener for Workspace 1 setup
hl.on("window.open", function(win)
    if not state.active then return end
    
    -- Track windows opening on WS 1
    if win.workspace.name == CONFIG.target_ws then
        table.insert(state.addrs, win.address)
        state.index = state.index + 1
        
        if CONFIG.apps[state.index] then
            hl.exec_cmd(CONFIG.apps[state.index].cmd, { workspace = CONFIG.target_ws .. " silent" })
        else
            state.active = false
            hl.timer(function()
                local m, s1, s2 = state.addrs[1], state.addrs[2], state.addrs[3]
                if not (m and s1 and s2) then return end

                run_sequence({
                    function() hl.dispatch(hl.dsp.focus({ window = "address:" .. s1 })) end,
                    function() hl.dispatch(hl.dsp.window.move({ window = "address:" .. s2, direction = "d" })) end,
                    function() hl.dispatch(hl.dsp.focus({ window = "address:" .. m })) end,
                    function() hl.dispatch(hl.dsp.layout("splitratio " .. CONFIG.master_ratio .. " exact")) end,
                    function() hl.dispatch(hl.dsp.focus({ window = "address:" .. s1 })) end,
                    function() hl.dispatch(hl.dsp.layout("splitratio " .. CONFIG.slave_ratio .. " exact")) end,
                    function() notify(CONFIG.on_done, "ok") end
                }, CONFIG.step_delay)
            end, { timeout = CONFIG.settle_delay, type = "oneshot" })
        end
    end
end)

-- Function to trigger the setup (called from startup.lua or keybind)
local function start_setup()
    state.active = true
    state.index  = 1
    state.addrs  = {}
    notify("Orchestrating Workspace 1...", "info", true)
    hl.exec_cmd(CONFIG.apps[1].cmd, { workspace = CONFIG.target_ws .. " silent" })
end

-- Also bind to CTRL+ALT+W to manually re-run if needed
hl.bind("CTRL + ALT + E", start_setup, { description = "Re-run Workspace 1 Setup" })

-- Auto-start the sequence when this module is loaded
start_setup()

-- conf/extra/scratchpad.lua
-- Ghost-Free Hybrid Scratchpad (Robust Workspace State Management)

local CONFIG = {
    class      = "foot-scratchpad",
    cmd        = "foot -a foot-scratchpad -e zellij attach --create scratchpad",
    width_pct  = 0.6,
    height_pct = 0.5,
    y_pct      = 0.05,
    special_ws = "special:scratchpad"
}

local state = {
    addr      = nil,
    animating = false,
    launching = false
}

local function get_win()
    if state.addr then
        local win = hl.get_window("address:" .. state.addr)
        if win then return win end
    end
    for _, c in ipairs(hl.get_windows()) do
        if c.class == CONFIG.class then state.addr = c.address; return c end
    end
    return nil
end

local function toggle_scratchpad()
    if state.animating then return end

    local win = get_win()
    if not win then
        state.launching = true
        hl.notification.create({ text = "Initializing Scratchpad...", timeout = 1000 })
        hl.exec_cmd(CONFIG.cmd)
        return
    end

    local mon       = hl.get_active_monitor()
    local active_ws = hl.get_active_workspace().name
    local w         = math.floor(mon.width * CONFIG.width_pct)
    local h         = math.floor(mon.height * CONFIG.height_pct)
    local x         = math.floor(mon.x + (mon.width - w) / 2)
    local target_y  = math.floor(mon.y + mon.height * CONFIG.y_pct)
    local hidden_y  = mon.y - h - 250 

    state.animating = true

    -- REALITY CHECK: Is it already on our current workspace?
    if win.workspace.name == active_ws then
        -- HIDE: Unpin first (so it doesn't stay visible across all workspaces while hidden)
        if win.pinned then
            hl.dispatch(hl.dsp.window.pin({ window = "address:" .. win.address }))
        end

        -- HIDE: Slide up on current WS first
        hl.dispatch(hl.dsp.window.set_prop({ window = "address:" .. win.address, prop = "no_anim", value = "0" }))
        hl.dispatch(hl.dsp.window.move({ window = "address:" .. win.address, x = x, y = hidden_y }))
        
        -- After slide and bounce are finished, move it to special workspace
        hl.timer(function()
            -- Final warp to special (instant)
            hl.dispatch(hl.dsp.window.set_prop({ window = "address:" .. win.address, prop = "no_anim", value = "1" }))
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. win.address, workspace = CONFIG.special_ws, follow = false }))
            state.animating = false
        end, { timeout = 650, type = "oneshot" })
    else
        -- SHOW: Warp and Slide
        hl.dispatch(hl.dsp.window.set_prop({ window = "address:" .. win.address, prop = "no_anim", value = "1" }))
        hl.dispatch(hl.dsp.window.move({ window = "address:" .. win.address, workspace = active_ws, follow = false }))
        hl.dispatch(hl.dsp.window.float({ window = "address:" .. win.address, action = "on" }))
        
        -- SHOW: Pin it (so it follows workspaces while active)
        if not win.pinned then
            hl.dispatch(hl.dsp.window.pin({ window = "address:" .. win.address }))
        end

        hl.dispatch(hl.dsp.window.move({ window = "address:" .. win.address, x = x, y = hidden_y }))
        hl.dispatch(hl.dsp.window.resize({ window = "address:" .. win.address, x = w, y = h }))
        
        hl.timer(function()
            hl.dispatch(hl.dsp.window.set_prop({ window = "address:" .. win.address, prop = "no_anim", value = "0" }))
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. win.address, x = x, y = target_y }))
            hl.dispatch(hl.dsp.focus({ window = "address:" .. win.address }))
            hl.timer(function() state.animating = false end, { timeout = 600, type = "oneshot" })
        end, { timeout = 50, type = "oneshot" })
    end
end

-- Rules & Listeners
hl.window_rule({
    name = "scratchpad-hybrid",
    match = { class = CONFIG.class },
    float = true,
    workspace = CONFIG.special_ws .. " silent",
    animation = "windowsMove, 1, 6, overshot, slidevert"
})

-- Safety: When switching workspaces, make sure the scratchpad isn't "leaking"
hl.on("workspace.active", function()
    local win = get_win()
    if win and win.workspace.name == CONFIG.special_ws and win.pinned then
        hl.dispatch(hl.dsp.window.pin({ window = "address:" .. win.address }))
    end
end)

hl.on("window.open", function(win)
    if win.class == CONFIG.class and state.launching then
        state.launching = false
        hl.timer(toggle_scratchpad, { timeout = 400, type = "oneshot" })
    end
end)

hl.on("window.close", function(win)
    if win.address == state.addr or win.class == CONFIG.class then
        state.addr, state.animating, state.launching = nil, false, false
    end
end)

hl.bind("SUPER + S", toggle_scratchpad, { description = "Toggle Zellij Scratchpad" })

return { toggle = toggle_scratchpad }

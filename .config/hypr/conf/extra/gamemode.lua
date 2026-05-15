local game_matches = {
    "steam_app_[0-9]+",
    "gamescope",
    -- "Minecraft.*", -- Example of using .* to match titles/classes
}

local game_ws = "10"
local effects_script = os.getenv("HOME") .. "/.config/hypr/scripts/GameMode.sh"
local is_gamemode_active = false

-- Helper to check if a workspace has any windows
local function workspace_has_windows(ws_name)
    local windows = hl.get_workspace_windows(ws_name)
    return windows ~= nil and #windows > 0
end

for _, class_regex in ipairs(game_matches) do
    hl.window_rule({
        name = "move-game-" .. class_regex,
        match = { class = "^(" .. class_regex .. ")$" },
        workspace = game_ws,
        center = true,
    })
end

local active_ws = hl.get_active_workspace()
local last_ws_name = active_ws and active_ws.name or "1"

-- Initial check
if last_ws_name == game_ws and workspace_has_windows(game_ws) then
    is_gamemode_active = true
    hl.exec_cmd(effects_script .. " enable")
end

-- 1. Handle workspace switching
hl.on("workspace.active", function(ws)
    local current_ws_name = ws.name

    -- Entering game workspace
    if current_ws_name == game_ws and last_ws_name ~= game_ws then
        if workspace_has_windows(game_ws) then
            is_gamemode_active = true
            hl.exec_cmd(effects_script .. " enable")
        end
    end

    -- Leaving game workspace
    if last_ws_name == game_ws and current_ws_name ~= game_ws then
        if is_gamemode_active then
            is_gamemode_active = false
            hl.exec_cmd(effects_script .. " disable")
        end
    end

    last_ws_name = current_ws_name
end)

-- 2. Handle windows leaving Workspace (Closing or Moving)
local function check_and_disable_if_empty()
    if is_gamemode_active and not workspace_has_windows(game_ws) then
        is_gamemode_active = false
        hl.exec_cmd(effects_script .. " disable")
    end
end

-- window.destroy fires AFTER animations, ensuring the list is updated
hl.on("window.destroy", check_and_disable_if_empty)

-- Also check if you manually move a game out of WS
hl.on("window.move_to_workspace", check_and_disable_if_empty)

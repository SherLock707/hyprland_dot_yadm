-- return {
-- {
--     "nvimdev/dashboard-nvim",
--     priority = 1001,
--     lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
--     opts = function()
--     local function read_color_from_file()
--         local file_path = "~/.cache/hellwal/colors-icons"
--         local file = io.open(vim.fn.expand(file_path), "r")
        
--         -- Read the color and return it (assumes it’s in #RRGGBB format)
--         local color = file:read("*all"):match("#?([0-9a-fA-F]+)")
--         file:close()
      
--         -- Return the color in proper format (with #)
--         return "#" .. color
--       end
      
--       -- Read the color from the file
--       local logo_color = read_color_from_file()
      
--       -- Set a custom highlight group for the logo using the read color
--       vim.api.nvim_set_hl(0, "DashboardLogo", { fg = logo_color })
      
--       -- Your logo
--       local logo = [[
--         . 󰅣                  .                  .     .
--          +                    +                   │      ;      󰖐       +   󰅣
--                       .                   .      ╭╯╮ - --+--
--         󰅣     .        ╭╮          .            . │ │     !   .   ╭─────╮     ╭╮
--                       ╭╯╰╮                 ╭──╮  ╭╯'│  +  ' ╭─╮   │.   ╭╯ ╭───╯│
--            ╭─╮    ╭───╯  ╰╮     ╭─╮    ╭───╯  ╰╮ │  ╰╮   ╭──╯'│ . ││   │╭─╯   .│
--       .  ╭─╯ │ ╭──╯    │  │.  ╭─╯ │ ╭──╯    │  │╭╯   ╰─╮ │    │   │    ││     ││
--        󰹩 │'  │ │ │.    │  │ 󰣇 │'  │ │ │.   │  ││   │ │ │    │ ╭─╯    ││    ││
--       ───╯   ╰─╯       '  ╰───╯   ╰─╯       '  ╰╯    ' ╰─╯    ╰─╯'     ╰╯      ╰
--       ]]
  
--       logo = string.rep("\n", 14) .. logo .. "\n\n"
  
--       local opts = {
--         theme = "doom",
--         hide = {
--           -- this is taken care of by lualine
--           -- enabling this messes up the actual laststatus setting after loading a file
--           statusline = false,
--         },
--         config = {
--           header = vim.split(logo, "\n"),
--           highlight = "DashboardLogo",
--           -- stylua: ignore
--           center = {
--             { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },
--             { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
--             { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },
--             { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },
--             { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
--             { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
--             { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
--             { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
--             { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
--           },
--           footer = function()
--             local stats = require("lazy").stats()
--             local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
--             return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
--           end,
--         },
--       }
  
--       for _, button in ipairs(opts.config.center) do
--         button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
--         button.key_format = "  %s"
--       end
  
--       -- open dashboard after closing lazy
--       if vim.o.filetype == "lazy" then
--         vim.api.nvim_create_autocmd("WinClosed", {
--           pattern = tostring(vim.api.nvim_get_current_win()),
--           once = true,
--           callback = function()
--             vim.schedule(function()
--               vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
--             end)
--           end,
--         })
--       end
  
--       return opts
--     end,
--   }
-- }


return {
  {
    "nvimdev/dashboard-nvim",
    priority = 1001,
    lazy = false,
    opts = function()
      local function read_color_from_file()
        local file = io.open(vim.fn.expand("~/.cache/hellwal/colors-icons"), "r")
        local hex = "#" .. file:read("*all"):match("#?([0-9a-fA-F]+)")
        file:close()
        return hex
      end

      local logo_color = read_color_from_file()
      vim.api.nvim_set_hl(0, "DashboardHeader", { fg = logo_color })

      local logo = [[
        . 󰅣                  .                  .     .
       +                    +                   │      ;      󰖐       +   󰅣
    .                   .      ╭╯╮ - --+--
        󰅣     .        ╭╮          .            . │ │     !   .   ╭─────╮     ╭╮
                      ╭╯╰╮                 ╭──╮  ╭╯'│  +  ' ╭─╮   │.   ╭╯ ╭───╯│
           ╭─╮    ╭───╯  ╰╮     ╭─╮    ╭───╯  ╰╮ │  ╰╮   ╭──╯'│ . ││   │╭─╯   .│
      .  ╭─╯ │ ╭──╯    │  │.  ╭─╯ │ ╭──╯    │  │╭╯   ╰─╮ │    │   │    ││     ││
       󰹩 │'  │ │ │.    │  │ 󰣇 │'  │ │ │.   │  ││   │ │ │    │ ╭─╯    ││    ││
      ───╯   ╰─╯       '  ╰───╯   ╰─╯       '  ╰╯    ' ╰─╯    ╰─╯'     ╰╯      ╰
      ]]
      logo = string.rep("\n", 14) .. logo .. "\n\n"

      return {
        theme = "doom",
        hide = { statusline = false },
        config = {
          header = vim.split(logo, "\n"),
          center = {
              { action = 'lua LazyVim.pick()()',                           desc = " Find File          ",       icon = " ", key = "f" },
              { action = "ene | startinsert",                              desc = " New File           ",        icon = " ", key = "n" },
              { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files       ",    icon = " ", key = "r" },
              { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text          ",       icon = " ", key = "g" },
              -- { action = 'lua LazyVim.pick.config_files()()',              desc = " Config             ",          icon = " ", key = "c" },
              { action = 'lua require("persistence").load()',              desc = " Restore Session    ", icon = " ", key = "s" },
              { action = "LazyExtras",                                     desc = " Lazy Extras        ",     icon = " ", key = "x" },
              { action = "Lazy",                                           desc = " Lazy               ",            icon = "󰒲 ", key = "l" },
              { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit               ",            icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in "
                     .. (math.floor(stats.startuptime * 100 + .5)/100) .. "ms" }
          end,
        },
      }
    end,
  },
}

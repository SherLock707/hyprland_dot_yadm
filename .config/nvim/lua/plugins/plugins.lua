return {
  -- COLOR SCHEME/THEME
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { "italic" }, -- Change the style of comments
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })
    end,
  },

  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      transparent_mode = true,
    },
  },

  -- NOTIFY

  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- TELESCOPE

  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules",
          },
        },
      })
    end,
    keys = {
      {
        "<leader>sf",
        function()
          require("telescope.builtin").find_files({})
        end, -- adjust the function parameters as needed
        desc = "Find Files (root dir)",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

-- LSP CONFIG
{
  "neovim/nvim-lspconfig",
  init = function()
    require("lazyvim.util").lsp.on_attach(function(_, bufnr)
      -- Your custom LSP setup here
      -- Example:
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local opts = { noremap=true, silent=true }

      -- Example key mappings
      buf_set_keymap('n', '<leader>co', '<Cmd>lua vim.lsp.buf.organize_imports()<CR>', opts)
      buf_set_keymap('n', '<leader>cR', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    end)
  end,
  opts = {
    servers = {
      -- No language servers specified
    },
  },
},


  -- TREESITTER

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "json",
        "lua",
        "python",
        "query",
        "regex",
        "vim",
        "yaml",
        "rust"
      },
    },
  },

  -- DISCORD PRESENCE
  -- {
  --   "SIGMazer/presence.nvim",
  --   config = function()
  --     require("presence").setup({
  --       -- General options
  --       auto_update = true, -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
  --       neovim_image_text = "League of Legends", -- Text displayed when hovered over the Neovim image
  --       main_image = "https://raw.githubusercontent.com/github/explore/b088bf18ff2af3f2216294ffb10f5a07eb55aa31/topics/league-of-legends/league-of-legends.png", -- Main image display (either "neovim" or "file")
  --       --client_id = "793271441293967371", -- Use your own Discord application client id (not recommended)
  --       log_level = nil, -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
  --       debounce_timeout = 10, -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
  --       enable_line_number = false, -- Displays the current line number instead of the current project
  --       blacklist = {}, -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
  --       buttons = false, -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
  --       file_assets = {}, -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
  --       show_time = true, -- Show the timer

  --       -- Rich Presence text options
  --       editing_text = "In Queue", -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
  --       file_explorer_text = "In Queue", -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
  --       git_commit_text = "In Queue", -- Format string rendered when committing changes in git (either string or function(filename: string): string)
  --       plugin_manager_text = "In Queue", -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
  --       reading_text = "In Queue", -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
  --       workspace_text = "", -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
  --       line_number_text = "",
  --     })
  --   end,
  -- },

  -- GITHUB COPILOT
  -- {
  --   "github/copilot.vim",
  --   init = function()
  --     vim.g.copilot_no_tab_map = true
  --     vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  --   end,
  --   config = function()
  --     vim.keymap.set("i", "<C-e>", [[copilot#Accept("\<CR>")]], {
  --       silent = true,
  --       expr = true,
  --       script = true,
  --       replace_keycodes = false,
  --     })
  --   end,
  -- },

  -- COMMENTS
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  -- HARPOON
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup()
    end,
    keys = {
      {
        "<leader>a",
        function()
          require("harpoon"):list():append()
        end,
        desc = "harpoon file",
      },
      {
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "harpoon quick menu",
      },
      {
        "<leader>1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "harpoon to file 1",
      },
      {
        "<leader>2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "harpoon to file 2",
      },
      {
        "<leader>3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "harpoon to file 3",
      },
      {
        "<leader>4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "harpoon to file 4",
      },
      {
        "<leader>5",
        function()
          require("harpoon"):list():select(5)
        end,
        desc = "harpoon to file 5",
      },
    },
  },
}

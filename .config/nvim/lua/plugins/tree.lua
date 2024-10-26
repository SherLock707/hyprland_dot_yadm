return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "hyprlang",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rasi",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
    config = function()
      vim.filetype.add({
        pattern = {
          [".*/hypr/.*%.conf"] = "hyprlang",
          [".*/waybar/config"] = "jsonc",
          [".*/mako/config"] = "dosini",
          [".*/wofi/config"] = "dosini",
          [".*/kitty/*.conf"] = "bash",
          [".*/rofi/*.rasi"] = "rasi",
          [".*/wlogout/layout"] = "json",
          ["/usr/share/rofi/themes/*.rasi"] = "rasi",
        },
      })
    end,
  },
}

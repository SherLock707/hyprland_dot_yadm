-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- leader g b :Git blame

vim.api.nvim_set_keymap("n", "<leader>gb", ":Git blame_line<CR>", { noremap = true, silent = true })

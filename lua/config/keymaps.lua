-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Save all
vim.keymap.set({ "n", "v" }, "<C-s>", "<cmd>wa<cr>", { desc = "Save All" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>wa<cr>gi", { desc = "Save All" })

-- Quit all
vim.keymap.set({ "n", "v" }, "<C-x>", "<cmd>qa<cr>", { desc = "Quit All" })
vim.keymap.set("i", "<C-x>", "<Esc><cmd>qa<cr>", { desc = "Quit All" })

-- Manual format (overrides default <C-f> page-down)
vim.keymap.set({ "n", "x" }, "<C-f>", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })

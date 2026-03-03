local source = debug.getinfo(1, "S").source:sub(2)
local repo_root = vim.fn.fnamemodify(source, ":p:h:h:h")
local plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"

if vim.fn.isdirectory(plenary_path) == 0 then
  error("plenary.nvim not found at " .. plenary_path)
end

vim.opt.runtimepath:prepend(plenary_path)
vim.opt.runtimepath:prepend(repo_root)
vim.opt.packpath = vim.opt.runtimepath:get()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.cmd("runtime plugin/plenary.vim")
vim.cmd("filetype plugin indent on")

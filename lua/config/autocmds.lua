-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local cpp_template_group = augroup("cpp_template", { clear = true })

autocmd("BufNewFile", {
  group = cpp_template_group,
  pattern = { "*.cpp", "*.cc", "*.cxx", "*.c++" },
  callback = function()
    if vim.fn.line("$") ~= 1 or vim.fn.getline(1) ~= "" then
      return
    end

    local template = vim.fn.stdpath("config") .. "/templates/cpp.cpp"
    if vim.fn.filereadable(template) == 1 then
      vim.cmd("0r " .. vim.fn.fnameescape(template))
      local target_line = nil
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      for i, line in ipairs(lines) do
        if line:match("^%s*cin%.tie%(%s*nullptr%s*%)%s*;%s*$") then
          target_line = i + 1
          break
        end
      end

      local line_count = vim.api.nvim_buf_line_count(0)
      if target_line and target_line <= line_count then
        vim.api.nvim_buf_set_lines(0, target_line - 1, target_line, false, { "    " })
        vim.api.nvim_win_set_cursor(0, { target_line, 4 })
      else
        vim.cmd("normal! G")
      end
    end
  end,
})

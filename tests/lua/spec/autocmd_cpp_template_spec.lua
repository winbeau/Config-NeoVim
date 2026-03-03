local repo_root = vim.fn.getcwd()
local autocmd_file = repo_root .. "/lua/config/autocmds.lua"

describe("cpp template autocmd", function()
  it("inserts cpp template for new cpp files", function()
    dofile(autocmd_file)

    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, "p")
    local file = dir .. "/sample.cpp"

    vim.cmd("edit " .. vim.fn.fnameescape(file))
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local cursor = vim.api.nvim_win_get_cursor(0)

    assert.are.equal("#include <bits/stdc++.h>", lines[1])
    assert.are.equal("    ", lines[10])
    assert.are.same({ 10, 3 }, cursor)
  end)
end)

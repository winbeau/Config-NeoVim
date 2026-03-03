local repo_root = vim.fn.getcwd()
local ftplugin_file = repo_root .. "/after/ftplugin/cpp.lua"

describe("cpp ftplugin", function()
  it("sets 4-space indentation", function()
    vim.cmd("enew")
    dofile(ftplugin_file)

    assert.are.equal(4, vim.opt_local.shiftwidth:get())
    assert.are.equal(4, vim.opt_local.tabstop:get())
    assert.are.equal(4, vim.opt_local.softtabstop:get())
    assert.is_true(vim.opt_local.expandtab:get())
  end)
end)

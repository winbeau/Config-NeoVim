local repo_root = vim.fn.getcwd()
local noice_file = repo_root .. "/lua/plugins/noice.lua"

describe("noice opts", function()
  it("disables cmdline UI and limits mini view height", function()
    local specs = dofile(noice_file)
    local plugin = specs[1]

    local opts = {}
    plugin.opts(nil, opts)

    assert.is_false(opts.cmdline.enabled)
    assert.are.equal(1, opts.views.mini.size.max_height)
  end)
end)

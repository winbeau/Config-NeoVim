local repo_root = vim.fn.getcwd()
local noice_file = repo_root .. "/lua/plugins/noice.lua"

describe("noice opts", function()
  it("enables cmdline UI and keeps mini view compact", function()
    local specs = dofile(noice_file)
    local plugin = specs[1]

    local opts = {}
    plugin.opts(nil, opts)

    assert.is_true(opts.cmdline.enabled)
    assert.is_true(opts.presets.command_palette)
    assert.is_true(opts.presets.bottom_search)
    assert.are.equal(1, opts.views.mini.size.max_height)
  end)
end)

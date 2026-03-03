local repo_root = vim.fn.getcwd()
local keymaps_file = repo_root .. "/lua/config/keymaps.lua"

local function get_map(mode, lhs)
  local lhs_upper = string.upper(lhs)
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if string.upper(map.lhs) == lhs_upper then
      return map
    end
  end
end

describe("keymaps", function()
  it("registers save and quit maps", function()
    dofile(keymaps_file)

    assert.is_truthy(get_map("n", "<C-s>"))
    assert.is_truthy(get_map("v", "<C-s>"))
    assert.is_truthy(get_map("i", "<C-s>"))

    assert.is_truthy(get_map("n", "<C-x>"))
    assert.is_truthy(get_map("v", "<C-x>"))
    assert.is_truthy(get_map("i", "<C-x>"))
  end)

  it("registers manual format map", function()
    dofile(keymaps_file)
    assert.is_truthy(get_map("n", "<C-f>"))
    assert.is_truthy(get_map("x", "<C-f>"))
  end)
end)

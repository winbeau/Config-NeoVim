local repo_root = vim.fn.getcwd()
local cpp_plugin_file = repo_root .. "/lua/plugins/cpp.lua"

local function find_plugin(specs, plugin_name)
  for _, spec in ipairs(specs) do
    if spec[1] == plugin_name then
      return spec
    end
  end
  return nil
end

local function has_value(tbl, value)
  for _, item in ipairs(tbl or {}) do
    if item == value then
      return true
    end
  end
  return false
end

describe("cpp plugin spec", function()
  it("sets mason PATH policy and required tools", function()
    local specs = dofile(cpp_plugin_file)
    local mason_spec = find_plugin(specs, "mason-org/mason.nvim")
    assert.is_truthy(mason_spec)

    local opts = {}
    mason_spec.opts(nil, opts)

    assert.are.equal("append", opts.PATH)
    assert.is_true(has_value(opts.ensure_installed, "clangd"))
    assert.is_true(has_value(opts.ensure_installed, "clang-format"))
  end)

  it("configures clangtidy when executable exists", function()
    local specs = dofile(cpp_plugin_file)
    local lint_spec = find_plugin(specs, "mfussenegger/nvim-lint")
    assert.is_truthy(lint_spec)

    local original_executable = vim.fn.executable
    vim.fn.executable = function(name)
      if name == "clang-tidy" then
        return 1
      end
      return original_executable(name)
    end

    local opts = { linters_by_ft = {} }
    lint_spec.opts(nil, opts)

    vim.fn.executable = original_executable

    assert.are.same({ "clangtidy" }, opts.linters_by_ft.c)
    assert.are.same({ "clangtidy" }, opts.linters_by_ft.cpp)
  end)

  it("disables clangtidy when executable is missing", function()
    local specs = dofile(cpp_plugin_file)
    local lint_spec = find_plugin(specs, "mfussenegger/nvim-lint")
    assert.is_truthy(lint_spec)

    local original_executable = vim.fn.executable
    vim.fn.executable = function(name)
      if name == "clang-tidy" then
        return 0
      end
      return original_executable(name)
    end

    local opts = { linters_by_ft = {} }
    lint_spec.opts(nil, opts)

    vim.fn.executable = original_executable

    assert.are.same({}, opts.linters_by_ft.c)
    assert.are.same({}, opts.linters_by_ft.cpp)
  end)
end)

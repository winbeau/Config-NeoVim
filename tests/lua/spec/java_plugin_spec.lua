local repo_root = vim.fn.getcwd()
local java_plugin_file = repo_root .. "/lua/plugins/java.lua"

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

local function find_arg_index(tbl, value)
  for i, item in ipairs(tbl or {}) do
    if item == value then
      return i
    end
  end
  return nil
end

describe("java plugin spec", function()
  it("ensures jdtls is installed via mason", function()
    local specs = dofile(java_plugin_file)
    local mason_spec = find_plugin(specs, "mason-org/mason.nvim")
    assert.is_truthy(mason_spec)

    local opts = {}
    mason_spec.opts(nil, opts)
    assert.is_true(has_value(opts.ensure_installed, "jdtls"))
  end)

  it("disables nvim-jdtls when java 21 is unavailable", function()
    local specs = dofile(java_plugin_file)
    local jdtls_spec = find_plugin(specs, "mfussenegger/nvim-jdtls")
    assert.is_truthy(jdtls_spec)

    local old_java21 = vim.env.JAVA21_HOME
    local old_jdk21 = vim.env.JDK21_HOME
    local old_glob = vim.fn.glob
    local old_executable = vim.fn.executable
    vim.env.JAVA21_HOME = nil
    vim.env.JDK21_HOME = nil
    vim.fn.glob = function(pattern, ...)
      if tostring(pattern):find("/usr/lib/jvm/") then
        return {}
      end
      return old_glob(pattern, ...)
    end
    vim.fn.executable = function(path)
      local p = tostring(path)
      if p:find("/usr/lib/jvm/") and p:match("/bin/java$") then
        return 0
      end
      return old_executable(path)
    end

    local enabled = jdtls_spec.enabled()

    vim.fn.executable = old_executable
    vim.fn.glob = old_glob
    vim.env.JAVA21_HOME = old_java21
    vim.env.JDK21_HOME = old_jdk21

    assert.is_false(enabled)
  end)

  it("injects java 21 executable when available", function()
    local specs = dofile(java_plugin_file)
    local jdtls_spec = find_plugin(specs, "mfussenegger/nvim-jdtls")
    assert.is_truthy(jdtls_spec)

    local tmp_root = vim.fn.tempname()
    local bin_dir = tmp_root .. "/bin"
    vim.fn.mkdir(bin_dir, "p")
    local java_bin = bin_dir .. "/java"

    local script = {
      "#!/usr/bin/env sh",
      "echo 'openjdk version \"21.0.2\"' 1>&2",
      "exit 0",
    }
    vim.fn.writefile(script, java_bin)
    vim.fn.system({ "chmod", "+x", java_bin })

    local old_java21 = vim.env.JAVA21_HOME
    vim.env.JAVA21_HOME = tmp_root

    local enabled = jdtls_spec.enabled()
    local opts = jdtls_spec.opts(nil, { cmd = { "jdtls", "--foo" } })

    vim.env.JAVA21_HOME = old_java21

    assert.is_true(enabled)
    assert.is_truthy(opts.cmd)
    local idx = find_arg_index(opts.cmd, "--java-executable")
    assert.is_truthy(idx)
    assert.are.equal(java_bin, opts.cmd[idx + 1])
  end)
end)

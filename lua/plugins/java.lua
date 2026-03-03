local warned_missing_java21 = false

local function parse_java_major(output)
  local major = output:match('version%s+"(%d+)')
  if not major then
    major = output:match("openjdk%s+(%d+)")
  end
  return tonumber(major)
end

local function is_java21(bin)
  if not bin or bin == "" or vim.fn.executable(bin) ~= 1 then
    return false
  end
  local out = vim.fn.system(bin .. " -version 2>&1")
  if vim.v.shell_error ~= 0 then
    return false
  end
  local major = parse_java_major(out)
  return major ~= nil and major >= 21
end

local function find_java21_bin()
  local candidates = {}
  local function add(path)
    if path and path ~= "" then
      table.insert(candidates, path)
    end
  end

  add(vim.env.JAVA21_HOME and (vim.env.JAVA21_HOME .. "/bin/java"))
  add(vim.env.JDK21_HOME and (vim.env.JDK21_HOME .. "/bin/java"))
  add("/usr/lib/jvm/java-21-openjdk-amd64/bin/java")
  add("/usr/lib/jvm/java-21-openjdk/bin/java")

  vim.list_extend(candidates, vim.fn.glob("/usr/lib/jvm/*21*/bin/java", true, true))
  vim.list_extend(candidates, vim.fn.glob("/usr/lib/jvm/*/bin/java", true, true))

  local seen = {}
  for _, bin in ipairs(candidates) do
    if not seen[bin] then
      seen[bin] = true
      if is_java21(bin) then
        return bin
      end
    end
  end
  return nil
end

local function find_jdtls_bin()
  local mason_jdtls = vim.fn.expand("$MASON/bin/jdtls")
  if vim.fn.executable(mason_jdtls) == 1 then
    return mason_jdtls
  end
  return vim.fn.exepath("jdtls")
end

local function notify_missing_java21()
  if warned_missing_java21 then
    return
  end
  warned_missing_java21 = true
  vim.schedule(function()
    vim.notify("jdtls requires Java 21. Install openjdk-21-jdk and reopen Neovim.", vim.log.levels.WARN)
  end)
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "jdtls" })
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    enabled = function()
      local java21 = find_java21_bin()
      if not java21 then
        notify_missing_java21()
      end
      return java21 ~= nil
    end,
    opts = function(_, opts)
      opts = opts or {}

      local java21 = find_java21_bin()
      if not java21 then
        notify_missing_java21()
        return opts
      end

      local jdtls_bin = find_jdtls_bin()
      local raw_cmd = vim.deepcopy(opts.cmd or {})
      if jdtls_bin ~= "" then
        if #raw_cmd == 0 then
          table.insert(raw_cmd, jdtls_bin)
        else
          raw_cmd[1] = jdtls_bin
        end
      end

      -- Keep existing args (e.g. lombok), but enforce a single java executable.
      local cmd = {}
      local skip_next = false
      for _, arg in ipairs(raw_cmd) do
        if skip_next then
          skip_next = false
        elseif arg == "--java-executable" then
          skip_next = true
        elseif type(arg) == "string" and arg:match("^%-%-java%-executable=") then
          -- drop inline form and re-add below
        else
          table.insert(cmd, arg)
        end
      end
      table.insert(cmd, "--java-executable")
      table.insert(cmd, java21)
      opts.cmd = cmd

      local previous = opts.jdtls
      opts.jdtls = function(config)
        if type(previous) == "function" then
          config = previous(config) or config
        elseif type(previous) == "table" then
          config = vim.tbl_deep_extend("force", config, previous)
        end

        local old_on_attach = config.on_attach
        config.on_attach = function(client, bufnr)
          if type(old_on_attach) == "function" then
            pcall(old_on_attach, client, bufnr)
          end

          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format")
          map("<leader>co", function()
            require("jdtls").organize_imports()
          end, "Organize Imports")
        end

        return config
      end

      return opts
    end,
  },
}

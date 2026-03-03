-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable autoformat on save (use manual formatting instead)
vim.g.autoformat = false

-- Prefer a working tree-sitter CLI (>=0.25 when available) over Mason's binary.
do
  local function parse_version(s)
    local a, b, c = tostring(s):match("(%d+)%.(%d+)%.(%d+)")
    if not a then
      return nil
    end
    return { tonumber(a), tonumber(b), tonumber(c) }
  end

  local function ge(v1, v2)
    if v1[1] ~= v2[1] then
      return v1[1] > v2[1]
    end
    if v1[2] ~= v2[2] then
      return v1[2] > v2[2]
    end
    return v1[3] >= v2[3]
  end

  local candidates = {}
  local exepath = vim.fn.exepath("tree-sitter")
  if exepath ~= "" then
    table.insert(candidates, exepath)
  end
  vim.list_extend(candidates, vim.fn.glob(vim.fn.expand("$HOME/.cargo/bin/tree-sitter"), true, true))
  vim.list_extend(candidates, vim.fn.glob(vim.fn.expand("$HOME/.nvm/versions/node/*/bin/tree-sitter"), true, true))

  local seen = {}
  local best_any = nil
  local best_modern = nil
  local min = { 0, 25, 0 }

  for _, bin in ipairs(candidates) do
    if not seen[bin] and vim.fn.executable(bin) == 1 then
      seen[bin] = true
      local out = vim.fn.system({ bin, "--version" })
      if vim.v.shell_error == 0 then
        local ver = parse_version(out)
        if ver then
          local rec = { bin = bin, ver = ver }
          if not best_any or ge(ver, best_any.ver) then
            best_any = rec
          end
          if ge(ver, min) and (not best_modern or ge(ver, best_modern.ver)) then
            best_modern = rec
          end
        end
      end
    end
  end

  local picked = best_modern or best_any
  if picked then
    local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
    local dir = vim.fn.fnamemodify(picked.bin, ":h")
    vim.env.PATH = dir .. sep .. (vim.env.PATH or "")
  end
end

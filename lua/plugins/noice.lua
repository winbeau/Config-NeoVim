return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.enabled = true

      opts.presets = opts.presets or {}
      opts.presets.command_palette = true
      opts.presets.bottom_search = true

      opts.views = opts.views or {}
      opts.views.mini = opts.views.mini or {}
      opts.views.mini.size = opts.views.mini.size or {}
      opts.views.mini.size.max_height = 1
    end,
    config = function(_, opts)
      local ok, noice = pcall(require, "noice")
      if not ok then
        vim.schedule(function()
          vim.notify("noice.nvim failed to load; fallback to native cmdline", vim.log.levels.WARN)
        end)
        return
      end

      local setup_ok = pcall(noice.setup, opts)
      if not setup_ok then
        opts.cmdline = opts.cmdline or {}
        opts.cmdline.enabled = false
        pcall(noice.setup, opts)
        vim.schedule(function()
          vim.notify("noice cmdline setup failed; using native cmdline fallback", vim.log.levels.WARN)
        end)
      end
    end,
  },
}

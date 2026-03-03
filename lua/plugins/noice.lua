return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      -- Fallback to native ':' cmdline to avoid treesitter crashes in noice cmdline view.
      opts.cmdline.enabled = false

      opts.views = opts.views or {}
      opts.views.mini = opts.views.mini or {}
      opts.views.mini.size = opts.views.mini.size or {}
      opts.views.mini.size.max_height = 1
    end,
  },
}

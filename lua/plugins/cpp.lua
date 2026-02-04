return {
  -- C/C++ LSP
  { import = "lazyvim.plugins.extras.lang.clangd" },

  -- Lint on save
  { import = "lazyvim.plugins.extras.linting.nvim-lint" },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        c = { "clangtidy" },
        cpp = { "clangtidy" },
      },
    },
  },

  -- Ensure tools are installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "clangd", "clang-format", "clang-tidy" })
    end,
  },
}

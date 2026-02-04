return {
  -- C/C++ LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {},
      },
    },
  },

  -- Lint on save (LazyVim already includes nvim-lint)
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      if vim.fn.executable("clang-tidy") == 1 then
        opts.linters_by_ft.c = { "clangtidy" }
        opts.linters_by_ft.cpp = { "clangtidy" }
      else
        -- Avoid ENOENT if clang-tidy is not installed
        opts.linters_by_ft.c = {}
        opts.linters_by_ft.cpp = {}
      end
    end,
  },

  -- Ensure tools are installed
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- mason registry does not provide clang-tidy
      vim.list_extend(opts.ensure_installed, { "clangd", "clang-format" })
    end,
  },
}

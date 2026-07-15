vim.lsp.config['rust_analyzer'] = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  settings = {
    ['rust-analyzer'] = {
      -- https://rust-analyzer.github.io/book/configuration.html
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      references = {
        excludeTests = true,
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
        allTargets = true,
        targetDir = "target/nvim-lsp-rust-analyzer",
        features = "all",
      },
      check = {
        allTargets = true,
      },
      cfg = {
        setTest = true,
      },
      procMacro = {
        enable = true
      },
    }
  },
}
vim.lsp.enable('rust_analyzer')

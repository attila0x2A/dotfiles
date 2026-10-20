vim.lsp.config['pylsp'] = {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
}
vim.lsp.enable('pylsp')

-- Type errors only. pylsp gives completion, hover and go-to-definition, so
-- pyrefly does not repeat them. pyrefly shows type errors only in projects
-- with a pyrefly config ([tool.pyrefly] in pyproject.toml, or pyrefly.toml).
vim.lsp.config['pyrefly'] = {
  cmd = { 'pyrefly', 'lsp' },
  filetypes = { 'python' },
  root_markers = { 'pyrefly.toml', 'pyproject.toml', '.git' },
  settings = {
    python = {
      pyrefly = { disableLanguageServices = true },
    },
  },
}
vim.lsp.enable('pyrefly')

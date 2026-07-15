vim.lsp.config['beancount'] = {
  filetypes = { 'beancount' },
  cmd = { 'beancount-language-server' },
  init_options = {
    -- journal_file = "<path to journal file>",
    pythonPath = vim.fn.expand("~/.pyenv/shims/python3"),
  },
}
vim.lsp.enable('beancount')

require('plugins')

require('config.options')
require('config.mappings')
require('config.commands')
require('config.autocmds')
require('config.lsp')
require('config.treesitter')

require('hop').setup()
require('aerial').setup({
  backends = { "lsp", "treesitter" },
  filter_kind = false,
})

vim.g.python3_host_prog = '/usr/bin/python3'

require('plugins')

require('config.autocmds')
require('config.commands')
require('config.filetypes')
require('config.lsp')
require('config.mappings')
require('config.options')
require('config.treesitter')

require('hop').setup()
require('aerial').setup({
  backends = { "lsp", "treesitter" },
  filter_kind = false,
})

-- Required to work on Nix
vim.g.python3_host_prog = '/usr/bin/python3'

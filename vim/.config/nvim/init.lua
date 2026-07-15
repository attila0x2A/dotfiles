require('plugins')

require('config.options').setup()
require('config.mappings').setup()
require('config.commands').setup()
require('config.autocmds').setup()
require('config.lsp').setup()
require('config.treesitter').setup()

require('hop').setup()
require('aerial').setup({
  backends = { "lsp", "treesitter" },
  filter_kind = false,
})

vim.g.python3_host_prog = '/usr/bin/python3'

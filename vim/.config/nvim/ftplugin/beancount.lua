vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2

vim.keymap.set('i', '<C-L>', '<C-O>/Expenses:TODO<C-M><C-O>cE', { buffer = true })
vim.keymap.set('n', '<Leader>l', '/Expenses:TODO<C-M>cE', { buffer = true })

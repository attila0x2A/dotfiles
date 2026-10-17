-- FZF
vim.keymap.set('n', '<C-p>', ':Files<CR>', { silent = true })
vim.keymap.set('n', '<Leader>ff', ':Files<CR>', { silent = true })
vim.keymap.set('n', '<Leader>fb', ':Buffers<CR>', { silent = true })
vim.keymap.set('n', '<Leader>fl', ':Lines<CR>', { silent = true })
vim.keymap.set('n', '<Leader>fw', ':Windows<CR>', { silent = true })
vim.keymap.set('n', '<Leader>fj', ':Jumps<CR>', { silent = true })
vim.keymap.set('n', '<Leader>fh', ':History<CR>', { silent = true })

-- General
vim.keymap.set('n', '<Leader><Leader>', ':nohls | CloseFloatingWindows<CR>', { silent = true })
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', '<Leader>y%', ':let @+=@% | echo getreg("+")<CR>')
vim.keymap.set('n', '<Leader>q', ':ToggleQuickFix<CR>', { silent = true })

-- Vim config
vim.keymap.set('n', '<Leader>ve', ':tab split <C-R>=resolve(expand($MYVIMRC))<CR><CR>')
vim.keymap.set('n', '<Leader>vs', ':source $MYVIMRC<CR>')

-- Git
vim.keymap.set('n', '<Leader>gs', ':Git<CR>')
vim.keymap.set('n', '<Leader>gh', ':.GBrowse<CR>')
vim.keymap.set('v', '<Leader>gh', ":'<,'>GBrowse<CR>")
vim.keymap.set('n', '<Leader>gy', ':.GBrowse!<CR>')
vim.keymap.set('v', '<Leader>gy', ":'<,'>GBrowse!<CR>")
vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>')

-- Outline
vim.keymap.set('n', '<Leader>o', ':AerialToggle<CR>', { silent = true })

-- Folding
vim.keymap.set('n', '<Leader>sfi', ':setl foldmethod=indent<CR>')
vim.keymap.set('n', '<Leader>sfm', ':setl foldmethod=manual<CR>')

-- Completion: enter shouldn't select.
vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-e><CR>'
  end
  return '<CR>'
end, { expr = true })

-- Cmdline
-- <C-A> to jump to the start, same as in terminal.
vim.keymap.set('c', '<C-A>', '<C-B>')

-- Snippet navigation
vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if vim.snippet.active() then
    vim.snippet.jump(1)
  end
end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if vim.snippet.active() then
    vim.snippet.jump(-1)
  end
end, { silent = true })

-- Hop
vim.keymap.set('n', '<leader>h', require('hop').hint_words, { silent = true })
vim.keymap.set('n', '<leader>/', ':HopPattern<CR>', { silent = true })
vim.keymap.set('o', 'h', ':HopWord<CR>', { silent = true })

vim.keymap.set('n', '<leader><CR>', function()
  vim.fn.chansend(vim.bo.channel, "\r")
end, { desc = "Send Enter to Terminal" })

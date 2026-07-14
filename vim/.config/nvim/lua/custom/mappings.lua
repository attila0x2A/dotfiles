local M = {}

function M.setup()
  vim.api.nvim_create_user_command('Ag', function(opts)
    vim.fn['fzf#vim#ag'](opts.args, '--ignore=node_modules', vim.fn['fzf#vim#with_preview'](), opts.bang)
  end, { bang = true, nargs = '*' })

  -- FZF
  vim.keymap.set('n', '<C-p>', ':Files<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>ff', ':Files<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>fb', ':Buffers<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>fl', ':Lines<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>fw', ':Windows<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>fj', ':Jumps<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>fh', ':History<CR>', { silent = true })

  -- General
  vim.keymap.set('n', '<Leader><Leader>', ':nohls | CloseFloatingWindows<CR>:LTClearJumpHL<CR>', { silent = true })
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

  -- Debugging
  vim.keymap.set('n', '<Leader>dc', ':TContinue<CR>')
  vim.keymap.set('n', '<Leader>dn', ':TNext<CR>')
  vim.keymap.set('n', '<Leader>ds', ':TStep<CR>')
  vim.keymap.set('n', '<Leader>df', ':TSendCommand finish<CR>')

  vim.keymap.set('n', '<Leader>dp', ':TPrint <C-R>=expand("<cword>")<CR><CR>')
  vim.keymap.set('n', '<Leader>db', ':TToggleBreak<CR>')
  vim.keymap.set('n', '<Leader>dd', ':TDebug<CR>')
  vim.keymap.set('n', '<Leader>dr', ':TRunFile<CR>')
  vim.keymap.set('n', '<Leader>dt', ':TRun <C-R>=expand("%:t:r")<CR>::<C-R>=expand("<cword>")<CR><CR>')

  vim.keymap.set('n', '<F5>', ':TContinue<CR>')
  vim.keymap.set('n', '<F10>', ':TNext<CR>')
  vim.keymap.set('n', '<F11>', ':TStep<CR>')
  vim.keymap.set('n', '<F12>', ':TSendCommand finish<CR>')

  -- Outline
  vim.keymap.set('n', '<Leader>o', ':AerialToggle<CR>', { silent = true })

  -- Folding
  vim.keymap.set('n', '<Leader>sfi', ':setl foldmethod=indent<CR>')
  vim.keymap.set('n', '<Leader>sfm', ':setl foldmethod=manual<CR>')

  -- Cmdline
  -- <C-A> to jump to the start, same as in terminal.
  vim.keymap.set('c', '<C-A>', '<C-B>')

  -- Hop
  vim.keymap.set('n', '<leader>h', require('hop').hint_words, { silent = true })
  vim.keymap.set('n', '<leader>/', ':HopPattern<CR>', { silent = true })
  vim.keymap.set('o', 'h', ':HopWord<CR>', { silent = true })
end

return M

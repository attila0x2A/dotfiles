vim.cmd('colorscheme gruvbox')
vim.defer_fn(function()
  vim.cmd([[
    hi! LineNrBelow ctermfg=131 guifg=#af5f5f
    hi! LineNrAbove ctermfg=108 guifg=#87af87
  ]])
end, 100)
vim.opt.termguicolors = true

if vim.fn.executable('rg') == 1 then
  vim.opt.grepprg = 'rg --vimgrep --no-heading --smart-case'
  vim.opt.grepformat = '%f:%l:%c:%m'
end

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.shiftround = true
vim.opt.joinspaces = false

vim.opt.backup = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.autoread = true
vim.opt.undolevels = 10000
vim.opt.autowrite = true

vim.opt.formatoptions:append('croqlj')
vim.opt.foldcolumn = '1'

vim.opt.matchpairs:append('<:>')
vim.opt.iminsert = 0
vim.opt.imsearch = -1

vim.opt.list = true
vim.opt.listchars = 'tab:>-,trail:\u{0126}'

vim.opt.completeopt = 'menu,menuone,noinsert,popup,fuzzy'
vim.opt.wildoptions = 'fuzzy,pum'
vim.opt.wildmode = 'full'

vim.cmd([[set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P]])

vim.opt.equalalways = false
vim.opt.swapfile = false

vim.g.netrw_preview   = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize   = 30

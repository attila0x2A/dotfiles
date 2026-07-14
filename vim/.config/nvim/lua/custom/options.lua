local M = {}

function M.setup()
  vim.cmd('filetype plugin indent on')
  vim.cmd('colorscheme gruvbox')
  vim.opt.termguicolors = true
  vim.cmd([[
    hi! LineNrBelow guifg=#a89984 guibg=NONE guisp=NONE gui=NONE
    hi! LineNrAbove guifg=#b0a390 guibg=NONE guisp=NONE gui=NONE
  ]])
  vim.cmd('syntax on')

  if vim.fn.executable('ag') == 1 then
    vim.opt.grepprg = 'ag --nogroup --nocolor'
  end

  vim.opt.cursorline = true
  vim.opt.backspace = 'indent,eol,start'
  vim.opt.expandtab = true
  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.smarttab = true
  vim.opt.shiftround = true
  vim.opt.joinspaces = false

  vim.opt.history = 10000
  vim.opt.backup = false
  vim.opt.ruler = true
  vim.opt.showcmd = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.hidden = true
  vim.opt.wildmenu = true
  vim.opt.wildmode = 'longest,list,full'
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.autoread = true
  vim.opt.undolevels = 10000
  vim.opt.autowrite = true

  vim.opt.formatoptions:append('croqlj')
  vim.opt.foldcolumn = '1'
  vim.opt.encoding = 'utf-8'

  vim.opt.matchpairs:append('<:>')
  vim.opt.iminsert = 0
  vim.opt.imsearch = -1

  vim.opt.incsearch = true
  vim.opt.hlsearch = true

  vim.opt.list = true
  vim.opt.listchars = 'tab:>-,trail:\u{0126}'

  vim.opt.completeopt = 'longest,menuone'

  vim.cmd([[
    set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P
    set laststatus=2
  ]])

  vim.opt.modeline = true
  vim.opt.equalalways = false
  vim.opt.swapfile = false

  vim.g.rustfmt_autosave = 1
end

return M

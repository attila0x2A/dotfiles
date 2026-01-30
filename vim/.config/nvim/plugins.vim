" Required by Vundle
filetype off
set rtp+=~/.config/nvim/bundle/Vundle.vim

call vundle#begin('~/.config/nvim/bundle/')

Plugin 'VundleVim/Vundle.vim'

Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
Plugin 'will133/vim-dirdiff'

Plugin 'nathangrigg/vim-beancount'
Plugin 'peitalin/vim-jsx-typescript'

Plugin 'neovim/nvim-lspconfig'
Plugin 'ray-x/lsp_signature.nvim'

" Colorscheme
Plugin 'morhetz/gruvbox'

" Auto-completions.
Plugin 'hrsh7th/cmp-nvim-lsp'
Plugin 'hrsh7th/cmp-buffer'
Plugin 'hrsh7th/cmp-path'
Plugin 'hrsh7th/cmp-cmdline'
Plugin 'hrsh7th/nvim-cmp'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'petertriho/cmp-git'

Plugin 'SirVer/ultisnips'
Plugin 'quangnguyen30192/cmp-nvim-ultisnips'
Plugin 'honza/vim-snippets'

" Fast navigation
Plugin 'smoka7/hop.nvim'
Plugin 'tpope/vim-unimpaired'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

Plugin 'mfussenegger/nvim-dap'
Plugin 'nvim-neotest/nvim-nio'
Plugin 'rcarriga/nvim-dap-ui'
" Plugin 'mxsdev/nvim-dap-vscode-js'
Plugin 'epheien/termdbg'

Plugin 'nvim-treesitter/nvim-treesitter'

Plugin 'stevearc/aerial.nvim'
" Public archive
" Plugin 'simrat39/symbols-outline.nvim'

Plugin 'nvim-lua/lsp-status.nvim'
Plugin 'ldelossa/litee.nvim'
Plugin 'ldelossa/litee-calltree.nvim'

call vundle#end()

packadd! matchit

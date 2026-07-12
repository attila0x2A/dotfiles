-- Plugin list, installed with Neovim's built-in package manager (vim.pack).
-- Requires Neovim >= 0.12.
--
-- Usage:
--   * Add a plugin:    add a URL below, then :restart (or reopen Neovim).
--   * Update plugins:  :lua vim.pack.update()
--   * Remove a plugin: delete its line below, then
--                       :lua vim.pack.del({'plugin-name'})
--   * Inspect state:   :lua vim.print(vim.pack.get())

vim.pack.add({
  -- Git integration
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-rhubarb',
  'https://github.com/will133/vim-dirdiff',

  -- Filetypes
  'https://github.com/nathangrigg/vim-beancount',
  'https://github.com/peitalin/vim-jsx-typescript',

  -- LSP
  'https://github.com/ray-x/lsp_signature.nvim',

  -- Colorscheme
  'https://github.com/morhetz/gruvbox',

  -- Completion
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-buffer',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/hrsh7th/cmp-cmdline',
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/petertriho/cmp-git',

  -- Fast navigation
  'https://github.com/smoka7/hop.nvim',
  'https://github.com/tpope/vim-unimpaired',
  -- NOTE: no build hook needed here (same as the old plugins.vim) because
  -- the README already requires the `fzf` binary to be installed
  -- system-wide; these two just add the vim commands/runtime files.
  'https://github.com/junegunn/fzf',
  'https://github.com/junegunn/fzf.vim',

  -- Debugging
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/epheien/termdbg',

  -- Treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',

  -- Symbols / outline
  'https://github.com/stevearc/aerial.nvim',
  'https://github.com/ldelossa/litee.nvim',
  'https://github.com/ldelossa/litee-calltree.nvim',
})

-- Was `packadd! matchit` in the old plugins.vim.
vim.cmd('packadd! matchit')

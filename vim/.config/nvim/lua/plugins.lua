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

  -- Colorscheme
  'https://github.com/morhetz/gruvbox',

  -- Fast navigation
  'https://github.com/smoka7/hop.nvim',
  'https://github.com/tpope/vim-unimpaired',
  -- NOTE: no build hook needed here (same as the old plugins.vim) because
  -- the README already requires the `fzf` binary to be installed
  -- system-wide; these two just add the vim commands/runtime files.
  'https://github.com/junegunn/fzf',
  'https://github.com/junegunn/fzf.vim',

  -- Treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',

  -- Outline
  'https://github.com/stevearc/aerial.nvim',
})

-- Was `packadd! matchit` in the old plugins.vim.
vim.cmd('packadd! matchit')
vim.cmd('packadd! termdebug')


-- Remove non-active plugins
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(function()
      local stale = vim.iter(vim.pack.get())
        :filter(function(x) return not x.active end)
        :map(function(x) return x.spec.name end)
        :totable()
      if next(stale) ~= nil then
        vim.pack.del(stale)
      end
    end)
  end,
})

require('nvim-treesitter').install({
  'rust',
  'lua',
  'python',
  'toml',
  'beancount',
  'javascript',
  'typescript',
  'jsx',
  'tsx',
  'html',
  'json'
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'rust',
    'lua',
    'python',
    'toml',
    'beancount',
    'javascript',
    'typescript',
    'jsx',
    'tsx',
    'html',
    'json',
  },
  callback = function(ev)
    vim.schedule(function()
      vim.treesitter.start(ev.buf)
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldmethod = 'expr'
      if vim.bo.filetype == 'beancount' then
        vim.wo.foldlevel = 0
      else
        vim.wo.foldlevel = 99
      end
    end)
  end,
})

require('plugins')

require('custom.options').setup()
require('custom.mappings').setup()

vim.cmd [[
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
]]

vim.api.nvim_create_user_command('CloseFloatingWindows', function(opts)
    for _, window_id in ipairs(vim.api.nvim_list_wins()) do
        -- If window is floating
        if vim.api.nvim_win_get_config(window_id).relative ~= '' then
            -- Force close if called with !
            vim.api.nvim_win_close(window_id, opts.bang)
        end
    end
end, { bang = true, nargs = 0 })


vim.api.nvim_create_user_command('ToggleQuickFix', function()
  local quickfix_open = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.fn.win_gettype(win) == "quickfix" then
      quickfix_open = true
      break
    end
  end
  if quickfix_open then
    vim.cmd "cclose"
  else
    vim.cmd "botright copen"
  end
end, { nargs = 0 })

-- Required to work in Nix.
vim.g.python3_host_prog = '/usr/bin/python3'

-- lua/custom/lsp.lua
require('custom.lsp').setup()

require('hop').setup()

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
});
vim.filetype.add({
  extension = {
    bean = 'beancount',
  }
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
  };
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

require("aerial").setup({
  backends = { "lsp", "treesitter" },
  filter_kind = false,
})

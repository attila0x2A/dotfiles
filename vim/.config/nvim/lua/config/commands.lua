local M = {}

function M.setup()
  vim.api.nvim_create_user_command('CloseFloatingWindows', function(opts)
    for _, window_id in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(window_id).relative ~= '' then
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

  vim.api.nvim_create_user_command('Ag', function(opts)
    vim.fn['fzf#vim#ag'](opts.args, '--ignore=node_modules', '--hidden', vim.fn['fzf#vim#with_preview'](), opts.bang)
  end, { bang = true, nargs = '*' })

end

return M

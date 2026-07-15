local M = {}

function M.setup()
  vim.cmd [[
    augroup CursorLine
      au!
      au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
      au WinLeave * setlocal nocursorline
    augroup END
  ]]
end

return M

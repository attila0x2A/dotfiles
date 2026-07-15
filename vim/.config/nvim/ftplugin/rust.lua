vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = function()
    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
  end,
})

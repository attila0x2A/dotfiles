require('config.lsp.beancount')
require('config.lsp.go')
require('config.lsp.lua')
require('config.lsp.python')
require('config.lsp.rust')

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
      autotrigger = true,
      convert = function(item)
        local text = nil
        if item.textEdit and item.textEdit.newText then
          text = item.textEdit.newText
        elseif item.insertText then
          text = item.insertText
        end

        if text then
          text = text:gsub('%$%b{}', function(s)
            return s:match('%${%d+:(.*)}') or ''
          end):gsub('%$%d+', '')
        else
          text = item.label
        end

        return { abbr = text, menu = '' }
      end,
    })

    vim.api.nvim_create_autocmd('InsertCharPre', {
      buffer = ev.buf,
      callback = function()
        if vim.v.char:match('[a-zA-Z_]') then
          vim.schedule(vim.lsp.completion.get)
        end
      end,
    })

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- Declarations aren't supported for TS.
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, opts)

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gR', function()
      require('calltree').open('incoming')
    end, opts)
    vim.keymap.set('n', 'gC', function()
      require('calltree').open('outgoing')
    end, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format {}
      vim.cmd [[write]]
    end, opts)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = ev.buf,
        callback = function() vim.lsp.buf.document_highlight() end,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = ev.buf,
        callback = function() vim.lsp.buf.clear_references() end,
      })
    end
  end,
})

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end)

local M = {}

function M.setup()
  vim.lsp.config['ts_ls'] = {
    init_options = {
      hostInfo = 'neovim',
    },
  }

  vim.lsp.config['rust_analyzer'] = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    settings = {
      ['rust-analyzer'] = {
        -- https://rust-analyzer.github.io/book/configuration.html
        imports = {
            granularity = {
                group = "module",
            },
            prefix = "self",
        },
        references = {
          excludeTests = true,
        },
        cargo = {
            buildScripts = {
                enable = true,
            },
            allTargets = true,
            targetDir = "target/nvim-lsp-rust-analyzer",
            features = "all",
        },
        check = {
          allTargets = true,
        },
        cfg = {
          setTest = true,
        },
        procMacro = {
            enable = true
        },
      }
    },
  }
  vim.lsp.enable('rust_analyzer');

  vim.lsp.config['lua_ls'] = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },

    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        format = {
          enable = true,
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths here.
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          }
        }
      })
    end,
    settings = {
      Lua = {}
    }
  }
  vim.lsp.enable('lua_ls');

  local prettier = {
    formatCommand = 'prettierd "${INPUT}"',
    formatStdin = true,
    env = {
      'PRETTIERD_LOCAL_PRETTIER_ONLY=1',
    },
  }
  vim.lsp.config['efm'] = {
    init_options = { documentFormatting = true },
    settings = {
      rootMarkers = { ".git/" },
      logFile = "/tmp/efm.log",
      logLevel = 1,
      languages = {
        lua = {
          { formatCommand = "lua-format -i", formatStdin = true }
        },
        javascript = { prettier },
        typescript = { prettier },
        typescriptreact = { prettier },
      }
    },
    filetypes = { 'javascript', 'typescript', 'typescriptreact' },
  }

  vim.lsp.config['beancount'] = {
    filetypes = { 'beancount' },
    cmd = { 'beancount-language-server' },
    init_options = {
      -- journal_file = "<path to journal file>",
      pythonPath = "/home/attila/.pyenv/shims/python3",
    },
  }
  vim.lsp.enable('beancount');

  vim.lsp.config['pylsp'] = {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
  };
  vim.lsp.enable('pylsp');

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

      -- Complete on each keystroke.
      vim.api.nvim_create_autocmd('TextChangedI', {
        buffer = ev.buf,
        callback = function()
          vim.lsp.completion.get()
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
        require('custom.calltree').open('incoming')
      end, opts)
      vim.keymap.set('n', 'gC', function()
        require('custom.calltree').open('outgoing')
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
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
end

return M

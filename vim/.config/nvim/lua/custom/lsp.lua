local M = {}
--
local function rename_file()
  local source_file, target_file

  vim.ui.input({
      prompt = "Source : ",
      completion = "file",
      default = vim.api.nvim_buf_get_name(0)
    },
    function(input)
      source_file = input
    end
  )
  vim.ui.input({
      prompt = "Target : ",
      completion = "file",
      default = source_file
    },
    function(input)
      target_file = input
    end
  )

  local params = {
    command = "_typescript.applyRenameFile",
    arguments = {
      {
        sourceUri = source_file,
        targetUri = target_file,
      },
    },
    title = ""
  }

  vim.lsp.util.rename(source_file, target_file)
  vim.lsp.buf.execute_command(params)
end


function M.setup()
  require('litee.lib').setup({
      panel = {
          orientation = "bottom",
          panel_size = 15,
      },
  })
  require('litee.calltree').setup({
    no_hls = true,
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  vim.lsp.config('ts_ls', {
    capabilities = capabilities,
    init_options = {
      hostInfo = 'neovim',
    },
    commands = {
      RenameFile = {
        rename_file,
        description = "Rename File"
      },
    }
  })

  vim.lsp.config('eslint', {
    capabilities = capabilities,
    cmd = { 'vscode-eslint-language-server', '--stdio', '--max_old_space_size=16096' },
    settings = {
      nodePath = '~/tulip/tulip/environments/node_modules',
      runtime = 'node',
    },
    -- TODO: Reconsider doing this at write - latency may not be good.
    -- on_attach = function(client, bufnr)
    --   vim.api.nvim_create_autocmd("BufWritePre", {
    --     buffer = bufnr,
    --     command = "EslintFixAll",
    --   })
    -- end,
  })

  local prettier = {
    formatCommand = 'prettierd "${INPUT}"',
    formatStdin = true,
    env = {
      'PRETTIERD_LOCAL_PRETTIER_ONLY=1',
    },
  }

  vim.lsp.config('rust_analyzer', {
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
            -- FIXME
            features = "all",
            -- features = {"protocol_feature_spice", "test_features", "nightly", "clock"},
        },
        check = {
          -- command = "clippy",
          -- extraEnv = { RUSTFLAGS = "-D warnings" },
          -- extraArgs = { "--all-features", "--locked" },
          allTargets = true,
        },
        cfg = {
          setTest = true,
        },
        procMacro = {
            enable = true
        },
        -- },
        -- check = {
        --   -- features = 'all',
        --   command = "clippy",
        --   extraArgs = {
        --     "--",
        --     -- "--no-deps",
        --     "-Dwarnings",
        --     -- "-Dclippy::correctness",
        --     -- "-Dclippy::complexity",
        --     -- "-Wclippy::perf",
        --     "-Dclippy::pedantic",
        --     -- "-Aclippy::missing_errors_doc",
        --   },
        -- },
      }
    },
    -- on_attach = function(_client, bufnr)
    --     vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    -- end
  });
  vim.lsp.enable('rust_analyzer');

  vim.lsp.config('lua_ls', {
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
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
          -- library = vim.api.nvim_get_runtime_file("", true)
        }
      })
    end,
    settings = {
      Lua = {}
    }
  })
  vim.lsp.enable('lua_ls');

  vim.lsp.config('efm', {
    capabilities = capabilities,
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
  })

  vim.lsp.config('beancount', {
    capabilities = capabilities,
    init_options = {
      -- journal_file = "<path to journal file>",
      pythonPath = "/home/attila/.pyenv/shims/python3",
    },
  });

  -- lspconfig.pylsp.setup {};

  -- Use LspAttach autocommand to only map the following keys
  -- after the language server attaches to the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

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
      vim.keymap.set('n', 'gR', vim.lsp.buf.incoming_calls, opts)
      vim.keymap.set('n', '<space>f', function()
        vim.lsp.buf.format {
          -- async = true,
          -- timeout_ms = 1000,
          -- filter = function(client) return client.name == "efm" end,
        }
        -- vim.cmd [[EslintFixAll]]
        vim.cmd [[write]]
      end, opts)
    end,
  })

  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

  -- TODO: Figure out configuration, possibly get rid of or replace with something else.
  require "lsp_signature".setup({
    floating_window = true,
  })
end

return M

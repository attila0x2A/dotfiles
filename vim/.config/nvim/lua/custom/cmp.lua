local M = {}

function M.setup()
  local cmp = require('cmp')
  require("cmp_git").setup()

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it]
      --  (https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  local function delay(fn, time)
    local timer = vim.loop.new_timer()
    timer:start(time, 0, vim.schedule_wrap(function()
        fn()
        timer:stop()
    end))
  end

  -- https://github.com/hrsh7th/cmp-cmdline/issues/33#issuecomment-1594039784
  cmd_mapping = cmp.mapping.preset.cmdline()
  cmd_mapping_override = {
      ['<Tab>'] = {
          c = function()
              if vim.api.nvim_get_mode().mode == "c" and cmp.get_selected_entry() == nil then
                  local text = vim.fn.getcmdline()
                  local expanded = vim.fn.expandcmd(text)
                  if expanded ~= text then
                      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, true, true) .. expanded, "n", false)
                      -- triggering right away won't work, need to wait a cycle
                      delay(cmp.complete, 0)
                  elseif cmp.visible() then
                      cmp.select_next_item()
                  else
                      cmp.complete()
                  end
              else
                  if cmp.visible() then
                      cmp.select_next_item()
                  else
                      cmp.complete()
                  end
              end -- in the real mapping there are other elseif clauses
          end,
      },
      ['<S-Tab>'] = {
          c = function()
              if vim.api.nvim_get_mode().mode == "c" and cmp.get_selected_entry() == nil then
                  local text = vim.fn.getcmdline()
                  local expanded = vim.fn.expandcmd(text)
                  if expanded ~= text then
                      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, true, true) .. expanded, "n", false)
                      -- triggering right away won't work, need to wait a cycle
                      delay(cmp.complete, 0)
                  elseif cmp.visible() then
                      cmp.select_prev_item()
                  else
                      cmp.complete()
                  end
              else
                  if cmp.visible() then
                      cmp.select_prev_item()
                  else
                      cmp.complete()
                  end
              end
          end
      }
  }
  for k, v in pairs(cmd_mapping_override) do
      cmd_mapping[k] = v
  end

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
      mapping = cmd_mapping,
      sources = cmp.config.sources({
          { name = 'cmdline' },
          { name = 'path' },
          { name = 'cmdline_history' }
      })
  })

  --   -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  --   cmp.setup.cmdline(':', {
  --     mapping = cmp.mapping.preset.cmdline(),
  --     sources = cmp.config.sources({
  --       { name = 'path' }
  --     }, {
  --       {
  --         name = 'cmdline',
  --         option = {
  --           ignore_cmds = { 'Man' },
  --         },
  --         keyword_pattern = [=[[^[:blank:]%]*]=],
  --       }
  --     })
  --   })
end

return M

local dap = require('dap')
local dapui = require("dapui")
local M = {}

function M.setup()
  dapui.setup()

  dap.adapters.lldb = {
    type = 'executable',
    command = '/opt/homebrew/opt/llvm/bin/lldb-dap',
    name = 'lldb'
  }
  dap.defaults.rust.exception_breakpoints = {}
  dap.defaults.fallback.exception_breakpoints = {}

  vim.api.nvim_create_user_command('DapTest', function (opts)
      local program = function()
        local output = vim.fn.systemlist("cargo test -p " ..  opts.fargs[1] .." --no-run --message-format=json -q 2>1")
        for _, l in ipairs(output) do
          local json = vim.json.decode(l)
          if json == nil then
            error("error parsing json")
          end
          if json.success == false then
            return error("error building package")
          end
          if json.executable ~= nil and json.executable ~= vim.NIL then
            return json.executable
          end
        end
      end
      dap.run({
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = '/Users/attila-work/near/nearcore/target/debug/deps/test_loop_tests-d978ebd810b4ebb3',
        --program = program,
        -- args = { 'garbage_collection::test_state_transition_data_gc' },
        args = { '${fileBasenameNoExtension}' },
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        exception_breakpoints = {},
        runInTerminal = false,

         initCommands = function()
           -- Find out where to look for the pretty printer Python module.
           local rustc_sysroot = vim.fn.trim(vim.fn.system 'rustc --print sysroot')
           assert(
             vim.v.shell_error == 0,
             'failed to get rust sysroot using `rustc --print sysroot`: '
               .. rustc_sysroot
           )
           local script_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py'
           local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'
           return {
             ([[!command script import '%s']]):format(script_file),
             ([[command source '%s']]):format(commands_file),
           }
       end
      })
  end,
  {
    nargs = 1,
  })

  -- dap.listeners.before.attach.dapui_config = function()
  --   dapui.open()
  -- end
  -- dap.listeners.before.launch.dapui_config = function()
  --   dapui.open()
  -- end
  -- dap.listeners.before.event_terminated.dapui_config = function()
  --   dapui.close()
  -- end
  -- dap.listeners.before.event_exited.dapui_config = function()
  --   dapui.close()
  -- end

  -- vim.keymap.set('n', '<Leader>dc', function() require('dap').continue() end)
  -- vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
  -- vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
  -- vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
  -- vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
  -- vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
  -- vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end)
  -- vim.keymap.set('n', '<Leader>dm', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
  -- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
  -- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
  -- vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  --   require('dap.ui.widgets').hover()
  -- end)
  -- vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  --   require('dap.ui.widgets').preview()
  -- end)
  -- vim.keymap.set('n', '<Leader>df', function()
  --   local widgets = require('dap.ui.widgets')
  --   widgets.centered_float(widgets.frames)
  -- end)
  -- vim.keymap.set('n', '<Leader>ds', function()
  --   local widgets = require('dap.ui.widgets')
  --   widgets.centered_float(widgets.scopes)
  -- end)
end

return M

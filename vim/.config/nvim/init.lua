require('plugins')

vim.cmd [[
source ~/.config/nvim/mappings.vim
source ~/.config/nvim/options.vim
]]

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

vim.api.nvim_create_user_command('TPrint', function(opts)
  vim.cmd("TSendCommand p " .. opts.fargs[1])
end, {nargs = 1})

vim.api.nvim_create_user_command('TRun', function(opts)
  local test = opts.fargs[1]
  vim.cmd("TSendCommand run " .. test)
end, { nargs = 1 })

vim.api.nvim_create_user_command('TRunFile', function()
  local test = vim.fn.expand("%:t:r")
  vim.cmd("TSendCommand run " .. test)
end, { nargs = 0 })

vim.api.nvim_create_user_command('TDebug', function()
  local package = FindCargoPackage()
  print(package)
  local program = function()
    local output = vim.fn.systemlist("cargo test -p " ..  package .." --features=protocol_feature_spice --no-run --message-format=json -q 2>&1")
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
  local initCommands = function()
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
      ([[command script import '%s']]):format(script_file),
      ([[command source '%s']]):format(commands_file),
    }
  end

  vim.cmd("Termdbg lldb " .. program())
  for _, cmd in ipairs(initCommands()) do
    vim.cmd("TSendCommand " .. cmd)
  end
end, { nargs = 0 })

function GetCargoPackageName(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil, "Could not open Cargo.toml: " .. filepath
  end

  local name = nil
  for line in file:lines() do
    local match = line:match("^name%s*=%s*\"([^\"]+)\"")
    if match then
      name = match
      break
    end
  end

  file:close()

  if name then
    return name, nil
  else
    return nil, "Name not found in Cargo.toml: " .. filepath
  end
end

function FindCargoPackage()
  local current_dir = vim.fn.expand("%:h")
  while current_dir ~= vim.fn.getcwd() do
    local cargo_file = current_dir .. "/Cargo.toml"
    if vim.fn.filereadable(cargo_file) == 1 then
      vim.api.nvim_echo({{"Cargo.toml found in: " .. current_dir}}, true, {})
      local name, err = GetCargoPackageName(cargo_file)
      if name then
        return name
      else
        error(err)
      end
      return
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h") -- Get parent directory
  end
  vim.api.nvim_echo({{"Cargo.toml not found in any parent directory."}}, true, {})
end

-- Required to work in Nix.
vim.g.python3_host_prog = '/usr/bin/python3'

-- TODO: Find a better place for this configuration.
-- For JS - fixes enum using 4 spaces indentation everywhere apart form the first line.
vim.g.typescript_indent_disable = 1

-- lua/custom/lsp.lua
require('custom.lsp').setup()
-- lua/custom/cmp.lua
require('custom.cmp').setup()
-- lua/custom/dap.lua
require('custom.dap').setup()

require('hop').setup()

require('nvim-treesitter').install(
  { 'rust', 'lua', 'python', 'toml' }
);
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'lua', 'python', 'toml' },
  callback = function()
    vim.schedule(function()
      vim.treesitter.start()
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldmethod = 'expr'
      vim.wo.foldlevel = 99
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end)
  end,
})

require("aerial").setup({
  backends = { "lsp", "treesitter" },
  filter_kind = false,
})

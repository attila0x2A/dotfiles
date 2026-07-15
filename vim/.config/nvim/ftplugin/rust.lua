vim.g.termdebugger = "rust-gdb"

---@return boolean
local function termdebug_running()
  return vim.fn.bufnr("gdb") ~= -1
end

---@param toml_path string
---@return string|nil
local function parse_cargo_package_name(toml_path)
  local file = io.open(toml_path, "r")
  if not file then
    return nil
  end
  local name = nil
  for line in file:lines() do
    local match = line:match('^name%s*=%s*"([^"]+)"')
    if match then
      name = match
      break
    end
  end
  file:close()
  return name
end

---Walks upward from the current buffer to find the nearest Cargo.toml
---with a [package] name. Falls back to vim.b.rust_package if set.
---Returns nil if a workspace-root Cargo.toml is found (no [package] name)
---or if no Cargo.toml exists in the hierarchy.
---@return string|nil
local function find_rust_package()
  if vim.b.rust_package then
    return vim.b.rust_package
  end

  local buf_path = vim.api.nvim_buf_get_name(0)
  local start_path = buf_path == "" and vim.fn.getcwd() or vim.fs.dirname(buf_path)

  local cargo_files = vim.fs.find("Cargo.toml", {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = start_path,
  })

  for _, cargo_file in ipairs(cargo_files) do
    local name = parse_cargo_package_name(cargo_file)
    if name then
      vim.notify("package: " .. name, vim.log.levels.INFO)
      return name
    end
  end

  if #cargo_files > 0 then
    vim.notify("no [package] name in nearest Cargo.toml, building workspace", vim.log.levels.WARN)
    return nil
  end

  vim.notify("no Cargo.toml found", vim.log.levels.ERROR)
  return nil
end

---Parses cargo --message-format=json output and returns the first executable path.
---@param output string[]
---@return string|nil
local function parse_cargo_json(output)
  for _, line in ipairs(output) do
    local ok, json = pcall(vim.json.decode, line)
    if ok and json then
      if json.success == false then
        vim.notify("cargo build failed: " .. (json.message or "unknown error"), vim.log.levels.ERROR)
        return nil
      end
      if json.executable and json.executable ~= vim.NIL then
        return json.executable
      end
    end
  end
  return nil
end

---Builds the crate and returns the path to the resulting binary.
---@param package string|nil
---@param mode '"build"'|'"test"'
---@return string|nil
local function build_binary(package, mode)
  local cargo_cmd
  if mode == "test" then
    cargo_cmd = package and ("cargo test -p " .. package .. " --no-run --message-format=json -q 2>&1")
      or "cargo test --no-run --message-format=json -q 2>&1"
  else
    cargo_cmd = package and ("cargo build -p " .. package .. " --message-format=json -q 2>&1")
      or "cargo build --message-format=json -q 2>&1"
  end

  vim.notify(cargo_cmd, vim.log.levels.INFO)
  local output = vim.fn.systemlist(cargo_cmd)

  if vim.v.shell_error ~= 0 then
    for _, line in ipairs(output) do
      if line ~= "" then
        vim.notify(line, vim.log.levels.ERROR)
      end
    end
    vim.notify("cargo build failed", vim.log.levels.ERROR)
    return nil
  end

  local binary = parse_cargo_json(output)
  if binary then
    vim.notify("binary: " .. binary, vim.log.levels.INFO)
    return binary
  end

  vim.notify("no binary found in cargo output", vim.log.levels.ERROR)
  return nil
end

-- Debugging (Termdebug)
vim.keymap.set('n', '<Leader>dc', ':Continue<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>do', ':Over<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>ds', ':Step<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>df', ':Finish<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>dp', ':Evaluate <C-R>=expand("<cword>")<CR><CR>', { buffer = true })
vim.keymap.set('n', '<Leader>db', ':Break<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>dr', ':Run<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>dt', ':Run <C-R>=expand("%:t:r")<CR><CR>', { buffer = true })
vim.keymap.set('n', '<Leader>dw', ':Run <C-R>=expand("%:t:r")<CR>::<C-R>=expand("<cword>")<CR><CR>', { buffer = true })

vim.keymap.set('n', '<Leader>dd', ':RustDebugTest<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>dm', ':RustDebug<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>dB', ':RustRebuild<CR>', { buffer = true })

vim.keymap.set('n', '<Leader>rt', ':RustRunTest<CR>', { buffer = true })

vim.keymap.set('n', '<F5>', ':Continue<CR>', { buffer = true })
vim.keymap.set('n', '<F10>', ':Over<CR>', { buffer = true })
vim.keymap.set('n', '<F11>', ':Step<CR>', { buffer = true })
vim.keymap.set('n', '<F12>', ':Finish<CR>', { buffer = true })

vim.api.nvim_create_user_command("RustDebug", function()
  local binary = build_binary(find_rust_package(), "build")
  if binary then
    vim.b.rust_debug_mode = "build"
    vim.cmd("Termdebug " .. binary)
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("RustDebugTest", function()
  local binary = build_binary(find_rust_package(), "test")
  if binary then
    vim.b.rust_debug_mode = "test"
    vim.cmd("Termdebug " .. binary)
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("RustRebuild", function()
  if not termdebug_running() then
    vim.notify("no Termdebug session running", vim.log.levels.ERROR)
    return
  end
  local mode = vim.b.rust_debug_mode or "build"
  local binary = build_binary(find_rust_package(), mode)
  if binary then
    local gdb_buf = vim.fn.bufnr("gdb")
    if gdb_buf ~= -1 then
      vim.api.nvim_buf_delete(gdb_buf, { force = true })
    end
    vim.wait(500, function()
      return vim.fn.bufnr("gdb") == -1
    end)
    vim.cmd("Termdebug " .. binary)
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("RustRunTest", function(opts)
  local package = find_rust_package()
  local cmd_parts = { "cargo", "test" }
  if package then
    table.insert(cmd_parts, "-p")
    table.insert(cmd_parts, package)
  end
  if opts.args and opts.args ~= "" then
    table.insert(cmd_parts, opts.args)
  end
  local cmd = table.concat(cmd_parts, " ")
  vim.notify(cmd, vim.log.levels.INFO)
  vim.cmd("terminal " .. cmd)
end, { nargs = "?" })

vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = function()
    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
  end,
})

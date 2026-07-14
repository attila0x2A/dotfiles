---@class CallTreeState
---@field mode '"incoming"' | '"outgoing"'
---@field nodes CallTreeNode[]
---@field source_win integer
---@field source_buf integer
---@field calltree_win integer
---@field calltree_buf integer
---@field augroup integer?
---@field encoding string

---@class CallTreeNode
---@field item lsp.CallHierarchyItem
---@field children CallTreeNode[]
---@field expanded boolean
---@field rendered_line integer?

---@type CallTreeState?
local state = nil

local function render()
  if not state or not state.calltree_buf or not vim.api.nvim_buf_is_valid(state.calltree_buf) then
    return
  end

  local lines = {} ---@type string[]

  local function walk(nodes, depth)
    for _, node in ipairs(nodes) do
      node.rendered_line = #lines + 1

      local expand = node.expanded and '-' or '+'
      local name = node.item.name
      local fname = vim.fn.fnamemodify(vim.uri_to_fname(node.item.uri), ':.')
      local lnum = node.item.selectionRange.start.line + 1
      local detail = node.item.detail or ''

      local indent = string.rep('  ', depth)
      local text = string.format('%s%s %s  │  %s:%d', indent, expand, name, fname, lnum)
      if detail ~= '' then
        text = text .. '  │  ' .. detail
      end
      lines[#lines + 1] = text

      if node.expanded then
        walk(node.children, depth + 1)
      end
    end
  end

  walk(state.nodes, 0)

  vim.bo[state.calltree_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.calltree_buf, 0, -1, false, lines)
  vim.bo[state.calltree_buf].modifiable = false
  vim.bo[state.calltree_buf].modified = false
end

local function restore_cursor(node)
  if not state or not node or not node.rendered_line then return end
  pcall(vim.api.nvim_win_set_cursor, state.calltree_win, { node.rendered_line, 0 })
end

local function get_node_at_cursor()
  if not state then return nil end
  local cursor = vim.fn.line('.')

  local function search(nodes)
    for _, node in ipairs(nodes) do
      if node.rendered_line == cursor then
        return node
      end
      if node.expanded then
        local found = search(node.children)
        if found then return found end
      end
    end
    return nil
  end

  return search(state.nodes)
end

local function expand_node(node, callback)
  if not state then return end

  local client = vim.lsp.get_clients({ bufnr = state.source_buf, method = 'textDocument/prepareCallHierarchy' })[1]
  if not client then
    if callback then callback() end
    return
  end

  local method = state.mode == 'incoming' and 'callHierarchy/incomingCalls' or 'callHierarchy/outgoingCalls'

  client:request(method, { item = node.item }, function(err, result)
    if not state then return end

    if err or not result then
      vim.notify('Failed to fetch: ' .. (err and err.message or 'unknown'), vim.log.levels.WARN)
      if callback then callback() end
      return
    end

    node.expanded = true
    node.children = {}
    for _, entry in ipairs(result) do
      local item = state.mode == 'incoming' and entry.from or entry.to
      table.insert(node.children, {
        item = item,
        fromRanges = entry.fromRanges or {},
        children = {},
        expanded = false,
      })
    end
    if callback then callback() end
  end, state.source_buf)
end

local function fetch_root(method, params)
  if not state then return end

  local client = vim.lsp.get_clients({ bufnr = state.source_buf, method = method })[1]
  if not client then
    vim.notify('No LSP client supports ' .. method, vim.log.levels.WARN)
    return
  end

  client:request(method, params, function(err, result)
    if not state then return end

    if err or not result or #result == 0 then
      vim.notify('No call hierarchy items found', vim.log.levels.INFO)
      return
    end

    state.nodes = {}
    for _, item in ipairs(result) do
      table.insert(state.nodes, {
        item = item,
        children = {},
        expanded = false,
      })
    end

    if #state.nodes > 0 then
      local remaining = #state.nodes
      for _, node in ipairs(state.nodes) do
        expand_node(node, function()
          remaining = remaining - 1
          if remaining == 0 then
            render()
          end
        end)
      end
      return
    end

    render()
  end, state.source_buf)
end

local function _reroot_from_source()
  if not state or not state.source_win or not vim.api.nvim_win_is_valid(state.source_win) then
    return
  end

  local encoding = state.encoding or 'utf-8'
  local params = vim.lsp.util.make_position_params(state.source_win, encoding)
  fetch_root('textDocument/prepareCallHierarchy', params)
end

local function setup_autocmds()
  if not state then return end

  if state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
  end
  local group = vim.api.nvim_create_augroup('CallTree', {})
  state.augroup = group

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = state.calltree_buf,
    once = true,
    callback = function()
      state = nil
    end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = state.source_buf,
    once = true,
    callback = function()
      if state and state.calltree_win and vim.api.nvim_win_is_valid(state.calltree_win) then
        pcall(vim.api.nvim_win_close, state.calltree_win, true)
      end
      state = nil
    end,
  })
end

local function setup_keymaps()
  if not state then return end

  local opts = { buffer = state.calltree_buf, silent = true, nowait = true }

  vim.keymap.set('n', 'zo', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node or node.expanded then return end
    expand_node(node, function()
      render()
      restore_cursor(node)
    end)
  end, opts)

  vim.keymap.set('n', 'zc', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node or not node.expanded then return end
    node.expanded = false
    node.children = {}
    render()
    restore_cursor(node)
  end, opts)

  vim.keymap.set('n', '<CR>', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node then return end
    if not vim.api.nvim_win_is_valid(state.source_win) then return end

    local fname = vim.uri_to_fname(node.item.uri)
    local lnum = nil
    if node.fromRanges and #node.fromRanges > 0 then
      lnum = node.fromRanges[1].start.line + 1
    else
      lnum = node.item.selectionRange.start.line + 1
    end

    if vim.fn.bufname(state.source_buf) ~= vim.fn.bufname(fname) then
      pcall(vim.api.nvim_set_current_win, state.source_win)
      vim.cmd('edit ' .. fname)
      state.source_buf = vim.api.nvim_get_current_buf()
    end

    vim.api.nvim_set_current_win(state.source_win)
    vim.api.nvim_win_set_cursor(state.source_win, { lnum, 0 })
    vim.cmd('normal! zz')
  end, opts)

  vim.keymap.set('n', 'p', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node then return end

    local fname = vim.uri_to_fname(node.item.uri)
    local lnum = nil
    if node.fromRanges and #node.fromRanges > 0 then
      lnum = node.fromRanges[1].start.line + 1
    else
      lnum = node.item.selectionRange.start.line + 1
    end

    vim.cmd('pedit +' .. lnum .. ' ' .. vim.fn.fnameescape(fname))
  end, opts)

  vim.keymap.set('n', 'g<CR>', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node then return end
    if not vim.api.nvim_win_is_valid(state.source_win) then return end

    local fname = vim.uri_to_fname(node.item.uri)
    local lnum = node.item.selectionRange.start.line + 1

    if vim.fn.bufname(state.source_buf) ~= vim.fn.bufname(fname) then
      pcall(vim.api.nvim_set_current_win, state.source_win)
      vim.cmd('edit ' .. fname)
      state.source_buf = vim.api.nvim_get_current_buf()
    end
    vim.api.nvim_set_current_win(state.source_win)
    vim.api.nvim_win_set_cursor(state.source_win, { lnum, 0 })
    vim.cmd('normal! zz')
  end, opts)

  vim.keymap.set('n', 'gp', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node then return end

    local fname = vim.uri_to_fname(node.item.uri)
    local lnum = node.item.selectionRange.start.line + 1

    vim.cmd('pedit +' .. lnum .. ' ' .. vim.fn.fnameescape(fname))
  end, opts)

  vim.keymap.set('n', 'r', function()
    if not state then return end
    local node = get_node_at_cursor()
    if not node then return end

    local params = {
      textDocument = { uri = node.item.uri },
      position = node.item.selectionRange.start,
    }
    fetch_root('textDocument/prepareCallHierarchy', params)
  end, opts)
end

local M = {}

---@param mode '"incoming"' | '"outgoing"'
function M.open(mode)
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local client = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/prepareCallHierarchy' })[1]
  if not client then
    vim.notify('No LSP client supports call hierarchy', vim.log.levels.WARN)
    return
  end

  -- Panel open in same mode: re-root
  if state and state.mode == mode and state.calltree_win and vim.api.nvim_win_is_valid(state.calltree_win) then
    state.source_win = win
    state.source_buf = bufnr
    _reroot_from_source()
    return
  end

  -- Panel open in different mode: switch
  if state and state.calltree_win and vim.api.nvim_win_is_valid(state.calltree_win) then
    state.mode = mode
    state.source_win = win
    state.source_buf = bufnr
    state.encoding = client.offset_encoding or 'utf-8'
    setup_autocmds()
    _reroot_from_source()
    return
  end

  -- Panel not open: create new
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_set_name(buf, 'Call Tree')

  vim.cmd('botright 15split')

  state = {
    mode = mode,
    nodes = {},
    source_win = win,
    source_buf = bufnr,
    calltree_buf = buf,
    calltree_win = vim.api.nvim_get_current_win(),
    encoding = client.offset_encoding or 'utf-8',
  }
  vim.api.nvim_win_set_buf(state.calltree_win, buf)

  setup_keymaps()
  setup_autocmds()
  _reroot_from_source()
end

return M

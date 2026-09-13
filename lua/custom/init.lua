local theme_cycle = require "custom.theme_cycle"

if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h13"
  vim.g.neovide_padding_top = 8
  vim.g.neovide_padding_bottom = 8
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10
end

if vim.lsp and vim.lsp.get_clients and vim.lsp.get_active_clients then
  local original = vim.lsp.get_active_clients
  vim.lsp.get_active_clients = function(opts)
    return vim.lsp.get_clients(opts) or original(opts)
  end
end

vim.api.nvim_create_user_command("ThemeShuffle", function(opts)
  local info = theme_cycle.shuffle()
  if opts.bang then
    theme_cycle.apply(info.primary)
  end
  local message = string.format(
    "%s (%s) secondary %s",
    info.primary,
    info.phase,
    info.secondary or info.primary
  )
  local note = opts.bang and "Applied immediately" or "Will load next start"
  vim.notify(
    note .. ": " .. message,
    vim.log.levels.INFO,
    { title = "Theme Shuffle", timeout = 3000 }
  )
end, { bang = true })

-- <C-b> in markdown: turn line into a checkbox, or toggle an existing one.
--   "foo"        -> "- [ ] foo"
--   "- foo"      -> "- [ ] foo"
--   "- [ ] foo"  -> "- [x] foo"
--   "- [x] foo"  -> "- [ ] foo"
local function md_toggle_checkbox(line)
  local indent, bullet, state, rest = line:match "^(%s*)([-*+]%s+)%[([ xX])%]%s?(.*)$"
  if state then
    local new = (state == " ") and "x" or " "
    return indent .. bullet .. "[" .. new .. "] " .. rest
  end
  indent, bullet, rest = line:match "^(%s*)([-*+]%s+)(.*)$"
  if bullet then
    return indent .. bullet .. "[ ] " .. rest
  end
  indent, rest = line:match "^(%s*)(.*)$"
  return indent .. "- [ ] " .. rest
end

local function md_toggle_checkbox_range(first, last)
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, first - 1, last, false)
  for i, l in ipairs(lines) do
    lines[i] = md_toggle_checkbox(l)
  end
  vim.api.nvim_buf_set_lines(buf, first - 1, last, false, lines)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    local opts = { buffer = ev.buf, desc = "Toggle markdown checkbox" }
    vim.keymap.set("n", "<C-b>", function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      md_toggle_checkbox_range(row, row)
    end, opts)
    vim.keymap.set("i", "<C-b>", function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local before = #vim.api.nvim_get_current_line()
      md_toggle_checkbox_range(row, row)
      -- keep the cursor on the same text after the prefix changes length
      local delta = #vim.api.nvim_get_current_line() - before
      local col = vim.api.nvim_win_get_cursor(0)[2]
      vim.api.nvim_win_set_cursor(0, { row, math.max(0, col + delta) })
    end, opts)
    vim.keymap.set("x", "<C-b>", function()
      local first = vim.fn.line "v"
      local last = vim.fn.line "."
      if first > last then first, last = last, first end
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      md_toggle_checkbox_range(first, last)
    end, opts)
  end,
})

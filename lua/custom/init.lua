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

local util = require("lspconfig.util")

-- Load default configurations from NvChad
local default_lspconfig = require("plugins.configs.lspconfig")

-- Define common setup options
local common_setup = {
  on_attach = default_lspconfig.on_attach,
  capabilities = default_lspconfig.capabilities,
  on_init = default_lspconfig.on_init,
}

local function with_common(opts)
  return vim.tbl_deep_extend("force", {}, common_setup, opts or {})
end

-- none-ls already provides formatting for these filetypes (clang-format,
-- prettierd, stylua), so disable the LSP's own formatter to stop
-- `vim.lsp.buf.format` from hitting two conflicting formatters at once.
local function without_native_format(opts)
  local resolved = with_common(opts)
  local base_on_attach = resolved.on_attach
  resolved.on_attach = function(client, bufnr)
    base_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
  return resolved
end

-- Setup for Rust
vim.lsp.config("rust_analyzer", with_common({
  filetypes = { "rust" },
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ["rust_analyzer"] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
}))

-- Setup for Zig
vim.lsp.config("zls", with_common())

-- Setup for C and C++ using clangd (clang-format via none-ls handles formatting)
vim.lsp.config("clangd", without_native_format())

-- Setup for JavaScript / TypeScript (prettierd via none-ls handles formatting)
vim.lsp.config("ts_ls", without_native_format())

-- lua_ls formatting is handled by stylua via none-ls
vim.lsp.config("lua_ls", without_native_format())

vim.lsp.enable({ "rust_analyzer", "zls", "clangd", "ts_ls", "lua_ls" })

dofile(vim.g.base46_cache .. "lsp")

-- NvChad's bundled LSP defaults still use vim.lsp.with, which is deprecated
-- on current Neovim. Pass the handler options directly instead.
local hover_handler = vim.lsp.handlers.hover
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  return hover_handler(err, result, ctx, vim.tbl_extend("force", config or {}, { border = "single" }))
end

local signature_handler = vim.lsp.handlers.signature_help
vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
  return signature_handler(err, result, ctx, vim.tbl_extend("force", config or {}, {
    border = "single",
    focusable = false,
    relative = "cursor",
  }))
end

vim.diagnostic.config {
  virtual_text = { prefix = "" },
  signs = true,
  underline = true,
  update_in_insert = false,
}

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs
M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })
end

-- disable semantic tokens
M.on_init = function(client, _)
  if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

vim.lsp.config("*", {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

vim.lsp.enable("lua_ls")

return M

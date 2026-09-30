local ok, null_ls = pcall(require, "null-ls")
if not ok then
  return
end

local utils = require "core.utils"

local defaults = {
  on_attach = function(client, bufnr)
    utils.load_mappings("lspconfig", { buffer = bufnr })

    if client.server_capabilities.signatureHelpProvider then
      require("nvchad.signature").setup(client)
    end
  end,
  on_init = function(client, _)
    if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
}

defaults.capabilities.textDocument.completion.completionItem = {
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

local formatting = null_ls.builtins.formatting

local sources = {}

if vim.fn.executable "stylua" == 1 then
  table.insert(sources, formatting.stylua)
end

if vim.fn.executable "clang-format" == 1 then
  table.insert(sources, formatting.clang_format)
end

if vim.fn.executable "prettierd" == 1 then
  table.insert(sources, formatting.prettierd)
end

null_ls.setup {
  on_attach = defaults.on_attach,
  on_init = defaults.on_init,
  capabilities = defaults.capabilities,
  sources = sources,
}

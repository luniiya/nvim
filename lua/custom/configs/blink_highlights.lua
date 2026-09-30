-- blink.cmp ships no base46 integration, so link its highlight groups to
-- the ones base46 already compiles for the (now-removed) nvim-cmp setup.
-- Called from the same place theme_cycle re-applies the theme, so it stays
-- correct across the daily theme rotation.
local M = {}

local links = {
  BlinkCmpMenu = "CmpPmenu",
  BlinkCmpMenuBorder = "CmpBorder",
  BlinkCmpMenuSelection = "CmpSel",
  BlinkCmpDoc = "CmpDoc",
  BlinkCmpDocBorder = "CmpDocBorder",
  BlinkCmpLabel = "CmpItemAbbr",
  BlinkCmpLabelMatch = "CmpItemAbbrMatch",
  BlinkCmpKind = "CmpItemKindText",
  BlinkCmpSignatureHelp = "CmpDoc",
  BlinkCmpSignatureHelpBorder = "CmpDocBorder",
}

local kind_links = {
  Constant = "CmpItemKindConstant",
  Function = "CmpItemKindFunction",
  Field = "CmpItemKindField",
  Variable = "CmpItemKindVariable",
  Snippet = "CmpItemKindSnippet",
  Text = "CmpItemKindText",
  Struct = "CmpItemKindStructure",
  Class = "CmpItemKindClass",
  Interface = "CmpItemKindInterface",
  Module = "CmpItemKindModule",
  Property = "CmpItemKindProperty",
  Enum = "CmpItemKindEnum",
  Unit = "CmpItemKindUnit",
  Keyword = "CmpItemKindKeyword",
  Method = "CmpItemKindMethod",
  Constructor = "CmpItemKindConstructor",
  Folder = "CmpItemKindFolder",
  EnumMember = "CmpItemKindEnumMember",
  Value = "CmpItemKindValue",
  Event = "CmpItemKindEvent",
  Operator = "CmpItemKindOperator",
  TypeParameter = "CmpItemKindTypeParameter",
  File = "CmpItemKindFile",
  Reference = "CmpItemKindReference",
  Color = "CmpItemKindColor",
}

function M.apply()
  for from, to in pairs(links) do
    pcall(vim.api.nvim_set_hl, 0, from, { link = to, default = false })
  end
  for kind, to in pairs(kind_links) do
    pcall(vim.api.nvim_set_hl, 0, "BlinkCmpKind" .. kind, { link = to, default = false })
  end
end

return M

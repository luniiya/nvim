local M = {}

M.general = {
  n = {
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },
  }
}

M.dap = {
  n = {
    ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, "Toggle breakpoint" },
    ["<leader>dc"] = { function() require("dap").continue() end, "Continue" },
    ["<leader>di"] = { function() require("dap").step_into() end, "Step into" },
    ["<leader>do"] = { function() require("dap").step_over() end, "Step over" },
    ["<leader>dO"] = { function() require("dap").step_out() end, "Step out" },
    ["<leader>dr"] = { function() require("dap").repl.toggle() end, "Toggle REPL" },
    ["<leader>dt"] = { function() require("dap").terminate() end, "Terminate" },
    ["<leader>du"] = { function() require("dapui").toggle() end, "Toggle DAP UI" },
  },
}

M.codecompanion = {
  n = {
    -- Open chat in a new split
    ["<leader>cc"] = {
      "<cmd>CodeCompanionChat<CR>",
      "Open chat"
    },
    -- Start inline chat

    ["<leader>ca"] = {
      "<cmd>Telescope codecompanion<CR>",
      "Open action palette"
    }
  }
}

return M

local dap = require "dap"
local dapui = require "dapui"

require("mason-nvim-dap").setup {
  ensure_installed = { "codelldb", "js-debug-adapter" },
  automatic_installation = true,
  handlers = {},
}

dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- codelldb: rust, c, c++, zig
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = mason_bin .. "/codelldb",
    args = { "--port", "${port}" },
  },
}

for _, lang in ipairs { "rust", "c", "cpp", "zig" } do
  dap.configurations[lang] = {
    {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
end

-- js-debug-adapter: javascript, typescript
local js_debug_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = { js_debug_path, "${port}" },
  },
}

for _, lang in ipairs { "typescript", "javascript" } do
  dap.configurations[lang] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
  }
end

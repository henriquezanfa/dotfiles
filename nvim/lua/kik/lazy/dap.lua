return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio"
  },
  config = function()
    local dap = require("dap")
    local ui = require("dapui")

    require("dapui").setup()

    dap.adapters.dart = {
      type = "executable",
      command = "dart",
      -- This command was introduced upstream in https://github.com/dart-lang/sdk/commit/b68ccc9a
      args = {"debug_adapter"}
    }
    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart Program",
        -- The nvim-dap plugin populates this variable with the filename of the current buffer
        program = "${file}",
        -- The nvim-dap plugin populates this variable with the editor's current working directory
        cwd = "${workspaceFolder}",
        args = {"--help"}, -- Note for Dart apps this is args, for Flutter apps toolArgs
      }
    }
    vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
    vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

    -- Eval var under cursor
    vim.keymap.set("n", "<space>?", function()
      require("dapui").eval(nil, { enter = true })
    end)

    vim.keymap.set("n", "<F1>", dap.continue)
    vim.keymap.set("n", "<F2>", dap.step_into)
    vim.keymap.set("n", "<F3>", dap.step_over)
    vim.keymap.set("n", "<F4>", dap.step_out)
    vim.keymap.set("n", "<F5>", dap.step_back)
    vim.keymap.set("n", "<F13>", dap.restart)

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end
  end
}

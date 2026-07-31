return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio"
  },
  config = function()
    local dap = require("dap")
    local ui = require("dapui")

    require("dapui").setup({
      layouts = {
        {
          -- Panels on the left side
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "watches", size = 0.25 },
            { id = "stacks", size = 0.25 },
          },
          position = "left", -- Can be "left", "right", "top", or "bottom"
          size = 40,         -- Width in columns (or height if position is top/bottom)
        },
        {
          -- Panels at the bottom
          elements = {
            { id = "repl", size = 1.0 }, -- Only show the REPL
            -- "console" removed!
          },
          position = "bottom",
          size = 10, -- lines
        },
      }
    })

    -- DapStopped's default sign asks for linehl = 'debugPC' (a Termdebug
    -- highlight group we never define), so only the arrow shows and not a
    -- full-line highlight like VS Code's. Point it at a real, always-defined
    -- group instead.
    vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "Visual" })
    vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

    -- Flutter apps need `flutter debug_adapter`, not `dart debug_adapter`:
    -- the standalone Dart adapter runs on the vanilla Dart VM, which has no
    -- Flutter engine and therefore no dart:ui.
    dap.adapters.dart = {
      type = "executable",
      command = "flutter",
      args = { "debug_adapter" },
    }

    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch flutter",
        program = "lib/main.dart",
      },
    }

    -- Prevent nvim-dap from automatically pausing on uncaught exceptions
    dap.defaults.fallback.exception_breakpoints = {}

    -- Flutter apps run multiple isolates (threads, in DAP terms). By default
    -- nvim-dap auto-resumes any isolate that reports "stopped" while a
    -- different one is already focused, assuming it's an unimportant
    -- background thread. For Dart that assumption doesn't hold and it can
    -- desync nvim-dap's tracked "stopped thread" from what's actually
    -- paused, so F3/step just does nothing until you manually pick "Resume
    -- stopped thread" from the F1/continue menu. Let extra stopped isolates
    -- just stay stopped instead of being silently auto-continued.
    dap.defaults.dart.auto_continue_if_many_stopped = false

    -- Workaround for a Dart debug_adapter quirk: it reports a completed step
    -- (F2/F3/F4) with reason = "pause" instead of the conventional "step".
    -- nvim-dap's own should_jump heuristic (dap/session.lua) treats
    -- reason == "pause" as an uninteresting/background stop and skips moving
    -- the cursor/arrow entirely - even though the adapter already resolved
    -- the correct new location. Net effect: stepping silently does nothing.
    -- If nothing is currently focused (stopped_thread_id is nil) when this
    -- happens, the stop is real and we should show it; Session:_frame_set
    -- does the same cursor-jump/sign-placement/scopes-fetch the built-in
    -- handler would have done, we just have to trigger it ourselves.
    dap.listeners.after.event_stopped["dart_pause_reason_workaround"] = function(session, body)
      if session.stopped_thread_id then
        return
      end
      if body.reason ~= "pause" or body.allThreadsStopped then
        return
      end
      local thread = session.threads[body.threadId]
      local frame = thread and thread.frames and thread.frames[1]
      if not frame then
        return
      end
      session.stopped_thread_id = body.threadId
      session:_frame_set(frame)
    end

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
    vim.keymap.set("n", "<F12>", dap.restart)
    
    vim.keymap.set("n", "td", function()
      ui.toggle({layout = 1})
    end)
    -- 1. When the debug session starts: Open ONLY the bottom tray (Layout 2 - REPL/console)
    dap.listeners.after.event_initialized["dapui_config"] = function()
      ui.open({ layout = 2 })
    end

    -- 2. Open the left sidebar ONLY if execution stopped because of a breakpoint
    dap.listeners.after.event_stopped["dapui_config"] = function(session, body)
      if body and (body.reason == "breakpoint" or body.reason == "function breakpoint") then
        ui.open({ layout = 1 })
      end
    end
    -- 3. When debugging ends or exits: Close all windows
    dap.listeners.before.event_terminated["dapui_config"] = function()
      ui.close()
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
      ui.close()
    end
    vim.api.nvim_create_user_command("Run", function()
      local dap = require("dap")

        dap.continue()
    end, {})
  end
}

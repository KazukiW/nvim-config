-- ~/.config/nvim/lua/plugins/dap.lua
return {
  { "mfussenegger/nvim-dap" },
  { "nvim-neotest/nvim-nio" },
  { "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]      = function() dapui.close() end
    end,
  },
  { "theHamsta/nvim-dap-virtual-text", config = true }, -- 行内に変数/ポインタ値を表示
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy" }, -- C/C++, Python
        automatic_installation = true,
      })

      -- ==== アダプタ設定（C/C++: codelldb, Python: debugpy） ====
      local dap = require("dap")
      local function get_python()
        -- 有効なvenvを優先 → .venv → python3
        if vim.env.VIRTUAL_ENV then
          return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
        end
        local root = vim.fs.root(0, { ".venv", "pyproject.toml", "requirements.txt", ".git" })
        if root and vim.loop.fs_stat(root .. "/.venv/bin/python") then
          return root .. "/.venv/bin/python"
        end
        return "python3"
      end

      -- Python (debugpy)
      -- ==== Python (prefer Mason's debugpy; fallback to project venv) ====
      local dap = require("dap")

      local function get_python()
        if vim.env.VIRTUAL_ENV then
          return (vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python"))
        end
        local root = vim.fs.root(0, { ".venv", "pyproject.toml", "requirements.txt", ".git" })
        if root and vim.loop.fs_stat(root .. "/.venv/bin/python") then
          return root .. "/.venv/bin/python"
        end
        return "python3"
      end

      -- Mason に入っている debugpy を優先
      local mason_debugpy = vim.fn.exepath("debugpy-adapter")
      if mason_debugpy ~= "" then
        dap.adapters.python = { type = "executable", command = mason_debugpy }
      else
        dap.adapters.python = function(cb)
          cb({ type = "executable", command = get_python(), args = { "-m", "debugpy.adapter" } })
        end
      end

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch current file",
          program = "${file}",
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "launch",
          name = "Launch w/ args",
          program = "${file}",
          console = "integratedTerminal",
          args = function()
            local a = vim.fn.input("args: ")
            return vim.split(vim.fn.expand(a), "%s+")
          end,
        },
      }

      -- C/C++/Rust (codelldb)
      -- ==== C/C++/Rust (codelldb → 無ければ lldb-dap/lldb-vscode) ====
      local codelldb_cmd = vim.fn.exepath("codelldb")
      if codelldb_cmd ~= "" then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = { command = codelldb_cmd, args = { "--port", "${port}" } },
        }
        local cfg = {
          {
            name = "Launch (ask for exe)",
            type = "codelldb",
            request = "launch",
            program = function() return vim.fn.input("executable: ", vim.fn.getcwd() .. "/", "file") end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
        dap.configurations.c    = cfg
        dap.configurations.cpp  = cfg
        dap.configurations.rust = cfg
      else
        local lldb = vim.fn.exepath("lldb-dap")
        if lldb == "" then lldb = vim.fn.exepath("lldb-vscode") end
        if lldb ~= "" then
          dap.adapters.lldb = { type = "executable", command = lldb, name = "lldb" }
          local cfg = {
            {
              name = "Launch (lldb)",
              type = "lldb",
              request = "launch",
              program = function() return vim.fn.input("executable: ", vim.fn.getcwd() .. "/", "file") end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          }
          dap.configurations.c    = cfg
          dap.configurations.cpp  = cfg
          dap.configurations.rust = cfg
        end
      end

      -- キーマップ（好みで変更OK）
      local map = vim.keymap.set
      map("n", "<F5>",  dap.continue)
      map("n", "<F10>", dap.step_over)
      map("n", "<F11>", dap.step_into)
      map("n", "<F12>", dap.step_out)
      map("n", "<leader>db", dap.toggle_breakpoint)
      map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)
      map("n", "<leader>dr", dap.repl.open)
      map("n", "<leader>du", function() require("dapui").toggle() end)
    end,
  },
}


return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Bridge between mason.nvim and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("configs.mason-lspconfig")
    end,
  },

  -- Mason tool installer (debugpy, ruff, etc.)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },

  -- Python DAP (debugger)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.adapters.python = {
        type = "executable",
        command = "python3",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function() return "python3" end,
          console = "integratedTerminal",
          justMyCode = true,
        },
        {
          type = "python",
          request = "launch",
          name = "Debug pytest",
          module = "pytest",
          args = { "${file}" },
          pythonPath = function() return "python3" end,
          console = "integratedTerminal",
          justMyCode = true,
        },
        {
          type = "python",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
          pythonPath = function() return "python3" end,
          console = "integratedTerminal",
          justMyCode = true,
        },
      }

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- DAP keymaps
      local map = vim.keymap.set
      map("n", "<F5>", function() dap.continue() end, { desc = "Debug: Continue" })
      map("n", "<F9>", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
      map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Debug: Conditional breakpoint" })
      map("n", "<F10>", function() dap.step_over() end, { desc = "Debug: Step over" })
      map("n", "<F11>", function() dap.step_into() end, { desc = "Debug: Step into" })
      map("n", "<F12>", function() dap.step_out() end, { desc = "Debug: Step out" })
      map("n", "<leader>dR", function() dap.clear_breakpoints() end, { desc = "Debug: Clear breakpoints" })
      map("n", "<leader>dr", function() dap.run_last() end, { desc = "Debug: Run last" })
      map("n", "<leader>dq", function() dap.terminate() end, { desc = "Debug: Terminate" })
      map("n", "<leader>dp", function() dap.repl.toggle() end, { desc = "Debug: Toggle REPL" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },

  -- Inline variable display during debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-dap-virtual-text").setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = "<module",
      }
    end,
  },

  -- Linting via nvim-lint (ruff, glslangValidator)
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      -- GLSL: validate with glslangValidator (Khronos reference validator)
      lint.linters.glsl = {
        cmd = vim.fn.stdpath("config") .. "/bin/glsl-lint.sh",
        stdin = false,
        append_fname = true,
        stream = "stdout",
        ignore_exitcode = true,
        parser = require("lint.parser").from_pattern(
          "^([^:]+):(%d+):(%a+):%s*(.*)$",
          { "file", "lnum", "severity", "message" },
          {
            error = vim.diagnostic.severity.ERROR,
            warning = vim.diagnostic.severity.WARN,
          }
        ),
      }

      lint.linters_by_ft = {
        python = { "ruff" },
        glsl = { "glsl" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufRead", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Python test runner (pytest)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = true },
          }),
        },
      }
    end,
  },

  {
    "vyfor/cord.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "python",
        "html", "css", "cpp", "c", "glsl"
      },
    },
  },
}

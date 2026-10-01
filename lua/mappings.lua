require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
local goto_buf = require("nvchad.tabufline").goto_buf

for i = 1, 9 do
  map("n", "<A-" .. i .. ">", function()
    local bufnr = vim.t.bufs[i]
    if bufnr then goto_buf(bufnr) end
  end, { desc = "Go to buffer " .. i })
end
map("i", "<S-Tab>", "<C-p>", { desc = "completion: previous suggestion" })

-- DAP UI keymaps (lazy-loaded)
map("n", "<leader>dU", function() require("dapui").toggle() end, { desc = "DAP: Toggle UI manually" })

-- Neotest mappings
map("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Test: Run file" })
map("n", "<leader>tl", function() require("neotest").run.run() end, { desc = "Test: Run nearest" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Test: Toggle summary" })
map("n", "<leader>to", function() require("neotest").output.open() end, { desc = "Test: Open output" })

-- Shader helper mappings
map("n", "<leader>se", "<cmd>lua vim.shader_helper.extract_shader()<cr>", { desc = "Extract shader to .glsl file" })
map("n", "<leader>sl", "<cmd>lua vim.shader_helper.list_shaders()<cr>", { desc = "List shaders in buffer" })
map("n", "<leader>si", "<cmd>lua vim.shader_helper.insert_shader_template()<cr>", { desc = "Insert shader template" })

-- Open glsl file for editing (gets full LSP completions)
map("n", "<leader>sv", "<cmd>split ~/.local/share/nvim/glsl_temp.vert<cr><cmd>setf glsl<cr>", { desc = "Open temp .glsl file" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Compile + run with Ctrl+F5 (async, non-blocking)
map("n", "<C-F5>", function()
  local root = vim.fn.findfile("CMakeLists.txt", ".;")
  if root == "" then
    vim.notify("No CMakeLists.txt found in the project root", vim.log.levels.ERROR)
    return
  end
  root = vim.fn.fnamemodify(root, ":p:h")
  vim.cmd("write")
  vim.fn.system("cmake --build " .. root .. "/build")
  if vim.v.shell_error == 0 then
    vim.fn.jobstart(root .. "/build/mygame", { detach = true })
  else
    vim.notify("Build failed", vim.log.levels.ERROR)
  end
end, { desc = "Build & Run (Ctrl+F5)" })

require("nvchad.configs.lspconfig").defaults()

-- Find active Python (prefer venv, fallback to system)
local function get_python_path()
  local venv_paths = {
    vim.fn.getcwd() .. "/.venv/bin/python",
    vim.fn.getcwd() .. "/venv/bin/python",
  }
  for _, p in ipairs(venv_paths) do
    if vim.fn.executable(p) == 1 then return p end
  end
  return "python3"
end

local python_path = get_python_path()

-- Python LSP (pyright)
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  settings = {
    python = {
      pythonPath = python_path,
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic",
        completeFunctionParens = true,
        inlayHintVariableTypes = true,
        inlayHintFunctionReturnTypes = true,
      },
    },
  },
})

-- Mason-lspconfig auto-enables installed servers
-- but we also ensure pyright is enabled directly
vim.lsp.enable("pyright")

-- Glsl shader
vim.lsp.config("glsl_analyzer", {
  cmd = { "/home/krisi/.local/share/zed/extensions/work/glsl/glsl_analyzer-v1.7.1/bin/glsl_analyzer" },
  filetypes = { "glsl", "vert", "frag", "geom", "comp", "tesc", "tese", "vs", "fs" },
  root_markers = { ".git" },
})
vim.lsp.enable("glsl_analyzer")

-- Clangd (C/C++)
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
  },
})
vim.lsp.enable("clangd")

-- Enable inlay hints globally (auto type deduction, parameter names, etc.)
vim.lsp.inlay_hint.enable(true)

-- LSP keymaps for all filetypes
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = vim.keymap.set
    map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = event.buf })
    map("n", "K", vim.lsp.buf.hover, { desc = "LSP hover", buffer = event.buf })
    map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP rename", buffer = event.buf })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action", buffer = event.buf })
  end,
})
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = {
    "pyright",
  },
  automatic_enable = true,
}

-- Auto-install DAP adapters and linters via Mason
require("mason-tool-installer").setup {
  ensure_installed = {
    "debugpy",
    "ruff",
  },
}
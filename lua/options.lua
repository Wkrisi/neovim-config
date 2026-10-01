require "nvchad.options"

vim.o.timeoutlen = 1000

-- Python: use 4-space indent (PEP 8)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

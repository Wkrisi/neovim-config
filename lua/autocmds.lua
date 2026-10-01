require "nvchad.autocmds"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    if vim.bo.commentstring == "" then
      vim.bo.commentstring = "// %s"
    end
  end,
})

vim.filetype.add({
  extension = {
    glsl = "glsl",
    vert = "glsl",
    frag = "glsl",
    geom = "glsl",
    comp = "glsl",
    tesc = "glsl",
    tese = "glsl",
    vs = "glsl",
    fs = "glsl",
  },
})

local shader_helper = require("shader_helper")
vim.shader_helper = shader_helper

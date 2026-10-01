-- Shader helper for Neovim - Simple and reliable version

local M = {}

-- Extract shader string at or near cursor to a temporary .glsl file for editing
function M.extract_shader()
  -- Get current cursor position
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  line = line - 1 -- convert to 0-based
  
  -- Get all lines in buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  
  -- Search for raw string literals that look like shaders
  -- We'll look for the pattern: R"delim( ... )delim" 
  local shaders = {}
  
  for lnum, line_text in ipairs(lines) do
    -- Find all occurrences of R" in this line
    local start = 1
    while true do
      local rs_start, rs_end = line_text:find('R%"', start)
      if not rs_start then break end
      
      -- Extract delimiter (between "% and ()
      local delim_start = rs_end + 1
      local delim_end = line_text:find('%(', delim_start, true)
      if delim_end then
        local delimiter = line_text:sub(delim_start, delim_end - 1)
        
        -- Find closing pattern: )delim"
        local closing = '%)"' .. delimiter .. '"'
        local re_start, re_end = line_text:find(closing, delim_end + 1, true)
        if re_start then
          -- Extract content
          local content_start = delim_end + 1
          local content_end = re_start - 1
          local content = line_text:sub(content_start, content_end)
          
          -- Check if it looks like a shader
          if content:find('#version') or 
             content:find('void main') or 
             content:find('gl_Position') or 
             content:find('FragColor') or
             content:find('in ') or 
             content:find('out ') or
             content:find('uniform ') then
            
            table.insert(shaders, {
              lnum = lnum,
              rs_start = rs_start,
              rs_end = re_end,
              delimiter = delimiter,
              content = content
            })
          end
        end
      end
      
      start = rs_end + 1
    end
  end
  
  if #shaders == 0 then
    vim.notify('No shader strings found in buffer', vim.log.levels.WARN)
    return
  end
  
  -- Find the shader nearest to the cursor
  local best_shader = shaders[1]
  local best_dist = math.huge
  
  for _, shader in ipairs(shaders) do
    -- Distance is vertical distance (line difference) 
    local dist = math.abs(shader.lnum - (line + 1)) -- +1 because line is 0-based, lnum is 1-based
    if dist < best_dist then
      best_dist = dist
      best_shader = shader
    end
  end
  
  -- Create temporary file
  local temp_file = os.tmpname() .. '.glsl'
  local file = io.open(temp_file, 'w')
  if not file then
    vim.notify('Failed to create temp file', vim.log.levels.ERROR)
    return
  end
  
  file:write(best_shader.content)
  file:close()
  
  -- Open in vertical split
  vim.cmd('vspl ' .. vim.fn.fnameescape(temp_file))
  vim.bo.filetype = 'glsl'
  
  -- Set up autocommand to write back when file is saved
  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      -- Read updated content
      local updated_content = io.open(temp_file, 'r'):read('*all')
      io.close(io.open(temp_file, 'r'))
      
      -- Update original buffer
      local new_match = 'R"' .. best_shader.delimiter .. '(' .. updated_content .. ')' .. best_shader.delimiter .. '"'
      vim.api.nvim_buf_set_text(0,
        best_shader.lnum - 1, best_shader.rs_start - 1,
        best_shader.lnum - 1, best_shader.rs_end - 1,
        {new_match})
      
      -- Clean up
      os.remove(temp_file)
      vim.notify('Shader updated in C++ file', vim.log.levels.INFO)
    end
  })
  
  -- Also clean up if buffer is abandoned without saving
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      os.remove(temp_file)
    end
  })
  
  vim.notify('Editing shader: ' .. temp_file, vim.log.levels.INFO)
end

-- Insert a shader template at current cursor position
function M.insert_shader_template()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  
  local template = [[#version 330 core
void main() {
    // TODO: Implement shader
}]]
  
  -- Insert as raw string literal with a unique delimiter
  local shader_code = string.format('R"#shader(\n%s\n)%s#"', template, '#shader')
  
  -- Insert at current line
  vim.api.nvim_buf_set_lines(0, line, line, false, {shader_code})
  
  -- Position cursor inside the shader for editing
  local inside_line = line + 1  -- line after the inserted line
  vim.api.nvim_win_set_cursor(0, {inside_line + 1, 4})  -- +1 for 1-based line, 4 for indent
  vim.cmd('startinsert')
end

-- List shader strings in buffer
function M.list_shaders()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local count = 0
  
  for _, line_text in ipairs(lines) do
    local start = 1
    while true do
      local rs_start, rs_end = line_text:find('R%"', start)
      if not rs_start then break end
      
      local delim_start = rs_end + 1
      local delim_end = line_text:find('%(', delim_start, true)
      if delim_end then
        local delimiter = line_text:sub(delim_start, delim_end - 1)
        local closing = '%)"' .. delimiter .. '"'
        local re_start, re_end = line_text:find(closing, delim_end + 1, true)
        if re_start then
          count = count + 1
        end
      end
      
      start = rs_end + 1
    end
  end
  
  if count == 0 then
    print('No shader strings found in buffer')
    return
  end
  
  print(string.format('Found %d potential shader string(s)', count))
end

return M
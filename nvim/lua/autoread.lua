-- Autoread toggle functionality
-- Allows toggling automatic file reloading when files change externally

local autoread_enabled = false

local function enable_autoread()
  autoread_enabled = true
  vim.opt.autoread = true
  
  -- Set up autocommands for automatic file checking
  local autoread_group = vim.api.nvim_create_augroup("AutoRead", { clear = true })
  
  -- Check for file changes when entering a buffer or window
  vim.api.nvim_create_autocmd({"BufEnter", "WinEnter", "FocusGained"}, {
    group = autoread_group,
    pattern = "*",
    command = "checktime"
  })
  
  -- Check for file changes when cursor stops moving
  vim.api.nvim_create_autocmd("CursorHold", {
    group = autoread_group,
    pattern = "*", 
    command = "checktime"
  })
  
  print("Autoread enabled")
end

local function disable_autoread()
  autoread_enabled = false
  vim.opt.autoread = false
  
  -- Clear the autocommands
  vim.api.nvim_clear_autocmds({ group = "AutoRead" })
  
  print("Autoread disabled")
end

function AutoreadToggle()
  if autoread_enabled then
    disable_autoread()
  else
    enable_autoread()
  end
end
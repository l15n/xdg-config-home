-- Colemak keyboard layout toggle functionality
-- Rewritten from simple-colemak.vim to Lua

local colemak_enabled = false

-- Define all keymaps that need to be set/unset
local keymaps = {
  -- Movement keys remapping (n=j, e=k, i=l)
  { modes = {'n', 'v', 'o'}, lhs = 'n', rhs = 'j' },
  { modes = {'n', 'v', 'o'}, lhs = 'e', rhs = 'k' },
  { modes = {'n', 'v', 'o'}, lhs = 'i', rhs = 'l' },
  { modes = {'n', 'v', 'o'}, lhs = 'N', rhs = 'J' },
  { modes = {'n', 'v', 'o'}, lhs = 'E', rhs = 'K' },
  { modes = {'n', 'v', 'o'}, lhs = 'I', rhs = 'L' },

  -- Remap displaced keys
  { modes = {'n', 'v', 'o'}, lhs = 'k', rhs = 'n' },  -- search next
  { modes = {'n', 'v', 'o'}, lhs = 'K', rhs = 'N' },  -- search previous
  { modes = {'n', 'v', 'o'}, lhs = 'u', rhs = 'i' },  -- insert mode
  { modes = {'n', 'v', 'o'}, lhs = 'U', rhs = 'I' },  -- insert at beginning
  { modes = {'n', 'v', 'o'}, lhs = 'l', rhs = 'u' },  -- undo
  { modes = {'n', 'v', 'o'}, lhs = 'L', rhs = 'U' },  -- undo line

  -- Fix g commands (position-based)
  { modes = {'n'}, lhs = 'ge', rhs = 'gj' },   -- down display line
  { modes = {'n'}, lhs = 'gu', rhs = 'gk' },   -- up display line
  { modes = {'n'}, lhs = 'gl', rhs = 'gu' },   -- lowercase (displaced from gu→gk)
  { modes = {'n'}, lhs = 'gL', rhs = 'gU' },   -- uppercase
  { modes = {'n'}, lhs = 'gk', rhs = 'gn' },   -- next search match (displaced from n→j)
  { modes = {'n'}, lhs = 'gK', rhs = 'gN' },   -- previous search match
  { modes = {'v'}, lhs = 'gk', rhs = 'gn' },   -- next search match in visual mode
  { modes = {'v'}, lhs = 'gK', rhs = 'gN' },   -- previous search match in visual mode

  -- Window movement keys
  { modes = {'n'}, lhs = '<C-w>n', rhs = '<C-w>j' },
  { modes = {'n'}, lhs = '<C-w>e', rhs = '<C-w>k' },
  { modes = {'n'}, lhs = '<C-w>i', rhs = '<C-w>l' },
  { modes = {'n'}, lhs = '<C-w>N', rhs = '<C-w>J' },
  { modes = {'n'}, lhs = '<C-w>E', rhs = '<C-w>K' },
  { modes = {'n'}, lhs = '<C-w>I', rhs = '<C-w>L' },
  { modes = {'n'}, lhs = '<C-w>k', rhs = '<C-w>n' },

  -- Command line editing (emacs-style)
  { modes = {'c'}, lhs = '<C-b>', rhs = '<Left>' },
  { modes = {'c'}, lhs = '<C-f>', rhs = '<Right>' },
  { modes = {'c'}, lhs = '<M-f>', rhs = '<S-Right>' },
  { modes = {'c'}, lhs = '<M-b>', rhs = '<S-Left>' },
  { modes = {'c'}, lhs = '<C-a>', rhs = '<Home>' },
  { modes = {'c'}, lhs = '<C-e>', rhs = '<End>' },

  -- Insert/Visual/Operator mode emacs-style navigation
  { modes = {'i', 'v', 'o'}, lhs = '<C-b>', rhs = '<Left>' },
  { modes = {'i', 'v', 'o'}, lhs = '<C-f>', rhs = '<Right>' },
  { modes = {'i', 'v', 'o'}, lhs = '<C-p>', rhs = '<Up>' },
  { modes = {'i', 'v', 'o'}, lhs = '<C-n>', rhs = '<Down>' },
  { modes = {'i', 'v', 'o'}, lhs = '<C-a>', rhs = '<Home>' },
  { modes = {'i', 'v', 'o'}, lhs = '<C-e>', rhs = '<End>' },
  { modes = {'i', 'v', 'o'}, lhs = '<C-v>', rhs = '<PageDown>' },
  { modes = {'i', 'v', 'o'}, lhs = '<M-v>', rhs = '<PageUp>' },

  -- Window navigation with Alt
  { modes = {'t'}, lhs = '<A-h>', rhs = '<C-\\><C-N><C-w>h' },
  { modes = {'t'}, lhs = '<A-n>', rhs = '<C-\\><C-N><C-w>n' },
  { modes = {'t'}, lhs = '<A-e>', rhs = '<C-\\><C-N><C-w>e' },
  { modes = {'t'}, lhs = '<A-i>', rhs = '<C-\\><C-N><C-w>i' },
  { modes = {'i'}, lhs = '<A-h>', rhs = '<C-\\><C-N><C-w>h' },
  { modes = {'i'}, lhs = '<A-n>', rhs = '<C-\\><C-N><C-w>n' },
  { modes = {'i'}, lhs = '<A-e>', rhs = '<C-\\><C-N><C-w>e' },
  { modes = {'i'}, lhs = '<A-i>', rhs = '<C-\\><C-N><C-w>i' },
  { modes = {'n'}, lhs = '<A-h>', rhs = '<C-w>h' },
  { modes = {'n'}, lhs = '<A-n>', rhs = '<C-w>n' },
  { modes = {'n'}, lhs = '<A-e>', rhs = '<C-w>e' },
  { modes = {'n'}, lhs = '<A-i>', rhs = '<C-w>i' },
}

local function enable_colemak()
  colemak_enabled = true
  
  -- Set all keymaps
  for _, keymap in ipairs(keymaps) do
    for _, mode in ipairs(keymap.modes) do
      vim.keymap.set(mode, keymap.lhs, keymap.rhs, { noremap = true, silent = true })
    end
  end
  
  print("Enabled Colemak")
end

local function disable_colemak()
  colemak_enabled = false
  
  -- Delete all keymaps
  for _, keymap in ipairs(keymaps) do
    for _, mode in ipairs(keymap.modes) do
      pcall(vim.keymap.del, mode, keymap.lhs)
    end
  end
  
  print("Disabled Colemak")
end

function ColemakToggle()
  if colemak_enabled then
    disable_colemak()
  else
    enable_colemak()
  end
end

-- Enable colemak by default
enable_colemak()
-- Package manager: https://github.com/lewis6991/pckr.nvim
local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

require('pckr').add{
  'scrooloose/nerdtree';
  'tpope/vim-fugitive';
  -- fugitive extension for Github integration
  'tpope/vim-rhubarb';
  -- :Rg using quickfix buffer
  'jremmen/vim-ripgrep';
  -- Lua-native fzf integration
  'ibhagwan/fzf-lua';
  'tpope/vim-surround';
  'tpope/vim-unimpaired';
  -- vim-repeat: Enables `.` for plugins like surround.vim, uninmpaired.vim
  'tpope/vim-repeat';
  'vim-ruby/vim-ruby';
  'tpope/vim-rails';
  'slim-template/vim-slim.git';
  'editorconfig/editorconfig-vim';
  -- display marks in gutter
  'kshenoy/vim-signature';
  'justinmk/vim-sneak';
  -- color scheme
  'fenetikm/falcon';
  'rose-pine/neovim';
  'rebelot/kanagawa.nvim';
  'folke/tokyonight.nvim';
  'vim-test/vim-test';

  { 'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    requires = {
	    {'williamboman/mason.nvim'},
	    {'williamboman/mason-lspconfig.nvim'},
	    -- LSP Support
	    {'neovim/nvim-lspconfig'},
	    -- Autocompletion
	    {'hrsh7th/nvim-cmp'},
	    {'hrsh7th/cmp-nvim-lsp'},
	    {'hrsh7th/cmp-path'},
	    {'hrsh7th/cmp-buffer'},
	    -- Snippets
	    {'saadparwaiz1/cmp_luasnip'},
	    {'L3MON4D3/LuaSnip'},
    },
  };

  { 'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  };
  --'nvim-treesitter/playground';
}

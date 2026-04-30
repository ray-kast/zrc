-- editor behavior
vim.o.compatible = false
vim.o.mouse = 'a'

vim.o.autoread = true
vim.o.autowrite = true
vim.o.wildignorecase = true
vim.o.clipboard = 'unnamedplus'
vim.o.formatoptions = 'cro/q21jp'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.scrolloff = 3
vim.o.sidescrolloff = 7
vim.o.spell = true
vim.o.spelllang = 'en_us'
vim.opt.sessionoptions = {
  'blank',
  'curdir',
  'folds',
  'localoptions',
  'skiprtp',
  'tabpages',
  'terminal',
  'winsize',
}

-- feedback
vim.o.errorbells = true
vim.o.visualbell = true
vim.o.showcmd = true

-- tabs and newlines
vim.o.tabstop = 2
vim.o.softtabstop = 0
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.wrap = true
vim.o.linebreak = true

-- search and substitute
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.gdefault = true

-- folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false

-- visual
vim.o.termguicolors = true
vim.cmd.syntax'on'
vim.cmd.colorscheme'slate'
vim.cmd.filetype'plugin indent on'
vim.o.background = 'dark'
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.list = true
vim.opt.listchars = { tab = '› ', space = '·', trail = '◀' }
vim.o.showbreak = '»'
vim.o.showmatch = true
vim.opt.matchpairs:append'<:>'
vim.opt.colorcolumn = { 80, 100 }
vim.opt.completeopt = { 'menu', 'menuone', 'longest', 'noinsert', 'preview' }
vim.opt.diffopt = { 'vertical', 'iwhiteall', 'internal', 'filler', 'hiddenoff', 'algorithm:histogram' }
vim.o.laststatus = 2

-- leader key
vim.g.mapleader = ','
vim.g.maplocalleader = ' '
vim.o.timeoutlen = 500

-- misc autocmds
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('TermInit', {}),
  callback = function(ev)
    for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
      vim.wo[win].spell = false
    end
  end
})

vim.api.nvim_create_autocmd('TermLeave', {
  group = vim.api.nvim_create_augroup('TermCheckt', {}),
  callback = function(ev)
    vim.cmd.checkt()
  end,
})

local ftgroup = vim.api.nvim_create_augroup('FiletypeConfig', {})

vim.api.nvim_create_autocmd('FileType', {
  group = ftgroup,
  pattern = 'swift,lean',
  callback = function(ev)
    for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
      vim.wo[win].spell = false
    end
  end,
})

-- commands
vim.api.nvim_create_user_command('Scratch', function(evt)
  vim.api.nvim_cmd({
    cmd = 'split',
    mods = {
      horizontal = evt.smods.horizontal,
      vertical = evt.smods.vertical,
      tab = evt.smods.tab,
    },
  }, { output = false })
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, buf)
end, {})

-- mappings
do
  local map = function(l, r, o) vim.keymap.set('n', l, r, o) end
  local nvmap = function(l, r, o) vim.keymap.set({ 'n', 'v' }, l, r, o) end
  local imap = function(l, r, o) vim.keymap.set({ 'i', 's' }, l, r, o) end
  local nimap = function(l, r, o) vim.keymap.set({ 'n', 'i', 's' }, l, r, o) end
  local tmap = function(l, r, o) vim.keymap.set('t', l, r, o) end
  local _map = vim.keymap.set

  map('gy', 'gvy')
  imap('<M-BS>', '<C-w>')

  map('gl', '<Cmd>tablast<CR>')

  map('<Leader>sp', '<Cmd>setl nospell<CR>')
  map('<Leader>d', '<Cmd>tab split<CR>')
  nimap('<Leader>e', '<Cmd>e<CR>')
  map('<Leader>m', '<Cmd>checkt<CR>')
  nimap('<Leader>qw', '<Cmd>wq<CR>')
  map('<Leader>s', '<Cmd>Scratch<CR>')
  map('<Leader>sv', '<Cmd>vertical Scratch<CR>')
  map('<Leader>st', '<Cmd>tab Scratch<CR>')
  map('<Leader>t', '<Cmd>tabnew +term<CR>')
  map('<Leader>w', '<Cmd>wa<CR>')
  nimap('<Leader>.', '<C-c>')
  tmap('<Leader>.', '<C-\\><C-n>')

  map('gn', vim.diagnostic.goto_next)
  map('gN', vim.diagnostic.goto_prev)
  map('<Leader>k', vim.diagnostic.open_float)

  local tab = vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
  local s_tab = vim.api.nvim_replace_termcodes('<S-Tab>', true, false, true)
end

if not vim.g.lazy_did_setup then
  local lazyroot = vim.fn.stdpath'data' .. '/lazy'
  local lazypath = lazyroot .. '/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system{
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable',
      lazypath,
    }
  end
  vim.opt.runtimepath:prepend(lazypath)

  -- vimscript plugin config
  vim.g.rnvimr_enable_ex = 1
  vim.g.rnvimr_enable_picker = 1

  local pkgs = {
    { 'folke/lazy.nvim', tag = 'stable' },

    {
      'https://codeberg.org/andyg/leap.nvim',
      dependencies = {
        'tpope/vim-repeat',
      },
      lazy = false,
      config = function()
	vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
      end
    },
    {
      'kevinhwang91/rnvimr',
      config = function()
        vim.keymap.set('n', '<Leader>r', ':RnvimrToggle<CR>')
        vim.keymap.set('t', '<Leader>r', '<C-\\><C-n>:RnvimrToggle<CR>')
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'JoosepAlviste/nvim-ts-context-commentstring',
        'windwp/nvim-ts-autotag',
      },
      build = ':TSUpdate',
      opts = {
        ensure_installed = {
          'bash',
          'comment',
          'csv',
          'diff',
          'dockerfile',
          'gitcommit',
          'gitignore',
          'ini',
          'json',
          'json5',
          'lua',
          'make',
          'python',
          'regex',
          'ruby',
          'rust',
          'ssh_config',
          'toml',
          'tsv',
          'vim',
          'vimdoc',
          'xml',
          'yaml',
        },
        auto_install = true,
        autotag = {
          enable = true,
          -- TODO: verify these filetypes are actually correct
          filetypes = { 'html', 'xml', 'javascript', 'typescript', 'jsx', 'tsx' },
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gr',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
        indent = {
          enable = true,
        },
        select = {
          enable = true,
          keymaps = {
            -- TODO: flesh this out more later
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
            ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
          },
        },
      },
      main = 'nvim-treesitter.configs',
    },
    {
      'JoosepAlviste/nvim-ts-context-commentstring',
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
    {
      'kylechui/nvim-surround',
      version = '*',
      event = 'VeryLazy',
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      config = true,
    },
    {
      'numToStr/Comment.nvim',
      opts = {
        toggler = {
          line = ',cc',
          block = ',bb',
        },
        opleader = {
          line = ',c',
          block = ',b',
        },
        ignore = '^%s*$',
      },
      lazy = false,
      dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
      },
      config = function(_, opts)
        opts.pre_hook = require'ts_context_commentstring.integrations.comment_nvim'.create_pre_hook()
        require'Comment'.setup(opts)
      end
    },
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'folke/trouble.nvim',
      },
      config = function(_, opts)
        local trouble = require'trouble.sources.telescope'.open
        require'telescope'.setup{
          defaults = {
            mappings = {
              i = {
                ['<C-k>'] = trouble,
              },
              n = {
                ['<C-k>'] = trouble,
              },
            },
          },
        }

        -- TODO: move this (and other plugin keymaps) to the keymap section
        local b = require'telescope.builtin'

        local files = function()
          b.find_files{
            hidden = true,
            path_display = { 'truncate' },
          }
        end

        vim.keymap.set('n', '<Leader>af', files)
        vim.keymap.set('n', '<Leader>ag', b.live_grep)
        vim.keymap.set('n', '<Leader>ab', b.buffers)
        vim.keymap.set('n', '<Leader>ah', b.help_tags)
      end,
    },
    {
      'rcarriga/nvim-notify',
      config = function(_, opts)
        vim.notify = require'notify'
      end
    },
    {
      'rickhowe/diffchar.vim',
    },
    {
      'tpope/vim-fugitive',
    },
  }

  require'lazy'.setup(pkgs, {
    root = lazyroot,
  })
end

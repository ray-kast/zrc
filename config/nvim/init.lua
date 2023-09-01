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
vim.o.spelllang = 'en_us'
vim.opt.sessionoptions = {
  'blank',
  'buffers',
  'curdir',
  'folds',
  'help',
  'tabpages',
  'winsize',
  'winpos',
  'terminal',
  'localoptions',
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

-- visual
vim.cmd.syntax('on')
vim.cmd.colorscheme('slate')
vim.cmd.filetype('plugin indent on')
vim.o.background = 'dark'
vim.o.number = true
vim.o.relativenumber = true
vim.o.list = true
vim.opt.listchars = { tab = '› ', space = '·', trail = '·' }
vim.o.showbreak = '»'
vim.o.showmatch = true
vim.opt.matchpairs:append('<:>')
vim.opt.colorcolumn = { 80, 100 }
vim.opt.completeopt = { 'menu', 'menuone', 'longest', 'noinsert', 'preview' }
vim.opt.diffopt = { 'vertical', 'iwhiteall', 'internal', 'filler', 'hiddenoff', algorithm = 'histogram' }
vim.o.laststatus = 2

-- leader key
vim.g.mapleader = ','
vim.g.maplocalleader = ' '
vim.o.timeoutlen = 500

-- mappings
do
  local map = function(l, r, o) vim.keymap.set('n', l, r, o) end
  local imap = function(l, r, o) vim.keymap.set('i', l, r, o) end
  local tmap = function(l, r, o) vim.keymap.set('t', l, r, o) end
  local _map = vim.keymap.set

  map('gy', 'gvy')
  imap('<M-BS>', '<C-w>')

  map('gl', '<Cmd>tablast<CR>')

  map(',qw', '<Cmd>wq<CR>')
  imap(',qw', '<Cmd>wq<CR>')
  map(',w', '<Cmd>wa<CR>')
  imap(',w', '<C-c><Cmd>wa<CR>')
  _map({ 'n', 'i' }, ',.', '<C-c>')
  tmap(',.', '<C-\\><C-n>')

  map(',m', '<Cmd>checkt<CR>')
  map(',t', '<Cmd>tabe | term<CR>')

  map('gn', vim.diagnostic.goto_next, args)
  map('gN', vim.diagnostic.goto_prev, args)
  map('<Leader>k', vim.diagnostic.open_float, args)

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspBinds', {}),
    callback = function(ev)
      args = { buffer = ev.buf }

      map('gD', vim.lsp.buf.declaration, args)
      map('gd', vim.lsp.buf.definition, args)
      map('gi', vim.lsp.buf.implementation, args)
      map('gr', vim.lsp.buf.references, args)
      map('K', vim.lsp.buf.hover, args)
      map('<C-k>', vim.lsp.buf.signature_help, args)
      map('<Leader>f', vim.lsp.buf.format, args)
    end
  })
end

if not vim.g.lazy_did_setup then
  local lazyroot = vim.fn.stdpath('data') .. '/lazy'
  local lazypath = lazyroot .. '/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable',
      lazypath,
    })
  end
  vim.opt.runtimepath:prepend(lazypath)

  -- vimscript plugin config
  vim.g.rnvimr_enable_ex = 1
  vim.g.rnvimr_enable_picker = 1

  require('lazy').setup({
    { 'folke/lazy.nvim', tag = 'stable' },

    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
        'neovim/nvim-lspconfig',
        'saadparwaiz1/cmp_luasnip',
      },
      config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')

        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
        end

        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<Esc>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fbk)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fbk()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fbk)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fbk()
              end
            end, { 'i', 's' }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          }, {
            { name = 'buffer' },
          })
        })

        cmp.setup.cmdline({ '/', '?' }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' },
          },
        })

        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' },
          }, {
            { name = 'cmdline' },
          }),
        })

        local caps = require('cmp_nvim_lsp').default_capabilities()

        for lsp, opts in pairs({
          leanls = {},
          rust_analyzer = {
            ['rust-analyzer'] = {
              cargo = {
                features = 'all',
              },
              check = {
                command = 'clippy',
                features = 'all',
              },
            },
          },
        }) do
          require('lspconfig')[lsp].setup({ capabilities = caps, settings = opts })
        end
      end
    },
    {
      'j-hui/fidget.nvim',
      tag = 'legacy', -- TODO
      event = 'LspAttach',
      config = true,
    },
    {
      'Julian/lean.nvim',
      event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      opts = {
        mappings = true,
        infoview = {
          autoopen = false,
        },
      },
    },
    {
      'kevinhwang91/rnvimr',
      config = function()
        vim.keymap.set('n', '<Leader>r', ':RnvimrToggle<CR>')
        vim.keymap.set('t', '<Leader>r', '<C-\\><C-n>:RnvimrToggle<CR>')
      end,
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
      'NeogitOrg/neogit',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'sindrets/diffview.nvim',
      },
      config = function(_, opts)
        local neogit = require('neogit')
        neogit.setup(opts)

        vim.keymap.set('n', '<Leader>g', neogit.open)
      end,
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        {
          'lvimuser/lsp-inlayhints.nvim',
          opts = {
            inlay_hints = {
              highlight = 'Comment',
            },
          },
          config = function(_, opts)
            local ih = require('lsp-inlayhints')
            ih.setup(opts)

            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('LspAttachInlayHints', {}),
              callback = function(args)
                if not (args.data and args.data.client_id) then
                  return
                end

                local client = vim.lsp.get_client_by_id(args.data.client_id)
                ih.on_attach(client, args.buf)
              end,
            })
          end,
        },
      },
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
      },
      lazy = false
    },
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
      config = function()
        local b = require('telescope.builtin')

        vim.keymap.set('n', '<Leader>af', b.find_files)
        vim.keymap.set('n', '<Leader>ag', b.live_grep)
        vim.keymap.set('n', '<Leader>ab', b.buffers)
        vim.keymap.set('n', '<Leader>ah', b.help_tags)
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
      },
    },
    {
      'phaazon/hop.nvim',
      config = function(_, opts)
        local hop = require('hop')
        local directions = require('hop.hint').HintDirection
        hop.setup(opts)

        vim.keymap.set('', 'f', function()
          hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
        end, { remap = true })

        vim.keymap.set('', 'F', function()
          hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
        end, { remap = true })
      end,
    },
    {
      'rmagatti/auto-session',
      opts = {
        bypass_session_save_file_types = { 'leaninfo' },
      },
    },
  }, {
    root = lazyroot,
  })
end

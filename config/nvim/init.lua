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
vim.cmd.syntax'on'
vim.cmd.colorscheme'slate'
vim.cmd.filetype'plugin indent on'
vim.o.background = 'dark'
vim.o.number = true
vim.o.relativenumber = true
vim.o.list = true
vim.opt.listchars = { tab = '› ', space = '·', trail = '·' }
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
  pattern = 'swift',
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
  local imap = function(l, r, o) vim.keymap.set({ 'i', 's' }, l, r, o) end
  local nimap = function(l, r, o) vim.keymap.set({ 'n', 'i', 's' }, l, r, o) end
  local tmap = function(l, r, o) vim.keymap.set('t', l, r, o) end
  local _map = vim.keymap.set

  map('gy', 'gvy')
  imap('<M-BS>', '<C-w>')

  map('gl', '<Cmd>tablast<CR>')

  map('<Leader>d', '<Cmd>tab split<CR>')
  nimap('<Leader>e', '<Cmd>e<CR>')
  map('<Leader>m', '<Cmd>checkt<CR>')
  nimap('<Leader>qw', '<Cmd>wq<CR>')
  map('<Leader>s', '<Cmd>Scratch<CR>')
  map('<Leader>sv', '<Cmd>vertical Scratch<CR>')
  map('<Leader>st', '<Cmd>tab Scratch<CR>')
  map('<Leader>t', '<Cmd>tabnew +term<CR>')
  map('<Leader>w', '<Cmd>wa<CR>')
  -- imap('<Leader>w', '<C-c><Cmd>wa<CR>', { remap = true })
  nimap('<Leader>.', '<C-c>')
  tmap('<Leader>.', '<C-\\><C-n>')

  map('gn', vim.diagnostic.goto_next)
  map('gN', vim.diagnostic.goto_prev)
  map('<Leader>k', vim.diagnostic.open_float)

  local tab = vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
  local s_tab = vim.api.nvim_replace_termcodes('<S-Tab>', true, false, true)

  imap('<Tab>', function()
    local luasnip = require'luasnip'
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      vim.api.nvim_feedkeys(tab, 'nt', false)
    end
  end)

  imap('<S-Tab>', function()
    local luasnip = require'luasnip'
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      vim.api.nvim_feedkeys(s_tab, 'nt', false)
    end
  end)

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspBinds', {}),
    callback = function(ev)
      args = { buffer = ev.buf }

      map('gd', vim.lsp.buf.definition, args)
      map('gdd', vim.lsp.buf.declaration, args)
      map('gdt', vim.lsp.buf.type_definition, args)
      map('gi', vim.lsp.buf.implementation, args)
      map('gr', vim.lsp.buf.references, args)
      map('K', vim.lsp.buf.hover, args)
      _map({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, args)
      map('<Leader>a', vim.lsp.buf.code_action, args)
      map('<Leader>A', vim.lsp.codelens.run, args)
      map('<Leader>f', vim.lsp.buf.format, args)
      map('<Leader>R', vim.lsp.buf.rename, args)
      map('<Leader>x', function() require'trouble'.open'workspace_diagnostics' end)
      -- Mostly stolen from nvim-lspconfig
      map('<Leader>lr', function()
        local detach = {}
        for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = ev.buf })) do
          client.stop()
          vim.lsp.codelens.clear(client.id)

          if vim.tbl_count(client.attached_buffers) > 0 then
            detach[client.name] = { client, client.attached_buffers }
          end
        end

        local timer = vim.loop.new_timer()
        timer:start(
          500,
          100,
          vim.schedule_wrap(function()
            for name, pair in pairs(detach) do
              local client, bufs = unpack(pair)

              if client.is_stopped() then
                for buf in pairs(bufs) do
                  require'lspconfig.configs'[name].launch(buf)
                end

                detach[name] = nil
              end
            end

            if next(detach) == nil and not timer:is_closing() then
              timer:close()
            end
          end)
        )
      end)

      local codelens = false
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnre = ev.buf })) do
        if client.supports_method'textDocument/codeLens' then
          codelens = true
        end
      end

      if codelens then
        vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
          group = vim.api.nvim_create_augroup('LspCodelens', { clear = false }),
          buffer = ev.buf,
          callback = function(ev) vim.lsp.codelens.refresh() end,
        })
      else
        vim.notify('Not enabling code lenses for buffer ' .. ev.buf, vim.log.levels.INFO)
      end
    end
  })
end

if not vim.g.lazy_did_setup then
  local lazyroot = vim.fn.stdpath'data' .. '/lazy'
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

  require'lazy'.setup({
    { 'folke/lazy.nvim', tag = 'stable' },

    {
      'digitaltoad/vim-pug',
      ft = 'pug',
    },
    {
      'folke/trouble.nvim',
      opts = {
        icons = false,
        fold_open = '-',
        fold_closed = '+',
        signs = {
          error = 'E',
          warning = 'W',
          hint = 'H',
          information = 'I',
          other = 'N',
        },
        use_diagnostic_signs = true,
      },
    },
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-path',
        { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
        'neovim/nvim-lspconfig',
        'saadparwaiz1/cmp_luasnip',
      },
      config = function()
        local cmp = require'cmp'
        local luasnip = require'luasnip'

        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match'%s' == nil
        end

        cmp.setup({
          snippet = {
            expand = function(args)
              require'luasnip'.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<Esc>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            -- ['<Tab>'] = cmp.mapping(function(fbk)
            --   if cmp.visible() then
            --     cmp.select_next_item()
            --   elseif luasnip.expand_or_jumpable() then
            --     luasnip.expand_or_jump()
            --   elseif has_words_before() then
            --     cmp.complete()
            --   else
            --     fbk()
            --   end
            -- end, { 'i', 's' }),
            -- ['<S-Tab>'] = cmp.mapping(function(fbk)
            --   if cmp.visible() then
            --     cmp.select_prev_item()
            --   elseif luasnip.jumpable(-1) then
            --     luasnip.jump(-1)
            --   else
            --     fbk()
            --   end
            -- end, { 'i', 's' }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
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

        local conf = require'lspconfig'
        local caps = require'cmp_nvim_lsp'.default_capabilities()

        for lsp, opts in pairs({
          dartls = {},
          eslint = {},
          jsonls = {},
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
          sourcekit = {
            { 'swift', 'c', 'cpp', 'objc', 'objective-c', 'objective-cpp' },
          },
          tailwindcss = {},
          texlab = {
            texlab = {
              chktex = {
                onOpenAndSave = true,
                onEdit = true,
              },
              latexindent = {
                modifyLineBreaks = true,
              },
            },
          },
          tsserver = {},
        }) do
          if opts[1] ~= nil then
            conf[lsp].setup{
              capabilities = caps,
              filetypes = opts[1],
              settings = opts[2] or {},
            }
          else
            conf[lsp].setup{
              capabilities = caps,
              settings = opts,
            }
          end
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
      'jparise/vim-graphql',
      ft = 'graphql',
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
          'c',
          'c_sharp',
          'comment',
          'cmake',
          'cpp',
          'css',
          'csv',
          'dart',
          'diff',
          'dockerfile',
          'dot',
          'git_config',
          'git_rebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
          'go',
          'graphql',
          'haskell',
          'html',
          'ini',
          'javascript',
          'json',
          'json5',
          'julia',
          'lalrpop',
          'latex',
          'lua',
          'luadoc',
          'luap',
          'make',
          'meson',
          'ninja',
          'nix',
          'norg',
          'objc',
          'perl',
          'proto',
          'pug',
          'python',
          'rasi',
          're2c',
          'regex',
          'ron',
          'ruby',
          'rust',
          'scheme',
          'scss',
          'sql',
          'ssh_config',
          'swift',
          'toml',
          'tsv',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'vue',
          'xml',
          'yaml',
          'zig',
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
    -- {
    --   'NeogitOrg/neogit',
    --   dependencies = {
    --     'nvim-lua/plenary.nvim',
    --     'nvim-telescope/telescope.nvim',
    --     'sindrets/diffview.nvim',
    --   },
    --   config = function(_, opts)
    --     local neogit = require'neogit'
    --     neogit.setup(opts)

    --     vim.keymap.set('n', '<Leader>g', neogit.open)
    --   end,
    -- },
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
            local ih = require'lsp-inlayhints'
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
      'nvim-neorg/neorg',
      lazy = false,
      dependencies = {
        'nvim-lua/plenary.nvim',
        {
          "vhyrro/luarocks.nvim",
          priority = 1000,
          config = true,
        },
      },
      config = function()
        require'neorg'.setup{
          load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {},
            ["core.dirman"] = {
              config = {
                workspaces = {
                  notes = "~/Documents/Notes",
                },
              },
            },
          },
        }
      end,
    },
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'folke/trouble.nvim',
      },
      config = function(_, opts)
        local trouble = require'trouble.providers.telescope'

        require'telescope'.setup({
          defaults = {
            mappings = {
              i = {
                ['<C-k>'] = trouble.open_with_trouble,
              },
              n = {
                ['<C-k>'] = trouble.open_with_trouble,
              },
            },
          },
        })

        -- TODO: move this (and other plugin keymaps) to the keymap section
        local b = require'telescope.builtin'

        vim.keymap.set('n', '<Leader>af', function() b.find_files({ hidden = true }) end)
        vim.keymap.set('n', '<Leader>ag', b.live_grep)
        vim.keymap.set('n', '<Leader>ab', b.buffers)
        vim.keymap.set('n', '<Leader>ah', b.help_tags)
      end,
    },
    {
      -- 'phaazon/hop.nvim', -- TODO: ded
      'smoka7/hop.nvim',
      config = function(_, opts)
        local hop = require'hop'
        local directions = require'hop.hint'.HintDirection
        hop.setup(opts)

        vim.keymap.set('', 'f', function()
          hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
        end, { remap = true })

        vim.keymap.set('', 'F', function()
          hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
        end, { remap = true })

        vim.keymap.set('', 't', function()
          hop.hint_char1({
            direction = directions.AFTER_CURSOR,
            current_line_only = false,
            hint_offset = -1,
          })
        end, { remap = true })

        vim.keymap.set('', 'T', function()
          hop.hint_char1({
            direction = directions.BEFORE_CURSOR,
            current_line_only = false,
            hint_offset = 1,
          })
        end, { remap = true })
      end,
    },
    {
      'rmagatti/auto-session',
      opts = {
        -- Turns out this doesn't work the way i was hoping :(
        -- bypass_session_save_file_types = { 'norg', 'leaninfo' },
      },
    },
    {
      'tpope/vim-fugitive',
    },
  }, {
    root = lazyroot,
  })
end

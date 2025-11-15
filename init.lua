-- Bootstrap lazy.nvim: The humble gatekeeper, cloning itself if absent
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key: Space, the breath between thoughts
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Sensible defaults: Like a well-tuned workbench, ergonomic and unyielding
vim.opt.number = true          -- Line numbers, a map for the mind's eye
vim.opt.relativenumber = true  -- Relative, for swift leaps
vim.opt.expandtab = true       -- Spaces, the gentle persuaders
vim.opt.shiftwidth = 2         -- 2 for JS/TS; we'll tune Rust later
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false           -- Straight lines, no meandering
vim.opt.swapfile = false       -- No ghostly backups haunting the forge
vim.opt.termguicolors = true   -- True colors, the palette of dreams
vim.opt.clipboard = "unnamedplus"  -- Seamless flow to the world's ledger

-- Awaken Lazy: The orchestrator of plugins, loading just in time
require("lazy").setup({
  -- Colorscheme: Catppuccin, a hearthside vigil in soft mauves and earths
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",  -- Warm, reflective—swap to "latte" for dawn's light if it suits
        transparent_background = false,  -- Grounded opacity, like ink on vellum
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- Treesitter: Parser of tongues, illuminating syntax with surgical grace
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "javascript", "typescript", "tsx", "rust", "lua", "json", "html", "css" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP: The sage advisor—completions, diagnostics, a whisper of wisdom
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",  -- The completion loom
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",  -- Snippet sparks
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp = require("cmp")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Mason: The smithy for LSP forges
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "tsserver",      -- For TS/JS/React/Next.js symphonies
          "rust_analyzer", -- Rust's unerring gaze
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup { capabilities = capabilities }
          end,
        },
      })

      -- Completion: A duet with the divine, suggestions blooming at your cue
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Keymaps: Motions etched in muscle memory
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- Telescope: The stargazer's lens—fuzzy hunts through files and forgotten lines
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    end,
  },

  -- Trouble: A ledger of woes, neatly docketed for swift remedy
  { "folke/trouble.nvim", config = true, cmd = "TroubleToggle" },

  -- Harpoon: Anchors for the frequent harbors—quick sails between files
  {
    "ThePrimeagen/harpoon",
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>a", mark.add_file)
      vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)
    end,
  },
})

-- Filetype Indents: Tailored widths, like custom chisels for each grain
vim.api.nvim_create_autocmd("FileType", {
  pattern = "javascript,typescript,tsx,json",
  callback = function() vim.opt_local.shiftwidth = 2 end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function() vim.opt_local.shiftwidth = 4 end,
})

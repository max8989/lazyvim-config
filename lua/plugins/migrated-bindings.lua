-- Plugins required by the migrated bindings. LazyVim retains its other defaults.
return {
  { "folke/flash.nvim", enabled = false },
  { "ibhagwan/fzf-lua", lazy = false,  config = function() require("migration.fzf-lua") end },
  { "smoka7/hop.nvim", lazy = false,  config = function() require("migration.nvim_hop") end },
  { "akinsho/toggleterm.nvim", lazy = false,  config = function() require("migration.toggleterm") end },
  { "tpope/vim-fugitive", lazy = false,  config = function() require("migration.fugitive") end },
  { "ruifm/gitlinker.nvim", lazy = false,  config = function() require("migration.git-linker") end },
  { "dnlhc/glance.nvim", lazy = false,  config = function() require("migration.glance") end },
  { "mizlan/iswap.nvim", lazy = false,  config = function() require("migration.iswap") end },
  { "kevinhwang91/nvim-hlslens", lazy = false,  config = function() require("migration.hlslens") end },
  { "kevinhwang91/nvim-ufo", lazy = false, dependencies = { "kevinhwang91/promise-async" }, init = function() vim.o.foldlevel = 99; vim.o.foldlevelstart = 99 end, config = function() require("migration.nvim_ufo") end },
  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false, branch = "main", config = function() require("migration.treesitter-textobjects") end },
  { "lewis6991/gitsigns.nvim", lazy = false,  config = function() require("migration.gitsigns") end },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- latest release; remove to track main
    ft = "markdown",
    cmd = "Obsidian", -- also load when running an :Obsidian command from any buffer
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false, -- use the new `:Obsidian <subcommand>` syntax
      workspaces = {
        {
          name = "obsidian",
          -- Portability: allow each machine to choose its own vault.
          path = vim.env.OBSIDIAN_VAULT or "~/Documents/obsidian",
        },
      },
      daily_notes = {
        enabled = true,
        folder = "40 Daily",
        date_format = "YYYY/MM/YYYY-MM-DD",
        template = "Daily",
        default_tags = { "daily-notes" },
      },
      templates = {
        enabled = true,
        folder = "Templates",
      },
      attachments = {
        folder = "Assets",
      },
      link = {
        style = "wiki", -- [[note]] style; use "markdown" for [..](..)
        format = "shortest",
      },
      -- Completion is provided by the built-in obsidian-ls LSP server (picked up
      -- by cmp-nvim-lsp), so the old completion.nvim_cmp option is no longer needed.
      -- render-markdown.nvim already handles in-buffer rendering, so turn off
      -- obsidian's built-in UI to avoid conflicts and silence the conceallevel warning.
      ui = { enable = false },
    },
  },
  { "nvim-telescope/telescope.nvim", cmd = "Telescope", dependencies = { "nvim-lua/plenary.nvim" }, opts = { defaults = { preview = { treesitter = false } } } },
  { "christoomey/vim-tmux-navigator", lazy = false, init = function() vim.g.tmux_navigator_no_mappings = 1 end,
    config = function()
      for key, direction in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
        vim.keymap.set("n", "<C-" .. key .. ">", "<cmd>TmuxNavigate" .. direction .. "<cr>")
      end
    end },
  { "mgierada/lazydocker.nvim", cmd = "Lazydocker", dependencies = { "akinsho/toggleterm.nvim" }, opts = { border = "curved" }, keys = { { "<leader>ld", function() require("lazydocker").open() end, desc = "LazyDocker" } } },
  { "nvim-zh/whitespace.nvim", event = "VeryLazy" },
  { "skywind3000/asyncrun.vim", cmd = "AsyncRun" },
  { "vim-pandoc/vim-markdownfootnotes", ft = "markdown" },
  { "wellle/targets.vim", event = "VeryLazy" },
  { "machakann/vim-sandwich", event = "VeryLazy", init = function() vim.keymap.set({ "n", "o" }, "s", "<Nop>") end },
  { "chrisbra/unicode.vim", event = "VeryLazy", init = function() vim.keymap.set("n", "ga", "<Plug>(UnicodeGA)") end },
  { "liuchengxu/vista.vim", cmd = "Vista", keys = { { "<leader>t", "<cmd>Vista!!<cr>", desc = "Toggle symbol outline" } } },
  -- Portability: select the completion extra in lazyvim.json before defaults load.
  { "saghen/blink.cmp", enabled = false },
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path", "hrsh7th/cmp-buffer", "hrsh7th/cmp-omni", "hrsh7th/cmp-cmdline", "quangnguyen30192/cmp-nvim-ultisnips", "SirVer/ultisnips", "xzbdmw/colorful-menu.nvim" }, config = function() require("migration.nvim-cmp") end },
  { "SirVer/ultisnips", init = function()
    vim.g.UltiSnipsExpandTrigger = "<c-j>"
    vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
    vim.g.UltiSnipsEnableSnipMate = 0
    vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", "my_snippets" }
  end },
  { "xzbdmw/colorful-menu.nvim", opts = {} },
  { "kevinhwang91/nvim-bqf", ft = "qf", config = function() require("migration.bqf") end },
  { "sindrets/diffview.nvim", cmd = "DiffviewOpen", config = function() require("migration.diffview") end },
  { "gbprod/yanky.nvim", cmd = "YankyRingHistory", config = function() require("migration.yanky") end },
  { "nvim-zh/better-escape.vim", event = "InsertEnter", init = function() vim.g.better_escape_interval = 200 end },
  { "lervag/vimtex", ft = "tex", enabled = function() return vim.fn.executable("latex") == 1 end,
    init = function() vim.api.nvim_create_autocmd("FileType", { pattern = "tex", callback = function(ev)
      vim.keymap.set("n", "<F9>", "<Plug>(vimtex-compile)", { buffer = ev.buf, remap = true })
    end }) end },
}

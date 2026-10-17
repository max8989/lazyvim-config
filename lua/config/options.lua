-- Options are automatically loaded before lazy.nvim startup.
-- Portability changes: detect the host OS and preserve packaged providers.
require("config.platform").setup()
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

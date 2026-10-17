-- Original nvim-config bindings, applied after LazyVim defaults.
require("migration.core")
require("migration.personal")
require("migration.lsp")
local map = vim.keymap.set
map("n", "<leader>qw", vim.diagnostic.setqflist, { desc = "Workspace diagnostics to quickfix" })
map("n", "<leader>qb", function() vim.diagnostic.setqflist({ bufnr = 0 }) end, { desc = "Buffer diagnostics to quickfix" })
map({ "n", "v" }, "<leader>F", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, { desc = "Format buffer / selection" })
map("n", "<leader>lg", function() Snacks.lazygit() end, { desc = "LazyGit" })
-- LazyVim terminal escape mappings otherwise consume Escape in terminal TUIs.
for _, key in ipairs({ "<Esc><Esc>" }) do pcall(vim.keymap.del, "t", key) end
vim.api.nvim_create_autocmd("TermOpen", { group = vim.api.nvim_create_augroup("MigratedTerminalEscape", { clear = true }), callback = function(ev)
  pcall(vim.keymap.del, "t", "<Esc><Esc>", { buffer = ev.buf })
end })

-- Picker mappings override LazyVim terminal shortcuts.
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<C-p>", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep_native<cr>", { desc = "Fuzzy grep files" })
vim.keymap.set(
  "n",
  "<leader>fh",
  "<cmd>FzfLua helptags<cr>",
  { desc = "Fuzzy grep tags in help files" }
)
vim.keymap.set(
  "n",
  "<leader>ft",
  "<cmd>FzfLua lsp_document_symbols<cr>",
  { desc = "Fuzzy search buffer tags" }
)
vim.keymap.set(
  "n",
  "<leader>fb",
  "<cmd>FzfLua buffers<cr>",
  { desc = "Fuzzy search opened buffers" }
)
vim.keymap.set(
  "n",
  "<leader>fr",
  "<cmd>FzfLua oldfiles<cr>",
  { desc = "Fuzzy search opened files history" }
)

local gitlinker = require("gitlinker")
local keymap = vim.keymap
keymap.set({ "n", "v" }, "<leader>gl", function()
  local mode = string.lower(vim.fn.mode())
  gitlinker.get_buf_range_url(mode)
end, {
  silent = true,
  desc = "Git: get permlink",
})

keymap.set("n", "<leader>gbr", function()
  gitlinker.get_repo_url {
    action_callback = gitlinker.actions.open_in_browser,
  }
end, {
  silent = true,
  desc = "Git: browse repo in browser",
})

local keymap = vim.keymap

keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git: show status" })
keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git: add file" })
keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git: commit changes" })
keymap.set("n", "<leader>gpl", "<cmd>Git pull<cr>", { desc = "Git: pull changes" })
keymap.set("n", "<leader>gpu", "<cmd>15 split|term git push<cr>", { desc = "Git: push changes" })
keymap.set("v", "<leader>gb", ":Git blame<cr>", { desc = "Git: blame selected line" })

-- convert git to Git in command line mode
vim.fn["utils#Cabbrev"]("git", "Git")

keymap.set("n", "<leader>gbn", function()
  vim.ui.input({ prompt = "Enter a new branch name" }, function(user_input)
    if user_input == nil or user_input == "" then
      return
    end

    local cmd_str = string.format("G checkout -b %s", user_input)
    vim.cmd(cmd_str)
  end)
end, {
  desc = "Git: create new branch",
})

keymap.set("n", "<leader>gf", ":Git fetch ", { desc = "Git: prune branches" })
keymap.set("n", "<leader>gbd", ":Git branch -D ", { desc = "Git: delete branch" })

vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { silent = true, desc = "Toggle file tree" })

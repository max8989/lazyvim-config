local ok, err = xpcall(function()
-- Suppressed optional-plugin checks can leave v:errmsg set without a failure.
vim.v.errmsg = ""
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
require("lazy").load({ plugins = { "nvim-cmp", "ultisnips", "nvim-lspconfig" } })

assert(_G.LazyVim ~= nil, "LazyVim was not loaded")
assert(vim.g.colors_name == "nordfox", "The captured Nordfox theme was not applied")
assert(vim.fn.has("python3") == 1, "The Python provider is unavailable")
assert(vim.fn.py3eval("1 + 1") == 2, "The Python provider could not execute code")
assert(vim.fn.exists(":UltiSnipsEdit") == 2, "UltiSnips was not loaded")
assert(require("cmp").get_config().sources[1] ~= nil, "Completion sources are missing")

-- Exercise the Python-backed engine, including placeholder expansion.
vim.cmd.enew()
local snippet_keys = [[i<C-R>=UltiSnips#Anon('provider_${1:ready}')<CR><Esc>]]
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(snippet_keys, true, false, true), "xt", false)
assert(vim.api.nvim_get_current_line() == "provider_ready", "UltiSnips could not expand a snippet")
vim.bo.modified = false

for _, key in ipairs({ "<leader>gg", "<leader>gG", "<leader>lg", "<leader>ff", "<leader>ld" }) do
  assert(vim.fn.maparg(key, "n") ~= "", "Missing keymap: " .. key)
end

if require("config.platform").is_nixos() then
  assert(require("lazy.core.config").plugins["mason.nvim"] == nil, "Mason should be disabled on NixOS")
end

vim.cmd.edit(vim.fn.stdpath("config") .. "/lua/config/platform.lua")
local attached = vim.wait(30000, function()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if client.name == "lua_ls" and client.initialized then
      return true
    end
  end
  return false
end, 100)
assert(attached, "The Lua language server did not attach; executable="
  .. vim.fn.exepath("lua-language-server") .. "; filetype=" .. vim.bo.filetype)
local messages = vim.api.nvim_exec2("messages", { output = true }).output
assert(not messages:find("Failed to run"), messages)
assert(not messages:find("Error detected"), messages)
print("PASS: LazyVim startup, theme, Python, snippet expansion, completion, keymaps, and Lua LSP")
end, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd.cquit(1)
end

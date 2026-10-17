-- Use the server installed by Nix, pacman, or Homebrew when it is available.
-- Additional servers can still be managed through Mason on Arch and macOS.
if vim.fn.executable("lua-language-server") ~= 1 then
  return {}
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { lua_ls = { mason = false } } },
  },
}

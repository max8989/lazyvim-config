-- Nix supplies the language server and formatters on this platform.
-- Mason's downloaded executables target conventional Linux distributions.
if not require("config.platform").is_nixos() then
  return {}
end

return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
}

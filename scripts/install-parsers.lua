local ok, err = xpcall(function()
  local parsers = LazyVim.opts("nvim-treesitter").ensure_installed or {}
  require("nvim-treesitter").install(parsers):wait(300000)
  assert(pcall(vim.treesitter.get_parser, 0, "lua"), "The Lua parser could not be loaded")
  print("PASS: syntax parsers installed")
end, debug.traceback)

if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd.cquit(1)
end

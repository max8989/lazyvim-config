local M = {}

function M.is_nixos()
  return vim.fn.filereadable("/etc/NIXOS") == 1
end

function M.setup()
  local system = vim.uv.os_uname().sysname
  vim.g.is_linux = system == "Linux"
  vim.g.is_mac = system == "Darwin"
  vim.g.is_win = system == "Windows_NT"

  -- Nix's wrapper supplies its own pynvim interpreter before init.lua runs.
  if vim.g.python3_host_prog then
    return
  end

  local candidates = {
    vim.env.NVIM_PYTHON3_HOST_PROG or "",
    vim.fn.exepath("nvim-python3"),
    vim.fn.stdpath("data") .. "/python/bin/python3",
  }
  for _, python in ipairs(candidates) do
    if python ~= "" and vim.fn.executable(python) == 1 then
      vim.g.python3_host_prog = python
      return
    end
  end
  -- Arch's python-pynvim and other system installations use normal discovery.
end

return M

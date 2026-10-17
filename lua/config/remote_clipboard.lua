-- Portability: support macOS paste and process ancestry as well as Linux.
-- Clipboard for sessions whose yanks may need to reach another machine:
-- every copy is emitted as OSC 52 (inside tmux this becomes a tmux buffer,
-- rebroadcast to every attached client, local or SSH). Paste prefers the
-- local Wayland clipboard when one is available, so content copied in other
-- apps remains pasteable; without a display, paste is an OSC 52 query that
-- tmux (or the terminal) answers.
local M = {}

local function proc_lines(pid, file)
  local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/" .. file)
  return ok and lines or {}
end

local function process_info(pid)
  for _, line in ipairs(proc_lines(pid, "status")) do
    local ppid = line:match("^PPid:%s+(%d+)")
    if ppid then
      return tonumber(ppid), proc_lines(pid, "comm")[1] or ""
    end
  end

  -- macOS does not mount /proc.
  if vim.fn.executable("ps") == 1 then
    local result = vim.system({ "ps", "-p", tostring(pid), "-o", "ppid=", "-o", "comm=" }, { text = true }):wait()
    if result.code == 0 then
      local ppid, name = result.stdout:match("^%s*(%d+)%s+([^\n]+)")
      return tonumber(ppid), name or ""
    end
  end
end

local function ancestor_process_named(name)
  local pid = vim.fn.getpid()

  for _ = 1, 16 do
    local ppid, comm = process_info(pid)
    if comm and comm:find(name, 1, true) then
      return true
    end
    if not ppid or ppid <= 1 then
      return false
    end

    pid = ppid
  end

  return false
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil
    or (not (in_tmux or in_ssh) and ancestor_process_named("herdr"))

  if not (in_tmux or in_ssh or in_herdr) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1
  local has_macos = vim.fn.has("macunix") == 1
    and vim.fn.executable("pbcopy") == 1
    and vim.fn.executable("pbpaste") == 1

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines)
      if has_wayland then
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        vim.fn.system(cmd, lines)
      elseif has_macos then
        vim.fn.system({ "pbcopy" }, lines)
      end

      if vim.g.remote_clipboard_osc52 ~= false and vim.g.omarchy_remote_clipboard_osc52 ~= false then
        emit(lines)
      end
    end
  end

  local function paste(register)
    if not (has_wayland or has_macos) then
      return osc52.paste(register)
    end

    return function()
      local cmd = has_wayland and { "wl-paste", "--no-newline" } or { "pbpaste" }
      if has_wayland and register == "*" then
        cmd[#cmd + 1] = "--primary"
      end

      local lines = vim.fn.systemlist(cmd, "", 1)
      return vim.v.shell_error == 0 and lines or {}
    end
  end

  vim.g.clipboard = {
    name = "PortableRemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }
end

return M

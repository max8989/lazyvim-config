local root = arg[1] or vim.fn.getcwd()
local native_vim = vim
local count = 0

local function check(condition, message)
  assert(condition, message)
  count = count + 1
end

for _, path in ipairs(vim.fn.glob(root .. "/**/*.lua", false, true)) do
  local chunk, err = loadfile(path)
  check(chunk ~= nil, path .. ": " .. tostring(err))
end

local function platform(system, opts)
  opts = opts or {}
  _G.vim = {
    g = opts.globals or {},
    env = opts.env or {},
    uv = { os_uname = function() return { sysname = system } end },
    fn = {
      filereadable = function(path) return path == "/etc/NIXOS" and opts.nixos and 1 or 0 end,
      exepath = function() return opts.host or "" end,
      stdpath = function() return "/data/nvim" end,
      executable = function(path) return opts.executables and opts.executables[path] and 1 or 0 end,
    },
  }
  local module = dofile(root .. "/lua/config/platform.lua")
  module.setup()
  return vim.g, module.is_nixos()
end

local flags, nixos = platform("Linux", { nixos = true, globals = { python3_host_prog = "/nix/host" } })
check(flags.is_linux and not flags.is_mac and not flags.is_win and nixos, "NixOS detection")
check(flags.python3_host_prog == "/nix/host", "Nix's Python provider must be preserved")
flags, nixos = platform("Linux")
check(flags.is_linux and not nixos, "Arch Linux detection")
check(flags.python3_host_prog == nil, "System Python discovery must remain available")
flags = platform("Darwin", { executables = { ["/data/nvim/python/bin/python3"] = true } })
check(flags.is_mac and not flags.is_linux, "macOS detection")
check(flags.python3_host_prog == "/data/nvim/python/bin/python3", "macOS pynvim virtualenv")
flags = platform("Linux", {
  env = { NVIM_PYTHON3_HOST_PROG = "/custom/python" },
  executables = { ["/custom/python"] = true, ["/data/nvim/python/bin/python3"] = true },
})
check(flags.python3_host_prog == "/custom/python", "Explicit Python override takes priority")
flags = platform("Linux", { host = "/bin/nvim-python3", executables = { ["/bin/nvim-python3"] = true } })
check(flags.python3_host_prog == "/bin/nvim-python3", "Packaged Python host discovery")
_G.vim = native_vim

local native_osc52 = package.loaded["vim.ui.clipboard.osc52"]
local function clipboard(opts)
  local calls = { emits = 0, queries = 0, commands = {} }
  package.loaded["vim.ui.clipboard.osc52"] = {
    copy = function() return function() calls.emits = calls.emits + 1 end end,
    paste = function() return function() calls.queries = calls.queries + 1; return { "remote" } end end,
  }
  _G.vim = {
    g = opts.globals or {}, env = opts.env or {}, v = { shell_error = 0 },
    fn = {
      getpid = function() return 10 end,
      readfile = function() return {} end,
      has = function(name) return name == "macunix" and opts.mac and 1 or 0 end,
      executable = function(name) return opts.executables and opts.executables[name] and 1 or 0 end,
      system = function(cmd) calls.commands[#calls.commands + 1] = cmd; return "" end,
      systemlist = function(cmd) calls.commands[#calls.commands + 1] = cmd; return { "local clipboard" } end,
    },
    system = function(cmd)
      return { wait = function()
        return { code = 0, stdout = cmd[3] == "10" and "20 /usr/bin/nvim\n" or "1 /Applications/herdr\n" }
      end }
    end,
  }
  dofile(root .. "/lua/config/remote_clipboard.lua").setup()
  return vim.g.clipboard, calls
end

local provider, calls = clipboard({ env = {} })
check(provider == nil, "Local clipboard detection must remain native")
provider, calls = clipboard({
  env = { TMUX = "/tmux", WAYLAND_DISPLAY = "wayland-1" },
  executables = { ["wl-copy"] = true, ["wl-paste"] = true },
})
provider.copy["*"]({ "text" })
check(calls.commands[1][1] == "wl-copy" and calls.commands[1][5] == "--primary", "Wayland primary copy")
check(calls.emits == 1, "Remote copy must also emit OSC 52")
check(provider.paste["*"]()[1] == "local clipboard" and calls.commands[2][3] == "--primary", "Wayland primary paste")
provider, calls = clipboard({
  mac = true, env = { TMUX = "/tmux" }, executables = { pbcopy = true, pbpaste = true },
})
provider.copy["+"]({ "text" })
provider.paste["+"]()
check(calls.commands[1][1] == "pbcopy" and calls.commands[2][1] == "pbpaste", "macOS clipboard in tmux")
provider, calls = clipboard({ env = { SSH_CONNECTION = "remote" } })
provider.copy["+"]({ "text" })
check(provider.paste["+"]()[1] == "remote" and calls.queries == 1, "Headless SSH clipboard query")
check(calls.emits == 1 and #calls.commands == 0, "Headless SSH copy must use OSC 52")
provider, calls = clipboard({
  mac = true, env = {}, executables = { ps = true, pbcopy = true, pbpaste = true },
})
check(provider ~= nil, "Herdr ancestry must work on macOS without /proc")
provider, calls = clipboard({ env = { TMUX = "/tmux" }, globals = { remote_clipboard_osc52 = false } })
provider.copy["+"]({ "text" })
check(calls.emits == 0, "OSC 52 opt-out")

_G.vim = native_vim
package.loaded["vim.ui.clipboard.osc52"] = native_osc52
print("PASS: " .. count .. " Lua syntax and portability checks")

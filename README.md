# Personal LazyVim

My Omarchy LazyVim setup, extracted from `omarchy-configs/config/nvim` and
adapted for **NixOS, Arch Linux, and macOS**. It preserves the Nordfox theme,
personal bindings, snippets, completion, Git tools, Obsidian support, and
terminal behavior. Neovim 0.12 or newer and tree-sitter CLI 0.26.1 or newer
are required. Install the CLI through your OS package manager, rather than npm,
as required by the pinned tree-sitter plugin.

## Install

Install the dependencies for your OS below, then clone and link this repo:

```sh
git clone git@github.com:max8989/lazyvim-config.git ~/repos/lazyvim-config
cd ~/repos/lazyvim-config
./scripts/install.sh
nvim --headless '+Lazy! restore' '+luafile scripts/install-parsers.lua' +qa
nvim
```

The installer backs up existing config, plugin data, state, and cache with a
`.before-lazyvim.<timestamp>` suffix. Re-running it for the same checkout is
safe. Existing editor sessions should be restarted after switching.

To try it alongside your existing setup:

```sh
NVIM_APPNAME=nvim-lazyvim ./scripts/install.sh
NVIM_APPNAME=nvim-lazyvim nvim --headless '+Lazy! restore' '+luafile scripts/install-parsers.lua' +qa
NVIM_APPNAME=nvim-lazyvim nvim
```

Use `:Lazy restore` to install the committed plugin versions. Use `:Lazy update`
only when intentionally updating them, then commit `lazy-lock.json`.

## NixOS

The flake supplies Neovim with Python support and its external tools. Mason is
disabled on NixOS; the Lua language server, formatters, compiler, and parser
tools come from Nix instead of downloaded Linux binaries.

The regular NixOS `neovim` package can have its Python provider disabled. If
UltiSnips reports that Python is unavailable, launch through `nix develop`
below or install this flake's package permanently. Installing `pynvim` alone
does not enable a provider that the editor wrapper explicitly disables.

```sh
nix develop
./scripts/install.sh
nvim --headless '+Lazy! restore' '+luafile scripts/install-parsers.lua' +qa
nvim
```

After linking the config, `nix run .` also launches the packaged editor. For a
persistent installation, replace an existing plain Neovim package with this
flake's default package, or import its Home Manager module:

```nix
# In your flake's inputs; use the Git URL appropriate to your repository access.
lazyvim-config.url = "git+ssh://git@github.com/max8989/lazyvim-config?ref=main";

# In a Home Manager module:
imports = [ inputs.lazyvim-config.homeManagerModules.default ];
```

The module installs the editor and tools. Run the installer from a writable
checkout for the config itself, so `:Lazy` and `:LazyExtras` can save their
lockfile and settings. Remove another `neovim` entry from `home.packages` to
avoid installing two editor packages.

The flake provides Git, curl, unzip, a C compiler, make, ripgrep, fd, fzf,
tree-sitter, lua-language-server, StyLua, shfmt, Node.js, Python, tmux, lazygit,
and lazydocker. Linux also gets Wayland and X11 clipboard tools. Additional
language servers should be installed through Nix and enabled through LazyVim
extras or `lua/plugins/`.

Nix outputs cover x86_64/aarch64 Linux and Apple Silicon/Intel macOS. Intel
macOS uses a separate pinned nixpkgs 26.05 input because unstable has removed
its toolchain. The Homebrew setup below is also available on Intel Macs.

## Arch Linux

```sh
sudo pacman -Syu --needed neovim git base-devel curl unzip ripgrep fd fzf \
  tree-sitter-cli nodejs npm python python-pynvim lua-language-server \
  stylua shfmt tmux lazygit lazydocker
```

For Wayland, install `wl-clipboard`; for X11, install `xclip`. Mason remains
available for additional language tools on Arch.
The system Lua language server is preferred when it is installed.

## macOS

Install the Xcode Command Line Tools (`xcode-select --install`) and Homebrew,
then:

```sh
brew install neovim git ripgrep fd fzf tree-sitter node uv \
  lua-language-server stylua shfmt tmux lazygit lazydocker
uv venv --python python3 "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/python"
uv pip install --python "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/python/bin/python3" pynvim
```

For the separate preview profile, replace `/nvim/python` with
`/nvim-lazyvim/python`. Both Apple Silicon and Intel Macs use this setup.
Mason remains available on macOS. Local copying uses the native clipboard;
inside tmux, pasting uses `pbpaste` and copying also emits OSC 52.
The Homebrew Lua language server is used directly.

## Personal settings

- Space is the leader. `<leader>gg` opens lazygit at the project root,
  `<leader>gG` uses the current directory, and `<leader>lg` is the personal
  lazygit shortcut. `<leader>ff` / Ctrl-P find files; `<leader>fg` searches text.
- `<leader>ld` opens lazydocker. Terminal sessions use Neovim's selected shell.
- UltiSnips uses `my_snippets/` and requires a working Python provider. A
  provider supplied by a Nix wrapper takes priority; otherwise the config
  checks `NVIM_PYTHON3_HOST_PROG`, `nvim-python3` on PATH, and the profile's
  `python/bin/python3` before leaving system discovery enabled.
- Set `OBSIDIAN_VAULT` to override `~/Documents/obsidian`. Optional LaTeX
  support activates when `latex` is installed.
- Local clipboard providers are detected by Neovim. SSH, tmux, and Herdr
  sessions use OSC 52 copying, with local Wayland/macOS paste when available.
  Set `vim.g.remote_clipboard_osc52 = false` to disable OSC 52 emission.
- The copied Nordfox theme works independently of Omarchy. The retained
  hot-reload hook also works when an Omarchy installation updates the theme.
- See [cheat-sheet.md](cheat-sheet.md) for the remaining personal bindings.

## Verification

```sh
nvim --headless -u NONE -l tests/portability.lua .
bash tests/install.sh
nix flake check
```

The checks parse every Lua file and exercise NixOS/Arch/macOS detection,
Python-provider selection, Wayland/macOS clipboard handling, SSH fallback,
and macOS process ancestry without touching the real clipboard. After
installing, also run `:checkhealth` and `:checkhealth provider`, open a Lua
file to check the language server, and verify your terminal's clipboard.
After restoring plugins, `nvim --headless '+luafile tests/startup.lua' +qa`
checks startup, Python, snippets, completion, mappings, and Lua LSP attachment.
GitHub Actions runs portability, installer, and full editor startup checks on
Ubuntu, Arch Linux, and macOS. The Nix package and full startup are also
verified locally on NixOS.

## Upstream references

The configuration follows the documented LazyVim layout and plugin override
mechanism. Its lazygit shortcuts follow LazyVim and Omarchy conventions:

- [LazyVim configuration](https://www.lazyvim.org/configuration)
- [LazyVim plugin overrides](https://www.lazyvim.org/configuration/plugins)
- [LazyVim keymaps](https://www.lazyvim.org/keymaps)
- [Omarchy Neovim manual](https://github.com/omacom/omarchy/blob/quattro/manual/16-neovim.md)
- [Omarchy TUIs manual](https://github.com/omacom/omarchy/blob/quattro/manual/21-tuis.md)
- [Neovim providers](https://neovim.io/doc/user/provider.html)
- [Pinned tree-sitter setup](https://github.com/nvim-treesitter/nvim-treesitter/blob/a1bcffc8095c142ad1f7a9671a4ae180333f9209/README.md)

Original starter licensing and source attribution are retained in
[LICENSE](LICENSE) and [NOTICE](NOTICE).

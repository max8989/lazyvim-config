{
  description = "Portable personal LazyVim configuration and Nix-managed tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # Unstable no longer has an Intel macOS stdenv. This branch still supplies
  # Neovim 0.12 and native tools for those machines.
  inputs.nixpkgs-darwin-intel.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

  outputs = { self, nixpkgs, nixpkgs-darwin-intel }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system:
        import (if system == "x86_64-darwin" then nixpkgs-darwin-intel else nixpkgs) { inherit system; };
      toolsFor = pkgs: with pkgs; [
        git
        curl
        unzip
        stdenv.cc
        gnumake
        ripgrep
        fd
        fzf
        tree-sitter
        lua-language-server
        stylua
        shfmt
        nodejs
        python3
        tmux
        lazygit
        lazydocker
      ] ++ lib.optionals stdenv.hostPlatform.isLinux [ wl-clipboard xclip ];
    in {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          editor = pkgs.neovim.override { withPython3 = true; };
        in {
          default = pkgs.symlinkJoin {
            name = "personal-lazyvim-${editor.version}";
            paths = [ editor ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/nvim --prefix PATH : ${pkgs.lib.makeBinPath (toolsFor pkgs)}
            '';
            meta.mainProgram = "nvim";
          };
        });

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = [ self.packages.${system}.default ];
        };
      });

      checks = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          portability = pkgs.runCommand "lazyvim-portability" {
            nativeBuildInputs = [ (pkgs.neovim.override { withPython3 = true; }) ];
          } ''
            export XDG_CONFIG_HOME="$TMPDIR/config"
            export XDG_DATA_HOME="$TMPDIR/data"
            export XDG_STATE_HOME="$TMPDIR/state"
            export XDG_CACHE_HOME="$TMPDIR/cache"
            nvim --headless -u NONE -l ${self}/tests/portability.lua ${self}
            bash ${self}/tests/install.sh ${self}
            touch "$out"
          '';
        });

      # The config stays in a writable Git checkout so :Lazy and :LazyExtras
      # can update their JSON files. This module supplies only the editor/tools.
      homeManagerModules.default = { pkgs, ... }: {
        home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      };
    };
}

{
  description = "Flake for nvim config (LazyVim, tools provided by Nix instead of Mason)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      mkNeovim = pkgs:
        let
          # Everything Mason would have installed, from nixpkgs instead.
          # Add tools here when enabling a new LazyVim extra.
          runtimeDeps = with pkgs; [
            # core tooling LazyVim expects
            git
            ripgrep
            fd
            fzf
            lazygit
            curl

            # treesitter grammars are compiled at runtime
            gcc
            tree-sitter

            # lua
            lua-language-server
            stylua

            # nix
            nil
            nixd
            nixfmt-rfc-style

            # go
            go
            gopls
            gofumpt
            gotools # goimports etc.
            delve

            # python
            pyright
            ruff

            # rust
            rustc
            cargo
            rust-analyzer
            rustfmt
            clippy
            taplo # TOML LSP (Cargo.toml)
            lldb # provides lldb-dap for debugging via rustaceanvim

            # typescript / svelte / web
            nodejs
            vtsls
            svelte-language-server
            vscode-langservers-extracted # jsonls, html, css, eslint
            prettier

            # markdown
            marksman
            markdownlint-cli2

            # shell
            shellcheck
            shfmt
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            wl-clipboard
          ];
          # The Lua config itself, copied into the store.
          config = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [
              ./init.lua
              ./lua
              ./lazy-lock.json
              ./lazyvim.json
            ];
          };
        in
        pkgs.symlinkJoin {
          name = "neovim-zilch";
          paths = [ pkgs.neovim ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
              --add-flags "-u ${config}/init.lua"
          '';
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkNeovim nixpkgs.legacyPackages.${system};
      });

      # Optional: use as an overlay to get `pkgs.neovim-zilch`
      overlays.default = final: prev: {
        neovim-zilch = mkNeovim final;
      };

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nvim";
        };
      });
    };
}

{
  description = "Flake for nvim config";
  inputs = {
      nixpkgs = {
          url = "github:Nixos/nixpkgs";
        };
    };
  outputs = { nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowBroken = true; };
    inherit (pkgs) lib;
    neovim = pkgs.neovim.overrideAttrs (oldAttrs: let
      runtimeDepencies = with pkgs; [
        git

        wl-clipboard
        lua-language-server
        nixd
        gopls
        go

        lua51Packages.luarocks-nix
        lua51Packages.magick
        lua5_1
      ];
    in {
      pname = "neovim-zilch";
      nativeBuildInputs = 
        (oldAttrs.nativeBuildInputs or [])
        ++ runtimeDepencies;
      
      installPhase = 
        (oldAttrs.installPhase or "")
        + (
          runtimeDepencies
          |> map (x: "ln -s ${x.out}/bin/* $out/bin")
          |> lib.concatStringsSep "\n"
        );
      postFixup = ''
        wrapProgram $out/bin/nvim \
          --prefix PATH : ${pkgs.lib.makeBinPath runtimeDepencies}
          --set DOTNET_CLI_TELEMETRY_OPTOUT 1
      '';
      }
    );
    in 
    {
        packages.x86_64-linux.default = neovim;
        apps.x86_64-linux.default = {
            type = "app";
            program = "${neovim}/bin/nvim";
            dependencies = with pkgs; [ gcc ];
          };
      };
  }










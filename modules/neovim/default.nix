{ lib, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.neovim-nvf =
        let
          statix-fix = pkgs.statix.overrideAttrs (_: rec {
            src = pkgs.fetchFromGitHub {
              owner = "oppiliappan";
              repo = "statix";
              rev = "43681f0da4bf1cc6ecd487ef0a5c6ad72e3397c7";
              hash = "sha256-LXvbkO/H+xscQsyHIo/QbNPw2EKqheuNjphdLfIZUv4=";
            };
            cargoDeps = pkgs.rustPlatform.importCargoLock {
              lockFile = src + "/Cargo.lock";
              allowBuiltinFetchGit = true;
            };
          });

          customPkgs = pkgs.extend (_: _: { statix = statix-fix; });
        in
        pkgs.callPackage (
          {
            dots ? null,
            host ? "xenomorph",
          }:
          (inputs.nvf.lib.neovimConfiguration {
            pkgs = customPkgs;
            modules = lib.pipe ./. [
              builtins.readDir
              (lib.filterAttrs (
                name: type:
                type == "regular" && lib.hasPrefix "_" name && lib.hasSuffix ".nix" name && name != "_helpers.nix"
              ))
              (lib.mapAttrsToList (name: _: ./. + "/${name}"))
            ];
            extraSpecialArgs = { inherit dots host; };
          }).neovim
        ) { };
    };

  flake.modules.nixos.programs_neovim =
    { config, pkgs, ... }:
    let
      customNeovim = pkgs.custom.neovim-nvf.override {
        inherit (config.custom.constants) dots host;
      };
      nvim-direnv = pkgs.writeShellApplication {
        name = "nvim-direnv";
        runtimeInputs = [ pkgs.direnv ];
        text = /* sh */ ''
          if ! direnv exec "$(dirname "$1")" nvim "$@"; then
            nvim "$@"
          fi
        '';
      };
      nvim-desktop-entry = pkgs.makeDesktopItem {
        name = "Neovim";
        desktopName = "Neovim";
        genericName = "Text Editor";
        icon = "nvim";
        terminal = true;
        # load direnv before opening nvim
        exec = ''${lib.getExe nvim-direnv} "%F"'';
      };
    in
    {
      environment = {
        systemPackages = [
          customNeovim
          nvim-direnv
          # add the new desktop entry
          (lib.hiPrio nvim-desktop-entry)
        ];
      };

      xdg = {
        mime = {
          defaultApplications = {
            "text/plain" = "nvim.desktop";
            "text/markdown" = "nvim.desktop";
            "text/x-nix" = "nvim.desktop";
            "application/x-shellscript" = "nvim.desktop";
            "application/xml" = "nvim.desktop";
          };
          addedAssociations = {
            "text/csv" = "nvim.desktop";
          };
        };
      };

      custom.programs.print-config = rec {
        neovim = /* sh */ "nvf-print-config | moor --lang lua";
        nvf = neovim;
      };

      custom.persist = {
        home.directories = [
          ".local/share/nvim" # data directory
          ".local/state/nvim" # persistent session info
          ".supermaven"
          ".local/share/supermaven"
        ];
      };
    };
}

{ pkgs, config, ... }:
let
  inherit (config.home) homeDirectory;
in
{
  home.packages = [
    (import ./noctalia-start.nix { inherit pkgs; })
    (import ./noctalia-restart.nix { inherit pkgs; })
    (import ./emopicker9000.nix { inherit pkgs; })
    (import ./keybinds.nix { inherit pkgs; })
    (import ./task-waybar.nix { inherit pkgs; })
    (import ./wallsetter.nix {
      inherit pkgs homeDirectory;
    })
    (import ./web-search.nix { inherit pkgs; })
    (import ./rofi-launcher.nix { inherit pkgs; })
    (import ./screenshootin.nix { inherit pkgs; })
    (import ./pwvucontrol-toggle.nix { inherit pkgs; })
    (import ./launch-webapp.nix { inherit pkgs; })
    (import ./zoom-launcher.nix { inherit pkgs; })
    (import ./hypr-suspend-fix.nix { inherit pkgs; })
    (import ./replace-string.nix { inherit pkgs; })

    # Dependencies
    pkgs.hyprshot
    pkgs.hyprcap
    pkgs.satty
    pkgs.slurp
  ];
}

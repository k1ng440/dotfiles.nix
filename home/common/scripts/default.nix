{ pkgs, config, ... }:
let
  inherit (config.home) homeDirectory;
in
{
  home.packages = [
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
    (import ./kdegamemode.nix { inherit pkgs; })

    # Dependencies
    pkgs.hyprshot
    pkgs.satty
    pkgs.slurp
  ];
}

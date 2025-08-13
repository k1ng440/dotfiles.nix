# Add your reusable home-manager modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
{ pkgs, inputs, ... }:
{
  imports = [
    ./emoji.nix
    ./git.nix
    ./kitty.nix
    ./ghostty.nix
    ./starship.nix
    ./virtmanager.nix
    ./cursor.nix
    ./rofi
    ./wofi
    ./wayland
    ./fastfetch
    ./scripts
    ./mime.nix
    ./user-directories.nix
    ./terminal-applications.nix
    ./desktop-entries.nix
  ];

  home.packages = [
    (import ./sway-open { inherit pkgs; })
  ];

  disabledModules = [
    "${inputs.stylix}/modules/neovim/hm.nix"
    "${inputs.stylix}/modules/lazygit/hm.nix"
    "${inputs.stylix}/modules/nvim/hm.nix"
    "${inputs.stylix}/modules/waybar/hm.nix"
    "${inputs.stylix}/modules/rofi/hm.nix"
    # "${inputs.stylix}/modules/sway/hm.nix"
    "${inputs.stylix}/modules/hyprland/hm.nix"
    "${inputs.stylix}/modules/hyprlock/hm.nix"
    "${inputs.stylix}/modules/hyprlock/hm.nix"
  ];
}

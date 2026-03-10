# Add your reusable home-manager modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./ime.nix
    ./emoji.nix
    ./git.nix
    ./kitty.nix
    ./ghostty.nix
    ./starship.nix
    ./virtmanager.nix
    ./cursor.nix
    ./qt.nix
    ./gtk.nix
    ./rofi
    ./wofi
    ./wayland
    ./fastfetch
    ./scripts
    ./mime.nix
    ./user-directories.nix
    ./terminal-applications.nix
    ./desktop-entries.nix
    ./wine.nix
  ];

  home.packages = [
    (import ./sway-open { inherit pkgs; })
  ];
}

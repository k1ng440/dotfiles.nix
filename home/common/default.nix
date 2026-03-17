# Add your reusable home-manager modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
{ pkgs, ... }:
{
  imports = [
    ./emoji.nix
    ./git.nix
    ./kitty.nix
    ./starship.nix
    ./virtmanager.nix
    ./rofi
    ./wofi
    ./wayland
    ./fastfetch
    ./gaming
    ./scripts
    ./mime.nix
    ./qt.nix
    ./gtk.nix
    ./user-directories.nix
    ./terminal-applications.nix
    ./desktop-entries.nix
    ./wine.nix
    ./thunar.nix
  ];

  home.packages = [
    (import ./sway-open { inherit pkgs; })
  ];
}

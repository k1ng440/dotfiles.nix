{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    dnsutils
    git
    htop
    home-manager
    tree
    inetutils
    ledger-udev-rules # Ledger Hardwawre
    SDL2 # SDL2 compatibility layer
    wayland
    wayland-protocols
    libxkbcommon
    libdecor
    libGL
  ];

  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];
}

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
    SDL2 # SDL2 compatibility layer
    libdecor
    libGL
  ];

  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];

}

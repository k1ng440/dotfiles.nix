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
  ];

  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];
}

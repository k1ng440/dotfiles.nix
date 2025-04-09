{ pkgs, ... }:
{
  # Common linux packages
  environment.systemPackages = with pkgs; [
    curl
    dnsutils
    git
    htop
    home-manager
    tree
    inetutils
  ];

  # List of available shells
  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];
}

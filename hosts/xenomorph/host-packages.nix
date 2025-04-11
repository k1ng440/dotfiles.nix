{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    curl
    dnsutils
    git
    htop
    home-manager
    tree
    inetutils
  ];

  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];
}

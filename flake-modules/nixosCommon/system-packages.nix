{pkgs}: {
  # Common linux packages
  environment.systemPackages = with pkgs; [
    bat
    bottom
    curl
    dnsutils
    git
    htop
    httpie
    jq
    ripgrep
  ];

  # List of available shells
  environment.shells = with pkgs; [bash zsh fish];
}

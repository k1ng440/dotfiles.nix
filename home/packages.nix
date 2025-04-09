{pkgs, ...}: {
  home.packages = with pkgs; [
    fzf
    trash-cli
    ripgrep
    jq
    bottom
    bat
    nh
  ];
}

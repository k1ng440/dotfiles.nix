{...}: {
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../../home/common.nix
    ../../home/fzf
    ../../home/zsh
    ../../home/nvim
    ../../home/git.nix
    ../../home/devops.nix
    ../../home/fd.nix
    ../../home/ghostty
    ../../home/lazygit
  ];
}

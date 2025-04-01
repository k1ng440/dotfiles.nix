{ ... }:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../../home/common.nix
    ../../home/nvim
    ../../zsh.nix
    ../../git.nix
    ../../devops.nix
    ../../fd.nix
    ../../fzf
    ../../ghostty
    # other inputs
  ];
}

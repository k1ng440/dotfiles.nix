{ pkgs, ... }:
{
  home.packages = with pkgs; [
    subversionClient
    pre-commit
    gnumake # make
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # better than native direnv nix functionality - https://github.com/nix-community/nix-direnv
  };
}

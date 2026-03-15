{ pkgs, ... }:
{
  programs = {
    enable = true;
    package = pkgs.imv;
    settings = {
    };
  };
}

{ pkgs, lib, ... }:
{
  programs.starship = {
    enable = lib.mkDefault true;
    package = pkgs.starship;
  };
}

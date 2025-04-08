{ pkgs, ... }:
{
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];
}

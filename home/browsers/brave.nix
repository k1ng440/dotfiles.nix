{ inputs, pkgs, ... }:
{
  programs.brave = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.brave;
    commandLineArgs = [
      "--no-default-browser-check"
      "--restore-last-session"
    ];
  };
}

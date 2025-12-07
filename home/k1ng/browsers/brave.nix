{ inputs, pkgs, ... }:
{
  programs.brave = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.brave;
    commandLineArgs = [
      "--no-default-browser-check"
      "--restore-last-session"
    ];
  };
}

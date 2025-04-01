{
  variables,
  nixpkgs-unstable,
  inputs,
  theme,
  nixos-hardware,
  zen-browser,
  rawNvimPlugins,
}: let
  x64System = "x86_64-linux";
in {
  x64System = x64System;
  x64SpecialArgs = {
    inherit
      variables
      inputs
      theme
      nixos-hardware
      zen-browser
      rawNvimPlugins
      ;

    system = x64System;
    username = variables.username;
    timeZone = variables.timeZone;

    pkgs-unstable = import nixpkgs-unstable {
      system = x64System;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [];
      overlays = [];
    };
  };
}

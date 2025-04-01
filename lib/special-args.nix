{
  variables,
  nixpkgs-unstable,
  inputs,
  rawNvimPlugins,
}: let
  x64System = "x86_64-linux";
in {
  x64System = x64System;
  x64SpecialArgs = {
    inherit variables inputs rawNvimPlugins;

    system = x64System;
    username = variables.username;

    pkgs-unstable = import nixpkgs-unstable {
      system = x64System;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [];
      overlays = [];
    };
  };
}

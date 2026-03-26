{
  inputs,
  lib,
  self,
  ...
}:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          self.overlays.default
          # self.overlays.pkgsCustom
          # self.overlays.pkgsPatches
          # self.overlays.writeShellApplicationCompletions
        ];
      };
    in
    {
      # initialize the pkgs for perSystem to be the patched nixpkgs
      _module.args = { inherit pkgs; };

      formatter = lib.mkDefault pkgs.nixfmt;
    };

  flake = {
    config.overlays = import ../overlays { inherit inputs; };

    options = {
      patches = lib.mkOption {
        type = lib.types.anything;
        default = [ ];
        description = "Patches to be applied onto nixpkgs";
      };

      wrapperModules = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Wrapper modules";
      };

      libCustom = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Custom library functions / utilities";
      };
    };
  };
}

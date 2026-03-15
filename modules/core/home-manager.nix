{
  config,
  npins,
  inputs,
  outputs,
  isNixOS,
  lib,
  ...
}:
let
  platform = if isNixOS then "nixos" else "darwin";
  platformModules = "${platform}Modules";
  userHomeConfig = lib.custom.relativeToRoot "home/${config.machine.username}/${config.machine.hostname}.nix";
in
{
  imports = [
    inputs.home-manager.${platformModules}.home-manager
  ];

  # Home manager configuration - evaluated lazily
  home-manager =
    lib.mkIf
      (
        inputs ? "home-manager" && !config.machine.computed.isMinimal && builtins.pathExists userHomeConfig
      )
      {
        backupFileExtension = "backup";
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit
            npins
            inputs
            outputs
            isNixOS
            ;
          inherit (config) machine;
          isHomeManager = true;
        };
        users.${config.machine.username} = {
          imports = [
            userHomeConfig
          ];
        };
      };
}

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
  machineDefined = config ? "machine" && config.machine ? "username" && config.machine ? "hostname";
  userHomeConfig = lib.custom.relativeToRoot "home/${config.machine.username}/${config.machine.hostname}.nix";
in
{
  imports = [
    inputs.home-manager.${platformModules}.home-manager
  ];

  home-manager = lib.mkIf machineDefined {
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

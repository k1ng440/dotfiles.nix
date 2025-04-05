{
  self,
  inputs,
  ...
}: {
  perSystem = {
    self',
    pkgs,
    ...
  }: let
    inherit (inputs) nixos-generators;

    defaultModule = {...}: {
      imports = [
        inputs.disko.nixosModules.disko
        ./base-iso.nix
      ];
      _module.args.self = self;
      _module.args.inputs = inputs;
    };
  in {
    packages = {
      xenomorph-iso-image = nixos-generators.nixosGenerate {
        inherit pkgs;
        format = "install-iso";
        modules = [
          defaultModule
          (
            {
              config,
              lib,
              pkgs,
              ...
            }: let
              # disko
              disko = pkgs.writeShellScriptBin "disko" ''${config.system.build.disko}'';
              disko-mount = pkgs.writeShellScriptBin "disko-mount" "${config.system.build.mountScript}";
              disko-format = pkgs.writeShellScriptBin "disko-format" "${config.system.build.formatScript}";

              # system
              system = self.nixosConfigurations.xenomorph.config.system.build.toplevel;

              install-system = pkgs.writeShellScriptBin "install-system" ''
                set -euo pipefail

                echo "Formatting disks..."
                . ${disko-format}/bin/disko-format

                echo "Mounting disks..."
                . ${disko-mount}/bin/disko-mount

                echo "Installing system..."
                nixos-install --system ${system}

                echo "Done!"
              '';
            in {
              imports = [
                # TODO: Figure out how to set this disk with hostname or something
                ../hosts/xenomorph/disko.nix
              ];

              # we don't want to generate filesystem entries on this image
              disko.enableConfig = lib.mkDefault false;

              # add disko commands to format and mount disks
              environment.systemPackages = [
                disko
                disko-mount
                disko-format
                install-system
              ];
            }
          )
        ];
      };
    };
  };
}

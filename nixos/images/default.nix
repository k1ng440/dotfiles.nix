{
  self,
  inputs,
  withSystem,
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
        ../modules/fish.nix
        ./base-iso.nix
      ];
      _module.args.self = self;
      _module.args.inputs = inputs;
    };
  in {
    packages = {
      # nix build .#xenomorph-iso-image
      xenomorph-iso-image = nixos-generators.nixosGenerate {
        pkgs = pkgs;
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
              disko = pkgs.writeShellScriptBin "disko" ''${config.system.build.diskoScript}'';
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

              users.users.nixos = {
                isNormalUser = true;
                extraGroups = ["wheel"];
                hashedPassword = "$y$j9T$UExSwLltSqOgCfYBEt7sa.$d/a68xX7TnHlNxxD2LttItl.gSMGFgVQApgKQXN/mh4";
              };
              security.sudo.wheelNeedsPassword = false;
              users.users.root.hashedPassword = "$y$j9T$UExSwLltSqOgCfYBEt7sa.$d/a68xX7TnHlNxxD2LttItl.gSMGFgVQApgKQXN/mh4";
              users.mutableUsers = false;
              users.users.root.openssh.authorizedKeys.keys = [
                "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBKYBN4nrD/zxmIuuXvwqU3lqJPvjIHDs2fXOvq9ZKaglkNCK2p223siEMmOhN7qPZ+JKVPo0/oOrEQ8y/ovVbFgAAAAEc3NoOg== contact@iampavel.dev"
              ];
            }
          )
        ];
      };
    };
  };
}

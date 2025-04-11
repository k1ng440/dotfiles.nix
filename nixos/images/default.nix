{
  self,
  inputs,
  withSystem,
  ...
}:
{
  perSystem =
    {
      self',
      pkgs,
      ...
    }:
    let
      inherit (inputs) nixos-generators;

      defaultModule =
        { ... }:
        {
          imports = [
            inputs.disko.nixosModules.disko
            ../modules/fish.nix
            ./base-iso.nix
          ];
          _module.args.self = self;
          _module.args.inputs = inputs;
        };
    in
    {
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
              }:
              let
                # disko
                disko = pkgs.writeShellScriptBin "disko" "${config.system.build.diskoScript}";
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
              in
              {
                imports = [ ../hosts/xenomorph/disko.nix ];

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
                  extraGroups = [ "wheel" ];
                  hashedPassword = "$y$j9T$UExSwLltSqOgCfYBEt7sa.$d/a68xX7TnHlNxxD2LttItl.gSMGFgVQApgKQXN/mh4";
                  # openssh = {
                  #     authorizedKeys = lib.mkForce [
                  #       "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqMh6k4NRNF4MzW/RYXlQ2FzFHkDE3rL3UuWT91ZzYK6oybFW2dXugxxHXA0a5d6jU4sToBB0zYLqCyCfb0rEJ+ukN0LIC+IJ2MVb7b7WSJyju0PeJqri1tice2quZO8C27rbYEMa1QgpUapDhEuNfFnDkXzkr0NnxOs2vwOdnGRm3VF1FRaV/0xmmJDeh8GmHdj40StH/UtNU63YvsTY1DJHb6Tw3O0hY4cvxx3z3SZv18bDDfn6EA/47Ao6BO88bT/b3qhmoQc55ESWX5siUk4/BtgEgQNuqZm8rxhRmW4NqdsWbLIwHdJCVn51DwokykP1A9x1QEAQRw5yqRy0fQ== rsa-key-20151130"
                  #     ];
                  #   };
                };
                security.sudo.wheelNeedsPassword = false;
                users.users.root.hashedPassword = "$y$j9T$UExSwLltSqOgCfYBEt7sa.$d/a68xX7TnHlNxxD2LttItl.gSMGFgVQApgKQXN/mh4";
                users.mutableUsers = false;
                users.users.root.openssh.authorizedKeys.keys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqMh6k4NRNF4MzW/RYXlQ2FzFHkDE3rL3UuWT91ZzYK6oybFW2dXugxxHXA0a5d6jU4sToBB0zYLqCyCfb0rEJ+ukN0LIC+IJ2MVb7b7WSJyju0PeJqri1tice2quZO8C27rbYEMa1QgpUapDhEuNfFnDkXzkr0NnxOs2vwOdnGRm3VF1FRaV/0xmmJDeh8GmHdj40StH/UtNU63YvsTY1DJHb6Tw3O0hY4cvxx3z3SZv18bDDfn6EA/47Ao6BO88bT/b3qhmoQc55ESWX5siUk4/BtgEgQNuqZm8rxhRmW4NqdsWbLIwHdJCVn51DwokykP1A9x1QEAQRw5yqRy0fQ== rsa-key-20151130"
                  "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBKYBN4nrD/zxmIuuXvwqU3lqJPvjIHDs2fXOvq9ZKaglkNCK2p223siEMmOhN7qPZ+JKVPo0/oOrEQ8y/ovVbFgAAAAEc3NoOg== contact@iampavel.dev"
                ];
              }
            )
          ];
        };
      };
    };
}

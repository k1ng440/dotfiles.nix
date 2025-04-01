{
  host,
  disko,
  nixpkgs,
  nixos-generators,
  lib,
  system,
  variables,
  theme,
  ...
}: let
  defaultModule = {...}: {
    imports = [
      disko.nixosModules.disko
      ./base-iso.nix
    ];
  };

  isoDotfilesLocation = builtins.toPath "/boot/dotfiles";
in
  nixos-generators.nixosGenerate {
    inherit system;
    specialArgs = {
      inherit variables theme;
    };

    modules = [
      defaultModule
      (
        {
          config,
          lib,
          pkgs,
          ...
        }: let
          disko = pkgs.writeShellScriptBin "disko" ''${config.system.build.diskoScript}'';
          disko-mount = pkgs.writeShellScriptBin "disko-mount" "${config.system.build.mountScript}";
          disko-format = pkgs.writeShellScriptBin "disko-format" "${config.system.build.formatScript}";

          # This is a bit of a hack, but it works
          mntDotfilesLocation = (builtins.toPath "/mnt") + variables.dotfilesLocation;
          actualIsoDotfilesLocation = (builtins.toPath "/iso") + isoDotfilesLocation;

          install-system = pkgs.writeShellScriptBin "install-system" ''
            set -euo pipefail

            echo "Formatting disks"
            . ${disko-format}/bin/disko-format

            echo "Mounting disks"
            . ${disko-mount}/bin/disko-mount

            echo "Installing system"
            nixos-install --root /mnt --flake ${actualIsoDotfilesLocation}#${host.name} -j 4

            echo "Copying dotfiles"
            mkdir -p ${mntDotfilesLocation}
            cp -r ${actualIsoDotfilesLocation}/* ${mntDotfilesLocation}

            echo "Setting permissions"
            nixos-enter --root /mnt -c "cd ${variables.dotfilesLocation}; sudo chown -R ${variables.username}:users ${variables.homeDirectory.path}"

            echo "Executing home-manager"
            echo "This might fail, but it's fine"
            echo "If it does, just run it manually after booting into the system"

            nixos-enter --root /mnt -c "cd ${variables.dotfilesLocation}; nixos-rebuild switch --flake .#${host.name}"

            echo "Done"
          '';
        in {
          imports = [
            host.disko
          ];

          disko.enableConfig = lib.mkDefault false;

          users.motd = ''
            ** Welcome to the NixOS Live Environment! **

            * Welcome to your Custom NixOS Live Environment!
            * Run `sudo install-system` to install NixOS using your flake config.
            * The default users "nixos" and "root" have no password.
            * To connect via Wi-Fi:
              sudo systemctl start wpa_supplicant
              sudo wpa_cli

            * See your dotfiles at: ${actualIsoDotfilesLocation}
          '';

          environment.systemPackages = [
            disko
            disko-mount
            disko-format
            install-system
          ];
        }
      )
    ];

    customFormats = {
      nix-live-iso = {
        imports = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];

        isoImage = {
          squashfsCompression = "zstd -Xcompression-level 3";
          contents = [
            {
              source = ../..;
              target = isoDotfilesLocation;
            }
          ];
        };

        # override installation-cd-base and enable wpa and sshd start at boot
        systemd.services.wpa_supplicant.wantedBy = lib.mkForce ["multi-user.target"];

        formatAttr = "isoImage";
        fileExtension = ".iso";
      };
    };

    format = "nix-live-iso";
  }

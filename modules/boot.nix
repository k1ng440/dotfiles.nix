{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      drv =
        { stdenvNoCC, fetchurl, ... }:
        stdenvNoCC.mkDerivation {
          pname = "distro-grub-themes-nixos";
          version = "3.2";
          src = fetchurl {
            url = "https://github.com/AdisonCavani/distro-grub-themes/releases/download/v3.2/nixos.tar";
            hash = "sha256-oW5DxujStieO0JsFI0BBl+4Xk9xe+8eNclkq6IGlIBY";
          };
          unpackPhase = "mkdir $out && tar -xvf $src -C $out";
        };
    in
    {
      packages.distro-grub-themes-nixos = pkgs.callPackage drv { };
    };

  flake.modules.nixos.core =
    { config, ... }:
    {
      # Bootloader.
      boot = {
        # kernelPackages = pkgs.linuxPackages_zen;
        kernelModules = [ "v4l2loopback" ];
        extraModulePackages = [
          # Kernel 6.18 make modules_install runs depmod, which leaves
          # modules.alias/modules.dep in the package and collides with the
          # kernel's own modules tree in aggregateModules.
          (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              rm -f $out/lib/modules/*/modules.*
            '';
          }))
        ];
        supportedFilesystems.ntfs = true;

        initrd = {
          # always allow booting from usb
          availableKernelModules = [ "uas" ];
        };

        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
          grub = {
            enable = true;
            devices = [ "nodev" ];
            efiSupport = true;
            gfxmodeEfi = "1024x768"; # Extremely slow otherwise
            # theme = pkgs.custom.distro-grub-themes-nixos;
          };
          timeout = 3;
        };

        kernelParams = [
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];

        kernel.sysctl = {
          "kernel.sysrq" = 1;
          "vm.max_map_count" = 2147483642;
        };

        tmp.cleanOnBoot = true;
      };

      # faster boot times
      systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

      # reduce journald logs
      services.journald.settings.Journal.SystemMaxUse = "50M";
    };
}

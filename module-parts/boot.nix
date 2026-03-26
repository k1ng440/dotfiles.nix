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
    { config, pkgs, ... }:
    {
      # Bootloader.
      boot = {
        kernelPackages = pkgs.linuxPackages_zen;
        kernelModules = [ "v4l2loopback" ];
        extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
        supportedFilesystems.ntfs = true;

        initrd = {
          # enable stage-1 bootloader
          systemd.enable = true;
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
            theme = pkgs.custom.distro-grub-themes-nixos;
          };
          timeout = 3;
        };

        kernelParams = [
          "splash"
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
      services.journald.extraConfig = "SystemMaxUse=50M";
    };
}

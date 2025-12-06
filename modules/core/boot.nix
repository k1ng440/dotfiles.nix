{ pkgs, config, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      timeout = 0;
    };

    initrd.verbose = false;

    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    kernelParams = [
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    # Set the same sysctl settings as are set on SteamOS
    kernel.sysctl = {

      "kernel.sysrq" = 1;
      "vm.max_map_count" = 2147483642;
    };

  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}

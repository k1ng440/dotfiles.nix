{
  pkgs,
  config,
  lib,
  ...
}:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = config.machine.boot.bootloader == "systemd-boot";
      grub.enable = config.machine.boot.bootloader == "grub";
      systemd-boot.configurationLimit = 5;

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      timeout = 0;
    };

    consoleLogLevel = if config.machine.boot.quietBoot then 3 else 4;
    initrd.verbose = !config.machine.boot.quietBoot;

    plymouth = {
      enable = config.machine.boot.quietBoot;
      theme = lib.mkForce "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    kernelParams = [
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ]
    ++ lib.optionals config.machine.boot.quietBoot [
      "quiet"
    ];

    # Set the same sysctl settings as are set on SteamOS
    kernel.sysctl = {

      "kernel.sysrq" = 1;
      "vm.max_map_count" = 2147483642;
    };

    tmp.cleanOnBoot = true;
  };
}

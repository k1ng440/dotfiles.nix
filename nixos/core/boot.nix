{ pkgs, ... }:
let
  theme = "hexagon_dots";
in {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;

    plymouth = {
      inherit theme;
      enable = true;
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ theme ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

  };
  systemd.services.plymouth-quit.after = [ "greetd.service" "graphical.target" ];
}

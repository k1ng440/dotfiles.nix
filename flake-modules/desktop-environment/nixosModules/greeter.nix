{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe;
in {
  # Create the greeter user
  users.users.greeter = {
    isSystemUser = true;
    description = "Greeter user";
    extraGroups = [ "video" "input" "seat" ]; # Needed for TTY, Wayland, etc.
    shell = pkgs.bashInteractive;
  };

  # Shows kernel logs only on tty1
  boot.kernelParams = ["console=tty1"];
  services.greetd = {
    enable = true;
    vt = 2; # This prevents kernel logs from mangling greetd
    settings.default_session = {
      user = "greeter";
      command = "${getExe pkgs.greetd.tuigreet} --time --cmd ${
        getExe pkgs.zsh
      }"; # Shell only by default
    };
  };

  # Launches hyprland, redirecting output to systemd journal
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "launch-hyprland";
      text = ''
        systemctl --user stop graphical-session.target
        uwsm start hyprland-uwsm.desktop
      '';
    })
  ];

  # Enable seatd (important for Wayland on non-root users)
  services.seatd.enable = true;

  security.pam.services.greetd.enableGnomeKeyring = true;
}

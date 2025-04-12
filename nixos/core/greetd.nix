{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  # Create the greeter user
  users.users.greeter = {
    isSystemUser = true;
    description = "Greeter user";
    extraGroups = [
      "video"
      "input"
      "seat"
    ];
    shell = pkgs.bashInteractive;
  };

  boot.kernelParams = [ "console=tty1" ];
  services.greetd = {
    enable = true;
    vt = 2; # This prevents kernel logs from mangling greetd
    settings.default_session = {
      user = "greeter";
      command = "${lib.getExe pkgs.greetd.tuigreet} --time --time-format '%a, %d %b %Y • %T' --asterisks --remember --cmd Hyprland";
    };
  };

  services.seatd.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}

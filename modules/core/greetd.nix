{
  pkgs,
  config,
  lib,
  ...
}:
{
  # Create the greeter user
  users.users.greeter = {
    isSystemUser = true;
    description = "Greeter user";
    group = "greeter";
    extraGroups = [
      "video"
      "input"
      "seat"
    ];
    shell = pkgs.bashInteractive;
  };

  users.groups.greeter = { };

  services = {
    greetd = {
      enable = lib.mkDefault (!config.machine.windowManager.gnome.enable);
      settings =
        let
          start = {
            user = "k1ng";
            command =
              if config.machine.windowManager.hyprland.enable then
                "run-hyprland"
              else if config.machine.windowManager.sway.enable then
                "run-sway"
              else if config.machine.windowManager.gnome.enable then
                "dbus-run-session -- gnome-session"
              else
                "${pkgs.bashInteractive}/bin/bash";
          };
        in
        {
          initial_session = start;
          default_session = start;
        };
    };

    seatd.enable = true;
  };

  security.pam.services.greetd.enableGnomeKeyring = lib.mkIf config.services.greetd.enable true;
}

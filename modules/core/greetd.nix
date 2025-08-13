{ pkgs, lib, config, ... }:
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

  services.greetd.enable = true;
  services.greetd.settings =
    let
      start = {
        user = "k1ng";
        command =
          if config.machine.windowManager.hyprland.enable then
            "run-hyprland"
          else if config.machine.windowManager.sway.enable then
            "run-sway"
          else
            "${pkgs.bashInteractive}/bin/bash";
      };
    in {
      initial_session = start;
      default_session = start;
    };

  services.seatd.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}

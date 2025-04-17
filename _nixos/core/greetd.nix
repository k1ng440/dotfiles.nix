{
  pkgs,
  lib,
  config,
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

  services.greetd.enable = true;
  services.greetd.settings =
    let
      start = {
        command = "${lib.getExe config.programs.uwsm.package} start hyprland-uwsm.desktop > /dev/null"; # dev/null for no messages on the screen`
        user = "k1ng";
      };
    in
    {
      initial_session = start;
      default_session = start;
    };

  # services.greetd = {
  #   enable = true;
  #   vt = 2; # This prevents kernel logs from mangling greetd
  #   settings.default_session = {
  #     user = "greeter";
  #     command = ''
  #       ${lib.getExe pkgs.greetd.tuigreet} --time --time-format '%a, %d %b %Y • %T' --asterisks --remember --cmd Hyprland \
  #       --greeting "Access is restricted to authorized personal only."
  #     '';
  #   };
  # };

  services.seatd.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}

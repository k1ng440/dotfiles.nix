{
  pkgs,
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
        command = "run-sway";
        user = "k1ng";
      };
    in
    {
      initial_session = start;
      default_session = start;
    };

  services.seatd.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}

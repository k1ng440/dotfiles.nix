{
  lib,
  config,
  ...
}:
{
  config =
    lib.mkIf
      (
        config ? "machine"
        && config.machine ? "computed"
        && config.machine ? "isMinimal"
        && !config.machine.computed.isMinimal
      )
      {
        services.flatpak = {
          enable = true;
          update = {
            onActivation = true;
            auto = {
              enable = true;
              onCalendar = "daily";
            };
          };
          overrides = {
            global = {
              Context.sockets = [
                "wayland"
                "!x11"
                "!fallback-x11"
              ];
              Environment = {
                XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
              };
            };
          };
        };
      };
}

{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (!config.machine.computed.isMinimal) {
    services.flatpak = {
      enable = true;
      update = {
        onActivation = true;
        auto = {
          enable = true;
          onCalendar = "daily";
        };
      };
      # Default flathub remote is added by the module

      overrides = {
        global = {
          # Force Wayland by default and disable X11 fallbacks
          Context.sockets = [
            "wayland"
            "!x11"
            "!fallback-x11"
          ];

          Environment = {
            # Fix un-themed cursor in some Wayland apps
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          };
        };
      };
    };
  };
}

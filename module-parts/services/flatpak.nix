{
  flake.modules.nixos.services_flatpak =
    { inputs, ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
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

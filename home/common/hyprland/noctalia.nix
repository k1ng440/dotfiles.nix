{
  lib,
  pkgs,
  machine,
  ...
}:
{
  programs.noctalia-shell = {
    inherit (machine.windowManager.hyprland.noctalia) enable;
    package = pkgs.noctalia-shell;
  };

  xdg.configFile = lib.mkIf machine.windowManager.hyprland.noctalia.enable {
    "noctalia/settings.json" = {
      source = lib.mkForce ./noctalia/settings.json;
    };
    "noctalia/user-templates.toml" = {
      source = lib.mkForce ./noctalia/user-templates.toml;
    };
    "noctalia/templates/fresh.json" = {
      source = lib.mkForce ./noctalia/templates/fresh.json;
    };
  };
}

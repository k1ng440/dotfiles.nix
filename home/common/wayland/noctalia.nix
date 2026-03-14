{
  lib,
  outputs,
  pkgs,
  config,
  machine,
  ...
}:
{
  programs.noctalia-shell = {
    enable = machine.windowManager.hyprland.noctalia.enable;
    package = pkgs.noctalia-shell-git-main;
  };

  xdg.configFile = lib.mkIf machine.windowManager.hyprland.noctalia.enable {
    "noctalia/settings.json" = {
      source = ./noctalia/settings.json;
    };
    "noctalia/user-templates.toml" = {
      source = ./noctalia/user-templates.toml;
    };
    "noctalia/templates/fresh.json" = {
      source = ./noctalia/templates/fresh.json;
    };
  };
}

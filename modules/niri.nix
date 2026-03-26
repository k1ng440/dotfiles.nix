{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.machine.windowManager.niri.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    environment.sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
  };
}

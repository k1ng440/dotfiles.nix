{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.machine.windowManager.hyprland.enable {
    programs.hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };

    environment.sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
  };
}

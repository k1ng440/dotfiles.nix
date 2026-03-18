{
  pkgs,
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

    # Noctalia shell (quickshell) requires power-profiles-daemon
    services.power-profiles-daemon.enable = lib.mkIf config.machine.windowManager.hyprland.noctalia.enable (
      lib.mkForce true
    );
    services.auto-cpufreq.enable = lib.mkIf config.machine.windowManager.hyprland.noctalia.enable (
      lib.mkForce false
    );

    environment.sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };

    environment.systemPackages = with pkgs; [
      kitty
    ];
  };
}

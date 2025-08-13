{ config, lib, ... }:  {
  imports = [
    ./hyprland
    ./swaywm
  ];

  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf config.machine.windowManager.enabled {
      XDG_CONFIG_HOME = "$HOME/.config";
      GTK_USE_PORTAL = "1";
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    })

    (lib.mkIf config.machine.windowManager.sway.enable {
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_DESKTOP = "sway";
    })

    (lib.mkIf config.machine.windowManager.hyprland.enable {
      XDG_CURRENT_DESKTOP = "hyprland";
      XDG_SESSION_DESKTOP = "hyprland";
    })
  ];
}

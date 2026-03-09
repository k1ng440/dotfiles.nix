{
  lib,
  pkgs,
  config,
  machine,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  config = mkIf machine.windowManager.kde.enable {
    # KWin should launch fcitx5 on its own for the Wayland input method frontend
    xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text = ''
      [Desktop Entry]
      Exec=fcitx5
      Icon=fcitx
      Name=Fcitx 5
      Type=Application
      X-KDE-Autostart-enabled=false
    '';

    xdg.configFile."autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Exec=blueman-applet
      Icon=blueman
      Name=Blueman Applet
      Type=Application
      NotShowIn=KDE;
    '';

    xdg.configFile."autostart/nm-applet.desktop".text = ''
      [Desktop Entry]
      Exec=nm-applet
      Icon=network-workgroup
      Name=Network-manager Applet
      Type=Application
      NotShowIn=KDE;
    '';

    programs.plasma = {
      enable = true;

      configFile.kwinrc.Wayland.VirtualKeyboardLib = "org.fcitx.Fcitx5";

      # Basic Plasma configuration
      workspace = {
        clickItemTo = "select"; # Double click to open
        lookAndFeel = "org.kde.breeze.desktop";
        cursor = {
          theme = "BreezeX-Dark";
          size = 24;
        };
      };

      input = {
        keyboard = {
          numlockOnStartup = "on";
          repeatDelay = 200;
          repeatRate = 50;
        };
      };

      configFile.kcminputrc = {
        # Mouse settings
        Mouse.PointerAccelerationProfile = 1; # None/Flat

        # Libinput Touchpad settings (global defaults often used)
        "Libinput/Touchpad".NaturalScroll = true;
        "Libinput/Touchpad".DisableWhileTyping = false;
      };

      shortcuts = {
        "services/org.kde.spectacle.desktop" = {
          "RectangularRegionScreenShot" = "Meta+Shift+S";
        };
        "kwin" = {
          "Window Maximize" = "Meta+W";
          "Window Close" = "Meta+C";
        };
      };

      panels = [
        # Default bottom panel
        {
          location = "bottom";
          widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.pager"
            "org.kde.plasma.icontasks"
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
          ];
        }
      ];
    };
  };
}

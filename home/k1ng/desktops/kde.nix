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

    home.packages = [
      pkgs.kdePackages.krohnkite
    ];

    programs.plasma = {
      enable = true;

      configFile.kwinrc = {
        Wayland.VirtualKeyboardLib = "org.fcitx.Fcitx5";
        Plugins.krohnkiteEnabled = true;
        Script-krohnkite = {
          enableFloating = true;
          screenGapBottom = 5;
          screenGapLeft = 5;
          screenGapRight = 5;
          screenGapTop = 5;
          tileLayoutGap = 5;
          tileGap = 8;
        };
        Effect-overview = {
          BorderActivate = 9;
        };
      };

      configFile.spectaclerc = {
        General = {
          launchAction = "DoNotTakeScreenshot";
          showOnClick = true;
          showMessageOnSave = true;
        };
        GuiConfig = {
          captureMode = 0;
          quitAfterSaveCopy = true;
        };
        Save = {
          saveFilenameFormat = "Screenshot_%Y%M%D_%H%M%S";
        };
      };

      spectacle.shortcuts = {
        recordRegion = "Meta+Alt+Print";
        captureActiveWindow = "Meta+Print";
        captureEntireDesktop = "Shift+Print";
        captureRectangularRegion = [
          "Meta+Shift+S"
          "Print"
        ];
      };

      hotkeys.commands = {
        "fuzzel-launcher" = {
          name = "Fuzzel Launcher";
          key = "Meta+R";
          command = "${pkgs.fuzzel}/bin/fuzzel";
        };
        "fuzzel-web-search" = {
          name = "Fuzzel Web Search";
          key = "Meta+Shift+R";
          command = "fuzzel-web-search";
        };
      };

      # Basic Plasma configuration
      workspace = {
        clickItemTo = "select"; # Double click to open
        cursor = {
          theme = "BreezeX-Light";
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
        "ksmserver" = {
          "Lock Session" = [
            "Screensaver"
            "Meta+Esc"
          ];
        };
        "kwin" = {
          "Window Maximize" = "Meta+W";
          "Window Close" = "Meta+C";

          # Krohnkite shortcuts
          "Krohnkite: Cycle Layout" = "Meta+Space";
          "Krohnkite: Focus Next" = "Meta+J";
          "Krohnkite: Focus Previous" = "Meta+K";
          "Krohnkite: Move Window Next" = "Meta+Shift+J";
          "Krohnkite: Move Window Previous" = "Meta+Shift+K";
          "Krohnkite: Shrink Main" = "Meta+H";
          "Krohnkite: Grow Main" = "Meta+L";
          "Krohnkite: Toggle Floating" = "Meta+F";
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

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
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers/wallpapers";
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
      overrideConfig = true;

      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

      configFile.kwinrc = {
        Compositing = {
          AllowTearing = true;
          Latency = 0; # Force lowest latency
        };
        Wayland.VirtualKeyboardLib = "org.fcitx.Fcitx5";
        Desktops = {
          SeparateScreenDesktops = true;
        };
        Plugins = {
          krohnkiteEnabled = true;
        };
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
        NightColor = {
          Active = true;
          Mode = "Location";
        };
      };

      configFile.dolphinrc = {
        General = {
          ShowFullPath = true;
        };
        MainWindow = {
          MenuBar = "Disabled";
          ToolbarsWidgetsProperty = "Disabled";
        };
      };

      configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
        "Containments/1/Wallpaper/org.kde.slideshow/General" = {
          SlidePaths = wallpaperDir;
          SlideInterval = 300;
        };
        "Containments/1" = {
          wallpaperplugin = "org.kde.slideshow";
        };
      };

      configFile.ksplashrc.KSplash.Theme = "None";

      configFile.kwinrc.ModifierOnlyShortcuts.Meta = "org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,Overview";

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
        "kitty" = {
          name = "Kitty Terminal";
          key = "Meta+Q";
          command = "${pkgs.kitty}/bin/kitty";
        };
        "dolphin" = {
          name = "Dolphin File Manager";
          key = "Meta+E";
          command = "${pkgs.kdePackages.dolphin}/bin/dolphin";
        };
      };

      # Basic Plasma configuration
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        clickItemTo = "select"; # Double click to open
        cursor = {
          theme = "BreezeX-Dark";
          size = 24;
        };

        wallpaperSlideShow = {
          path = wallpaperDir;
          interval = 300;
        };
      };

      kwin = {
        virtualDesktops = {
          number = 9;
          rows = 1;
        };
      };

      window-rules = [
        {
          description = "Picture-in-Picture";
          match = {
            title = "Picture-in-Picture";
            window-types = [ "normal" ];
          };
          apply = {
            keepabove = {
              value = true;
              apply = "force";
            };
            noborder = {
              value = true;
              apply = "force";
            };
            onallvt = {
              value = true;
              apply = "force";
            };
          };
        }
      ];

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
          "Window Minimize" = "Meta+M";
          "Window Close" = "Meta+C";
          "Window Fullscreen" = "Meta+Return";
          "Window Sticky" = "Meta+S";

          "Overview" = "Meta+Tab";
          "Grid View" = "Meta+G";

          "Switch to Desktop 1" = "Meta+1";
          "Switch to Desktop 2" = "Meta+2";
          "Switch to Desktop 3" = "Meta+3";
          "Switch to Desktop 4" = "Meta+4";
          "Switch to Desktop 5" = "Meta+5";
          "Switch to Desktop 6" = "Meta+6";
          "Switch to Desktop 7" = "Meta+7";
          "Switch to Desktop 8" = "Meta+8";
          "Switch to Desktop 9" = "Meta+9";

          "Window to Desktop 1" = "Meta+Shift+1";
          "Window to Desktop 2" = "Meta+Shift+2";
          "Window to Desktop 3" = "Meta+Shift+3";
          "Window to Desktop 4" = "Meta+Shift+4";
          "Window to Desktop 5" = "Meta+Shift+5";
          "Window to Desktop 6" = "Meta+Shift+6";
          "Window to Desktop 7" = "Meta+Shift+7";
          "Window to Desktop 8" = "Meta+Shift+8";
          "Window to Desktop 9" = "Meta+Shift+9";

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
        {
          location = "bottom";
          floating = true;
          height = 44;
          screen = "all";
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

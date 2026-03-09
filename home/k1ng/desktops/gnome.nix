{
  lib,
  pkgs,
  machine,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf machine.windowManager.gnome.enable {
    dconf.enable = true;
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "dash-to-dock@micxgx.gmail.com"
          "gsconnect@andyholmes.github.io"
          "just-perfection-desktop@just-perfection"
          "logomenu@aryan_naveen"
          "no-overview@fthx"
          "space-bar@luchrioh"
          "top-bar-organizer@julian.gse.jsts.xyz"
          "wireless-hid@chlumskyvaclav.gmail.com"
          "aylurs-widgets@aylur"
          "Vitals@CoreCoding.com"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "pop-shell@system76.com"
          "system-monitor@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          "logomenu@aryan_k"
          "blur-my-shell@aunetx"
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "spotify.desktop"
          "discord.desktop"
          "steam.desktop"
          "com.mitchellh.ghostty.desktop"
          "org.gnome.Settings.desktop"
        ];
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        clock-show-weekday = true;
        clock-show-date = true;
      };

      "org/gnome/desktop/default-applications/terminal" = {
        exec = "ghostty";
      };

      "org/gnome/desktop/peripherals/mouse" = {
        speed = 0.5;
        accel-profile = "flat";
      };

      "org/gnome/desktop/peripherals/keyboard" = {
        delay = lib.hm.gvariant.mkUint32 200;
        repeat-interval = lib.hm.gvariant.mkUint32 20;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        disable-while-typing = false;
        natural-scroll = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };

      "org/gnome/desktop/wm/keybindings" = {
        hide-window = [ ];
        minimize = [ "<Super>comma" ];
        close = [ "<Super>c" ];
        toggle-fullscreen = [ "<Shift><Super>f" ];
        toggle-message-tray = [ ];
        push-to-talk-quiet = [ ];

        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-5 = [ "<Super>5" ];
        switch-to-workspace-6 = [ "<Super>6" ];
        switch-to-workspace-7 = [ "<Super>7" ];
        switch-to-workspace-8 = [ "<Super>8" ];
        switch-to-workspace-9 = [ "<Super>9" ];
        switch-to-workspace-10 = [ "<Super>0" ];

        move-to-workspace-1 = [ "<Shift><Super>1" ];
        move-to-workspace-2 = [ "<Shift><Super>2" ];
        move-to-workspace-3 = [ "<Shift><Super>3" ];
        move-to-workspace-4 = [ "<Shift><Super>4" ];
        move-to-workspace-5 = [ "<Shift><Super>5" ];
        move-to-workspace-6 = [ "<Shift><Super>6" ];
        move-to-workspace-7 = [ "<Shift><Super>7" ];
        move-to-workspace-8 = [ "<Shift><Super>8" ];
        move-to-workspace-9 = [ "<Shift><Super>9" ];
        move-to-workspace-10 = [ "<Shift><Super>0" ];
      };

      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
        switch-to-application-5 = [ ];
        switch-to-application-6 = [ ];
        switch-to-application-7 = [ ];
        switch-to-application-8 = [ ];
        switch-to-application-9 = [ ];
        switch-to-application-10 = [ ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];

        screensaver = [ ]; # Disables GNOME Screen Lock
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-timeout = 0;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 0;
        sleep-inactive-battery-type = "nothing";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>r";
        command = "ulauncher";
        name = "Launcher";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super>q";
        command = "ghostty";
        name = "Ghostty";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        binding = "<Super>e";
        command = "thunar";
        name = "File Manager";
      };

      "org/gnome/shell/extensions/blur-my-shell/app-blur" = {
        blur = true;
        brightness = 0.6;
        sigma = 30;
        whitelist = [ "com.mitchellh.ghostty" ];
      };

      "org/gnome/shell/extensions/blur-my-shell/panel" = {
        blur = true;
        brightness = 0.6;
        sigma = 30;
        pipeline = "pipeline_default";
        round-corners = true;
        round-corners-radius = 12;
      };

      "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
        blur = true;
        brightness = 0.6;
        sigma = 30;
        static-blur = true;
      };

      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = false;
        workspaces-only-on-primary = true;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        autohide = true;
        dock-fixed = false;
        dock-position = "BOTTOM";
        pressure-threshold = 200.0;
        require-pressure-to-show = true;
        show-favorites = true;
        hot-keys = false;
      };

      "org/gnome/shell/extensions/just-perfection" = {
        panel-size = 48;
        activities-button = false;
        app-menu = false;
        search = false;
        window-picker-icon = false;
      };

      "org/gnome/shell/extensions/Logo-menu" = {
        hide-softwarecentre = true;
        menu-button-icon-click-type = 3;
        menu-button-icon-image = 23; # NixOS logo
      };

      "org/gnome/shell/extensions/space-bar/appearance" = {
        workspaces-bar-padding = 10;
        workspace-margin = 5;
        active-workspace-border-radius = 12;
      };

      "org/gnome/shell/extensions/space-bar/behavior" = {
        smart-format = true;
      };

      "org/gnome/shell/extensions/top-bar-organizer/order" = {
        left-box-order = [
          "space-bar"
          "logomenu"
        ];
        center-box-order = [ "dateMenu" ];
        right-box-order = [
          "vitalsMenu"
          "aggregateMenu"
        ];
      };

      "org/gnome/shell/extensions/pop-shell" = {
        tile-by-default = true;
        gap-inner = 2;
        gap-outer = 2;
        show-active-hint = true;
        active-hint-border-radius = 2;

        close-window = [ "<Super>c" ];
        activate-launcher = [ "<Super>slash" ];
        tile-enter = [ "<Super>Return" ]; # Enter management mode

        # Window Movement (within tiling)
        tile-move-left = [
          "<Shift><Super>h"
          "<Shift><Super>Left"
        ];
        tile-move-right = [
          "<Shift><Super>l"
          "<Shift><Super>Right"
        ];
        tile-move-up = [
          "<Shift><Super>k"
          "<Shift><Super>Up"
        ];
        tile-move-down = [
          "<Shift><Super>j"
          "<Shift><Super>Down"
        ];

        # Focus Navigation
        focus-left = [
          "<Super>h"
          "<Super>Left"
        ];
        focus-right = [
          "<Super>l"
          "<Super>Right"
        ];
        focus-up = [
          "<Super>k"
          "<Super>Up"
        ];
        focus-down = [
          "<Super>j"
          "<Super>Down"
        ];

        # Toggle between Horizontal and Vertical split for the next window
        tile-orientation = [ "<Super>o" ];

        # Toggle a window between Floating and Tiling (useful for calculators or small tools)
        tile-floating = [ "<Super>g" ];

        # Keep a window (like a terminal or docs) always on top
        always-on-top = [ "<Super>t" ];

        # Toggle Fullscreen (great for focused coding in Ghostty)
        toggle-fullscreen = [
          "<Super>f"
          "<Shift><Super>f"
        ];

        cycle-display-orientation = [ ];

        floating-exceptions = [ "Ulauncher" ];
      };
    };

    systemd.user.services.ulauncher = {
      Unit = {
        Description = "Linux Application Launcher";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
        Restart = "on-failure";
        StartLimitIntervalSec = 0;
        X-Restart-Triggers = [
          config.xdg.configFile."ulauncher/settings.json".source
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xdg.configFile."ulauncher/settings.json" = {
      force = true;
      text = builtins.toJSON {
        disable-desktop-filters = false;
        show-recent-apps = "10";
        theme-name = "dark";
      };
    };
  };
}

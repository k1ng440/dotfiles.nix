{
  lib,
  pkgs,
  machine,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf machine.windowManager.gnome.enable {
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "dash-to-dock@micxgx.gmail.com"
          "gsconnect@andyholmes.github.io"
          "gTile@vladimir.vitkov.jp"
          "just-perfection-desktop@just-perfection"
          "logomenu@aryan_naveen"
          "no-overview@fthx"
          "space-bar@github.com"
          "top-bar-organizer@gnome-shell-extensions.gcampax.github.com"
          "wireless-hid@chwick.github.com"
          "aylurs-widgets@aylur"
          "vitals@corecoding.com"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "spotify.desktop"
          "discord.desktop"
          "steam.desktop"
          "foot.desktop"
        ];
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        clock-show-weekday = true;
      };

      "org/gnome/desktop/peripherals/mouse" = {
        speed = 0.5; # Increase mouse speed (range -1.0 to 1.0)
        accel-profile = "flat";
      };

      "org/gnome/desktop/peripherals/keyboard" = {
        delay = 160; # Even lower delay (in ms)
        repeat-interval = 20; # Faster repeat interval (in ms)
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        disable-while-typing = false;
        natural-scroll = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };

      "org/gnome/desktop/wm/keybindings" = {
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

      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = false;
        workspaces-only-on-primary = false;
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
      };

      "org/gnome/shell/extensions/Logo-menu" = {
        hide-softwarecentre = true;
        menu-button-icon-click-type = 3;
        menu-button-icon-image = 23; # NixOS logo
      };

      "org/gnome/shell/extensions/aylurs-widgets" = {
        background-clock = false;
        battery-bar = false;
        dash-board = false;
        date-menu-date-format = "%H:%M  %B %d";
        date-menu-hide-clocks = true;
        date-menu-hide-system-levels = true;
        date-menu-hide-user = true;
        date-menu-indicator-position = 2;
        media-player = false;
        notification-indicator = false;
        power-menu = false;
        quick-toggles = false;
        workspace-indicator = false;
      };

      "org/gnome/shell/extensions/gtile" = {
        show-icon = false;
        grid-sizes = "8x2,4x2,2x2";
      };
    };
  };
}

{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
in {
  home.packages = with pkgs; [ inter mpv ];

  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Fluent-dark";
      package = pkgs.fluent-icon-theme;
    };
    settings = {
      global = {
        frame_width = "2";
        origin = "top-right";
        offset = "8x4";
        width = "300";
        height = "200";
        padding = 16;
        horizontal_padding = 16;
        follow = "mouse";
      };

      urgency_low = {
        background = lib.mkDefault "#2D2B40";
      };

      urgency_normal = {
        background = lib.mkDefault "#2D2B40";
        script = "${homeDir}/.config/dunst/play_normal.sh";
      };

      urgency_critical = {
        background = lib.mkDefault "#2D2B40";
        foreground = lib.mkDefault "#CBE3E7";
        frame_color = lib.mkDefault "#F48FB1";
        script = "${homeDir}/.config/dunst/play_critical.sh";
      };

      discord = {
        appname = "Discord";
        urgency = "low";
      };
    };
  };

  xdg.configFile."dunst/play_critical.sh" = {
    executable = true;
    text = "${pkgs.mpv}/bin/mpv ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/dialog-question.oga";
  };

  xdg.configFile."dunst/play_normal.sh" = {
    executable = true;
    text = "${pkgs.mpv}/bin/mpv ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/desktop-login.oga";
  };
}

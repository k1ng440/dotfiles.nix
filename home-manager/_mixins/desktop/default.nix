{
  config,
  desktop,
  lib,
  pkgs,
  username,
  ...
}: let
  inherit (pkgs.stdenv) isLinux isDarwin;
in {
  # import the DE specific configuration and any user specific desktop configuration
  imports =
    [
      ./apps
      ./features
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    ++ lib.optional (builtins.pathExists (
      ./. + "/${desktop}/${username}/default.nix"
    ))
    ./${desktop}/${username};

  # Enable the Catppuccin theme
  catppuccin = {
    ghostty.enable = config.programs.ghostty.enable;
    foot.enable = config.programs.foot.enable;
    fuzzel.enable = config.programs.fuzzel.enable;
    hyprland.enable = config.wayland.windowManager.hyprland.enable;
    waybar.enable = config.programs.waybar.enable;
    obs.enable = config.programs.obs-studio.enable;
  };

  # Authrorize X11 access in Distrobox
  home.file = lib.mkIf isLinux {
    ".distroboxrc".text = ''${pkgs.xorg.xhost}/bin/xhost +si:localuser:$USER'';
  };

  programs =
    lib.mkIf (username == "k1ng") {
    };

  services.mpris-proxy.enable = isLinux;

  xresources.properties = {
    "*background" = "#1E1E2E";
    "*foreground" = "#CDD6F4";
    # black
    "*color0" = "#45475A";
    "*color8" = "#585B70";
    # red
    "*color1" = "#F38BA8";
    "*color9" = "#F38BA8";
    # green
    "*color2" = "#A6E3A1";
    "*color10" = "#A6E3A1";
    # yellow
    "*color3" = "#F9E2AF";
    "*color11" = "#F9E2AF";
    # blue
    "*color4" = "#89B4FA";
    "*color12" = "#89B4FA";
    #magenta
    "*color5" = "#F5C2E7";
    "*color13" = "#F5C2E7";
    #cyan
    "*color6" = "#94E2D5";
    "*color14" = "#94E2D5";
    #white
    "*color7" = "#BAC2DE";
    "*color15" = "#A6ADC8";

    # Xterm Appearance
    "XTerm*background" = "#1E1E2E";
    "XTerm*foreground" = "#CDD6F4";
    "XTerm*letterSpace" = 0;
    "XTerm*lineSpace" = 0;
    "XTerm*geometry" = "132x50";
    "XTerm.termName" = "xterm-256color";
    "XTerm*internalBorder" = 2;
    "XTerm*faceName" = "FiraCode Nerd Font Mono:size=14:style=Medium:antialias=true";
    "XTerm*boldFont" = "FiraCode Nerd Font Mono:size=14:style=Bold:antialias=true";
    "XTerm*boldColors" = true;
    "XTerm*cursorBlink" = true;
    "XTerm*cursorUnderline" = false;
    "XTerm*saveline" = 2048;
    "XTerm*scrollBar" = false;
    "XTerm*scrollBar_right" = false;
    "XTerm*urgentOnBell" = true;
    "XTerm*depth" = 24;
    "XTerm*utf8" = true;
    "XTerm*locale" = false;
    "XTerm.vt100.metaSendsEscape" = true;
  };
}

{ pkgs, lib, machine, ... }: let
  cursorName = "catppuccin-mocha-red-cursors";
  cursorPkg = pkgs.catppuccin-cursors.mochaRed;
  cursorSize = 24;
in {
  home.packages = [
    cursorPkg
  ];

  home.pointerCursor = {
    name = lib.mkForce cursorName;
    package = lib.mkForce cursorPkg;
    size = lib.mkForce cursorSize;
    x11 = {
      enable = true;
      defaultCursor = lib.mkForce cursorName;
    };
    sway.enable = machine.windowManager.sway.enable;
    hyprcursor.enable =  machine.windowManager.hyprland.enable;
    dotIcons.enable = true;

  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = lib.mkForce cursorPkg;
      name = lib.mkForce cursorName;
      size = lib.mkForce cursorSize;
    };

    # GTK3 settings
    gtk3.extraConfig = {
      gtk-cursor-theme-name = lib.mkForce cursorName;
      gtk-cursor-theme-size = lib.mkForce cursorSize;
    };

    # GTK4 settings
    gtk4.extraConfig = {
      gtk-cursor-theme-name = lib.mkForce cursorName;
      gtk-cursor-theme-size = lib.mkForce cursorSize;
    };
  };

  xresources.properties = {
    "Xcursor.theme" = lib.mkForce cursorName;
    "Xcursor.size" = lib.mkForce (builtins.toString cursorSize);
  };

  home.sessionVariables = {
    XCURSOR_THEME = lib.mkForce cursorName;
    XCURSOR_SIZE = lib.mkForce (builtins.toString cursorSize);
  };

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "gtk";
    style.name = lib.mkForce "gtk2";
  };
}

{
  pkgs,
  lib,
  machine,
  ...
}:
let
  cursorName = "catppuccin-mocha-light-cursors";
  cursorPkg = pkgs.catppuccin-cursors.mochaLight;
  cursorSize = 24;
in
{
  home = {
    packages = lib.optionals machine.windowManager.enabled [ cursorPkg ];

    pointerCursor = {
      enable = machine.windowManager.enabled;
      name = cursorName;
      package = cursorPkg;
      size = cursorSize;
      x11 = {
        enable = true;
        defaultCursor = cursorName;
      };
      sway.enable = machine.windowManager.sway.enable;
      hyprcursor = {
        inherit (machine.windowManager.hyprland) enable;
        size = cursorSize;
      };
      dotIcons.enable = true;
    };

    activation.setHyprCursor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ "${toString machine.windowManager.hyprland.enable}" = "1" ]; then
        $DRY_RUN_CMD ${pkgs.hyprland}/bin/hyprctl setcursor ${cursorName} ${toString cursorSize} || echo "Failed to set cursor theme"
      fi
    '';
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = cursorPkg;
      name = cursorName;
      size = cursorSize;
    };

    # GTK3 settings
    gtk3.extraConfig = {
      gtk-cursor-theme-name = cursorName;
      gtk-cursor-theme-size = cursorSize;
    };

    # GTK4 settings
    gtk4.extraConfig = {
      gtk-cursor-theme-name = cursorName;
      gtk-cursor-theme-size = cursorSize;
    };
  };
}

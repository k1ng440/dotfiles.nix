_: {
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;

      bezier = [
        "smooth, 0.4, 0, 0.2, 1"
        "easeOut, 0, 0, 0.2, 1"
        "liner, 1, 1, 1, 1"
      ];

      animation = [
        "windows, 1, 4, smooth, slide"
        "windowsIn, 1, 4, smooth, popin"
        "windowsOut, 1, 3, easeOut, popin"
        "windowsMove, 1, 3, smooth, slide"
        "border, 1, 1, liner"
        "borderangle, 1, 30, liner, loop"
        "fade, 1, 3, smooth"
        "fadeIn, 1, 3, smooth"
        "fadeOut, 1, 2, easeOut"
        "fadeSwitch, 1, 3, smooth"
        "workspaces, 1, 4, smooth, slide"
      ];
    };
  };
}

{
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings."$term" = lib.getExe pkgs.kitty;
  wayland.windowManager.hyprland.myBinds.Return = {
    mod = "$mainMod";
    dispatcher = "exec";
    description = "Launch terminal emulator";
    arg = "$term";
  };
}

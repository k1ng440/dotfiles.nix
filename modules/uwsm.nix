{
  config,
  lib,
  ...
}:
{
  # Enable Universal Wayland Session Manager
  programs.uwsm = {
    enable = lib.mkIf config.machine.windowManager.hyprland.enable true;
  };
}

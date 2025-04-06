# Home-manager module
{
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./window-rules.nix
    ./lock.nix
    ./sound-control.nix
    ./backlight-control.nix
    ./launcher.nix
    ./binds
    ./monitors.nix
    ./terminal.nix
    ./workspaces.nix
    ./language.nix
    ./notifications.nix
    ./screenshot-mode.nix
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = assert lib.assertMsg osConfig.programs.uwsm.enable
  "uwsm should be enabled for this setting to work as exxpected"; (lib.mkForce false);

  /*
  *
   * simple notification daemon with a GTK gui for notifications and the control center
  *
  */
  services.swaync.enable = true;

  /*
  *
   * Home manager module that configures on screen display for stuff like: Brightness, Sound
  *
  */
  services.swayosd.enable = true;
}

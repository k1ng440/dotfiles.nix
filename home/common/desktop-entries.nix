{ lib, config, ... }:
let
  primaryMonitor = lib.findFirst (monitor: monitor.primary or false) null config.monitors;
in
{
  xdg.desktopEntries = {
    steam-bigpicture-gamescope = {
      name = "Steam Big Picture with Gamescope";
      exec = "gamescope -r ${toString primaryMonitor.refresh_rate} -W ${toString primaryMonitor.width} -H ${toString primaryMonitor.height} steam -- -bigpicture -pipewire-dmabuf -tenfoot";
      icon = "steam";
      categories = [ "Game" ];
      type = "Application";
    };
  };
}

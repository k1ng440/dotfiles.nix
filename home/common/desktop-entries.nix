{ lib, config, ... }:
let
  primaryMonitor = lib.findFirst (monitor: monitor.primary or false) null config.monitors;
in
{
  xdg.desktopEntries = {
    steam-flatpak = {
      name = "Steam (Flatpak)";
      genericName = "Gaming Platform";
      exec = "flatpak run com.valvesoftware.Steam";
      terminal = false;
      icon = "steam";
      categories = [ "Game" ];
    };
    steam = {
      name = "Steam (Native)";
      genericName = "Gaming Platform";
      exec = "steam %U";
      icon = "steam";
      terminal = false;
      categories = [
        "Network"
        "FileTransfer"
        "Game"
      ];
      mimeType = [
        "x-scheme-handler/steam"
        "x-scheme-handler/steamlink"
      ];
      settings = {
        PrefersNonDefaultGPU = "true";
        X-KDE-RunOnDiscreteGpu = "true";
      };
      actions = {
        Store = {
          name = "Store";
          exec = "steam steam://store";
        };
        Community = {
          name = "Community";
          exec = "steam steam://url/CommunityHome/";
        };
        Library = {
          name = "Library";
          exec = "steam steam://open/games";
        };
        Servers = {
          name = "Servers";
          exec = "steam steam://open/servers";
        };
        Screenshots = {
          name = "Screenshots";
          exec = "steam steam://open/screenshots";
        };
        News = {
          name = "News";
          exec = "steam steam://openurl/https://store.steampowered.com/news";
        };
        Settings = {
          name = "Settings";
          exec = "steam steam://open/settings";
        };
        BigPicture = {
          name = "Big Picture";
          exec = "steam steam://open/bigpicture";
        };
        Friends = {
          name = "Friends";
          exec = "steam steam://open/friends";
        };
      };
    };
    steam-bigpicture-gamescope = {
      name = "Steam Big Picture with Gamescope";
      exec = "gamescope -r ${toString primaryMonitor.refresh_rate} -W ${toString primaryMonitor.width} -H ${toString primaryMonitor.height} steam -- -bigpicture -pipewire-dmabuf -tenfoot";
      icon = "steam";
      categories = [ "Game" ];
      type = "Application";
    };
  };
}

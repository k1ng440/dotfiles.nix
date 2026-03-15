{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./gdm.nix ];
  config = lib.mkIf config.machine.windowManager.gnome.enable {
    services = {
      xserver = {
        enable = true;
        videoDrivers = lib.mkIf (lib.elem "nvidia-gpu" config.machine.capabilities) [
          "nvidia"
        ];
      };

      displayManager.gdm = {
        enable = true;
        wayland = false;
        autoSuspend = false;
      };

      desktopManager.gnome.enable = true;

      # GNOME relies on power-profiles-daemon for power management.
      # auto-cpufreq can conflict with it.
      power-profiles-daemon.enable = lib.mkForce true;
      auto-cpufreq.enable = lib.mkForce false;

      # Disable greetd when GNOME is enabled because we use GDM
      greetd.enable = lib.mkForce false;

      # GNOME specific fixes/tweaks
      udev.packages = with pkgs; [ gnome-settings-daemon ];
      libinput.enable = true;
    };

    environment = {
      systemPackages =
        (with pkgs; [
          gnome-tweaks
          gnome-extension-manager
          nautilus-python
          gnome-shell-extensions
          ulauncher
        ])
        ++ (with pkgs.gnomeExtensions; [
          appindicator
          dash-to-dock
          gsconnect
          just-perfection
          logo-menu
          no-overview
          space-bar
          top-bar-organizer
          wireless-hid
          vitals
          pop-shell
          blur-my-shell
        ]);

      gnome.excludePackages =
        (with pkgs; [
          gnome-photos
          gnome-tour
          epiphany
          geary
          gnome-font-viewer
          gnome-system-monitor
          gnome-maps
        ])
        ++ (with pkgs; [
          cheese # webcam tool
          gnome-music
          # epiphany # web browser
          # geary # email reader
          evince # document viewer
          gnome-characters
          totem # video player
          tali # poker game
          iagno # go game
          hitori # vcxo game
          atomix # puzzle game
        ]);
    };

    networking.firewall = {
      # Open firewall for samba connections to work.
      extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";

      # Open firewall for KDE Connect/GSConnect
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
}

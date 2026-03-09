{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./gdm.nix ];
  config = lib.mkIf config.machine.windowManager.gnome.enable {
    # Enable GNOME desktop environment
    services.xserver = {
      enable = true;
    };

    services.displayManager.gdm = {
      enable = true;
      wayland = false;
      autoSuspend = false;
    };

    services.desktopManager.gnome.enable = true;

    # GNOME relies on power-profiles-daemon for power management.
    # auto-cpufreq can conflict with it.
    services.power-profiles-daemon.enable = lib.mkForce true;
    services.auto-cpufreq.enable = lib.mkForce false;

    # Disable greetd when GNOME is enabled because we use GDM
    services.greetd.enable = lib.mkForce false;

    # Fix for GNOME on NVIDIA if applicable
    services.xserver.videoDrivers = lib.mkIf (lib.elem "nvidia-gpu" config.machine.capabilities) [
      "nvidia"
    ];

    environment.systemPackages =
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

    # GNOME specific fixes/tweaks
    services.udev.packages = with pkgs; [ gnome-settings-daemon ];
    services.libinput.enable = true;

    # Open firewall for samba connections to work.
    networking.firewall.extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";

    # Open firewall for KDE Connect/GSConnect
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];

    stylix.targets.gnome.enable = false;

    environment.gnome.excludePackages =
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
}

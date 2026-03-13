{ pkgs }:
pkgs.writeShellApplication {
  name = "kdegamemode";
  runtimeInputs = [
    pkgs.kdePackages.kconfig
    pkgs.kdePackages.kwin
    pkgs.qt6.qttools # for qdbus
    pkgs.libnotify
  ];
  text = ''
    #!/usr/bin/env sh

    # Detect if we are in a KDE session
    if [ "$XDG_CURRENT_DESKTOP" != "KDE" ]; then
      exit 0
    fi

    gamemode_on() {
      # Disable animations
      kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0
      kwriteconfig6 --file kwinrc --group Compositing --key AnimationSpeed 0
      # Allow tearing for lower latency (Wayland)
      kwriteconfig6 --file kwinrc --group Compositing --key AllowTearing true
      
      # Reload KWin configuration
      qdbus org.kde.KWin /KWin reconfigure
      
      notify-send -t 5000 "KDE Gamemode" "Performance tweaks applied [ON]"
    }

    gamemode_off() {
      # Restore default animations (1.0 is standard)
      kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 1.0
      kwriteconfig6 --file kwinrc --group Compositing --key AnimationSpeed 1
      
      # Reload KWin configuration
      qdbus org.kde.KWin /KWin reconfigure
      
      notify-send -t 5000 "KDE Gamemode" "Performance tweaks removed [OFF]"
    }

    case "''${1:-}" in
    on)
      gamemode_on
      ;;
    off)
      gamemode_off
      ;;
    *)
      # Toggle logic
      CURRENT=$(kreadconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor)
      if [ "$CURRENT" = "0" ]; then
        gamemode_off
      else
        gamemode_on
      fi
      ;;
    esac
  '';
}

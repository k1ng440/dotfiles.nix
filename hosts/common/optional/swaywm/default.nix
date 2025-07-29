{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (!config.machine.sway.eanble) {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "run-sway" ''
      set -euo pipefail
      log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
      }

      log "Starting Sway compositor..."

      log "Cleaning existing compositor environment..."
      unset DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true

      log "Setting up Sway environment..."
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland

      log "Updating D-Bus activation environment..."
      if ! dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE; then
          log "Warning: Failed to update D-Bus activation environment"
      fi

      log "Importing environment to systemd user session..."
      if ! systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE; then
          log "Warning: Failed to import environment to systemd"
      fi

      SWAY_CMD="sway"
      ${lib.optionalString (lib.elem "nvidia-gpu" config.machine.capabilities) ''
        log "NVIDIA GPU detected, adding --unsupported-gpu flag..."
        SWAY_CMD="$SWAY_CMD --unsupported-gpu"
      ''}

      log "Launching Sway with command: $SWAY_CMD $*"
      exec $SWAY_CMD "$@"
    '')
  ];


    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [ ] ++ lib.optionals (lib.elem config.machine.capabilities "nvidia-gpu") [
        "--unsupported-gpu"
      ];
      extraSessionCommands = "";
    };

    services.gnome.gnome-keyring.enable = true;
    programs.hyprlock.enable = true;

    security.pam.services.swaylock = { };
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "sway-session.target" ];
      wants = [ "sway-session.target" ];
      after = [ "sway-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}

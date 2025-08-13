{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.machine.windowManager.hyprland.enable) {

    programs.hyprland = {
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      enable = true;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      kitty

      (pkgs.writeShellScriptBin "run-hyprland" ''
        set -euo pipefail
        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
        }

        log "Starting Hyprland compositor..."

        log "Cleaning existing compositor environment..."
        unset DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true

        log "Setting up Hyprland environment..."
        export XDG_CURRENT_DESKTOP=Hyprland
        export XDG_SESSION_DESKTOP=Hyprland
        export XDG_SESSION_TYPE=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1

        log "Updating D-Bus activation environment..."
        if ! dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE _JAVA_AWT_WM_NONREPARENTING XCURSOR_SIZE; then
        log "Warning: Failed to update D-Bus activation environment"
        fi

        log "Importing environment to systemd user session..."
        if ! systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE _JAVA_AWT_WM_NONREPARENTING XCURSOR_SIZE; then
        log "Warning: Failed to import environment to systemd"
        fi

        HYPR_CMD="Hyprland"

        log "Launching Hyprland with command: $HYPR_CMD $*"
        exec $HYPR_CMD "$@"
      '')

    ];
  };
}

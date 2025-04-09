{ config, lib, pkgs, ... }:

with lib;
let
  cfg = trace "Audio" config.nixos-common.audio;
  # TODO: Make move this to a helper
  hasDE = any (x: x) [
    config.services.xserver.enable  # X11-based DEs (GNOME, KDE, XFCE, etc.)
    (config.programs.hyprland.enable or false)  # Hyprland Wayland compositor
    (config.services.gnome.core-shell.enable or false)  # GNOME
    (config.services.xserver.desktopManager.plasma5.enable or false)  # KDE Plasma
    (config.services.xserver.desktopManager.xfce.enable or false)  # XFCE
  ];
in
{
  options.nixos-common.audio = {
    enable = mkEnableOption "Enable audio support with PipeWire";
    package = mkOption {
      type = types.package;
      default = pkgs.pipewire;
      description = "The PipeWire package to use.";
    };
    pulseaudioSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Enable PulseAudio compatibility with PipeWire.";
    };
    alsaSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ALSA support with PipeWire.";
    };
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = mkDefault false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      package = cfg.package;
      alsa.enable = cfg.alsaSupport;
      alsa.support32Bit = cfg.alsaSupport;
      pulse.enable = cfg.pulseaudioSupport;
    };

    environment.systemPackages = with pkgs;
      # Always include CLI tools
      [ pamixer ] ++
      # Include GUI tools only if a desktop environment is enabled
      (optional hasDE pavucontrol);
  };
}

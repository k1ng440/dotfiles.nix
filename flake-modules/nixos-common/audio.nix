{ config, lib, pkgs, ... }:

let
  cfg = config.nixos-common.audio;
  hasDE = lib.any (x: x) [
    config.services.xserver.enable
    (config.programs.hyprland.enable or false)
    (config.services.gnome.core-shell.enable or false)
    (config.services.xserver.desktopManager.plasma5.enable or false)
    (config.services.xserver.desktopManager.xfce.enable or false)
  ];
in
{

  options.nixos-common.audio = {
    enable = lib.mkEnableOption "Enable audio support with PipeWire";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pipewire;
      description = "The PipeWire package to use.";
    };
    pulseaudioSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PulseAudio compatibility with PipeWire.";
    };
    alsaSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ALSA support with PipeWire.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.pulseaudio.enable = lib.mkDefault false;
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
      (lib.optional hasDE pavucontrol);
  };
}

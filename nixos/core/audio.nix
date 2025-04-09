{ config, lib, pkgs, ... }: let
  cfg = config.audio;
in {

  options.audio = {
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

    environment.systemPackages = with pkgs; [ pamixer pavucontrol ];
  };
}

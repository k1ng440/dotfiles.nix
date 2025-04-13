{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixconfig.drivers.audio;
in
{
  options.nixconfig.drivers.audio = {
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

    jackAudioSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Ja compatibility with PipeWire.";
    };

    alsaSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ALSA support with PipeWire.";
    };

    low-latency = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Low-latency tweaks";
    };

    yamaha-ur22c = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Tweak and configure for Yamaha UR22C Audio Interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.pulseaudio.enable = lib.mkDefault false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      raopOpenFirewall = true;
      package = cfg.package;
      alsa.enable = cfg.alsaSupport;
      alsa.support32Bit = cfg.alsaSupport;
      pulse.enable = cfg.pulseaudioSupport;
      jack.enable = cfg.jackAudioSupport;
    };

    # * Airplay
    services.pipewire.extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [ { name = "libpipewire-module-raop-discover"; } ];
      };
    };

    # * null-sinks
    services.pipewire.extraConfig.pipewire."91-null-sinks" = {
      "context.objects" = [
        {
          # A default dummy driver. This handles nodes marked with the "node.always-driver"
          # properyty when no other driver is currently active. JACK clients need this.
          factory = "spa-node-factory";
          args = {
            "factory.name" = "support.node.driver";
            "node.name" = "Dummy-Driver";
            "priority.driver" = 8000;
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Microphone-Proxy";
            "node.description" = "Microphone";
            "media.class" = "Audio/Source/Virtual";
            "audio.position" = "MONO";
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Main-Output-Proxy";
            "node.description" = "Main Output";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
      ];
    };

    # * Yamaha USB
    services.pipewire.wireplumber.configPackages = lib.mkIf cfg.yamaha-ur22c [
      (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-lowlatency.lua" ''
        alsa_monitor.rules = {
          {
            matches = {{{ "node.name", "matches", "alsa_output.usb-Yamaha_Corporation_Steinberg_UR22C-00.analog-stereo" }}};
            apply_properties = {
              ["audio.format"] = "S32LE",
              ["audio.rate"] = "96000",
              ["api.alsa.period-size"] = 128,
              ["api.alsa.disable-batch"] = true,
            },
          },
        }
      '')
    ];

    environment.systemPackages = with pkgs; [
      pamixer
      pwvucontrol
      alsa-utils
      qjackctl
      carla
    ];

    services.playerctld.enable = true;
  };
}

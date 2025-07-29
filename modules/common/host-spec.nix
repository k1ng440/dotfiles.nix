# Specifications For Differentiating Hosts
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.hostSpec = {
    # Data variables that don't dictate configuration settings
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username of the primary user";
    };
    userUid = lib.mkOption {
      type = lib.types.ints.positive;
      description = "The uid of the primary user";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };
    email = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "The email of the user";
    };
    work = lib.mkOption {
      default = { };
      type = lib.types.anything;
      description = "An attribute set of work-related information if isWork is true";
    };
    networking = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of networking information";
    };
    wifi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate if a host has wifi";
    };
    enableMsmtp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Used to indicate a host that uses msmtp for sending emails";
    };
    msmtp = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of msmtp information";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain of the host";
    };
    userFullName = lib.mkOption {
      type = lib.types.str;
      description = "The full name of the user";
    };
    handle = lib.mkOption {
      type = lib.types.str;
      description = "The handle of the user (eg: github user)";
    };
    home = lib.mkOption {
      type = lib.types.str;
      description = "The home directory of the user";
      default =
        let
          user = config.hostSpec.username;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
    };
    persistFolder = lib.mkOption {
      type = lib.types.str;
      description = "The folder to persist data if impermenance is enabled";
      default = "";
    };
    # Configuration Settings
    hostType = lib.mkOption {
      type = lib.types.enum [ "minimal" "workstation" "server" "mobile" ];
      default = "workstation";
      description = "The type of host system";
    };
    environment = lib.mkOption {
      type = lib.types.enum [ "development" "staging" "production" ];
      default = "production";
      description = "The environment this host runs in";
    };
    capabilities = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "gpu"
        "nvidia-gpu"
        "audio-production"
        "gaming"
        "development"
        "container-runtime"
        "virtualization"
        "networking"
        "storage-server"
      ]);
      default = [];
      description = "Special capabilities or roles of this host";
    };
    isMinimal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a minimal host";
    };
    isMobile = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a mobile host";
    };
    isProduction = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Used to indicate a production host";
    };
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a server host";
    };
    isWork = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that uses work resources";
    };
    # Sometimes we can't use pkgs.stdenv.isLinux due to infinite recursion
    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that is darwin";
    };
    isVirtualMachine = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate if the host is a physical machine or virtual machine";
    };
    useYubikey = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate if the host uses a yubikey";
    };
    isAutoStyled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that wants auto styling like stylix";
    };
    stylixImage = lib.mkOption {
      type = lib.types.path;
      default = ../../assets/wallpapers/wallpaper_3862_3440x1440.jpg;
      description = "Used for image based color scheme";
    };
    useWindowManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Used to indicate a host that uses a window manager";
    };
    hdr = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that uses HDR";
    };
    scaling = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "Used to indicate what scaling to use. Floating point number";
    };
    cloudflare-warp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Cloudflare Zero Trust client daemon.";
    };

    hyprland = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable hyprland.";
      };
    };

    swaywm = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable Sway window manager.";
      };
    };

    wm-enabled = lib.mkOption {
      type = lib.types.bool;
      description = "Whether window manager enabled.";
      default =
        let
          swaywm = config.hostSpec.swaywm;
          hyprland = config.hostSpec.hyprland;
        in
        swaywm.enabled || hyprland.enabled;
    };
  };

  config = {
    assertions =
      let
        # We import these options to HM and NixOS, so need to not fail on HM
        isImpermanent =
          config ? "system" && config.system ? "impermanence" && config.system.impermanence.enable;
      in
      [
        {
          assertion =
            !config.hostSpec.isWork || (config.hostSpec.isWork && !builtins.isNull config.hostSpec.work);
          message = "isWork is true but no work attribute set is provided";
        }
        {
          assertion = !isImpermanent || (isImpermanent && !("${config.hostSpec.persistFolder}" == ""));
          message = "config.system.impermanence.enable is true but no persistFolder path is provided";
        }
        {
          assertion = !(config.hostSpec.hyprland.enabled && config.hostSpec.swaywm.enabled);
          message = ''
            Cannot enable both Hyprland and Sway simultaneously.
            Current configuration:
              - hostSpec.hyprland.enabled = ${toString config.hostSpec.hyprland.enabled}
              - hostSpec.swaywm.enabled = ${toString config.hostSpec.swaywm.enabled}

            Please choose one compositor:
              - For modern features and animations: enable only Hyprland
              - For stability and i3 compatibility: enable only Sway
          '';
        }
      ];
  };
}

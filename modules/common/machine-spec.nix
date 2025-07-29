# Specifications For Differentiating Hosts
{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;

  # Common type definitions
  commonTypes = {
    nonEmptyStr = types.strMatching ".+" // {
      description = "non-empty string";
    };
    positiveFloat = types.strMatching "^[0-9]+(\\.[0-9]+)?$" // {
      description = "positive floating point number as string";
    };
    emailAddr = types.strMatching "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$" // {
      description = "valid email address";
    };
  };

  # Validation helpers
  validators = {
    validateHostType = hostType: capabilities:
      let
        serverCapabilities = [ "storage-server" "networking" "container-runtime" ];
        hasServerCapability = builtins.any (cap: builtins.elem cap capabilities) serverCapabilities;
      in
        if hostType == "server" && !hasServerCapability
        then throw "Server host type should have at least one server capability"
      else true;
  };
in
  {
  options.machine = {
    # === Core Identity ===
    username = mkOption {
      type = commonTypes.nonEmptyStr;
      description = "The username of the primary user";
      example = "k1ng";
    };

    userUid = mkOption {
      type = types.ints.between 1000 65533;
      description = "The uid of the primary user (must be between 1000-65533 for regular users)";
      example = 1000;
    };

    hostname = mkOption {
      type = types.strMatching "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$";
      description = "The hostname of the host (valid DNS hostname)";
      example = "workstation-01";
    };

    domain = mkOption {
      type = commonTypes.nonEmptyStr;
      description = "The domain of the host";
      example = "iampavel.dev";
    };

    userFullName = mkOption {
      type = commonTypes.nonEmptyStr;
      description = "The full name of the user";
      example = "Asaduzzaman Pavel";
    };

    handle = mkOption {
      type = commonTypes.nonEmptyStr;
      description = "The handle of the user (e.g., GitHub username)";
      example = "k1ng440";
    };

    home = mkOption {
      type = types.path;
      description = "The home directory of the user";
      default =
        let user = config.machine.username;
        in if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
      defaultText = lib.literalExpression ''
        if pkgs.stdenv.isLinux then "/home/''${config.machine.username}" else "/Users/''${config.machine.username}"
      '';
    };

    # === Contact Information ===
    email = mkOption {
      type = types.attrsOf commonTypes.emailAddr;
      description = "Email addresses for different purposes";
      default = {};
      example = {
        personal = "contact@iampavel.dev";
        work = "asad@example-work.com";
      };
    };

    # === Host Classification ===
    hostType = mkOption {
      type = types.enum [ "minimal" "workstation" "server" "mobile" ];
      default = "workstation";
      description = ''
        The type of host system:
        - minimal: Basic functionality only
        - workstation: Full desktop environment
        - server: Headless server configuration
        - mobile: Mobile/laptop optimized
      '';
    };

    environment = mkOption {
      type = types.enum [ "development" "staging" "production" ];
      default = "production";
      description = "The deployment environment this host runs in";
    };

    # === Platform Detection ===
    platform = {
      isDarwin = mkOption {
        type = types.bool;
        default = pkgs.stdenv.isDarwin;
        description = "Whether this host is running macOS";
        readOnly = true;
      };

      isLinux = mkOption {
        type = types.bool;
        default = pkgs.stdenv.isLinux;
        description = "Whether this host is running Linux";
        readOnly = true;
      };

      isVirtualMachine = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the host is a virtual machine";
      };
    };

    # === Hardware Capabilities ===
    capabilities = mkOption {
      type = types.listOf (types.enum [
        # Hardware capabilities
        "gpu"
        "nvidia-gpu"
        "high-memory"
        "low-power"
        "battery"
        "bluetooth"
        "camera"
        "multi-monitor"
        "tpm"
        "secure-boot"
        "audio"
        # Software/Service capabilities
        "audio-production"
        "gaming"
        "development"
        "machine-learning"
        "streaming"
        "container-runtime"
        "virtualization"
        # Server roles
        "networking"
        "storage-server"
      ]);
      default = [];
      description = "Special hardware capabilities or roles of this host";
      example = [ "gpu" "gaming" "development" ];
    };

    # === Hardware Configuration ===
    hardware = {
      wifi = mkEnableOption "WiFi support";
      useYubikey = mkEnableOption "YubiKey hardware security key support";
    };

    # === Networking ===
    networking = mkOption {
      type = types.submodule {
        options = {
          cloudflare-warp = mkEnableOption "Cloudflare Zero Trust client daemon";
          ports = {
            tcp = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submodule {
                options = {
                  port = lib.mkOption {
                    type = types.ints.positive;
                    description = "TCP port number to open in the firewall";
                  };
                  open = lib.mkEnableOption "Open this TCP port in the firewall";
                  service = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Service associated with this port (e.g., 'ssh', 'http')";
                  };
                  description = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Description of the port's purpose";
                  };
                };
              });
              default = {
                ssh = {
                  port = 6960;
                  open = true;
                  service = "ssh";
                  description = "SSH server";
                };
              };
              description = "TCP ports to configure in the firewall";
              example = {
                http = {
                  port = 80;
                  open = true;
                  service = "http";
                  description = "HTTP web server";
                };
                https = {
                  port = 443;
                  open = true;
                  service = "https";
                  description = "HTTPS web server";
                };
              };
            };

            udp = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submodule {
                options = {
                  port = lib.mkOption {
                    type = types.ints.positive;
                    description = "UDP port number to open in the firewall";
                  };
                  open = lib.mkEnableOption "Open this UDP port in the firewall";
                  service = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Service associated with this port (e.g., 'wireguard')";
                  };
                  description = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Description of the port's purpose";
                  };
                };
              });
              default = {};
              description = "UDP ports to configure in the firewall";
              example = {
                wireguard = {
                  port = 51820;
                  open = true;
                  service = "wireguard";
                  description = "WireGuard VPN";
                };
              };
            };
          };

          customConfig = mkOption {
            type = types.attrsOf types.anything;
            default = {};
            description = "Additional networking configuration";
          };
        };
      };
      default = {};
      description = "Networking configuration";
    };

    # === Email Configuration ===
    msmtp = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable msmtp for sending emails";
      };

      config = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "msmtp configuration options";
      };
    };

    # === Work Configuration ===
    work = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          enabled = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this is a work machine";
          };

          organization = mkOption {
            type = types.str;
            description = "Organization name";
            example = "Acme Corp";
          };

          vpn = mkOption {
            type = types.bool;
            default = false;
            description = "Whether work VPN is required";
          };

          customConfig = mkOption {
            type = types.attrsOf types.anything;
            default = {};
            description = "Additional work-specific configuration";
          };
        };
      });
      default = null;
      description = "Work-related configuration (null if not a work machine)";
    };

    # === Storage & Persistence ===
    storage = {
      persistFolder = mkOption {
        type = types.str;
        default = "";
        description = "The folder to persist data if impermanence is enabled";
        example = "/persist";
      };
    };

    # === Visual & Desktop Configuration ===
    desktop = {
      autoStyling = mkEnableOption "automatic styling with stylix";
      stylixImage = mkOption {
        type = types.path;
        default = ../../assets/wallpapers/wallpaper_3862_3440x1440.jpg;
        description = "Image for generating color scheme";
      };
    };

    # === Window Manager Configuration ===
    windowManager = {
      hyprland = {
        enable = mkEnableOption "Hyprland compositor";
      };

      sway = {
        enable = mkEnableOption "Sway window manager";
      };

      # Computed option
      enabled = mkOption {
        type = types.bool;
        description = "Whether any window manager is enabled";
        default = config.machine.windowManager.hyprland.enable || config.machine.windowManager.sway.enable;
        readOnly = true;
      };
    };

    security = {
      hardened = mkEnableOption "security hardening profiles";
      firewall = mkEnableOption "strict firewall rules";
      selinux = mkEnableOption "SELinux/AppArmor mandatory access control";
    };

    boot = {
      secureBoot = mkEnableOption "UEFI Secure Boot";
      encryptedRoot = mkEnableOption "full disk encryption";
      bootloader = mkOption {
        type = types.enum [ "systemd-boot" "grub" ];
        default = "systemd-boot";
      };
    };

    # === Backup & Restore Configuration ===
    backup = {
      enable = mkEnableOption "backup system";

      strategy = mkOption {
        type = types.enum [ "restic" "borg" "rsync" "zfs" "custom" ];
        default = "borg";
        description = "Backup strategy/tool to use";
      };

      destinations = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Destination name/identifier";
              example = "remote-server";
            };

            type = mkOption {
              type = types.enum [ "local" "remote" "cloud" "network" ];
              description = "Type of backup destination";
            };

            path = mkOption {
              type = types.str;
              description = "Backup destination path or URL";
              example = "/mnt/backup";
            };

            priority = mkOption {
              type = types.ints.between 1 10;
              default = 5;
              description = "Backup priority (1=highest, 10=lowest)";
            };

            encryption = mkOption {
              type = types.bool;
              default = true;
              description = "Whether backups to this destination are encrypted";
            };
          };
        });
        default = [];
        description = "List of backup destinations";
        example = [
          {
            name = "local-nas";
            type = "network";
            path = "sftp://nas.local/backups";
            priority = 1;
            encryption = true;
          }
        ];
      };

      schedule = mkOption {
        type = types.submodule {
          options = {
            frequency = mkOption {
              type = types.enum [ "hourly" "daily" "weekly" "monthly" "custom" ];
              default = "daily";
              description = "Backup frequency";
            };

            time = mkOption {
              type = types.str;
              default = "02:00";
              description = "Time to run backups (HH:MM format)";
            };

            cronExpression = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Custom cron expression (used when frequency=custom)";
              example = "0 2 * * 0"; # Weekly on Sunday at 2 AM
            };
          };
        };
        default = {};
        description = "Backup scheduling configuration";
      };

      retention = mkOption {
        type = types.submodule {
          options = {
            keepDaily = mkOption {
              type = types.ints.positive;
              default = 7;
              description = "Number of daily backups to keep";
            };

            keepWeekly = mkOption {
              type = types.ints.positive;
              default = 4;
              description = "Number of weekly backups to keep";
            };

            keepMonthly = mkOption {
              type = types.ints.positive;
              default = 6;
              description = "Number of monthly backups to keep";
            };

            keepYearly = mkOption {
              type = types.ints.positive;
              default = 2;
              description = "Number of yearly backups to keep";
            };
          };
        };
        default = {};
        description = "Backup retention policy";
      };

      paths = mkOption {
        type = types.submodule {
          options = {
            include = mkOption {
              type = types.listOf types.str;
              default = [ config.machine.home ];
              defaultText = "[ config.machine.home ]";
              description = "Paths to include in backups";
              example = [ "/home/user" "/etc" "/var/lib/important" ];
            };

            exclude = mkOption {
              type = types.listOf types.str;
              default = [
                "*.tmp"
                "*.cache"
                "*/.cache"
                "*/node_modules"
                "*/.git"
                "*/target" # Rust build dir
                "*/build" # Common build dir
              ];
              description = "Paths/patterns to exclude from backups";
            };
          };
        };
        default = {};
        description = "Backup path configuration";
      };

      notifications = mkOption {
        type = types.submodule {
          options = {
            onSuccess = mkOption {
              type = types.bool;
              default = false;
              description = "Send notification on successful backup";
            };

            onFailure = mkOption {
              type = types.bool;
              default = true;
              description = "Send notification on backup failure";
            };

            methods = mkOption {
              type = types.listOf (types.enum [ "email" "webhook" "desktop" "log" ]);
              default = [ "log" ];
              description = "Notification methods to use";
            };

            webhook = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Webhook URL for notifications";
              example = "https://hooks.slack.com/services/...";
            };
          };
        };
        default = {};
        description = "Backup notification configuration";
      };

      customConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Additional backup tool-specific configuration";
      };
    };

    # === Computed Properties ===
    computed = {
      isMinimal = mkOption {
        type = types.bool;
        description = "Whether this is a minimal host";
        default = config.machine.hostType == "minimal";
        readOnly = true;
      };

      isMobile = mkOption {
        type = types.bool;
        description = "Whether this is a mobile host";
        default = config.machine.hostType == "mobile";
        readOnly = true;
      };

      isServer = mkOption {
        type = types.bool;
        description = "Whether this is a server host";
        default = config.machine.hostType == "server";
        readOnly = true;
      };

      isProduction = mkOption {
        type = types.bool;
        description = "Whether this is a production host";
        default = config.machine.environment == "production";
        readOnly = true;
      };

      isWork = mkOption {
        type = types.bool;
        description = "Whether this is a work host";
        default = config.machine.work != null && config.machine.work.enabled;
        readOnly = true;
      };

      useWindowManager = mkOption {
        type = types.bool;
        description = "Whether to use a window manager";
        default = config.machine.hyprland.enable || config.machine.sway.enable;
        readOnly = true;
      };
    };
  };

  config = {
    assertions =
      let
        hostSpec = config.machine;
        isImpermanent = config ? "system" && config.system ? "impermanence" && config.system.impermanence.enable;
        wmConfig = hostSpec.windowManager;
      in [
        # Work configuration validation
        {
          assertion = !hostSpec.computed.isWork || (hostSpec.work != null && hostSpec.work.enabled);
          message = "Work is enabled but work configuration is missing or incomplete";
        }

        # Impermanence validation
        {
          assertion = !isImpermanent || hostSpec.storage.persistFolder != "";
          message = "Impermanence is enabled but no persistFolder path is provided in machine.storage.persistFolder";
        }

        # Window manager mutual exclusion
        {
          assertion = !(wmConfig.hyprland.enable && wmConfig.sway.enable);
          message = ''
            Cannot enable both Hyprland and Sway simultaneously.
            Current configuration:
              - machine.windowManager.hyprland.enable = ${toString wmConfig.hyprland.enable}
              - machine.windowManager.sway.enable = ${toString wmConfig.sway.enable}

            Please choose one compositor:
              - For modern features and animations: enable only Hyprland
              - For stability and i3 compatibility: enable only Sway
          '';
        }

        # Host type and capabilities validation
        {
          assertion = validators.validateHostType hostSpec.hostType hostSpec.capabilities;
          message = "Host type and capabilities mismatch detected";
        }

        # UID range validation for work environments
        {
          assertion = !hostSpec.computed.isWork || hostSpec.userUid >= 1000;
          message = "Work environments should use UIDs >= 1000 for security";
        }

        # Server configuration validation
        {
          assertion = !hostSpec.computed.isServer || !hostSpec.desktop.useWindowManager;
          message = "Server hosts should not use window managers";
        }

        # Mobile-specific validations
        {
          assertion = !hostSpec.computed.isMobile || hostSpec.hardware.wifi;
          message = "Mobile hosts should have WiFi enabled";
        }

        # Backup validation
        {
          assertion = !hostSpec.backup.enable || hostSpec.backup.strategy == "borg";
          message = "Only borg backup strategy is currently supported";
        }
      ];

    warnings =
      let
        hostSpec = config.machine;
      in lib.optional (hostSpec.hostType == "server" && hostSpec.useWindowManager)
      "Server host has window manager enabled - this may not be intended"
      ++ lib.optional (hostSpec.environment != "production" && hostSpec.computed.isWork)
      "Work environment detected in non-production setting - ensure this is intentional";
  };
}

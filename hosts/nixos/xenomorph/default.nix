{
  lib,
  inputs,
  config,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "hosts/common/core"
      # "hosts/common/optional/solaar"
    ])

    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    ./hardware-configuration.nix
    ./configurations.nix
    ./host-packages.nix
    ./firejail.nix
  ];

  machine = {
    hostType = "workstation";
    hostname = "xenomorph";
    username = "k1ng";
    userUid = 1000;
    backup.enable = true;
    platform = {
      isVirtualMachine = false;
      isLinux = true;
    };
    boot = {
      bootloader = "systemd-boot";
      quietBoot = true;
    };
    desktop = {
      thunar = true;
      localsend = true;
    };
    security = {
      antivirus = true;
    };
    services = {
      openrgb = true;
      wine = true;
      printing = true;
      ai = {
        ollama = true;
      };
    };
    networking = {
      cloudflare-warp = true;
      ports = {
        udp = {
          factorio = {
            port = 34197;
            open = true;
            service = "factorio";
            description = "Factorio multiplayer UDP";
          };
        };
      };
    };
    windowManager = {
      hyprland = {
        enable = true;
        noctalia.enable = true;
      };
    };
    capabilities = [
      "gpu"
      "nvidia-gpu"
      "audio"
      "high-memory"
      "bluetooth"
      "camera"
      "multi-monitor"
      "tpm"
      "secure-boot"
      "audio-production"
      "gaming"
      "development"
      "machine-learning"
      "streaming"
      "container-runtime"
      "virtualization"
    ];
  };

  hostConfig = {
    msmtp.enable = true;
    android-studio.enable = false;
  };

  services.samba.enable = true;
  fileSystems =
    let
      inherit (config.users.users.${config.machine.username}) uid;
      inherit (config.users.groups.${config.machine.username}) gid;
      smb_automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=${toString uid},gid=${toString gid}";
    in
    {
      "/mnt/sn550" = {
        device = "/dev/disk/by-uuid/02DCA7E7DCA7D2E9";
        fsType = "ntfs-3g";
        options = [
          "rw"
          "uid=${toString uid}"
        ];
      };

      "/mnt/kong/media" = {
        device = "//kong.lan/media";
        fsType = "cifs";
        options = [ "${smb_automount_opts},credentials=${config.sops.secrets."samba/kong".path}" ];
      };

      "/mnt/kong/photos" = {
        device = "//kong.lan/photos";
        fsType = "cifs";
        options = [ "${smb_automount_opts},credentials=${config.sops.secrets."samba/kong".path}" ];
      };

      "/mnt/kong/backup" = {
        device = "//kong.lan/backup";
        fsType = "cifs";
        options = [ "${smb_automount_opts},credentials=${config.sops.secrets."samba/kong".path}" ];
      };

      "/mnt/kong/torrents" = {
        device = "//kong.lan/torrents";
        fsType = "cifs";
        options = [ "${smb_automount_opts},credentials=${config.sops.secrets."samba/kong".path}" ];
      };

      "/mnt/hass" = {
        device = "//192.168.0.6/config";
        fsType = "cifs";
        options = [ "${smb_automount_opts},credentials=${config.sops.secrets."samba/hass".path}" ];
      };
    };
}

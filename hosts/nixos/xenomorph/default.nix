{
  lib,
  inputs,
  config,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/hosts/nixos"
      "modules/core"
      "hosts/common/core"
      "hosts/common/optional/nvidia"
      "hosts/common/optional/audio"
      "hosts/common/optional/fonts"
      "hosts/common/optional/hyprland"
      "hosts/common/optional/swaywm"
      "hosts/common/optional/solaar"
      "hosts/common/optional/thunar"
      "hosts/common/optional/virtualisation"
      "hosts/common/optional/gaming"
      "hosts/common/optional/ai"
      "hosts/common/optional/security"
      "hosts/common/optional/applications.nix"
      "hosts/common/optional/printing.nix"
      "hosts/common/optional/plymouth.nix"
      "hosts/common/optional/localsend.nix"
    ])

    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    ./hardware-configuration.nix
    ./configurations.nix
    ./host-packages.nix
    ./stylix.nix
    ./borgbackup.nix
  ];

  machine = {
    isMinimal = false;
    isVirtualMachine = false;
    hostname = "xenomorph";
    username = "k1ng";
    userUid = 1000;
    cloudflare-warp = true;
    swaywm.enabled = true;
    hyprland.enabled = false;
  };

  hostConfig = {
    msmtp.enable = true;
    android-studio.enable = true;
  };

  # Firewall
  networking.firewall.allowedUDPPorts = [ 34197 ]; # Factorio

  services.gvfs.enable = true;
  services.samba.enable = true;
  fileSystems =
    let
      uid = config.users.users.${config.machine.username}.uid;
      gid = config.users.groups.${config.machine.username}.gid;
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
    };
}

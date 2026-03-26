{ lib, inputs, ... }@top:
{
  flake.modules.nixos.host_xenomorph =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) projects isVm user;
    in
    {
      imports = with top.config.flake.modules.nixos; [
        inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
        hardware_nvidiagpu
        services_docker
      ];

      services.samba.enable = true;
      fileSystems =
        let
          inherit (config.users.users.${user}) uid;
          inherit (config.users.groups.${user}) gid;
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
    };
}

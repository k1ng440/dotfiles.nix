{ inputs, ... }@top:
{
  flake.modules.nixos.host_xenomorph =
    { config, ... }:
    let
      inherit (config.custom.constants) user;
    in
    {
      imports = with top.config.flake.modules.nixos; [
        gui
        wm

        inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
        hardware_nvidiagpu
        hardware_ledger
        hardware_linux-firmware
        hardware_qmk
        services_docker
        services_flatpak
        services_virtualisation
        gui_fonts
        programs_kitty
        programs_steam
        programs_vesktop
      ];

      custom = {
        hardware = {
          monitors = [
            {
              name = "DP-1";
              width = 3440;
              height = 1440;
              # niri / mango wants this to be exact down to the decimals
              refreshRate = "120.000";
              vrr = true;
              x = 3440;
              y = 1080;
              workspaces = [
                1
                2
                3
                4
                5
              ];
              hdr = false;
            }
            {
              name = "DP-3";
              width = 3440;
              height = 1440;
              refreshRate = "59.973";
              vrr = true;
              x = 0;
              y = 1080;
              transform = 0;
              workspaces = [
                6
                7
              ];
              defaultWorkspace = 6;
              hdr = false;
            }
            {
              name = "HDMI-A-1";
              width = 1920;
              height = 1080;
              refreshRate = "60.000";
              vrr = false;
              x = 3440;
              y = 0;
              scale = 1.0;
              workspaces = [
                8
                9
                10
              ];
              defaultWorkspace = 8;
              hdr = false;
            }
          ];
        };
        lock.enable = false;

        programs = {
          btop.extraSettings = {
            custom_gpu_name0 = "Nvidia RTX 3080";
          };
        };
      };

      custom.constants.hostname = "xenomorph";
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

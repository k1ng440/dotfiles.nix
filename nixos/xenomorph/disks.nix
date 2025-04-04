{
  lib,
  config,
  pkgs,
  hostname,
  ...
}:
let
  # Define your target disk device carefully! Use by-id if possible.
  diskDevice = "/dev/vda"; # Or /dev/nvme0n1 etc.

  zfsKeyPath = config.sops.secrets."${hostname}/zfs_root_key_bin".path;
in
{
  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  disko.devices = {
    disk = {
      "${diskDevice}" = {
        type = "disk";
        device = diskDevice;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ];
              };
            };
            zfs = {
              name = "ZFS";
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    # ZFS Pool (using the partition created above)
    zpool = {
      "zroot" = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
        };

        options = {
          ashift = "9";
          autotrim = "on";
        };

        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/"; # Mount this dataset at the root
              # --- Encryption Settings ---
              encryption = "aes-256-gcm";
              keyformat = "raw";
              keylocation = "file://${zfsKeyPath}"; # Use the sops-provided key file
            };
          };

          # Nix store dataset (inherits encryption)
          "root/nix" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/nix";
              atime = "on";
              compression = "lz4";
            };
          };

          # Home dataset (inherits encryption)
          "root/home" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home";
            };
          };

          # Log dataset (inherits encryption)
          "root/var/log" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/log";
            };
          };

          # README MORE: https://wiki.archlinux.org/title/ZFS#Swap_volume
          "root/swap" = {
            type = "zfs_volume";
            size = "10M";
            content = {
              type = "swap";
            };
            options = {
              volblocksize = "4096";
              compression = "zle";
              logbias = "throughput";
              sync = "always";
              primarycache = "metadata";
              secondarycache = "none";
              "com.sun:auto-snapshot" = "false";
            };
          };

          # Optional: Persistent data dataset (inherits encryption)
          "persist" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/persist";
              compression = "zstd";
              xattr = "sa";
              acltype = "posixacl";
              atime = "off";
            };
          };
        };
      };
    };
  };
}

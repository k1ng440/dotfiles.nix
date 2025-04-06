{ ... }: let
  # Define your target disk device carefully! Use by-id if possible.
  diskDevice = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBcc1af7e2-bd693cbf";
in {


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
                mountOptions = ["nofail"];
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
              mountpoint = "/";
              # encryption = "aes-256-gcm";
              # keyformat = "passphrase";
              #keylocation = "file:///tmp/secret.key";
              # keylocation = "prompt";
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
            size = "16g";
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


{ ... }:
let
  # Define your target disk device carefully! Use by-id if possible.
  diskDevice = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBcc1af7e2-bd693cbf";
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${diskDevice}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key";
                # settings = {
                #   allowDiscards = true;
                #   keyFile = "/tmp/secret.key";
                # };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "20M";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # disko.devices = {
  #   disk = {
  #     main = {
  #       device = "${diskDevice}";
  #       type = "disk";
  #       content = {
  #         type = "gpt";
  #         partitions = {
  #           ESP = {
  #             type = "EF00";
  #             size = "500M";
  #             content = {
  #               type = "filesystem";
  #               format = "vfat";
  #               mountpoint = "/boot";
  #               mountOptions = [ "umask=0077" ];
  #             };
  #           };
  #           root = {
  #             size = "100%";
  #             content = {
  #               type = "filesystem";
  #               format = "ext4";
  #               mountpoint = "/";
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}

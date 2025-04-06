{ ... }: let
  # Define your target disk device carefully! Use by-id if possible.
  diskDevice = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBcc1af7e2-bd693cbf";
in {
  disko.devices = {
    disk = {
      main = {
        device = "${diskDevice}";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

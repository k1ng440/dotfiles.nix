{
  config,
  inputs,
  lib,
  pkgs,
  username,
  isInstall,
  hostname,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./disks.nix
  ];

  environment.etc."hostid".source = lib.mkForce config.sops.secrets."${hostname}/host_id".path;
  networking.networkmanager.enable = true;
  # time.timeZone = "Asia/Dacca";

  boot = {
    # https://mynixos.com/nixpkgs/option/boot.zfs.forceImportRoot
    zfs = {
      forceImportRoot = false;
    };

    extraModprobeConfig = ''
      options zfs l2arc_noprefetch=0 l2arc_write_boost=33554432 l2arc_write_max=16777216 zfs_arc_max=2147483648
    '';

    initrd = lib.mkIf isInstall {
      verbose = false;
      luks.reusePassphrases = true;
      supportedFilesystems = [ "zfs" ];
      kernelModules = [
        "zfs"
        "r8169"
      ];
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "uas"
        "sd_mod"
      ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [ /etc/ssh/initrd_ssh_host_ed25519_key ];
          authorizedKeys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqMh6k4NRNF4MzW/RYXlQ2FzFHkDE3rL3UuWT91ZzYK6oybFW2dXugxxHXA0a5d6jU4sToBB0zYLqCyCfb0rEJ+ukN0LIC+IJ2MVb7b7WSJyju0PeJqri1tice2quZO8C27rbYEMa1QgpUapDhEuNfFnDkXzkr0NnxOs2vwOdnGRm3VF1FRaV/0xmmJDeh8GmHdj40StH/UtNU63YvsTY1DJHb6Tw3O0hY4cvxx3z3SZv18bDDfn6EA/47Ao6BO88bT/b3qhmoQc55ESWX5siUk4/BtgEgQNuqZm8rxhRmW4NqdsWbLIwHdJCVn51DwokykP1A9x1QEAQRw5yqRy0fQ== rsa-key-20151130"
          ];
        };
      };
    };
    kernelModules = [
      "kvm-amd"
      "nvidia"
      "r8169"
    ];
    kernelParams = [
      "zfs_force=1"
      "zfs.zfs_arc_max=12884901888" # 12 GB
      "video=DP-0:3440x1440@100"
      "video=DP-2:3440x1440@120"
      "video=HDMI-0:1920x1080@60"
    ];
    swraid = {
      enable = true;
      mdadmConf = "MAILADDR=contact+${username}@iampavel.dev";
    };
  };

  hardware = {
    mwProCapture.enable = true;
    nvidia = {
      # How to pin the NVIDIA driver version
      #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #  version = "555.58.02";
      #  sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
      #  sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
      #  openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
      #  settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
      #  persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
      #};
      open = false;

      prime = { };
    };
  };

  services = {
    zfs.autoScrub.enable = true;
    cron = {
      enable = false;
      systemCronJobs = [
      ];
    };
  };
  services.xserver.videoDrivers = [
    # "nvidia"
  ];

}

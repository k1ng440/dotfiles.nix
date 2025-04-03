{
  config,
  inputs,
  lib,
  pkgs,
  username,
  isInstall,
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

  # config.sops.secrets.drive_key =
  #   {
  #     sopsFile = "../../secrets/xenomorph_disks.key";
  #     path = "/mnt/etc/drive.key";
  #     format = "binary";
  #     mode = "0600";
  #     gid = 0;
  #     uid = 0;
  #   };
    # // lib.mkIf isInstall {
    #   path = "/etc/drive.key";
    # };

  # environment.etc."zfs/zroot.key" lib.mkIf (isInstall) = {
  #   source = config.sops.secrets.xenomorph_enc.path;
  #   mode = "0600";
  #   gid = 0;
  #   uid = 0;
  # };

  boot = {
    # https://mynixos.com/nixpkgs/option/boot.zfs.forceImportRoot
    zfs.forceImportRoot = false;

    initrd = lib.mkIf (isInstall) {
      verbose = false;
      luks.reusePassphrases = true;
      supportedFilesystems = [ "zfs" ];
      kernelModules = [ "zfs" ];
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "uas"
        "sd_mod"
      ];
      postDeviceCommands = lib.mkBefore ''
        zfs load-key -a
      '';
    };
    kernelModules = [
      "kvm-amd"
      "nvidia"
    ];
    kernelParams = [
      "zfs_force=1"
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

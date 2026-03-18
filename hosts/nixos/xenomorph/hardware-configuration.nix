{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
      kernelModules = [ ];
      luks.devices."crypted".device = "/dev/disk/by-uuid/c68421fb-14f7-41c7-9f9b-94e8fa9e845f";
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    supportedFilesystems = [
      "ntfs"
      "cifs"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/bfacc08f-cca5-4698-a3be-20a723202545";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/bfacc08f-cca5-4698-a3be-20a723202545";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/bfacc08f-cca5-4698-a3be-20a723202545";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

    "/.swapvol" = {
      device = "/dev/disk/by-uuid/bfacc08f-cca5-4698-a3be-20a723202545";
      fsType = "btrfs";
      options = [ "subvol=swap" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0CC8-65F6";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.udev.extraRules = ''
    # Logitech USB Receiver (Mouse)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c547", TEST=="power/control", ATTR{power/control}="on"
    # Yamaha Steinberg UR22C (Audio)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0499", ATTR{idProduct}=="172f", TEST=="power/control", ATTR{power/control}="on"
  '';
}

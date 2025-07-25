{ lib, inputs, ... }:
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
      "hosts/common/optional/solaar"
      "hosts/common/optional/thunar"
      "hosts/common/optional/virtualisation"
      "hosts/common/optional/gaming"
      "hosts/common/optional/ai"
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
  ];

  hostSpec = {
    isMinimal = false;
    isVirtualMachine = false;
    hostname = "xenomorph";
    username = "k1ng";
  };

  hostConfig = {
    msmtp.enable = true;
    android-studio.enable = true;
  };

  # Firewall
  networking.firewall.allowedUDPPorts = [ 34197 ]; # Factorio

  boot.kernelParams = [
    "hugepagesz=1G"
    "hugepages=8"
  ];

  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 8;
    "vm.hugetlb_shm_group" = 0;
    "vm.transparent_hugepage.enabled" = "never";
  };
}

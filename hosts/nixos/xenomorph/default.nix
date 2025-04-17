{ lib, inputs, ... }:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
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
      "hosts/common/optional/stylix"
      "hosts/common/optional/applications.nix"
      "hosts/common/optional/printing.nix"
    ])

    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    ./hardware-configuration.nix
    ./configuratioons.nix
    ./host-packages.nix
    ./users.nix
  ];

  hostSpec = {
    isMinimal = false;
    isVirtualMachine = false;
    hostname = "xenomorph";
    username = "k1ng";
  };
}

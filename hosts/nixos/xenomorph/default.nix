{ lib, inputs, ... }:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/common"
      "modules/core"
      "modules/core/drivers/nvidia"
      "modules/core/drivers/audio"
      "modules/core/optional/fonts"
      "modules/core/optional/hyprland"
      "modules/core/optional/solaar"
      "modules/core/optional/thunar"
      "modules/core/optional/virtualisation"
      "modules/core/optional/gaming"
      "modules/core/optional/ai"
      "modules/core/optional/applications.nix"
      "modules/core/optional/printing.nix"
    ])

    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    ./hardware-configuration.nix
    ./configuratioons.nix
    ./host-packages.nix
    ./users.nix
  ];

  hostSpec = {
    isVirtualMachine = false;
    hostname = "xenomorph";
    username = "k1ng";
  };
}

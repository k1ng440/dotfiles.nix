{ lib, ... }:
{

  machine = {
    platform = {
      isVirtualMachine = false;
      isLinux = true;
    };
    hostname = "nixos-minimal";
    username = "k1ng";
  };

  imports = [
  ] ++ lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/hosts/nixos"
      "modules/core"
      "hosts/common/core"
    ])
    ./configurations.nix
    ./hardware-configuration.nix
    ./host-packages.nix
  ];

  boot.kernelParams = [ ];
  boot.kernel.sysctl = { };
}

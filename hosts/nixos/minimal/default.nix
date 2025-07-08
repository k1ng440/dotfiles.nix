{ lib, ... }:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/hosts/nixos"
      "modules/core"
      "hosts/common/core"
    ])
    ./host-packages.nix
  ];

  hostSpec = {
    isMinimal = true;
    isVirtualMachine = false;
    hostname = "nixos-minimal";
    username = "k1ng";
  };

  hostConfig = {
    msmtp.enable = false;
  };

  boot.kernelParams = [ ];

  boot.kernel.sysctl = { };
}

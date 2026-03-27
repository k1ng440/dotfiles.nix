{
  flake.modules.nixos.hardware_linux-firmware =
    { pkgs, ... }:
    {
      hardware = {
        enableRedistributableFirmware = true;
        firmware = with pkgs; [
          linux-firmware
        ];
      };
    };
}

{hostname, ...}: let
  inherit (import ../../hosts/${hostname}/variables.nix) printEnable;
in {
  services = {
    printing = {
      enable = printEnable;
      drivers = [
        # pkgs.hplipWithPlugin
      ];
    };
    ipp-usb.enable = printEnable;
  };
}

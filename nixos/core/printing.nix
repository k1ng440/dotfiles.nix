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
    avahi = {
      enable = printEnable;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = printEnable;
  };
}

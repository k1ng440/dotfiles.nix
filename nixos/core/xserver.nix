{hostname, ...}: let
  inherit (import ../../hosts/${hostname}/variables.nix) keyboardLayout;
in {
  services.xserver = {
    enable = false;
    xkb = {
      layout = "${keyboardLayout}";
      variant = "";
    };
  };
}


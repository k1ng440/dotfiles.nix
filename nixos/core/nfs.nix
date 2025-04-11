{hostname, ...}: let
  inherit (import ../../hosts/${hostname}/variables.nix) enableNFS;
in {
  services = {
    rpcbind.enable = enableNFS;
    nfs.server.enable = enableNFS;
  };
}

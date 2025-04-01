{...}: {
  imports = [
    (import ../../modules/core-server.nix {diskPath = "/dev/sda";})
  ];
}

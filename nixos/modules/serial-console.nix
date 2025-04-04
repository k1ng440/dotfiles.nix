{...}: {
  # enable serial consoles
  # see: https://github.com/NixOS/nixpkgs/issues/84105#issuecomment-608084218
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0,115200"
  ];
}

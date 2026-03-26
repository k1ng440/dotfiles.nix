{
  flake.modules.nixos.hardware_ledger =
    _ : {
      hardware.ledger.enable = true;
    };
}

_: {
  flake.modules.nixos.core = _: {
    programs.nix-index-database.comma.enable = true;
  };
}

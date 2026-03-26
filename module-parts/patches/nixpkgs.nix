{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      nixpkgs-patcher = {
        enable = true;

        settings.patches = [
          # (pkgs.fetchpatch {
          #   url = "https://github.com/NixOS/nixpkgs/commit/xxxxxxxxxxxxxxxxxxxx.patch";
          #   hash = "sha256-BMXkKvxWUsHtkDETt2v1m0MWzN2I5VVHy5m8yDUIKP4=";
          # })
        ];
      };
    };
}

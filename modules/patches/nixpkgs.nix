{
  flake.modules.nixos.core = _: {
    nixpkgs-patcher = {
      enable = true;

      settings.patches = [
        # (pkgs.fetchpatch {
        #   url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/508574.patch";
        #   hash = "sha256-vvFhmViToUEYpDRpIMMVFDfyOZ7nRup9bwI406Rj9uE=";
        # })
      ];
    };
  };
}

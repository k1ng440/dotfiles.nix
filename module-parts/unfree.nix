_: {
  flake.modules.nixos.core =
    {
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "nvidia-x11"
          "libcublas"
          "libcufft"
          "libcusparse"
          "libnvjitlink"
          "libnpp"
          "libcusolver"
          "libcurand"
        ]
        || lib.hasPrefix "cuda" (lib.getName pkg);
    };
}

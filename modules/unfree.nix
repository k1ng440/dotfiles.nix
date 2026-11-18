_: {
  flake.modules.nixos.core =
    {
      lib,
      ...
    }:
    {
      # xsane/sane-frontends are GTK2-only; gtk2 is marked broken ahead of NixOS 27.05.
      # ponytail: keep building until an xsane replacement is picked.
      nixpkgs.config.problems.handlers."gtk+".broken = "warn";
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
          "teamviewer"
        ]
        || lib.hasPrefix "cuda" (lib.getName pkg);
    };
}

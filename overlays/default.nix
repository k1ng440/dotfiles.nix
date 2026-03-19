# This file defines overlays/custom modifications to upstream packages

{ inputs, ... }:
let
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  custom-packages = final: _prev: {
    stremio = final.callPackage ../packages/stremio.nix { };
    breezex-cursor = final.callPackage ../packages/breezex-cursor.nix { };
    # noctalia-shell-git-main = final.callPackage ../packages/noctalia-shell.nix {
    #   quickshell = inputs.noctalia-qs.packages.${final.stdenv.hostPlatform.system}.default;
    # };
  };
in
{
  default =
    final: prev:
    (stable-packages final prev) // (unstable-packages final prev) // (custom-packages final prev);
}

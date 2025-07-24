#
# This file defines overlays/custom modifications to upstream packages
#
{ inputs, ... }:
let
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  flameshot-grim = final: prev: {
    flameshot = prev.flameshot.overrideAttrs (previousAttrs: {
      cmakeFlags = [
        "-DUSE_WAYLAND_CLIPBOARD=1"
        "-DUSE_WAYLAND_GRIM=1"
      ];
      buildInputs = previousAttrs.buildInputs ++ [ final.libsForQt5.kguiaddons ];
    });
  };
in
{
  # Combined overlay that applies all modifications
  default = final: prev:
    (stable-packages final prev) //
    (unstable-packages final prev) //
    (flameshot-grim final prev);
}


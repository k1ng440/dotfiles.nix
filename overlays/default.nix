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
in
{
  # Combined overlay that applies all modifications
  default = final: prev:
    (stable-packages final prev) //
    (unstable-packages final prev);
}


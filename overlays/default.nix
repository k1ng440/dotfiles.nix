# This file defines overlays/custom modifications to upstream packages

{ inputs, ... }:
let
  # Define the fix in a single, reusable overlay
  fixAntlrOverlay = final: prev: {
    antlr-runtime-cpp = prev.antlr-runtime-cpp.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        (final.substituteAll {
          src = ./antlr-cmake.patch;
        })
      ];
    });
    pamixer = prev.pamixer.overrideAttrs (oldAttrs: {
      buildInputs = (oldAttrs.buildInputs or []) ++ [ final.icu ];
    });
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [ fixAntlrOverlay ];
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [ fixAntlrOverlay ];
    };
  };
in
{
  default = final: prev:
    (stable-packages final prev) //
    (unstable-packages final prev);
}

{
  lib,
  inputs,
  outputs,
  config,
  ...
}:
{
  # Overlays
  nixpkgs = {
    overlays = [
      outputs.overlays.default
      inputs.niri.overlays.niri
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # Optimize storage and automatic scheduled GC running
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      trusted-users = [ "@wheel" ];
      warn-dirty = false;
      allow-import-from-derivation = true;

      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      /*
        * substituter's priority can be set by adding query parameter: ?priority=xxx
        * NOTE: The lower the number, the higher the priority.
        *
      */
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}

{ lib, inputs, outputs, isNixOS, config, ... }:
let
  platform = if isNixOS then "nixos" else "darwin";
  platformModules = "${platform}Modules";
in {
  imports = lib.flatten [
    inputs.home-manager.${platformModules}.home-manager
    inputs.sops-nix.${platformModules}.sops
    inputs.stylix.${platformModules}.stylix

    (map lib.custom.relativeToRoot [
      "modules/common"
      "modules/hosts/common"
      "modules/hosts/${platform}"

      "hosts/common/core/${platform}.nix"
      "hosts/common/core/sops.nix"
      "hosts/common/core/ssh.nix"
      "hosts/common/core/i18n.nix"
      "hosts/common/core/time.nix"

      "hosts/common/users/primary"
      "hosts/common/users/primary/${platform}.nix"
    ])
  ];

  # Core host spec
  hostSpec = {
    username = "k1ng";
    handle = "k1ng440";
    inherit (inputs.nix-secrets)
    domain
    email
    userFullName
    networking
    ;
  };

  networking.hostName = config.hostSpec.hostname;

  # Configure Home manager
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "bk";

  # Overlays
  nixpkgs = {
    overlays = [
      outputs.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      trusted-users = [ "@wheel" ];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
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
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
}

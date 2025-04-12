{
  inputs,
  pkgs,
  hostname,
  ...
}:
let
  inherit (import ../../hosts/${hostname}/variables.nix) consoleKeyMap;
in
{
  nix = {
    # gc = {
    #   persistent = true;
    #   automatic = true;
    #   dates = "weekly";
    # };

    settings = {
      download-buffer-size = 250000000;
      auto-optimise-store = true;
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
    extraOptions = ''
      flake-registry = ${inputs.flake-registry}/flake-registry.json
    '';
    nixPath = [ "nixpkgs=${pkgs.path}" ];
  };

  time.timeZone = "Asia/Dhaka";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  environment.variables = { };
  console.keyMap = "${consoleKeyMap}";
  system.stateVersion = "24.11"; # Do not change!
}

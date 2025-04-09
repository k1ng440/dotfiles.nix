{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    nixosCommon.nix = {
      disable-extra-substituters = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to disable setting extra substituters.
        '';
      };
    };
  };

  config = {
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };

    nix = {
      gc = {
        persistent = true;
        automatic = true;
        dates = "weekly";
      };

      settings = {
        trusted-users = [ "root" "k1ng" ];

        experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
        auto-optimise-store = true;

        /*
          * substituter's priority can be set by adding query parameter: ?priority=xxx
          * NOTE: The lower the number, the higher the priority.
          *
        */
        substituters =
          [
            "https://cache.nixos.org"
          ]
          ++ lib.optionals (!config.nixosCommon.nix.disable-extra-substituters) [
            "https://nix-community.cachix.org"
            "https://hyprland.cachix.org"
          ];
        trusted-public-keys =
          [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ]
          ++ lib.optionals (!config.nixosCommon.nix.disable-extra-substituters) [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ];
      };

      extraOptions = ''
        experimental-features = nix-command flakes
        http-connections = 120
        max-substitution-jobs = 120
      '';

      nixPath = [ "nixpkgs=${pkgs.path}" ];
    };
  };
}

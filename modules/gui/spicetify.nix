{ withSystem, ... }:
{
  flake.modules.nixos.programs_spicetify =
    {
      pkgs,
      inputs,
      config,
      ...
    }:
    let
      spicePkgs = withSystem pkgs.stdenv.hostPlatform.system (
        { inputs', ... }: inputs'.spicetify-nix.legacyPackages
      );
    in
    {
      imports = [ inputs.spicetify-nix.nixosModules.default ];

      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";

        enabledExtensions = with spicePkgs.extensions; [
          adblockify
          hidePodcasts
          shuffle
        ];

        enabledCustomApps = with spicePkgs.apps; [
          newReleases
          lyricsPlus
        ];
      };

      # Noctalia template for dynamic spicetify colors
      custom.programs.noctalia.colors.templates = {
        "spicetify" = {
          input_path = "${config.hj.xdg.config.directory}/spicetalia/colors.ini";
          output_path = "${config.hj.xdg.config.directory}/spicetalia/colors.ini";
        };
      };

      custom.persist = {
        home.directories = [ ".config/spotify" ];
      };
    };
}

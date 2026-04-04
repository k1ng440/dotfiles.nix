{ withSystem, ... }:
{
  flake.modules.nixos.programs_spicetify =
    { pkgs, inputs, ... }:
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

      custom.persist = {
        home.directories = [ ".config/spotify" ];
      };
    };
}

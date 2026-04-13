{ inputs, lib, ... }:
let
  berkeleyMono =
    system:
    let
      packages = inputs.nix-secrets.packages or { };
    in
    if packages ? ${system} && packages.${system} ? BerkeleyMonoFont then
      packages.${system}.BerkeleyMonoFont
    else
      null;
in
{
  flake.modules.nixos.gui =
    { pkgs, ... }:
    let
      berkeleyMonoPackage = berkeleyMono pkgs.stdenv.hostPlatform.system;
      hasBerkeleyMono = berkeleyMonoPackage != null;
      primaryMono = if hasBerkeleyMono then "Berkeley Mono" else "JetBrainsMono Nerd Font";
    in
    {
      options.custom.fonts = {
        regular = lib.mkOption {
          type = lib.types.str;
          default = "Geist";
          description = "The font to use for regular text";
        };
        monospace = lib.mkOption {
          type = lib.types.str;
          default = primaryMono;
          description = "The font to use for monospace text";
        };
      };

      config.fonts = {
        enableDefaultPackages = true;
        packages =
          with pkgs;
          [
            dejavu_fonts
            garamond-libre
            font-awesome
            material-icons
            nerd-fonts.jetbrains-mono
            nerd-fonts.symbols-only
            inter
            ibm-plex
          ]
          ++ lib.optional hasBerkeleyMono berkeleyMonoPackage;

        fontconfig = {
          enable = true;
          cache32Bit = true;
          defaultFonts = {
            serif = [
              "IBM Plex Serif"
              "Noto Serif CJK JP"
              "Symbols Nerd Font"
            ];
            sansSerif = [
              "IBM Plex Sans"
              "Noto Sans CJK JP"
              "Symbols Nerd Font"
            ];
            monospace = [
              primaryMono
              "IBM Plex Mono"
              "Noto Sans CJK JP"
              "Symbols Nerd Font"
            ];
            emoji = [ "Noto Emoji" ];
          };
        };
      };
    };
}

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

      kalpurush = pkgs.stdenvNoCC.mkDerivation {
        pname = "kalpurush";
        version = "0.258";
        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/potasiyam/kalpurush/212bef1414db954b9259f099c0fdbad5cd95a80e/release/Kalpurush0.258ship.ttf";
          hash = "sha256-g2E6A+U6rYM38r6fuXRAmiPB2Zs7S0lFZ7qdFWxJKwE=";
        };
        dontUnpack = true;
        installPhase = ''
          install -Dm644 $src $out/share/fonts/truetype/Kalpurush.ttf
        '';
        meta = {
          description = "Kalpurush Bengali font (OmicronLab/Ekushey)";
          license = lib.licenses.ofl;
          platforms = lib.platforms.all;
        };
      };
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
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
            kalpurush
          ]
          ++ lib.optional hasBerkeleyMono berkeleyMonoPackage;

        fontconfig = {
          enable = true;
          cache32Bit = true;
          defaultFonts = {
            serif = [
              "IBM Plex Serif"
              "Noto Serif CJK JP"
              "Kalpurush"
              "Noto Serif Bengali"
              "Symbols Nerd Font"
            ];
            sansSerif = [
              "IBM Plex Sans"
              "Noto Sans CJK JP"
              "Kalpurush"
              "Noto Sans Bengali"
              "Symbols Nerd Font"
            ];
            monospace = [
              primaryMono
              "IBM Plex Mono"
              "Noto Sans CJK JP"
              "Kalpurush"
              "Noto Sans Bengali"
              "Symbols Nerd Font"
            ];
            emoji = [ "Noto Emoji" ];
          };
        };
      };
    };
}

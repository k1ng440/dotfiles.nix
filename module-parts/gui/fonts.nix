{ inputs, lib, ... }:
{
  flake.modules.nixos.gui_font =
  { pkgs, ... }:
  {
    options.custom = {
      fonts = {
        regular = lib.mkOption {
          type = lib.types.str;
          default = "Geist";
          description = "The font to use for regular text";
        };
        monospace = lib.mkOption {
          type = lib.types.str;
          default = "JetBrainsMono Nerd Font";
          description = "The font to use for monospace text";
        };
      };
    };

    config = {
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          dejavu_fonts
          # noto-fonts
          garamond-libre
          font-awesome
          material-icons
          # noto-fonts-cjk-sans
          # noto-fonts-cjk-serif
          # noto-fonts-monochrome-emoji
          nerd-fonts.jetbrains-mono
          nerd-fonts.symbols-only
          inter
          ibm-plex
          inputs.nix-secrets.packages."${pkgs.stdenv.hostPlatform.system}".BerkeleyMonoFont
        ];
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
              "IBM Plex Mono"
              "Noto Sans CJK JP"
              "Symbols Nerd Font"
            ];
            emoji = [ "Noto Emoji" ];
          };
        };
      };
    };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nixconfig.desktop-environment;
in
{
  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      font-awesome
      material-icons
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "NerdFontsSymbolsOnly"
        ];
      })
      inter
      ibm-plex
    ];

    # ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.maple-mono);
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "IBM Plex Serif"
          "Symbols Nerd Font"
        ];
        sansSerif = [
          "IBM Plex Sans"
          "Symbols Nerd Font"
        ];
        monospace = [
          "IBM Plex Mono"
          "Symbols Nerd Font"
        ];
        emoji = [ "Noto Emoji" ];
      };
    };
  };
}

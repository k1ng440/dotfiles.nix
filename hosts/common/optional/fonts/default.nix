{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{

  config = lib.mkIf (config.machine.useWindowManager && !config.isMinimal) {
    fonts.packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      garamond-libre
      font-awesome
      material-icons
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      inter
      ibm-plex
      inputs.nix-secrets.packages."${pkgs.system}".BerkeleyMonoFont
    ];

    fonts.fontconfig = {
      enable = true;
      cache32Bit = true;
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

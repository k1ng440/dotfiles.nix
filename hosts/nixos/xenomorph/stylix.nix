{
  pkgs,
  lib,
  ...
}:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml"; # preview https://dt.iki.fi/base16-previews#gruvbox-dark-hard
    image = ../../../assets/wallpapers/wallpaper_3862_3440x1440.jpg;
    polarity = "dark";
    fonts = {
      monospace = {
        package = pkgs.fira-code;
        name = "FiraCode";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme = lib.mkForce "lxqt";
    style = lib.mkForce "adwaita-dark";
  };
}

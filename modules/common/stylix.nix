{
  pkgs,
  lib,
  ...
}:
{
  stylix = {
    enable = true;
    image = lib.custom.relativeToRoot "assets/wallpapers/cyberpunk-1.jpg";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
    polarity = "dark";

    opacity = {
      terminal = 0.9;
      applications = 0.9;
      desktop = 0.9;
      popups = 0.9;
    };

    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 28;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      serif = {
        package = pkgs.roboto;
        name = "Roboto";
      };

      sizes = {
        applications = 12;
        terminal = 14;
        desktop = 10;
        popups = 10;
      };
    };
  };
}

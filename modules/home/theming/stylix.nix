{inputs, config, pkgs, lib, ...}: {
  # disabledModules = [
  #   "${inputs.stylix}/modules/neovim/hm.nix"
  #   "${inputs.stylix}/modules/lazygit/hm.nix"
  # ];
  #
  # stylix.targets = {
  #   waybar.enable = false;
  #   rofi.enable = false;
  #   hyprland.enable = false;
  #   hyprlock.enable = false;
  #   ghostty.enable = false;
  #   qt.enable = true;
  # };

  # https://journix.dev/posts/ricing-linux-has-never-been-easier-nixos-and-stylix/
  # config = lib.mkIf config.hostSpec.isAutoStyled {
  #   stylix = {
  #     enable = true;
  #     base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  #     image = ../../../assets/wallpapers/wallpaper_3862_3440x1440.jpg;
  #     polarity = "dark";
  #     fonts = {
  #       monospace = {
  #         package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
  #         name = "JetBrainsMono Nerd Font Mono";
  #       };
  #
  #       serif = {
  #         package = pkgs.dejavu_fonts;
  #         name = "DejaVu Serif";
  #       };
  #
  #       sansSerif = {
  #         package = pkgs.dejavu_fonts;
  #         name = "DejaVu Sans";
  #       };
  #
  #       # monospace = {
  #       #   package = pkgs.dejavu_fonts;
  #       #   name = "DejaVu Sans Mono";
  #       # };
  #
  #       emoji = {
  #         package = pkgs.noto-fonts-emoji;
  #         name = "Noto Color Emoji";
  #       };
  #     };
  #
  #     cursor = {
  #       package = pkgs.bibata-cursors;
  #       name = "Bibata-Modern-Ice";
  #       size = 24;
  #     };
  #   };
  # };
}

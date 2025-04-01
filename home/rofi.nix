{...}: {
  home.file.".config/rofi/config.rasi".text = builtins.readFile ../rofi/config.rasi;
  home.file.".local/share/rofi/tokyonight.rasi".text = builtins.readFile ../rofi/tokyonight.rasi;
  home.file.".config/rofi/scripts/rofi-power-menu".text = builtins.readFile ../rofi/scripts/rofi-power-menu;
}

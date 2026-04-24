{ lib, ... }:
{
  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    {
      environment = {
        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "qt6ct";
          QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
        };

        systemPackages = with pkgs; [
          qt6Packages.qt6ct
          qt6Packages.qtstyleplugin-kvantum
          qt6Packages.qtwayland
        ];
      };

      custom.programs.noctalia.colors.templates =
        let
          defaultFont = "${config.custom.gtk.font.name},${toString config.custom.gtk.font.size}";
          createQtctConf = filename: font: {
            input_path = pkgs.writeText filename (
              lib.generators.toINI { } {
                Appearance = {
                  color_scheme_path = "%HOME%/.config/qt6ct/colors/matugen.conf";
                  custom_palette = true;
                  icon_theme = "Tela-{{ colors.primary.default.hex_stripped }}";
                  standard_dialogs = "xdgdesktopportal";
                  style = "kvantum";
                };
                Fonts = {
                  fixed = font;
                  general = font;
                };
              }
            );
            output_path = "${config.hj.xdg.config.directory}/${filename}";
          };
        in
        {
          "qt5ct.conf" = createQtctConf "qt5ct.conf" ''"${defaultFont},-1,5,50,0,0,0,0,0"'';
          "qt6ct.conf" =
            createQtctConf "qt6ct.conf" ''"${defaultFont},-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular"'';
        };
    };
}

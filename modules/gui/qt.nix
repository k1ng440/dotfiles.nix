{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      # Template for dynamic Kvantum theme
      kvantum-template = pkgs.runCommand "kvantum-template" { } /* sh */ ''
        mkdir -p $out/share/Kvantum

        # Use rose-pine-moon-iris as base template
        cp -r ${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-moon-iris "$out/share/Kvantum/Noctalia-Template"

        # Make it writable for dynamic color replacement
        chmod -R +w "$out/share/Kvantum/Noctalia-Template"

        # Replace the accent color with a placeholder
        find "$out/share/Kvantum/Noctalia-Template" -name "*.svg" -exec sed -i \
          -e 's/#c4a7e7/#PLACEHOLDER_ACCENT/g' \
          {} +
      '';
    in
    {
      packages = {
        inherit kvantum-template;

        # Script to generate dynamic Kvantum theme from noctalia colors
        dynamic-kvantum-theme = pkgs.writeShellApplication {
          name = "dynamic-kvantum-theme";
          runtimeInputs = [ ];
          text = /* sh */ ''
                        if [[ -z "''${1:-}" ]]; then
                            echo "ERROR: A hex color is required. (e.g. #c4a7e7)"
                            exit 1
                        fi

                        COLOR="''${1#\#}"
                        THEME_NAME="Noctalia-''${COLOR}"
                        THEME_DIR="$HOME/.config/Kvantum/$THEME_NAME"

                        mkdir -p "$HOME/.config/Kvantum"
                        rm -rf "$THEME_DIR"
                        
                        cp -r ${kvantum-template}/share/Kvantum/Noctalia-Template "$THEME_DIR"

                        # Replace placeholder with actual color
                        find "$THEME_DIR" -name "*.svg" -exec sed -i "s/#PLACEHOLDER_ACCENT/$1/g" {} +
                        
                        # Update the kvconfig file
                        cat > "$THEME_DIR/$THEME_NAME.kvconfig" << EOF
            [General]
            theme=$THEME_NAME
            EOF
          '';
        };
      };
    };

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    {
      environment = {
        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "qt5ct";
          QT_STYLE_OVERRIDE = "kvantum";
        };

        systemPackages = with pkgs; [
          qt6Packages.qt6ct
          qt6Packages.qtstyleplugin-kvantum
          qt6Packages.qtwayland
          pkgs.rose-pine-kvantum
          pkgs.custom.dynamic-kvantum-theme
        ];
      };

      # use gtk theme on qt apps
      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "kvantum";
      };

      custom.programs.noctalia.colors.templates =
        let
          defaultFont = "${config.custom.gtk.font.name},${toString config.custom.gtk.font.size}";
          createQtctConf = filename: font: {
            # dummy values so noctalia doesn't complain
            input_path = pkgs.writeText filename (
              lib.generators.toINI { } {
                Appearance = {
                  custom_palette = false;
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

          # Dynamic Kvantum theme
          "kvantum-theme" = {
            post_hook = ''${lib.getExe pkgs.custom.dynamic-kvantum-theme} "{{ colors.primary.default.hex }}"'';
            input_path = "${config.hj.xdg.config.directory}/user-dirs.conf";
            output_path = "/dev/null";
          };
        };

      hj.xdg.config.files = {
        "Kvantum/kvantum.kvconfig" = {
          generator = lib.generators.toINI { };
          value = {
            General.theme = "Noctalia-PLACEHOLDER";
          };
        };
      };
    };
}

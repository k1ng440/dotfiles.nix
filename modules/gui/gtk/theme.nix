{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      # Template for dynamic GTK theme generation
      gtk-theme-template = pkgs.runCommand "gtk-theme-template" { } /* sh */ ''
        mkdir -p $out/share/themes

        # Use rose-pine-gtk-theme as base template
        src="${pkgs.rose-pine-gtk-theme}/share/themes/rose-pine-moon"
        cp -rT "$src/" "$out/"

        # Make it writable for dynamic color replacement
        chmod -R +w "$out"
      '';
    in
    {
      packages = {
        inherit gtk-theme-template;

        # Script to generate dynamic GTK theme from noctalia colors
        dynamic-gtk-theme = pkgs.writeShellApplication {
          name = "dynamic-gtk-theme";
          runtimeInputs = [ pkgs.dconf ];
          text = /* sh */ ''
            if [[ -z "''${1:-}" || -z "''${2:-}" ]]; then
                echo "ERROR: Two hex colors required (primary, background)"
                exit 1
            fi

            PRIMARY="''${1#\#}"
            BG="''${2#\#}"
            THEME_NAME="Noctalia-''${PRIMARY}-''${BG}"
            THEME_DIR="/tmp/$THEME_NAME"

            if [[ ! -d "$THEME_DIR" ]]; then
              cp -r ${gtk-theme-template} "$THEME_DIR"
              chmod -R +w "$THEME_DIR"

              # Replace accent colors in CSS files
              find "$THEME_DIR" -name "*.css" -type f -exec sed -i \
                -e "s/c4a7e7/$PRIMARY/g" \
                -e "s/232136/$BG/g" \
                {} +

              sed -i "s/rose-pine-moon/$THEME_NAME/g" "$THEME_DIR/index.theme"
            fi

            mkdir -p "$HOME/.local/share/themes"
            ln -sfn "$THEME_DIR" "$HOME/.local/share/themes/$THEME_NAME"
            dconf write "/org/gnome/desktop/interface/gtk-theme" "'$THEME_NAME'"
          '';
        };
      };
    };

  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      options.custom = {
        gtk = {
          theme = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.rose-pine-gtk-theme;
              description = "Package providing the theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              # Default to rose-pine-moon until noctalia generates dynamic theme
              default = "rose-pine-moon";
              description = "The name of the theme within the package.";
            };
          };
        };
      };
    };

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.rose-pine-gtk-theme
        pkgs.custom.dynamic-gtk-theme
      ];

      # set dynamic GTK theme with noctalia
      custom.programs.noctalia.colors.templates = {
        "gtk-theme" = {
          post_hook = ''${lib.getExe pkgs.custom.dynamic-gtk-theme} "{{ colors.primary.default.hex }}" "{{ colors.background.default.hex }}"'';
          # Dummy values so noctalia doesn't complain
          input_path = "${config.hj.xdg.config.directory}/user-dirs.conf";
          output_path = "/dev/null";
        };
      };
    };
}

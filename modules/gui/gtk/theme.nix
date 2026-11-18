{ lib, ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      options.custom = {
        gtk = {
          theme = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.juno-theme;
              description = "Package providing the theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "Juno";
              description = "The name of the theme within the package.";
            };
          };
        };
      };
    };

  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        config.custom.gtk.theme.package
      ];

      # gtk.css only imports noctalia.css so a rebuild cannot clobber the palette;
      # noctalia renders the imported file itself (see templates below).
      hj.xdg = {
        config.files."gtk-3.0/gtk.css".text = ''
          @import url("noctalia.css");
        '';

        config.files."gtk-4.0/gtk.css".text = ''
          @import url("noctalia.css");
        '';
      };

      custom.programs.noctalia.colors.templates = {
        "gtk3" = {
          input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/gtk/gtk3.css";
          output_path = "${config.hj.xdg.config.directory}/gtk-3.0/noctalia.css";
        };

        "gtk4" = {
          input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/gtk/gtk4.css";
          output_path = "${config.hj.xdg.config.directory}/gtk-4.0/noctalia.css";
        };
      };
    };
}

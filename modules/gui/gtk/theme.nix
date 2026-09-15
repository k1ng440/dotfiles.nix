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
    { config, ... }:
    {
      environment.systemPackages = [
        config.custom.gtk.theme.package
      ];

      hj.xdg = {
        config.files."gtk-3.0/gtk.css".text = ''
          @import url("dank-colors.css");
        '';

        config.files."gtk-4.0/gtk.css".text = ''
          @import url("dank-colors.css");
        '';
      };
    };
}

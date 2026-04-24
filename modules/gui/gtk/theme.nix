{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        tokyonight-gtk-theme =
          (pkgs.tokyonight-gtk-theme.override {
            colorVariants = [ "dark" ];
            sizeVariants = [ "compact" ];
            themeVariants = [ "all" ];
          }).overrideAttrs
            (o: {
              patches = (o.patches or [ ]) ++ [ ./tokyonight-style.patch ];

              postInstall = (o.postInstall or "") + ''
                rm -rf $out/share/themes/*Light*

                for theme in "$out"/share/themes/*Dark*; do
                  ln -s "$theme" "''${theme/Dark/Light}";
                done
              '';
            });
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
              default = pkgs.custom.tokyonight-gtk-theme;
              description = "Package providing the theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "Tokyonight-Dark-Compact";
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

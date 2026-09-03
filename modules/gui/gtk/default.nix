{ lib, ... }:
{
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    {
      options.custom = {
        # type referenced from nixpkgs:
        # https://github.com/NixOS/nixpkgs/blob/554be6495561ff07b6c724047bdd7e0716aa7b46/nixos/modules/programs/dconf.nix#L121C9-L134C11
        dconf.settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "An attrset used to generate dconf keyfile.";
          example = lib.literalExpression ''
            with lib.gvariant;
            {
              "com/raggesilver/BlackBox" = {
                scrollback-lines = mkUint32 10000;
                theme-dark = "Tommorrow Night";
              };
            }
          '';
        };
        gtk = {
          bookmarks = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "/home/jane/Documents" ];
            description = "File browser bookmarks.";
          };

          font = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.geist-font;
              description = "Package providing the font";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = config.custom.fonts.regular;
              description = "The family name of the font within the package.";
            };

            size = lib.mkOption {
              type = lib.types.number;
              default = 10;
              description = "The size of the font.";
            };
          };

        };
      };
    };

  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    let
      gtkCfg = config.custom.gtk;
      toIni = lib.generators.toINI {
        mkKeyValue =
          key: value:
          let
            value' = if lib.isBool value then lib.boolToString value else toString value;
          in
          "${lib.escape [ "=" ] key}=${value'}";
      };
      gtkIni = toIni {
        Settings = {
          gtk-theme-name = gtkCfg.theme.name;
          gtk-icon-theme-name = config.custom.gtk.iconTheme.name;
          gtk-font-name = "${gtkCfg.font.name} 10";
          gtk-application-prefer-dark-theme = 1;
          gtk-error-bell = 0;
        };
      };
    in
    {
      environment = {
        etc = {
          "xdg/gtk-3.0/settings.ini".text = gtkIni;
          "xdg/gtk-4.0/settings.ini".text = gtkIni;
          "xdg/gtk-2.0/gtkrc".text = ''
            gtk-font-name = "${gtkCfg.font.name} 10";
            gtk-icon-theme-name = "${config.custom.gtk.iconTheme.name}";
            gtk-theme-name = "${gtkCfg.theme.name}";
          '';
        };

        sessionVariables = {
          GTK2_RC_FILES = "/etc/xdg/gtk-2.0/gtkrc";
        };
      };

      fonts.packages = [
        gtkCfg.font.package
      ];

      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = lib.recursiveUpdate config.custom.dconf.settings {
              # disable dconf first use warning
              "ca/desrt/dconf-editor" = {
                show-warning = false;
              };
              # gtk related settings
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark"; # set dark theme for gtk 4
                cursor-theme = gtkCfg.cursor.name;
                cursor-size = lib.gvariant.mkUint32 gtkCfg.cursor.size;
                font-name = "${gtkCfg.font.name} 10";
                gtk-theme = gtkCfg.theme.name;
                icon-theme = gtkCfg.iconTheme.name;
                # disable middle click paste
                gtk-enable-primary-paste = false;
              };
            };
          }
        ];
      };

      hj.xdg = {
        # use per user settings
        config.files."gtk-3.0/bookmarks".text = lib.concatMapStringsSep "\n" (
          b: "file://${b}"
        ) gtkCfg.bookmarks;
      };

      # The NixOS `programs.dconf` module only writes read-only database
      # files into /nix/store. The mutable `~/.config/dconf/user` database
      # has higher precedence, so stale keys there (e.g. gtk-theme pointing
      # at a removed theme) silently override the declarative settings and
      # make GTK apps fall back to a light theme.
      #
      # hjem has no activation hooks, so reset these keys once per graphical
      # session to make the declarative values win again.
      systemd.user.services.gtk-dconf-reset = {
        description = "Reset stale GTK theme dconf overrides";
        wantedBy = [ "graphical-session.target" ];
        before = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.glib.bin}/bin/gsettings reset org.gnome.desktop.interface gtk-theme
          ${pkgs.glib.bin}/bin/gsettings reset org.gnome.desktop.interface color-scheme
        '';
      };
    };
}

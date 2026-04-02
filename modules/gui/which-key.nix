{
  flake.modules.nixos.programs_whichkey =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.custom.programs.which-key;
      yamlFormat = pkgs.formats.yaml { };

      menusToList =
        menus:
        lib.mapAttrsToList (
          key: entry:
          if entry ? submenu && entry.submenu != null then
            {
              inherit key;
              inherit (entry) desc;
              submenu = menusToList entry.submenu;
            }
          else
            {
              inherit key;
              inherit (entry) desc cmd;
            }
        ) menus;

      configFile = yamlFormat.generate "which-key-config.yaml" (
        cfg.settings // { menu = menusToList cfg.menus; }
      );
      menuPkg = pkgs.writeShellScriptBin "which-key-menu" ''
        exec ${pkgs.lib.getExe pkgs.wlr-which-key} ${configFile} "$@"
      '';

      menuType = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            key = lib.mkOption { type = lib.types.str; };
            desc = lib.mkOption { type = lib.types.str; };
            cmd = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            submenu = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.attrsOf (
                  lib.types.submodule {
                    options = {
                      key = lib.mkOption { type = lib.types.str; };
                      desc = lib.mkOption { type = lib.types.str; };
                      cmd = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                      };
                      submenu = lib.mkOption {
                        type = lib.types.nullOr lib.types.attrs;
                        default = null;
                      };
                    };
                  }
                )
              );
              default = null;
            };
          };
        }
      );
    in
    {
      options.custom.programs.which-key = {
        settings = lib.mkOption {
          type = lib.types.attrs;
          default = {
            font = "Berkeley Mono 15";
            background = "#24283bd0";
            color = "#c0caf5";
            border = "#7aa2f7";
            separator = " ➜ ";
            anchor = "center";
            corner_r = 10;
            padding = 15;
            border_width = 2;
          };
        };
        menus = lib.mkOption {
          type = menuType;
          default = { };
        };
      };
      config = lib.mkIf (cfg.menus != { }) {
        environment.systemPackages = [ menuPkg ];
        custom.programs.niri.settings.binds."Mod+D".spawn = [
          (lib.getExe menuPkg)
        ];
      };
    };
}

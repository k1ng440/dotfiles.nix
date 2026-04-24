{ lib, ... }:
{
  flake.modules.nixos.core = {
    options.custom = {
      startup = lib.mkOption {
        description = "Programs to run on startup";
        type = lib.types.listOf (
          lib.types.oneOf [
            lib.types.str
            (lib.types.submodule {
              options = {
                app-id = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  description = "The app-id (class) of the program to start";
                  default = null;
                };
                enable = lib.mkEnableOption "Rule" // {
                  default = true;
                };
                title = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  description = "The window title of the program to start, for differentiating between multiple instances";
                  default = null;
                };
                delay = lib.mkOption {
                  type = lib.types.int;
                  description = "Delay in seconds before starting the program";
                  default = 0;
                };
                spawn = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  description = "Command to execute";
                  default = null;
                };
                workspace = lib.mkOption {
                  type = lib.types.nullOr lib.types.int;
                  description = "lib.Optional workspace to start program on";
                  default = null;
                };
                niriArgs = lib.mkOption {
                  type = lib.types.attrs;
                  description = "Extra arguments for niri window rules";
                  default = { };
                };
              };
            })
          ]
        );
        default = [ ];
      };

      startupServices = lib.mkOption {
        description = "Services to start after the WM is initialized";
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  # flake.modules.nixos.wm =
  # generic functionality for all WMs
  # { config, ... }:
  # let
  # ensure setting terminal title using --title or exec with -e works
  # termExe =
  #   assert config.custom.programs.terminal.package.pname == "ghostty";
  #   "ghostty";
  # in
  # {
  #   custom = {
  #     startup = [
  #     ];
  #   };
  # };
}

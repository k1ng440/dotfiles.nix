# The options set using this module are intended for use with logic defined in specific workspace management configurations.
{ lib, config, ... }:
{
  options.monitors = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            example = "DP-1";
          };
          primary = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          noBar = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          width = lib.mkOption {
            type = lib.types.int;
            example = 1920;
          };
          height = lib.mkOption {
            type = lib.types.int;
            example = 1080;
          };
          refreshRate = lib.mkOption {
            type = lib.types.int;
            default = 60;
          };
          x = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
          y = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
          scale = lib.mkOption {
            type = lib.types.number;
            default = 1.0;
          };
          transform = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          workspaces = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "The name or ID of the workspace (e.g., '1', 'main', 'web').";
                  example = "1";
                };
                persistent = lib.mkOption {
                  type = lib.types.bool;
                  description = "Whether the workspace persists even when empty.";
                  default = false;
                  example = true;
                };
                default = lib.mkOption {
                  type = lib.types.bool;
                  description = "Whether this workspace is the default one for the monitor.";
                  default = false;
                  example = true;
                };
                layout = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  description = "The layout for this workspace (e.g., 'dwindle', 'master').";
                  default = null;
                  example = "dwindle";
                };
                onStart = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  description = "Commands to run when the workspace is created.";
                  default = null;
                  example = ["firefox" "kitty"];
                };
              };
            }));
            description = ''
              Defines a list of workspaces that should be configured for this monitor.
              Each workspace can specify its name, persistence, default status, and layout.
            '';
            default = null;
          };
          vrr = lib.mkOption {
            type = lib.types.int;
            description = "Variable Refresh Rate aka Adaptive Sync aka AMD FreeSync.\nValues are oriented towards hyprland's vrr values which are:\n0 = off, 1 = on, 2 = fullscreen only\nhttps://wiki.hyprland.org/Configuring/Variables/#misc";
            default = 0;
          };

        };
      }
    );
    default = [ ];
  };
  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
      {
        assertion = let
          workspaceNames = lib.concatMap (m: map (w: w.name) (m.workspaces or [])) config.monitors;
        in lib.length (lib.unique workspaceNames) == lib.length workspaceNames || true;
        message = "Duplicate workspace names detected.";
      }
    ];
  };
}

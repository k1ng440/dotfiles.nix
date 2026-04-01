{ lib, self, ... }:
{
  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) host;
      gap = if host == "xenomorph" then 8 else 4;
      strut = gap + 12;
    in
    {
      custom.programs = {
        niri.settings = {
          layout = {
            gaps = gap;

            struts = {
              left = strut;
              right = strut;
              top = gap;
              bottom = gap;
            };
            focus-ring = {
              width = 2;
              # Overwritten by wallpaper script later
              active-gradient._attrs = {
                angle = 45;
                from = "#89B4FA";
                relative-to = "workspace-view";
                to = "#94E2D5";
              };
              inactive-color = "#1e1e2e";
            };
            border = {
              off = null;
            };
            shadow = {
              on = null;
              offset._attrs = {
                x = 0.0;
                y = 5.0;
              };
              softness = 30;
              spread = 4;
              draw-behind-window = false;
              color = "#1a1a1aee";
            };
            tab-indicator = {
              hide-when-single-tab = null;
              gap = 0;
              width = 12;
              length._attrs = {
                total-proportion = 1.0;
              };
              position = "top";
              gaps-between-tabs = 0.0;
              corner-radius = 0.0;
            };
            default-column-width = {
              proportion = 0.5;
            };
            preset-column-widths = [
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
              { proportion = 1.0; }
            ];
            preset-window-heights = [
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
              { proportion = 1.0; }
            ];
            center-focused-column = "never";
            always-center-single-column = null;
          };

          window-rules = [
            {
              draw-border-with-background = false;
              geometry-corner-radius = 4;
              clip-to-geometry = true;
              open-maximized-to-edges = false;
            }
          ];

          # use blurred overview from noctalia
          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-overview*"; } ];
              place-within-backdrop = true;
            }
          ];

          # create monitors config
          outputs =
            config.custom.hardware.monitors
            |> lib.imap1 (
              i: d:
              let
                # Normalizes rotation to 0, 90, 180, 270
                rotationVal = lib.mod (d.transform * 90) 360;
                rotationStr = toString rotationVal;

                # 4-7 are typically the 'flipped' variants in DRM/Wayland
                flipped = d.transform >= 4;

                # Vertical if rotated 90 or 270 (1, 3, 5, 7)
                isVertical = lib.mod d.transform 2 != 0;

                transformName = "${lib.optionalString flipped "flipped-"}${
                  if rotationStr == "0" then "normal" else rotationStr
                }";
              in
              {
                inherit (d) name;
                value = {
                  inherit (d) scale;
                  mode = "${toString d.width}x${toString d.height}";
                  transform = transformName;
                  position._attrs = { inherit (d) x y; };
                }
                // lib.optionalAttrs (i == 1) {
                  focus-at-startup = null;
                }
                // lib.optionalAttrs (d.vrr or false) {
                  variable-refresh-rate = null;
                }
                // lib.optionalAttrs isVertical {
                  layout = {
                    default-column-width = {
                      proportion = 1.0;
                    };
                  };
                };
              }
            )
            |> lib.listToAttrs;

          input = {
            keyboard = {
              xkb = {
                layout = "us";
                model = "";
                rules = "";
                variant = "";
              };
              repeat-delay = 200;
              repeat-rate = 50;
              track-layout = "global";
              numlock = null;
            };
            mouse.accel-profile = "flat";
            touchpad = {
              tap = null;
              dwt = null;
            };
            focus-follows-mouse._attrs = {
              max-scroll-amount = "85%";
            };
            # workspace-auto-back-and-forth = null;
            disable-power-key-handling = null;
          };

          blur = {
            on = null;
            passes = 2;
            offset = 1;
            noise = 0.02;
            saturation = 1.5;
          };

          prefer-no-csd = null;

          gestures = {
            hot-corners = {
              off = null;
            };
          };

          cursor = {
            xcursor-theme = config.custom.gtk.cursor.name;
            xcursor-size = config.custom.gtk.cursor.size;
          };

          recent-windows.binds = {
            "Alt+Tab" = {
              next-window._attrs = {
                scope = "output";
              };
            };
            "Alt+Shift+Tab" = {
              previous-window._attrs = {
                scope = "output";
              };
            };
            "Ctrl+Alt+Tab" = {
              next-window._attrs = {
                scope = "all";
                filter = "app-id";
              };
            };
            "Ctrl+Alt+Shift+Tab" = {
              previous-window._attrs = {
                scope = "all";
                filter = "app-id";
              };
            };
          };

          screenshot-path = "${config.hj.directory}/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S%z.png";

          debug = {
            honor-xdg-activation-with-invalid-serial = null;
          };

          hotkey-overlay = {
            skip-at-startup = null;
          };

          clipboard = {
            disable-primary = null;
          };

          overview = {
            zoom = 0.4;
          };

          xwayland-satellite = {
            path = lib.getExe pkgs.xwayland-satellite;
          };

          extraConfig = lib.mkMerge [
            # Don't use the workspaces key in setting as attrset keys are unordered and it becomes 1, 10, 2, 3...
            (
              config.custom.hardware.monitors
              |> self.libCustom.mapWorkspaces (
                {
                  workspace,
                  monitor,
                  ...
                }:
                ''workspace "${toString workspace}" { open-on-output "${monitor.name}"; }''
              )
              |> lib.concatLines
            )
            # Always source original config.kdl at the end
            (lib.mkAfter ''
              include optional=true "${config.hj.xdg.config.directory}/niri/config.kdl";
              include optional=true "${config.hj.xdg.config.directory}/niri/noctalia.kdl";
            '')
          ];
        };
      };
    };
}

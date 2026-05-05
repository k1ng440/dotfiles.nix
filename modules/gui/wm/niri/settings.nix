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
            background-color = "transparent";

            struts = {
              left = strut;
              right = strut;
              top = gap;
              bottom = gap;
            };
            focus-ring = {
              width = 2;
              # Overwritten by wallpaper script later
              active-gradient = _: {
                props = {
                  angle = 45;
                  from = "#89B4FA";
                  relative-to = "workspace-view";
                  to = "#94E2D5";
                };
              };
              inactive-color = "#1e1e2e";
            };
            border = {
              off = _: { };
            };
            shadow = {
              on = _: { };
              offset = _: {
                x = 0.0;
                y = 5.0;
              };
              softness = 30;
              spread = 4;
              draw-behind-window = false;
              color = "#1a1a1aee";
            };
            tab-indicator = {
              hide-when-single-tab = _: { };
              gap = 0;
              width = 12;
              length = _: {
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
            always-center-single-column = _: { };
          };
          window-rules = [
            # General window appearance
            {
              draw-border-with-background = false;
              geometry-corner-radius = 4;
              clip-to-geometry = true;
              open-maximized-to-edges = false;
            }
            # DMS windows - float by default
            {
              matches = [
                {
                  app-id = "org.quickshell";
                }
              ];
              open-floating = true;
            }
          ];

          # use blurred overview from noctalia
          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-overview*"; } ];
              place-within-backdrop = true;
            }
            {
              matches = [ { namespace = "^quickshell$"; } ];
              place-within-backdrop = true;
            }
            {
              matches = [ { namespace = "dms:blurwallpaper"; } ];
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
                  position = _: {
                    props = { inherit (d) x y; };
                  };
                }
                // lib.optionalAttrs (i == 1) { focus-at-startup = _: { }; }
                // lib.optionalAttrs d.vrr { variable-refresh-rate = _: { }; }
                // lib.optionalAttrs isVertical {
                  layout = {
                    default-column-width = {
                      proportion = 1.0;
                    };
                  };
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
              numlock = _: { };
            };
            mouse.accel-profile = "flat";
            touchpad = {
              tap = _: { };
              dwt = _: { };
            };
            focus-follows-mouse = _: {
              max-scroll-amount = "85%";
            };
            # workspace-auto-back-and-forth = _: {};
            disable-power-key-handling = _: { };
          };

          blur = {
            on = _: { };
            passes = 2;
            offset = 1;
            noise = 0.02;
            saturation = 1.5;
          };

          prefer-no-csd = _: { };

          gestures = {
            hot-corners = {
              off = _: { };
            };
          };

          cursor = {
            xcursor-theme = config.custom.gtk.cursor.name;
            xcursor-size = config.custom.gtk.cursor.size;
          };

          recent-windows.binds = {
            "Alt+Tab" = {
              next-window = _: {
                props = {
                  scope = "all";
                };
              };
            };
            "Alt+Shift+Tab" = {
              previous-window = _: {
                props = {
                  scope = "output";
                };
              };
            };
            "Ctrl+Alt+Tab" = {
              next-window = _: {
                props = {
                  scope = "all";
                  filter = "app-id";
                };
              };
            };
            "Ctrl+Alt+Shift+Tab" = {
              previous-window = _: {
                props = {
                  scope = "all";
                  filter = "app-id";
                };
              };
            };
          };

          screenshot-path = "${config.hj.directory}/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S%z.png";

          debug = {
            honor-xdg-activation-with-invalid-serial = _: { };
          };

          hotkey-overlay = {
            skip-at-startup = _: { };
          };

          clipboard = {
            disable-primary = _: { };
          };

          overview = {
            zoom = 0.6;
            backdrop-color = "#1e1e2e";
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
            (lib.mkAfter ''
              include optional=true "${config.hj.xdg.config.directory}/niri/config.kdl";
              include optional=true "${config.hj.xdg.config.directory}/niri/dms/colors.kdl";
              include optional=true "${config.hj.xdg.config.directory}/niri/dms/layout.kdl";
              include optional=true "${config.hj.xdg.config.directory}/niri/dms/alttab.kdl";
              include optional=true "${config.hj.xdg.config.directory}/niri/dms/binds.kdl";
            '')
          ];
        };
      };
    };
}

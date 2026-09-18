{
  lib,
  ...
}:
{
  flake.modules.nixos.wm =
    {
      config,
      ...
    }:
    let
      inherit (config.custom.constants) host;
      inherit (config.custom.hardware) monitors;

      gap = if host == "xenomorph" then 8 else 4;
      outer = gap * 2;

      # niri app-id float list -> hyprland window rules
      floatClasses = [
        "^org\\.gnome\\.Calculator$"
        "^localsend$"
        "^nm-connection-editor$"
        "^blueman-manager$"
        "^nwg-look$"
        "^qt5ct$"
        "^qt6ct$"
        "^org\\.gnome\\.FileRoller$"
        "^gnome-disks$"
        "^seahorse$"
        "^swayimg$"
        "^com\\.gabm\\.satty$"
        "^vedetector\\.exe$"
      ];

      # media players forced opaque + floating
      mediaClasses = [
        "^mpv$"
        "^vlc$"
        "^imv$"
        "^zoom$"
        "^feh$"
        "^com\\.obsproject\\.Studio$"
        "^capcut\\.exe$"
      ];

      toMonitor = d: {
        output = d.name;
        mode = "${toString d.width}x${toString d.height}@${toString d.refreshRate}";
        position = "${toString d.x}x${toString d.y}";
        inherit (d) scale transform;
      };

      # old: `workspace = 1, monitor:DP-1`
      # rule names are looked up by the engine, keep them identifier-safe
      slug = s: lib.stringAsChars (c: if builtins.match "[a-zA-Z0-9]" c != null then c else "-") s;

      # old: `workspace = 1, monitor:DP-1`
      toWorkspaceRule =
        d:
        map (
          ws:
          {
            workspace = toString ws;
            monitor = d.name;
          }
          // (lib.optionalAttrs (ws == d.defaultWorkspace) { default = true; })
        ) d.workspaces;
    in
    {
      custom.programs.hyprland = {
        monitors = map toMonitor monitors;

        workspaceRules = lib.flatten (map toWorkspaceRule monitors);

        # old: `animations { bezier = ... }`
        curves = {
          md3_decel = {
            type = "bezier";
            points = [
              [
                0.05
                0.7
              ]
              [
                0.1
                1
              ]
            ];
          };
          md3_accel = {
            type = "bezier";
            points = [
              [
                0.3
                0
              ]
              [
                0.8
                0.15
              ]
            ];
          };
          linear = {
            type = "bezier";
            points = [
              [
                0
                0
              ]
              [
                1
                1
              ]
            ];
          };
          ease = {
            type = "bezier";
            points = [
              [
                0.25
                0.1
              ]
              [
                0.25
                1
              ]
            ];
          };
        };

        # old: `animation = windows, 1, 2, md3_decel, popin 60%`
        # (name, enabled, duration in deciseconds, curve, style)
        # default durations are 3 (windows/workspaces) and 2 (fade/layers);
        # these are snappier. drop to 1 for near-instant.
        animations = [
          {
            leaf = "windows";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
            style = "popin 60%";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
            style = "popin 60%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 2;
            bezier = "md3_accel";
            style = "popin 60%";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
            style = "slidevert";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
            style = "slide";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 2;
            bezier = "md3_accel";
            style = "slide";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
          }
          {
            leaf = "fadeLayers";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 2;
            bezier = "ease";
          }
          {
            leaf = "borderangle";
            enabled = true;
            speed = 20;
            bezier = "linear";
            style = "once";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 2;
            bezier = "md3_decel";
            style = "slide";
          }
        ];

        settings = {
          general = {
            gaps_in = gap;
            gaps_out = outer;
            border_size = 2;

            # niri focus-ring gradient / inactive color
            col = {
              active_border = {
                colors = [
                  "rgba(89B4FAff)"
                  "rgba(94E2D5ff)"
                ];
                angle = 45;
              };
              inactive_border = "rgba(1e1e2eff)";
            };

            resize_on_border = true;
            allow_tearing = false;
            layout = "dwindle";
          };

          animations.enabled = true;

          decoration = {
            rounding = 4;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            blur = {
              enabled = true;
              size = 8;
              passes = 2;
              noise = 0.02;
              contrast = 1.0;
              brightness = 1.0;
              vibrancy = 0.1696;
              new_optimizations = true;
            };

            shadow = {
              enabled = true;
              range = 30;
              render_power = 3;
              color = "rgba(1a1a1aee)";
              offset = [
                0
                5
              ];
            };
          };

          dwindle = {
            preserve_split = true;
            smart_split = false;
            smart_resizing = false;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            force_default_wallpaper = 0;
            focus_on_activate = true;
            disable_xdg_env_checks = true;
          };

          input = {
            kb_layout = "us";
            repeat_delay = 200;
            repeat_rate = 50;
            numlock_by_default = true;

            # niri mouse.accel-profile = "flat"
            sensitivity = 0;
            accel_profile = "flat";
            force_no_accel = true;

            # niri focus-follows-mouse with max-scroll-amount 85%
            follow_mouse = 2;

            touchpad = {
              tap_to_click = true;
              disable_while_typing = true;
              natural_scroll = false;
            };
          };

          cursor = {
            sync_gsettings_theme = true;
            inactive_timeout = 0;
          };

          xwayland = {
            force_zero_scaling = true;
          };
        };

        gestures = [
          {
            fingers = 3;
            direction = "horizontal";
            action = "workspace";
          }
        ];

        # mouse drag move / resize (old bindm)
        binds = [
          {
            keys = "SUPER + mouse:272";
            dsp = "hl.dsp.window.drag()";
            flags.mouse = true;
          }
          {
            keys = "SUPER + mouse:273";
            dsp = "hl.dsp.window.resize()";
            flags.mouse = true;
          }
        ];

        # force opaque + floating for media players
        windowRules =
          (map (c: {
            name = "media-${slug c}";
            match.class = c;
            float = true;
            opacity = "1.0";
          }) mediaClasses)
          ++ (map (c: {
            name = "float-${slug c}";
            match.class = c;
            float = true;
          }) floatClasses)
          ++ [
            {
              name = "steam-opaque";
              match.class = "^(steam)$";
              opacity = "1.0";
            }
            {
              name = "steam-friends";
              match = {
                class = "^(steam)$";
                title = "^(Friends List)$";
              };
              float = true;
            }
            {
              name = "steam-news";
              match = {
                class = "^(steam)$";
                title = "^(Steam - News)$";
              };
              float = true;
            }
            {
              name = "steam-chat";
              match = {
                class = "^(steam)$";
                title = ".* - Chat$";
              };
              float = true;
            }

            {
              name = "pip";
              match.title = "^(Picture-in-Picture)$";
              float = true;
              size = [
                480
                270
              ];
            }
            {
              name = "pip-alt";
              match.title = "^(Picture in picture)$";
              float = true;
              size = [
                480
                270
              ];
            }
          ]
          ++ (map
            (title: {
              name = "portal-${title}";
              match = {
                class = "^(xdg-desktop-portal-gtk)$";
                inherit title;
              };
              float = true;
              size = [
                900
                600
              ];
              center = true;
            })
            [
              "(Open File)"
              "(Save File)"
              "(Open Folder)"
            ]
          )
          ++ [
            {
              name = "pavucontrol";
              match.class = "^(pavucontrol)$";
              float = true;
              size = [
                800
                600
              ];
              center = true;
            }
            {
              name = "helium-zoom";
              match = {
                class = "^(helium)$";
                title = ".*Zoom Meeting$";
              };
              float = true;
              size = [
                800
                600
              ];
              move = [
                "monitor_w-832"
                "32"
              ];
            }
            {
              name = "quickshell-opaque";
              match.class = "^(org\\.quickshell)$";
              opacity = "1.0";
            }
          ];

        layerRules = [
          {
            name = "noctalia-overview";
            match.namespace = "^noctalia-overview.*$";
            ignore_alpha = 0;
            blur = true;
          }
          {
            name = "quickshell";
            match.namespace = "^quickshell$";
            ignore_alpha = 0;
            blur = true;
          }
          {
            name = "dms-blurwallpaper";
            match.namespace = "dms:blurwallpaper";
            ignore_alpha = 0;
            blur = true;
          }
        ];
      };
    };
}

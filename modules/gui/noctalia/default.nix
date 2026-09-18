{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      drv =
        {
          lib,
          noctalia-shell,
          writeShellApplication,
        }:
        writeShellApplication {
          name = "noctalia-ipc";
          runtimeInputs = [ ];
          text = /* sh */ ''
            NOCTALIA="${lib.getExe noctalia-shell}"

            if ! "$NOCTALIA" msg status >/dev/null 2>&1; then
              "$NOCTALIA" --daemon
              sleep 2
            fi

            "$NOCTALIA" msg "$@"
          '';
        };
    in
    {
      packages = rec {
        noctalia-shell' = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        noctalia-ipc = pkgs.callPackage drv { noctalia-shell = noctalia-shell'; };
        noctalia-copy = pkgs.writeShellApplication {
          name = "noctalia-copy";
          runtimeInputs = with pkgs; [
            wl-clipboard
            noctalia-shell'
          ];
          text = /* sh */ ''
            noctalia config export | wl-copy
          '';
        };
        noctalia-diff = pkgs.writeShellApplication {
          name = "noctalia-diff";
          runtimeInputs = with pkgs; [ noctalia-shell' ];
          text = /* sh */ ''
            diff \
              <(noctalia config export) \
              <(cat "''${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml" 2>/dev/null || echo "")
          '';
        };
      };
    };

  flake.modules.nixos.core = {
    options.custom = {
      programs.noctalia = {
        # Reducer functions are used instead of plain attrsets, as attrsets cannot be merged together to override
        # lists at arbitrary indexes
        settingsReducers = lib.mkOption {
          type = lib.types.listOf (
            lib.mkOptionType {
              name = "noctalia-settings-reducer";
              check = lib.isFunction;
            }
          );
          default = [
            (
              prev:
              lib.recursiveUpdate prev {
                hooks.enabled = true;
              }
            )
          ];
          description = "Reducers that will be applied to a copy of desktop's settings.json";
        };
      };
    };
  };

  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) isLaptop;
      # settings.json is the desktop copy of gui-settings.json without any modifications
      defaultSettings = builtins.fromJSON (builtins.readFile ./settings.json);
      noctalia-reload = pkgs.writeShellApplication {
        name = "noctalia-reload";
        runtimeInputs = [ pkgs.noctalia-shell ];
        text = /* sh */ ''
          pkill -x noctalia || true
          sleep 0.2
          noctalia --daemon
        '';
      };
      noctalia-start = pkgs.writeShellApplication {
        name = "noctalia-start";
        runtimeInputs = [
          pkgs.noctalia-shell
          pkgs.custom.noctalia-ipc # needed for wallpaper
        ];
        text = /* sh */ ''
          noctalia --daemon
          sleep 3
          ${lib.optionalString isLaptop "noctalia msg bar-hide"}
          wallpaper
        '';
      };
    in
    {
      nixpkgs.overlays = [
        (_: _prev: {
          noctalia-shell = pkgs.custom.noctalia-shell';
        })
      ];

      hj.xdg =
        let
          official = "https://github.com/noctalia-dev/noctalia-plugins";
        in
        {
          config.files = {
            "noctalia/settings.json" = {
              generator = lib.strings.toJSON;
              # Create settings by applying reducers
              value =
                config.custom.programs.noctalia.settingsReducers
                |> lib.foldl' (curr: reducer: reducer curr) defaultSettings;
            };
            "noctalia/plugins.json" = {
              generator = lib.strings.toJSON;
              value = {
                sources = [
                  {
                    enabled = true;
                    name = "Official Noctalia Plugins";
                    url = official;
                  }
                ];
                states = {
                  # official plugins
                  kaomoji-provider = {
                    enabled = true;
                    sourceUrl = official;
                  };
                  screen-recorder = {
                    enabled = true;
                    sourceUrl = official;
                  };
                  timer = {
                    enabled = true;
                    sourceUrl = official;
                  };
                  polkit-agent = {
                    enabled = true;
                    sourceUrl = official;
                  };
                  kde-connect = {
                    enabled = true;
                    sourceUrl = official;
                  };
                  # third party plugins
                };
                version = 2;
              };
            };
          };
          cache.files = {
          };
        };

      custom = {
        # startup = lib.mkBefore [ { spawn = [ (lib.getExe noctalia-start) ]; } ];

        programs = {
          # Setup blur for hyprland
          hyprland.layerRules = [
            {
              name = "noctalia-background";
              match.namespace = "noctalia-background-.*$";
              ignore_alpha = 0.5;
              blur = true;
            }
          ];

          niri.settings = {
            # bar blur
            layer-rules = [
              {
                matches = [ { namespace = "^noctalia-background-.*$"; } ];
                background-effect = {
                  blur = true;
                };
              }
            ];

            # settings window blur
            window-rules = [
              {
                matches = [ { app-id = "^dev.noctalia.noctalia-qs$"; } ];
                background-effect = {
                  blur = true;
                };
              }
            ];
          };

          print-config = {
            noctalia = /* sh */ "noctalia config export | moor";
          };
        };
      };

      hj.files = {
        ".face".source = ./face.jpg;
      };

      environment.systemPackages = [
        pkgs.noctalia-shell
        pkgs.gpu-screen-recorder # screen recorder plugin
        noctalia-reload
        noctalia-start
      ]
      ++ (with pkgs.custom; [
        noctalia-copy
        noctalia-ipc
        noctalia-diff
      ]);

      custom.persist = {
        home = {
          directories = [
            ".config/noctalia"
            # plugin git repos, materialized plugins, settings.toml overrides
            ".local/state/noctalia"
            # local dev plugins
            ".local/share/noctalia"
          ];
        };
      };
    };
}

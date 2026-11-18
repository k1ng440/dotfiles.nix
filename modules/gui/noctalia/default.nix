{
  inputs,
  ...
}:
let
  # Put Noctalia in the overlay rather than depending on whatever nixpkgs
  # happens to ship, so there is exactly one noctalia binary in the closure and
  # the hjem module's mkDefault package agrees with everything else.
  overlay = final: _prev: {
    noctalia = inputs.noctalia.packages.${final.stdenv.hostPlatform.system}.default;
  };
in
{
  perSystem =
    { pkgs, ... }:
    let
      # The same derivation the nixos overlay exposes as `pkgs.noctalia`.
      # Referenced through the input rather than an overlay because
      # flake-parts' perSystem has no `nixpkgs.overlays` option.
      noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # The `wallpaper` wrapper (modules/gui/wallpaper-go) drives Noctalia with
      # v4's argument order: `noctalia-ipc wallpaper set <path> <monitor>`.
      # v5 renamed the command to `wallpaper-set <connector> <path>` -- the
      # monitor comes first. Translate it so the Go code works unmodified.
      noctalia-ipc = pkgs.writeShellApplication {
        name = "noctalia-ipc";
        runtimeInputs = [ noctalia ];
        text = /* sh */ ''
          if [ "$1" = wallpaper ] && [ "$2" = set ] && [ "$#" -ge 4 ]; then
            shift 2
            path="$1"
            shift
            exec noctalia msg wallpaper-set "$@" "$path"
          fi
          exec noctalia msg "$@"
        '';
      };

      # v5 applies config changes live, so this is a reload rather than the v4
      # pkill/restart. The name is kept because it is bound to Mod+Shift+A and
      # invoked by the `wallpaper` wrapper.
      noctalia-reload = pkgs.writeShellApplication {
        name = "noctalia-reload";
        runtimeInputs = [ noctalia ];
        text = "noctalia msg config-reload";
      };

      # `noctalia config export` still exists in v5 and prints the merged config.
      noctalia-copy = pkgs.writeShellApplication {
        name = "noctalia-copy";
        runtimeInputs = [
          noctalia
          pkgs.wl-clipboard
        ];
        text = "noctalia config export | wl-copy";
      };

      # Shows what the settings UI has layered on top of the declarative config.
      noctalia-diff = pkgs.writeShellApplication {
        name = "noctalia-diff";
        runtimeInputs = [ noctalia ];
        text = /* sh */ ''
          diff \
            <(noctalia config export) \
            <(cat "''${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml" 2>/dev/null || echo "")
        '';
      };
    in
    {
      packages = {
        inherit
          noctalia-ipc
          noctalia-reload
          noctalia-copy
          noctalia-diff
          ;
      };
    };

  # A module that declares `options` must nest every config attribute under an
  # explicit `config`, so that is why the body below is split in two.
  flake.modules.nixos.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.custom.constants) home user;
    in
    {
      options.custom.programs.noctalia = {
        # Reducer functions rather than plain attrsets: attrsets cannot be merged
        # to override a list entry at an arbitrary index.
        settingsReducers = lib.mkOption {
          type = lib.types.listOf (
            lib.mkOptionType {
              name = "noctalia-settings-reducer";
              check = lib.isFunction;
            }
          );
          default = [ ];
          description = ''
            Reducers applied in order to `programs.noctalia.settings`. Each is
            `prev: settings` and returns the updated settings attrset, so other
            modules can contribute to Noctalia's config without restating it.

            A reducer can add or override keys but not remove one.
          '';
        };
      };

      config = {
        nixpkgs.overlays = [ overlay ];

        # Noctalia's hjem module renders `settings` to TOML and runs
        # `noctalia config validate` at build time, so a bad key here fails the
        # build instead of silently doing nothing at runtime.
        hjem.extraModules = [ inputs.noctalia.hjemModules.default ];

        hjem.users.${user}.programs.noctalia = {
          enable = true;

          # Let hjem render config.toml only; the unit and its ordering are
          # owned by the NixOS-side block below. See `custom.startupServices`.
          systemd.enable = false;

          settings = lib.foldl' (curr: reducer: reducer curr) {
            theme = {
              mode = "dark";
              source = "wallpaper";
              wallpaper_scheme = "m3-content";
            };

            # Global output policy for every capture path: the
            # screenshot-region / screenshot-fullscreen IPC commands, the
            # screenshot-annotate editor's Save, and the bar widget all read
            # this one table. Left unset, captures land in XDG_PICTURES_DIR with
            # a `screenshot_%s` name; niri's own screenshot-path is separate and
            # unused now that both compositors route Print through noctalia.
            shell.screenshot = {
              save_to_file = true;
              directory = "${home}/Pictures/Screenshots";
              filename_pattern = "%Y-%m-%dT%H-%M-%S";
              copy_to_clipboard = true;
              # Snapshot the outputs before the overlay opens, so the selection
              # rectangle and the bar are not baked into the capture.
              freeze_screen = true;
              remember_last_region = true;
              show_cursor = false;
              # Leave annotation on Shift+Print / screenshot-annotate instead of
              # forcing the editor open on every plain capture.
              annotate = false;
            };

            wallpaper = {
              enabled = true;
              directory = "${home}/Pictures/Wallpapers";
              fill_mode = "crop";
              transition = [ "fade" ];
              transition_duration = 800.0;
            };

            # Blur is applied from the compositor side (layer rules in the wm
            # modules) rather than through bar settings, so it behaves the same
            # across noctalia versions.
            bar.default = {
              position = "top";
              thickness = 34;
              radius = 12.0;
              start = [
                "launcher"
                "workspaces"
                # Left-click runs screenshot-region, right-click a
                # fullscreen/region menu, both on the shell.screenshot policy
                # above. Omitted entirely if the compositor lacks
                # wlr-screencopy, so this is safe to list unconditionally.
                "screenshot"
              ];
              center = [ "clock" ];
              end = [
                "media"
                "tray"
                "volume"
                "battery"
                "control-center"
                "session"
              ];
            };

            # Stock clock format is 24h ("{:%H:%M}"), `%-I` drops the leading
            # zero on a 12h clock.
            widget.clock.format = "{:%-I:%M %p}";
          } config.custom.programs.noctalia.settingsReducers;
        };

        # `custom.startupServices` is the existing hook for exactly this: both
        # session targets already do `Wants = [ <wm> ] ++ startupServices`
        # together with `Before = startupServices`, and execOnce pulls the
        # target in once the compositor has a Wayland socket
        # (modules/gui/wm/{hyprland,niri}/startup.nix). Listing both
        # compositors is fine -- only the running one's target ever starts.
        #
        # The unit below therefore carries no After=/wantedBy= of its own. A
        # target implicitly orders After everything it Wants, so
        # `after = [ <target> ]` combined with `wantedBy = [ <target> ]` is a
        # self-cycle, and systemd answers it by deleting the start job. That is
        # what the hjem module's unit did: it hardcodes `After = <target>` on
        # top of `wantedBy = <target>` (default graphical-session.target),
        # closing graphical-session.target -> hyprland-session.target ->
        # noctalia.service -> graphical-session.target. That unit was also
        # written to $XDG_CONFIG_HOME/systemd/user, where it shadowed this one.
        # systemd.enable = false above leaves hjem rendering config.toml only.
        custom.startupServices = [ "noctalia.service" ];

        systemd.user.services.noctalia = {
          # Without this the service gets a minimal
          # Environment=PATH=coreutils:findutils:… which clobbers the PATH the
          # display environment imported into the user manager.
          enableDefaultPath = false;

          serviceConfig = {
            ExecStart = lib.getExe pkgs.noctalia;
            # Restart rather than give up: at login the Wayland socket can still
            # be missing, and a dead bar is worse than a slow one.
            Restart = "on-failure";
          };
        };

        custom.programs.print-config.noctalia = "noctalia config export | moor";
      };
    };

  flake.modules.nixos.wm =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs.custom; [
        noctalia-ipc
        noctalia-reload
        noctalia-copy
        noctalia-diff
      ];

      custom.programs = {
        # v5 renamed the app-id from v4's `dev.noctalia.noctalia-qs`.
        niri.settings = {
          window-rules = [
            {
              matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
              open-floating = true;
              default-column-width = {
                fixed = 1080;
              };
              default-window-height = {
                fixed = 920;
              };
            }
          ];
        };
      };

      # `~/.config/noctalia/config.toml` is symlinked into the store by the hjem
      # module, but the settings UI also writes palettes/ into that directory.
      custom.persist.home.directories = [
        ".config/noctalia"
        # GUI-managed overrides. These are merged last and therefore win over
        # config.toml, so this is what to inspect when a setting seems ignored.
        ".local/state/noctalia"
      ];
    };
}

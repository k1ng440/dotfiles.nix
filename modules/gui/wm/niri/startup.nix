{ lib, ... }:
{
  flake.modules.nixos.wm =
    { pkgs, config, ... }:
    let
      # Helper to add delay to spawn commands
      mkSpawn =
        startup:
        if startup.delay > 0 then
          [
            "sh"
            "-c"
            "sleep ${toString startup.delay} && ${lib.escapeShellArgs startup.spawn}"
          ]
        else
          startup.spawn;
    in
    {
      custom.programs.niri.settings = lib.mkMerge (
        (
          config.custom.startup
          |> lib.filter (startup: startup.enable)
          |> map (startup: {
            spawn-at-startup = [ (mkSpawn startup) ];
            window-rules = lib.optional (startup.app-id != null || startup.title != null) (
              {
                matches = [
                  (
                    {
                      at-startup = true;
                    }
                    // (lib.optionalAttrs (startup.app-id != null) { inherit (startup) app-id; })
                    // (lib.optionalAttrs (startup.title != null) { inherit (startup) title; })
                  )
                ];
                open-on-workspace = toString startup.workspace;
              }
              // startup.niriArgs
            );
          })
        )
        ++ [
          {
            spawn-at-startup = lib.mkBefore [
              "${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user niri-session.target"
            ];
          }
        ]
        ++ [
          # Focus default workspace for each monitor
          {
            spawn-at-startup = lib.mkAfter (
              map (mon: [
                "niri"
                "msg"
                "action"
                "focus-workspace"
                "${toString mon.defaultWorkspace}"
              ]) (lib.reverseList config.custom.hardware.monitors)
            );
          }
        ]
      );

      systemd.user = {
        # ly -> niri.service -> niri-session.service -> startupServices
        targets.niri-session = {
          wantedBy = [ "niri.service" ];

          unitConfig = {
            Description = "Niri compositor session";
            BindsTo = [ "niri.service" ];
            # Start the other services here after the WM has already started (push vs pull)
            Wants = [ "niri.service" ] ++ config.custom.startupServices;
            Before = config.custom.startupServices;
            After = [ "niri.service" ];
          };
        };
      };
    };
}

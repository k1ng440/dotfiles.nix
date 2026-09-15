{
  lib,
  ...
}:
{
  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    {
      custom.programs.hyprland.settings = {
        exec-once = [
          # stop fucking with my cursors
          "hyprctl setcursor ${config.custom.gtk.cursor.name} ${toString config.custom.gtk.cursor.size}"
        ]
        # propagate the session env into systemd, then start the session target
        ++ [
          "${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user start hyprland-session.target"
        ]
        # generate from startup options
        ++ builtins.filter (s: s != "") (
          map (
            {
              enable,
              spawn,
              workspace,
              ...
            }:
            let
              rules = lib.optionalString (workspace != null) "[workspace ${toString workspace} silent]";
              exec = lib.concatStringsSep " " spawn;
            in
            lib.optionalString enable "${rules} ${exec}"
          ) config.custom.startup
        )
        # focus default workspace for each monitor
        ++ (
          lib.reverseList config.custom.hardware.monitors
          |> lib.concatMap (mon: [
            "hyprctl dispatch focusmonitor ${mon.name}"
            "hyprctl dispatch workspace ${toString mon.defaultWorkspace}"
          ])
        );
      };

      systemd.user = {
        # ly -> hyprland.service -> hyprland-session.target -> startupServices
        targets.hyprland-session = {
          wantedBy = [ "graphical-session.target" ];

          unitConfig = {
            Description = "Hyprland compositor session";
            BindsTo = [ "graphical-session.target" ];
            # start the other services here after the WM has already started (push vs pull)
            Wants = [ "graphical-session-pre.target" ] ++ config.custom.startupServices;
            Before = config.custom.startupServices;
            After = [ "graphical-session-pre.target" ];
          };
        };
      };
    };
}

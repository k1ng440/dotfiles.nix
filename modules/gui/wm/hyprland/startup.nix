{
  lib,
  ...
}:
{
  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    {
      custom.programs.hyprland.execOnce = [
        # stop fucking with my cursors
        "hyprctl setcursor ${config.custom.gtk.cursor.name} ${toString config.custom.gtk.cursor.size}"
      ]
      # propagate the session env into systemd, then start the session target
      ++ [
        "${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprland-session.target"
      ]
      # generate from startup options.
      # the default workspace of each monitor is handled by the `default` workspace
      # rules in settings.nix, so no `hyprctl dispatch focusmonitor/workspace` needed.
      ++ builtins.filter (s: s != "") (
        map (
          {
            enable,
            spawn,
            workspace,
            ...
          }:
          let
            command = lib.concatStringsSep " " spawn;
          in
          if !enable then
            ""
          else if workspace == null then
            command
          else
            {
              inherit command;
              rules.workspace = "${toString workspace} silent";
            }
        ) config.custom.startup
      );

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

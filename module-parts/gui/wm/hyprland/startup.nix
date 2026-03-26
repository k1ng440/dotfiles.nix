{ lib, ... }:
{
  flake.modules.nixos.wm =
    { config, ... }:
    {
      custom.programs.hyprland.settings = {
        exec-once = [
          # stop fucking with my cursors
          "hyprctl setcursor ${"Simp1e-Tokyo-Night"} ${toString 28}"
          "hyprctl dispatch workspace 1"
        ]
        # generate from startup options
        ++ map (
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
        ) config.custom.startup;
      };

      systemd.user = {
        # ly -> hyprland-start -> exec-once hyprland-session.service -> startupServices
        # so the environment will be properly set
        targets.hyprland-session = {
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

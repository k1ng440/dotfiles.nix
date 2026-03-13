{ pkgs, machine, ... }:
let
  hyprgamemode = pkgs.writeShellApplication {
    name = "hyprgamemode";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.coreutils
      pkgs.gawk
      pkgs.libnotify
    ]
    ++ pkgs.lib.optional machine.windowManager.hyprland.noctalia.enable pkgs.noctalia-shell;
    text = ''
      #!/usr/bin/env sh

      gamemode_on() {
        systemctl --user stop wallpaper-cycler.timer
        ${pkgs.lib.optionalString machine.windowManager.hyprland.noctalia.enable "noctalia-shell ipc call powerProfile enableNoctaliaPerformance"}
        hyprctl --batch " \
          keyword animations:enabled 0; \
          keyword animation borderangle,0; \
          keyword decoration:shadow:enabled 0; \
          keyword decoration:blur:enabled 0; \
          keyword decoration:fullscreen_opacity 1; \
          keyword general:gaps_in 0; \
          keyword general:gaps_out 0; \
          keyword general:border_size 1; \
          keyword decoration:rounding 0"
        hyprctl notify 1 5000 "rgb(40a02b)" "Gamemode [ON]"
        exit 0
      }

      gamemode_off() {
        systemctl --user start wallpaper-cycler.timer
        ${pkgs.lib.optionalString machine.windowManager.hyprland.noctalia.enable "noctalia-shell ipc call powerProfile disableNoctaliaPerformance"}
        hyprctl notify 1 5000 "rgb(d20f39)" "Gamemode [OFF]"
        hyprctl reload
        exit 0
      }

      case "''${1:-}" in
      on)
        gamemode_on
        ;;
      off)
        gamemode_off
        ;;
      *)
        HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
        if [ "$HYPRGAMEMODE" = 1 ]; then
          gamemode_on
        else
          gamemode_off
        fi
        ;;
      esac
    '';
  };
in
{
  home.packages = [
    hyprgamemode
  ];

  systemd.user.services.hypr-gamemode = {
    Unit.Description = "Optimize Hyprland for Gaming";
    Service = {
      Type = "oneshot";
      ExecStart = "${hyprgamemode}/bin/hyprgamemode on";
      ExecStop = "${hyprgamemode}/bin/hyprgamemode off";
      RemainAfterExit = true;
    };
  };
}

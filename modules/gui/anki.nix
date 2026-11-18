# ABOUTME: Installs Anki (system-Qt build, fcitx5-safe) into the NixOS system.
# ABOUTME: Wires MIME, which-key, floating window rules, and home persistence.
{
  flake.modules.nixos.programs_anki =
    { lib, pkgs, ... }:
    let
      # Login-time reminder, at most once per day. Delayed so the notification
      # daemon is up; the stamp is only written if notify-send succeeds.
      ankiReminder = pkgs.writeShellApplication {
        name = "anki-reminder";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.libnotify
        ];
        text = ''
          state="''${XDG_STATE_HOME:-$HOME/.local/state}/anki-reminder"
          today="$(date +%F)"
          [ "$(cat "$state" 2>/dev/null)" = "$today" ] && exit 0
          sleep 20
          notify-send -a Anki -i anki -t 0 'Anki' 'Time to review your cards' || exit 0
          mkdir -p "$(dirname "$state")"
          printf '%s\n' "$today" > "$state"
        '';
      };
    in
    {
      environment.systemPackages = [ pkgs.anki ];

      xdg.mime.defaultApplications = {
        "application/x-apkg" = "anki.desktop";
        "application/x-anki" = "anki.desktop";
        "application/x-ankiaddon" = "anki.desktop";
      };

      custom = {
        persist = {
          home.directories = [ ".local/share/Anki2" ];
        };

        startup = [
          {
            spawn = [ (lib.getExe ankiReminder) ];
          }
        ];

        programs.niri.settings.window-rules = [
          {
            matches = [
              { app-id = "^net\\.ankiweb\\.Anki$"; }
              { app-id = "^Anki$"; }
            ];
            open-floating = true;
            background-effect = {
              blur = true;
            };
          }
        ];
        programs.which-key.menus = {
          a = {
            desc = "Anki";
            cmd = lib.getExe pkgs.anki;
          };
        };
      };
    };
}

_: {
  # Noctalia v5 owns both halves of this: `[idle.behavior.*]` covers the idle
  # timeouts and `noctalia msg session lock` is the same path
  # `loginctl lock-session` takes. Lid close and suspend are covered by
  # `[lockscreen].lock_before_suspend` (default on). Locking is unconditional
  # -- getty autologin stays off everywhere so no tty can bypass it
  # (modules/auth.nix).
  flake.modules.nixos.wm =
    { lib, ... }:
    {
      custom.programs = {
        noctalia.settingsReducers = [
          (
            prev:
            lib.recursiveUpdate prev {
              idle.behavior = {
                screen-off = {
                  timeout = 600;
                  action = "screen_off";
                  enabled = true;
                };
                lock = {
                  timeout = 660;
                  action = "lock";
                  enabled = true;
                };
                # The session is already locked by the time this fires, so
                # `lock_before_suspend` has nothing left to do.
                suspend = {
                  timeout = 1800;
                  action = "suspend";
                  enabled = true;
                };
              };
            }
          )
        ];

        # manual lock
        hyprland.binds = [
          {
            keys = "SUPER + SHIFT + CTRL + x";
            description = "Lock session";
            dsp = ''hl.dsp.exec_cmd("noctalia msg session lock")'';
          }
        ];

        niri.settings.binds."Mod+Shift+Ctrl+x".spawn = [ "noctalia msg session lock" ];
      };
    };
}

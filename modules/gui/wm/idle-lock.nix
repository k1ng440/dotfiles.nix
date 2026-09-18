{ lib, ... }:
{
  flake.modules.nixos.core =
    { config, ... }:
    {
      options.custom = {
        lock.enable = lib.mkEnableOption "screen locking of host" // {
          default = config.custom.constants.isLaptop;
        };
      };
    };

  flake.modules.nixos.wm =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) isLaptop;
      lock = pkgs.writeShellApplication {
        name = "lock";
        runtimeInputs = [
          config.programs.dms-shell.package
          pkgs.systemd
        ];
        text = /* sh */ ''
          ${lib.optionalString config.custom.lock.enable "loginctl lock-session"}
          ${lib.optionalString config.custom.lock.enable "systemctl suspend"}
          ${lib.optionalString (!config.custom.lock.enable) "dms dpms off"}
        '';
      };
    in
    {
      environment.systemPackages = [
        lock
      ];

      # manual lock key and laptop lid
      custom.programs = {
        hyprland.binds = [
          {
            keys = "SUPER + SHIFT + CTRL + x";
            dsp = ''hl.dsp.exec_cmd("${lib.getExe lock}")'';
          }
        ]
        # handle laptop lid
        ++ lib.optionals isLaptop [
          {
            keys = "switch:Lid Switch";
            dsp = ''hl.dsp.exec_cmd("${lib.getExe lock}")'';
            flags.locked = true;
          }
        ];

        niri.settings = {
          binds = {
            "Mod+Shift+Ctrl+x".spawn = [
              (lib.getExe lock)
            ];
          };

          switch-events = {
            lid-open = {
              spawn = lib.getExe lock;
            };
          };
        };

        # mango.settings = {
        #   bind = [ "$mod+SHIFT+CTRL, x, spawn, ${lib.getExe lock}" ];
        # };
      };
    };
}

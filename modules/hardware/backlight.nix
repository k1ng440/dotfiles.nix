_: {
  flake.modules.nixos.hardware_backlight =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.brightnessctl
      ];

      custom.programs = {
        hyprland.binds = [
          {
            keys = "XF86MonBrightnessDown";
            description = "Brightness down";
            dsp = ''hl.dsp.exec_cmd("brightnessctl set 5%-")'';
          }
          {
            keys = "XF86MonBrightnessUp";
            description = "Brightness up";
            dsp = ''hl.dsp.exec_cmd("brightnessctl set +5%")'';
          }
        ];

        niri.settings.binds = {
          "XF86MonBrightnessDown" = {
            spawn = [
              "brightnessctl"
              "set"
              "5%-"
            ];
            _attrs = {
              allow-when-locked = true;
            };
          };
          "XF86MonBrightnessUp" = {
            spawn = [
              "brightnessctl"
              "set"
              "+5%"
            ];
            _attrs = {
              allow-when-locked = true;
            };
          };
        };

        mango.settings.bind = [
          "NONE,XF86MonBrightnessDown, spawn, brightnessctl set 5%-"
          "NONE,XF86MonBrightnessUp, spawn, brightnessctl set +5%"
        ];

        # v4 needed its control-center brightness card switched on explicitly by
        # id. v5 has no per-card `enabled` flag -- brightness lives in the
        # control center's own tab and follows [brightness] instead, so there is
        # nothing left to enable here.
      };
    };
}

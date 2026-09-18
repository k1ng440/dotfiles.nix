{ lib, ... }:
{
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
            dsp = ''hl.dsp.exec_cmd("brightnessctl set 5%-")'';
          }
          {
            keys = "XF86MonBrightnessUp";
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

        noctalia.settingsReducers = [
          # enable control center brightness card
          (
            prev:
            lib.recursiveUpdate prev {
              controlCenter.cards = map (
                card: if card.id == "brightness-card" then card // { enabled = true; } else card
              ) prev.controlCenter.cards;
            }
          )
        ];
      };
    };
}

{
  flake.modules.nixos.gui =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [
        pkgs.pavucontrol
        pkgs.qpwgraph
        pkgs.easyeffects
      ];

      custom = {
        programs = {
          which-key.menus = {
            p = {
              desc = "PulseAudio Volume Control";
              cmd = lib.getExe pkgs.pavucontrol;
            };
          };
          niri.settings = {
            window-rules = [
              {
                matches = [ { app-id = "^org.pulseaudio.pavucontrol$"; } ];
                open-floating = true;
                default-column-width.fixed = 1300;
                default-window-height.fixed = 600;
              }
            ];
          };
        };
      };
    };
}

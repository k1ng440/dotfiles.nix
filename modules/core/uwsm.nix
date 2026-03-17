{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable Universal Wayland Session Manager
  programs.uwsm = {
    enable = lib.mkIf config.machine.windowManager.enabled true;
    waylandCompositors = lib.mkIf config.machine.windowManager.sway.enable {
      sway = {
        prettyName = "Sway";
        comment = "Sway managed by UWSM";
        binPath = "${pkgs.sway}/bin/sway";
        extraArgs = lib.optionals (lib.elem "nvidia-gpu" config.machine.capabilities) [
          "--unsupported-gpu"
        ];
      };
    };
  };
}

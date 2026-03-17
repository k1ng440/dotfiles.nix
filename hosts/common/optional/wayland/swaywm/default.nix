{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.machine.windowManager.sway.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = lib.optionals (lib.elem "nvidia-gpu" config.machine.capabilities) [
        "--unsupported-gpu"
      ];
      extraSessionCommands = "";
    };

    services.gnome.gnome-keyring.enable = true;

    security.pam.services.swaylock = { };
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "sway-session.target" ];
      wants = [ "sway-session.target" ];
      after = [ "sway-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}

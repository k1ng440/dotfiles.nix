{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (!config.hostSpec.isMinimal && config.hostSpec.swaywm.enabled) {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "run-sway" (builtins.readFile ./run-sway.sh))
    ];

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [
        "--unsupported-gpu"
      ];
      extraSessionCommands = "";
      extraPackages = [
      ];
    };

    services.gnome.gnome-keyring.enable = true;
    programs.hyprlock.enable = true;

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

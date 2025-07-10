{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (!config.hostSpec.isMinimal) {
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
    security.pam.services.swaylock = { };
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };
}

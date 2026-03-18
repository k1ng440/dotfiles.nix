{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.machine.hardware.useYubikey {
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    sops.secrets."keys/u2f_keys" = {
      owner = config.machine.username;
      path = "${config.machine.home}/.config/Yubico/u2f_keys";
    };

    security.pam.u2f = {
      enable = true;
      control = "sufficient";
      settings = {
        interactive = false;
        cue = true;
      };
    };

    security.pam.services = {
      login.u2fAuth = true;
      greetd.u2fAuth = true;
      gdm.u2fAuth = true;
      sudo.u2fAuth = true;
      hyprlock.u2fAuth = true;
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager
    ];
  };
}

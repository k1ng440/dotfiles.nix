{ pkgs, config, ... }:

{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  sops.secrets."keys/u2f_keys" = {
    owner = config.hostSpec.username;
    path = "/home/${config.hostSpec.username}/.config/Yubico/u2f_keys";
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
    sudo.u2fAuth = true;
    hyprlock.u2fAuth = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
  ];
}

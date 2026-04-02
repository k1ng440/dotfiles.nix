{
  flake.modules.nixos.hardware_yubikey =
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (config.custom.constants) user;
    in
    {
      services.udev.packages = [ pkgs.yubikey-personalization ];
      services.pcscd.enable = true;

      sops.secrets."keys/u2f_keys" = {
        owner = user;
        path = "${config.users.users.${user}.home}/.config/Yubico/u2f_keys";
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

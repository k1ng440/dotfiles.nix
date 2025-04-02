{
  lib,
  pkgs,
  username,
  ...
}:
let
  installFor = [ "k1ng" ];
in
lib.mkIf (builtins.elem username installFor) {
  environment.systemPackages = with pkgs; [
    cpu-x
    dconf-editor
    pika-backup
    squirreldisk
    usbimager
  ];

  programs = {
    dconf.profiles.user.databases = [
      {
        settings = with lib.gvariant; {
          "ca/desrt/dconf-editor" = {
            show-warning = false;
          };
        };
      }
    ];
  };
}

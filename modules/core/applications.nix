{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (!config.hostSpec.isMinimal) {
    # AppImage
    programs.appimage.binfmt = true;

    # Flatpak
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (!config.machine.computed.isMinimal) {
    programs.appimage.binfmt = true;
    programs.nix-ld.enable = true;
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

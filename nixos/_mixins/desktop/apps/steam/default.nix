{
  config,
  hostname,
  lib,
  pkgs,
  ...
}:
let
  installOn = [ "xenomorph" ];
in
lib.mkIf (lib.elem hostname installOn) {
  # Only include mangohud if Steam is enabled
  environment.systemPackages =
    with pkgs;
    lib.mkIf config.programs.steam.enable [
      mangohud
      steamguard-cli
    ];
  # https://nixos.wiki/wiki/Steam
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      # extraCompatPackages = pkgs.proton-ge-bin;
    };
  };
}

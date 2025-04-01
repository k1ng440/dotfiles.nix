{
  lib,
  pkgs,
  ...
}: {
  virtualisation.docker = {
    enable = lib.mkDefault true;
    enableOnBoot = lib.mkDefault true;
    liveRestore = false;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

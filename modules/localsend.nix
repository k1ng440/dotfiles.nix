{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.desktop.localsend {
    environment.systemPackages = with pkgs; [ localsend ];
    programs.localsend = {
      enable = true;
      openFirewall = true; # Opens port 53317 (TCP/UDP) for LocalSend
    };
  };
}

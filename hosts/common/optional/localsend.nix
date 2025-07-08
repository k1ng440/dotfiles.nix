{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ localsend ];
  programs.localsend = {
    enable = true;
    openFirewall = true; # Opens port 53317 (TCP/UDP) for LocalSend
  };
}

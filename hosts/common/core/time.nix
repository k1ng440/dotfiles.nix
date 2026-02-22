{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Dhaka";
  networking.timeServers = [
    "time.google.com"
    "time.cloudflare.com"
  ];
}

{ config, ... }:
{
  services.cloudflare-warp.enable = config.machine.networking.cloudflare-warp;
}

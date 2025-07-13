{ config, ... }:
let
  hostSpec = config.hostSpec;
in
{
  services.cloudflare-warp.enable = hostSpec.cloudflare-warp;
}

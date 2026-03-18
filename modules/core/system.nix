{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Dhaka";
  console.keyMap = "us";
  system.stateVersion = "24.11"; # Do not change!
  zramSwap.enable = true;
}

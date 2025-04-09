{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nixos-common.bluetooth;
  hasDE = any (x: x) [
    config.services.xserver.enable
    (config.programs.hyprland.enable or false)
    (config.services.gnome.core-shell.enable or false)
    (config.services.xserver.desktopManager.plasma5.enable or false)
    (config.services.xserver.desktopManager.xfce.enable or false)
  ];
in
{
  options.nixos-common.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth support";
    package = mkOption {
      type = types.package;
      default = pkgs.bluez;
      description = "The Bluez package to use for Bluetooth.";
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket"; # Support audio and other profiles
        };
      };
    };

    services.blueman.enable = mkIf hasDE true;

    environment.systemPackages = with pkgs;
      [ bluez-tools ] ++
      (optional hasDE blueman);
  };
}

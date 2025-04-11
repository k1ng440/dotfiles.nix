{ config, lib, pkgs, ... }:
let
  cfg = config.hardware.bluetooth;
in {
  options.nixos-common.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth support";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bluez;
      description = "The Bluez package to use for Bluetooth.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    services.blueman.enable = true;
    environment.systemPackages = with pkgs; [ bluez-tools blueman];
  };
}

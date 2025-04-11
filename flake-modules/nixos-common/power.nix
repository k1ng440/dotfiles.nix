{ config, lib, pkgs, ... }:

let
  cfg = config.nixos-common.power;
  hasDE = lib.any (x: x) [
    config.services.xserver.enable
    (config.programs.hyprland.enable or false)
    (config.services.gnome.core-shell.enable or false)
    (config.services.xserver.desktopManager.plasma5.enable or false)
    (config.services.xserver.desktopManager.xfce.enable or false)
  ];
in
{
  # Define options for power-related services
  options.nixos-common.power = {
    enable = lib.mkEnableOption "Enable power management services (UPower and NUT)";
    upower = {
      enable = lib.mkEnableOption "Enable UPower for power management";
    };
    nut = {
      enable = lib.mkEnableOption "Enable Network UPS Tools (NUT) for UPS monitoring";
    };
  };

  config = lib.mkIf cfg.enable {
    services.upower = lib.mkIf cfg.upower.enable { enable = true; };

    # services.nut = lib.mkIf cfg.nut.enable {
    #   enable = true;
    #   upsmon = {
    #     enable = true;
    #     settings = {
    #       MONITOR = [ "ups@localhost 1 upsmon password master" ];
    #     };
    #   };
    # };

    # Ensure D-Bus is enabled (required for UPower)
    services.dbus.enable = lib.mkIf (cfg.upower.enable || hasDE) true;

    # Add power-related packages
    environment.systemPackages = with pkgs;
      (lib.optional cfg.upower.enable upower) ++  # UPower CLI tools
      (lib.optional cfg.nut.enable nut);  # NUT tools (e.g., upsc, upsmon)
  };
}

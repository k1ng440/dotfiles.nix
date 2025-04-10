{lib, inputs, pkgs, config, ...}:
let
  cfg = config.desktop-environment.solaar;
in {

  options.desktop-environment = {
    solaar = {
     enable = lib.mkEnableOption "Enable Solaar For logitech";
    };
  };

  imports = [ inputs.solaar.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    hardware.logitech.wireless.enable = true;
    services.solaar = {
      enable = true; # Enable the service
      package = pkgs.solaar; # The package to use
      window = "hide"; # Show the window on startup (show, *hide*, only [window only])
      batteryIcons = "regular"; # Which battery icons to use (*regular*, symbolic, solaar)
      extraArgs = ""; # Extra arguments to pass to solaar on startup
    };
  };
}

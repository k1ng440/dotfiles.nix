{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.solaar.nixosModules.default ];
  config = {
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

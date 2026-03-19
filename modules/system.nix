{ lib, ... }:
{
  options.hostConfig = {
    msmtp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable msmtp";
      };
    };
    android-studio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install Android Studio and ADB.";
      };
    };
  };

  config = {
    console.keyMap = "us";
    system.stateVersion = "24.11"; # Do not change!
    zramSwap.enable = true;
  };
}

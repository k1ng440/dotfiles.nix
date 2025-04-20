{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.hostConfig.android-studio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Android Studio and ADB.";
    };
  };

  config = lib.mkIf config.hostConfig.android-studio.enable {
    environment.systemPackages = with pkgs; [
      android-studio
    ];

    programs.adb.enable = true;
  };
}

{ lib, pkgs, ... }:
{
  stylix.targets.plymouth.enable = false;
  environment.systemPackages = [ pkgs.adi1090x-plymouth-themes ];
  boot = {
    kernelParams = [
      "quiet" # shut up kernel output prior to prompts
    ];
    plymouth = {
      enable = true;
      theme = lib.mkForce "hexagon_dots";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "hexagon_dots" ]; })
      ];
    };
    consoleLogLevel = 0;
  };
}

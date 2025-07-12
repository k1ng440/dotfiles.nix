{
  inputs,
  pkgs,
  ...
}:
{
  programs.hyprland = {
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    enable = false;
    withUWSM = true;
    xwayland = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ kitty ];
}

{ pkgs, ... }:
{
  programs = {
    thunar = {
      enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer # Need For Video / Image Preview
    thunar-archive-plugin
    thunar-volman
  ];
}

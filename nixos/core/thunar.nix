{ host, pkgs, ... }: let
  inherit (import ../../hosts/${host}/variables.nix) thunarEnable;
in {
  programs = {
    thunar = {
      enable = thunarEnable;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer # Need For Video / Image Preview
  ];
}

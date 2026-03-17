{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /mnt/loop 0755 root root -"
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  programs.xfconf.enable = true;

  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer
    tumbler
    xarchiver
    webp-pixbuf-loader
    libheif
    gdk-pixbuf
    file-roller
  ];

  services.gvfs.enable = true;
  services.tumbler.enable = true;
}

{ ... }:
{
  xdg.mime.enable = true;
  xdg.mimeApps.defaultApplications = {
    "image/*" = [ "swappy.desktop" ];
    "video/*" = [ "mpv.desktop" ];
  };
}

{ ... }:
{
  xdg.mime.enable = true;
  xdg.mimeApps.defaultApplications = {
    # Image
    "image/" = [ "swappy.desktop" ];
    "image/png" = [ "swappy.desktop" ];
    "image/jpeg" = [ "swappy.desktop" ];
    "image/jpg" = [ "swappy.desktop" ];
    "image/gif" = [ "swappy.desktop" ];
    "image/webp" = [ "swappy.desktop" ];
    "image/svg+xml" = [ "swappy.desktop" ];
    "image/bmp" = [ "swappy.desktop" ];
    "image/tiff" = [ "swappy.desktop" ];
    "image/x-xcf" = [ "swappy.desktop" ];

    # Video
    "video/*" = [ "mpv.desktop" ];
    "video/mp4" = [ "mpv.desktop" ];
    "video/x-matroska" = [ "mpv.desktop" ]; # .mkv
    "video/webm" = [ "mpv.desktop" ];
    "video/ogg" = [ "mpv.desktop" ];
    "video/x-msvideo" = [ "mpv.desktop" ]; # .avi
    "video/x-flv" = [ "mpv.desktop" ];
    "video/x-ms-wmv" = [ "mpv.desktop" ];
    "video/mpeg" = [ "mpv.desktop" ];

    # Audio MIME types
    "audio/*" = [ "mpv.desktop" ];
    "audio/mpeg" = [ "mpv.desktop" ]; # .mp3
    "audio/ogg" = [ "mpv.desktop" ]; # .ogg
    "audio/wav" = [ "mpv.desktop" ]; # .wav
    "audio/x-wav" = [ "mpv.desktop" ]; # alternate .wav
    "audio/x-flac" = [ "mpv.desktop" ]; # .flac
    "audio/flac" = [ "mpv.desktop" ];
    "audio/x-aac" = [ "mpv.desktop" ]; # .aac
    "audio/aac" = [ "mpv.desktop" ];
    "audio/mp4" = [ "mpv.desktop" ]; # .m4a
    "audio/webm" = [ "mpv.desktop" ]; # audio-only webm
    "audio/x-ms-wma" = [ "mpv.desktop" ]; # .wma

    # Directory
    "inode/directory" = [ "thunar" ];
  };
}

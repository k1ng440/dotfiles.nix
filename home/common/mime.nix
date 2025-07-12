{ ... }:
let
  browser = "firefox.desktop";
  file-manager = "thunar.desktop";
  video-player = "mpv.desktop";
  audio-player = "mpv.desktop";
  image-viewer = "swappy.desktop";
in
{
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/calendar" = [ "thunderbird.desktop" ];

      # Image
      "image/" = [ image-viewer ];
      "image/png" = [ image-viewer ];
      "image/jpeg" = [ image-viewer ];
      "image/jpg" = [ image-viewer ];
      "image/gif" = [ image-viewer ];
      "image/webp" = [ image-viewer ];
      "image/svg+xml" = [ image-viewer ];
      "image/bmp" = [ image-viewer ];
      "image/tiff" = [ image-viewer ];
      "image/x-xcf" = [ image-viewer ];

      # Video
      "video/*" = [ video-player ];
      "video/mp4" = [ video-player ];
      "video/x-matroska" = [ video-player ]; # .mkv
      "video/webm" = [ video-player ];
      "video/ogg" = [ video-player ];
      "video/x-msvideo" = [ video-player ]; # .avi
      "video/x-flv" = [ video-player ];
      "video/x-ms-wmv" = [ video-player ];
      "video/mpeg" = [ video-player ];

      # Audio MIME types
      "audio/*" = [ audio-player ];
      "audio/mpeg" = [ audio-player ]; # .mp3
      "audio/ogg" = [ audio-player ]; # .ogg
      "audio/wav" = [ audio-player ]; # .wav
      "audio/x-wav" = [ audio-player ]; # alternate .wav
      "audio/x-flac" = [ audio-player ]; # .flac
      "audio/flac" = [ audio-player ];
      "audio/x-aac" = [ audio-player ]; # .aac
      "audio/aac" = [ audio-player ];
      "audio/mp4" = [ audio-player ]; # .m4a
      "audio/webm" = [ audio-player ]; # audio-only webm
      "audio/x-ms-wma" = [ audio-player ]; # .wma

      # Directory
      "inode/directory" = [ file-manager ];

      # Browser
      "default-web-browser" = [ browser ];
      "text/html" = [ browser ];
      "x-scheme-handler/http" = [ browser ];
      "x-scheme-handler/https" = [ browser ];
      "x-scheme-handler/ftp" = [ browser ];
      "x-scheme-handler/chrome" = [ browser ];
      "x-scheme-handler/about" = [ browser ];
      "x-scheme-handler/unknown" = [ browser ];
      "application/x-extension-htm" = [ browser ];
      "application/x-extension-html" = [ browser ];
      "application/x-extension-shtml" = [ browser ];
      "application/xhtml+xml" = [ browser ];
      "application/x-extension-xhtml" = [ browser ];
      "application/x-extension-xht" = [ browser ];
    };
  };
}

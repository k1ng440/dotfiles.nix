_: {
  flake.modules.nixos.gui =
    { config, ... }:
    let
      browser = "helium.desktop";
      file-manager = "nemo.desktop";
      video-player = "mpv.desktop";
      audio-player = "mpv.desktop";
      pdf-viewer = "org.kde.okular.desktop";
    in
    {
      xdg = {
        terminal-exec = {
          enable = true;
          settings = {
            default = [ config.custom.programs.terminal.desktop ];
          };
        };

        mime.enable = true;
        mime.defaultApplications = {
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

          "inode/directory" = [ file-manager ];
          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/vnd.rar" = "org.gnome.FileRoller.desktop";
          "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
          "application/x-bzip2-compressed-tar" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";

          # Browser
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;
          "x-scheme-handler/ftp" = [ browser ];
          "x-scheme-handler/chrome" = [ browser ];
          "application/x-extension-htm" = [ browser ];
          "application/x-extension-html" = [ browser ];
          "application/x-extension-shtml" = [ browser ];
          "application/xhtml+xml" = [ browser ];
          "application/x-extension-xhtml" = [ browser ];
          "application/x-extension-xht" = [ browser ];

          # Documents
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
            "libreoffice-writer.desktop"
          ]; # .docx
          "application/msword" = [ "libreoffice-writer.desktop" ]; # .doc
          "application/vnd.oasis.opendocument.text" = [ "libreoffice-writer.desktop" ]; # .odt
          "text/rtf" = [ "libreoffice-writer.desktop" ]; # .rtf
          "application/pdf" = [ pdf-viewer ];

          # Spreadsheets
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
            "libreoffice-calc.desktop"
          ]; # .xlsx
          "application/vnd.ms-excel" = [ "libreoffice-calc.desktop" ]; # .xls
          "application/vnd.oasis.opendocument.spreadsheet" = [ "libreoffice-calc.desktop" ]; # .ods

          # Presentations
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
            "libreoffice-impress.desktop"
          ]; # .pptx
          "application/vnd.ms-powerpoint" = [ "libreoffice-impress.desktop" ]; # .ppt
          "application/vnd.oasis.opendocument.presentation" = [ "libreoffice-impress.desktop" ]; # .odp

          # Other Formats
          "application/vnd.oasis.opendocument.graphics" = [ "libreoffice-draw.desktop" ]; # .odg
          "application/vnd.oasis.opendocument.formula" = [ "libreoffice-math.desktop" ]; # .odf
        };
      };
    };
}

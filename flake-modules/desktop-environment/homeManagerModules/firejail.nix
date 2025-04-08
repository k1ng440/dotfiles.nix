{
  pkgs,
  lib,
  ...
}:
{
  programs.firejail.enable = true;
  programs.firejail.wrappedBinaries = {
    thunderbird = {
      executable = "${lib.getBin pkgs.thunderbird}/bin/thunderbird";
      profile = "${pkgs.firejail}/etc/firejail/thunderbird.profile";
    };
    telegram-desktop = {
      executable = "${lib.getBin pkgs.tdesktop}/bin/telegram-desktop";
      profile = "${pkgs.firejail}/etc/firejail/telegram.profile";
    };
  };
  # Firejail-specific desktop shortcuts
  home-manager.users.k1ng = _: {
    xdg.desktopEntries = {
      thunderbird = {
        name = "Thunderbird";
        comment = "🦊Firejailed";
        genericName = "Mail Client";
        exec = "thunderbird %U";
        icon = "thunderbird";
        terminal = false;
        mimeType = [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/vnd.mozilla.xul+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/ftp"
        ];
      };
      telegram = {
        name = "Telegram";
        comment = "🦊Firejailed";
        exec = "telegram-desktop -- %u";
        icon = "telegram";
        terminal = false;
        mimeType = [ "x-scheme-handler/tg" ];
      };
    };
  };
}

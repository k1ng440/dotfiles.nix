{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--no-default-browser-check"
      "--restore-last-session"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };
}

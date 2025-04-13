{ config, ... }:
let
  homeDir = config.home.homeDirectory;
  defaultSettings = {
    "browser.urlbar.suggest.searches" = true; # Need this for basic search suggestions
    "browser.tabs.tabMinWidth" = 75; # Make tabs able to be smaller to prevent scrolling
    "browser.aboutConfig.showWarning" = false; # No warning when going to config
    "browser.warnOnQuitShortcut" = false;
    "browser.tabs.loadInBackground" = true; # Load tabs automatically
    "media.ffmpeg.vaapi.enabled" = true; # Enable hardware acceleration
    "layers.acceleration.force-enabled" = true;
    "gfx.webrender.all" = true;
    "ui.systemUsesDarkTheme" = true;
    "extensions.autoDisableScopes" = 0; # Automatically enable extensions
    "extensions.update.enabled" = false;
    "widget.use-xdg-desktop-portal.file-picker" = 1; # Use new gtk file picker instead of legacy one
    "widget.dmabuf.force-enabled" = 1;
  };
in
{
  programs.firefox = {
    enable = true;

    # Refer to https://mozilla.github.io/policy-templates or `about:policies#documentation` in firefox
    policies = {
      AppAutoUpdate = false; # Disable automatic application update
      BackgroundAppUpdate = false; # Disable automatic application update in the background, when the application is not running.
      DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
      DisableBuiltinPDFViewer = false;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = false; # Enable Firefox Sync
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false; # Managed by Bitwarden
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        # Exceptions = ["https://example.com"]
      };
      ExtensionUpdate = false;

      # To add additional extensions, find it on addons.mozilla.org, find
      # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
      # Then, download the install the plugin. Once done, open about:memory. Click "measure" in Show
      # memory reports. In the Main Process section, scroll down to Other Measurements.
      # There you will find the installed (active) extensions with their names and their ids
      # displayed as baseURL=moz-extension://[random-ids].
      ExtensionSettings =
        (
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "normal_installed";
              };
            };
          in
          builtins.listToAttrs [
            # Privacy / Security
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "ignore-cookies" "jid1-KKzOGWgsW3Ao4Q@jetpack") # failed # Ignore cookie setting pop-ups
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
            (extension "cookie-autodelete" "CookieAutoDelete@kennydo.com")
            (extension "facebook-container" "@contain-facebook")
            (extension "duckduckgo-for-firefox" "jid1-ZAdIEUB7XOzOJw@jetpack")

            # Website Related
            (extension "return-youtube-dislikes" "{762f9885-5a13-4abd-9c77-433dcd38b8fd}") # Youtube
            (extension "betterttv" "firefox@betterttv.net") # Youtube & Twitch

            # Translate
            (extension "simple-translate" "simple-translate@sienori")

            # Layout / Themeing
            (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
            (extension "darkreader" "addon@darkreader.org")

            # Misc
            (extension "auto-tab-discard" "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}")
            (extension "reddit-enhancement-suite" "jid1-xUfzOsOFlzSOXg@jetpack")
          ]
        );
    };

    profiles.main = {
      id = 0;
      name = "k1ng";
      isDefault = true;

      settings = defaultSettings // {
        "signon.rememberSignons" = false; # Disable built-in password manager
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # enable compact mode
        "browser.aboutConfig.showWarning" = false;
        "browser.download.dir" = "${homeDir}/Downloads";
        "browser.tabs.firefox-view" = true; # Sync tabs across devices
        "ui.systemUsesDarkTheme" = 1; # force dark theme
        "extensions.pocket.enabled" = false;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

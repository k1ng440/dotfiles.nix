_: {
  flake.modules.nixos.programs_google-chrome =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # Privacy-focused Chrome wrapper
      chromePrivacyWrapper = pkgs.writeShellScriptBin "google-chrome-privacy" ''
        exec ${pkgs.google-chrome}/bin/google-chrome-stable \
          --disable-background-networking \
          --disable-component-update \
          --disable-default-apps \
          --disable-domain-reliability \
          --disable-features=InterestFeedContentSuggestions,TranslateUI,MediaRouter,OptimizationHints,NetworkPrediction,AutofillServerCommunication,AutofillCreditCardUpload \
          --disable-hang-monitor \
          --disable-popup-blocking \
          --disable-prompt-on-repost \
          --disable-sync \
          --enable-features=StrictSiteIsolation \
          --force-webrtc-ip-handling-policy=default_public_interface_only \
          --no-default-browser-check \
          --no-first-run \
          --password-store=basic \
          "''${@}"
      '';
    in
    {
      options.custom.programs.google-chrome = {
        enable = lib.mkEnableOption "Google Chrome browser with privacy settings";

        privacyMode = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable maximum privacy settings";
        };
      };

      config = lib.mkIf config.custom.programs.google-chrome.enable {
        environment.systemPackages = [ chromePrivacyWrapper ];

        # Chrome/Chromium policies for privacy
        programs.chromium = {
          enable = true;
          extraOpts = {
            # Privacy and security
            "SafeBrowsingEnabled" = false;
            "SafeBrowsingExtendedReportingEnabled" = false;
            "AutofillCreditCardEnabled" = false;
            "AutofillAddressEnabled" = false;
            "PasswordManagerEnabled" = false;
            "SpellcheckEnabled" = false;
            "SpellcheckUseSpellingService" = false;
            "AlternateErrorPagesEnabled" = false;
            "SearchSuggestEnabled" = false;
            "PredictiveSearchEnabled" = false;
            "NetworkPredictionOptions" = 2; # 0=always, 1=wifi-only, 2=never
            "UrlKeyedAnonymizedDataCollectionEnabled" = false;
            "MetricsReportingEnabled" = false;
            "ReportVersionData" = false;
            "CloudPrintProxyEnabled" = false;
            "CloudPrintSubmitEnabled" = false;
            "DefaultCookiesSetting" = 4; # Block third-party cookies
            "EnableMediaRouter" = false;
            "ShowFullUrlsInAddressBar" = true;

            # Disable sign-in
            "ForceBrowserSignin" = false;
            "BrowserSignin" = 0; # 0=disabled, 1=enabled, 2=force
            "SyncDisabled" = true;

            # Disable various features
            "SpellCheckServiceEnabled" = false;
            "TranslateEnabled" = false;
            "DefaultGeolocationSetting" = 2; # 0=allow, 1=ask, 2=block
            "DefaultNotificationsSetting" = 2; # Block notifications
            "DefaultPopupsSetting" = 2; # Block popups

            # Disable background apps
            "BackgroundModeEnabled" = false;
            "HardwareAccelerationModeEnabled" = true; # Keep enabled for performance

            # Enable strict security
            "ForceGoogleSafeSearch" = false;
            "ForceYouTubeRestrict" = 0;
            "DefaultInsecureContentSetting" = 2; # Block insecure content on HTTPS sites
          };
        };

        # Create a desktop entry for the privacy wrapper
        hj.xdg.config.files."applications/google-chrome-privacy.desktop" = {
          text = lib.generators.toINI { } {
            "Desktop Entry" = {
              Name = "Google Chrome (Privacy)";
              Exec = "${chromePrivacyWrapper}/bin/google-chrome-privacy %U";
              StartupNotify = true;
              Terminal = false;
              Icon = "google-chrome";
              Type = "Application";
              Categories = "Network;WebBrowser;";
              MimeType = "text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;";
              Actions = "new-window;new-private-window;";
            };
            "Desktop Action new-window" = {
              Name = "New Window";
              Exec = "${chromePrivacyWrapper}/bin/google-chrome-privacy --new-window %U";
            };
            "Desktop Action new-private-window" = {
              Name = "New Incognito Window";
              Exec = "${chromePrivacyWrapper}/bin/google-chrome-privacy --incognito %U";
            };
          };
        };

        # Create wrapper script alias
        environment.shellAliases = {
          chrome = "google-chrome-privacy";
          chrome-privacy = "google-chrome-privacy";
        };
      };
    };
}

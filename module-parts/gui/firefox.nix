{ lib, ... }:
{
  flake.modules.nixos.gui =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) user;
      configPath = ".mozilla/firefox";
      cachePath = ".cache/mozilla/firefox";
    in
    {
      systemd.tmpfiles.rules = [
        "d ${config.hj.directory}/${configPath}/${user} 0700 ${user} users - -"
        "d ${config.hj.directory}/${cachePath}/${user} 0700 ${user} users - -"
      ];

      programs.firefox = {
        enable = true;
        package = pkgs.firefox.overrideAttrs (o: {
          buildCommand = o.buildCommand + ''
            wrapProgram "$out/bin/firefox" \
              --set 'HOME' '${config.hj.xdg.config.directory}' \
              --append-flags "${
                lib.concatStringsSep " " [
                  "--profile ${config.hj.directory}/${configPath}/${user}"
                ]

              }"
          '';
        });

        policies = {
          Extensions = {
            Install = [
              "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/"
              "https://addons.mozilla.org/firefox/downloads/latest/darkreader/"
              "https://addons.mozilla.org/firefox/downloads/latest/screenshot-capture-annotate/"
              "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/"
              "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/"
            ];
            # Extension ID can be obtained after installation by going to about:support
            Locked = [
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" # Bitwarden
              "addon@darkreader.org"
              "jid0-GXjLLfbCoAx0LcltEdFrEkQdQPI@jetpack" # screenshot-capture-annotate
              "sponsorBlocker@ajay.app"
              "uBlock0@raymondhill.net"
            ];
            ExtensionSettings = {
              # Bitwarden
              "{446900e4-71c2-419f-a6a7-df9c091e268b}".private_browsing = true;
              "addon@darkreader.org".private_browsing = true;
              # screenshot-capture-annotate
              "jid0-GXjLLfbCoAx0LcltEdFrEkQdQPI@jetpack".private_browsing = true;
              "sponsorBlocker@ajay.app".private_browsing = true;
              "uBlock0@raymondhill.net".private_browsing = true;
            };
          };
        };

        preferences = {
          "browser.download.dir" = "${config.hj.directory}/Downloads";
          "browser.download.useDownloadDir" = false;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };

      custom.persist = {
        home.directories = [
          configPath
          cachePath
        ];
      };
    };
}

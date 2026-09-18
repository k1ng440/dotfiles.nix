{ lib, ... }:
{
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) user;
    in
    {
      config = lib.mkMerge [
        # ssh settings
        {
          services.openssh = {
            enable = true;
            # disable password auth
            settings = {
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
            };
          };

          # users.users =
          #   let
          #     keyFiles = [
          #       ./id_rsa.pub
          #       ./id_ed25519.pub
          #     ];
          #   in
          #   {
          #     root.openssh.authorizedKeys.keyFiles = keyFiles;
          #     ${user}.openssh.authorizedKeys.keyFiles = keyFiles;
          #   };
        }

        # keyring settings
        {
          services.gnome.gnome-keyring.enable = true;
          # greetd's PAM service substacks/includes `login`, so unlocking the
          # keyring here with the typed password also covers the login screen
          security.pam.services.login.enableGnomeKeyring = true;
          services.gnome.gcr-ssh-agent.enable = true;
        }

        {
          security = {
            polkit.enable = true;
          };

          # Some programs need SUID wrappers, can be configured further or are
          # started in user sessions.
          environment.variables = {
            GNUPGHOME = "${config.hj.xdg.data.directory}/.gnupg";
          };

          programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = false;
          };

          # persist keyring and misc other secrets
          custom.persist = {
            root = {
              directories = [
                "/etc/ssh"
              ];
            };
            home = {
              directories = [
                ".ssh"
                ".local/share/.gnupg"
                ".local/share/keyrings"
              ];
            };
          };
        }

        # PAM login limits
        {
          security.pam.loginLimits = [
            {
              domain = "*";
              type = "-";
              item = "memlock";
              value = "unlimited";
            }
            {
              domain = "*";
              type = "-";
              item = "nofile";
              value = "1048576";
            }
            {
              domain = "*";
              type = "-";
              item = "nproc";
              value = "unlimited";
            }
          ];
        }

        {
          services.displayManager = {
            defaultSession = lib.mkDefault "niri";
          };

          services.greetd = {
            enable = true;
            useTextGreeter = true;
            settings.default_session.command = lib.concatStringsSep " " [
              (lib.getExe pkgs.tuigreet)
              "--time"
              "--remember"
              "--remember-session"
              "--user-menu"
              "--greeting ${config.networking.hostName}"
              "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
              "--xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions"
            ];
          };

          # greetd feeds its config to the daemon from the store, so mirror it at
          # a stable path for the `greetd-config` helper.
          environment.etc."greetd/config.toml".source =
            (pkgs.formats.toml { }).generate "greetd.toml"
              config.services.greetd.settings;

          custom.programs.print-config = {
            greetd = /* sh */ ''moor "/etc/greetd/config.toml"'';
          };

          # block other ttys from autologin when bypassed from lockscreen
          services.getty.autologinUser = lib.mkIf (!config.custom.lock.enable) user;
        }
      ];
    };
}

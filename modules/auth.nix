{ lib, ... }:
{
  flake.modules.nixos.core =
    { config, ... }:
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
          security.pam.services.login.enableGnomeKeyring = true;
          # ly runs its own PAM service; unlock gnome-keyring here with the
          # password typed at the login screen
          security.pam.services.ly.enableGnomeKeyring = true;
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

            ly = {
              enable = true;
              settings = {
                bigclock = "en";
                save = false; # don't use previous successful session
                session_log = "${config.hj.xdg.data.directory}/ly-session.log";
              };
            };
          };

          custom.programs.print-config = {
            ly = /* sh */ ''moor "/etc/ly/config.ini"'';
          };

          # block other ttys from autologin when bypassed from lockscreen
          services.getty.autologinUser = lib.mkIf (!config.custom.lock.enable) user;
        }
      ];
    };
}

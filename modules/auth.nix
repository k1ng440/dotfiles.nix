{ lib, ... }:
{
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) user;
      askpass = pkgs.symlinkJoin {
        name = "ssh-askpass";
        paths = [ pkgs.openssh-askpass ];
        postBuild = ''
          mkdir -p $out/bin
          ln -s $out/libexec/gtk-ssh-askpass $out/bin/ssh-askpass
        '';
      };
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
          # the display manager's PAM service substacks/includes `login`, so
          # unlocking the keyring here with the typed password also covers the
          # login screen
          security.pam.services.login.enableGnomeKeyring = true;
          # Do not use gcr-ssh-agent here. It preloads every ~/.ssh/*.pub and,
          # on each sign request for an encrypted key, runs a *synchronous*
          # `ssh-add <key>` via its own askpass. Under niri/Hyprland that
          # prompt never appears, so ssh-add blocks forever and every ssh
          # client hangs at authentication. A plain OpenSSH agent lets ssh
          # decrypt the key through the askpass below and cache it normally.
          services.gnome.gcr-ssh-agent.enable = false;
          environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/${
            toString config.users.users.${user}.uid
          }/ssh-agent";

          # password/passphrase prompts for ssh live in a dialog, so they still
          # show under compositors where the terminal has no tty of its own.
          # `force` ignores DISPLAY/tty heuristics and always uses the helper.
          #
          # SSH_ASKPASS itself comes from programs.ssh: it hard-sets the var to ""
          # unless enableAskPassword is set, and environment.variables outranks
          # environment.sessionVariables, so setting it here would just collide.
          programs.ssh = {
            startAgent = true;
            enableAskPassword = true;
            askPassword = "${askpass}/libexec/gtk-ssh-askpass";
          };
          environment.sessionVariables.SSH_ASKPASS_REQUIRE = "force";
          # openssh-askpass only ships libexec/gtk-ssh-askpass; expose it under
          # the name ssh(1) and scripts expect
          environment.systemPackages = [ askpass ];
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

          security.pam.services.ly.enableGnomeKeyring = true;

          custom.programs.print-config = {
            ly = /* sh */ ''moor "/etc/ly/config.ini"'';
          };

          # No getty autologin anywhere: the session locks itself after idle
          # (modules/gui/wm/idle-lock.nix), and a passwordless tty would be a
          # straight bypass of that lock. Login happens through ly.
        }
      ];
    };
}

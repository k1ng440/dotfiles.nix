{ inputs, ... }:
{
  flake.modules.nixos.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      sopsFolder = builtins.toString inputs.nix-secrets + "/sops";
      inherit (config.custom.constants) user host;
      # Script to bootstrap a new install
      install-remote-secrets = pkgs.writeShellApplication {
        name = "install-remote-secrets";
        runtimeInputs = [ pkgs.rsync ];
        text =
          let
            persistHome = "/persist${config.hj.directory}";
            copy = src: ''rsync -aP --mkpath "${persistHome}/${src}" "$user@$remote:$target/${src}"'';
          in
          /* sh */ ''
            read -rp "Enter ip of remote host: " remote
            target="/mnt${persistHome}"

            while true; do
              read -rp "Use /mnt? [y/n] " yn
              case $yn in
                [Yy]*)
                  echo "y";
                  target="/mnt${persistHome}"
                  break;;
                [Nn]*)
                  echo "n";
                  target="${persistHome}"
                  break;;
                *)
                  echo "Please answer yes or no.";;
              esac
            done

            read -rp "Enter user on remote host: [nixos] " user
            user=''${user:-nixos}

            ${copy ".ssh/"}
            ${copy ".config/sops/age/"}
          '';
      };
    in
    {
      sops = {
        defaultSopsFile = "${sopsFolder}/${host}.yaml";
        validateSopsFiles = false;
        age = {
          # Automatically import host SSH keys as age keys
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          keyFile = "/var/lib/sops-nix/key.txt";
          generateKey = true;
        };
      };

      sops.secrets = lib.mkMerge [
        {
          # These age keys are unique for the user on each host and are generated on their own (i.e. they are not derived
          # from a ssh key).
          "keys/age" = {
            owner = config.users.users.${user}.name;
            inherit (config.users.users.${user}) group;
            # We need to ensure the entire directory structure is that of the user...
            path = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
          };
          # Extract password/username to /run/secrets-for-users/ so it can be used to create the user
          "passwords/${user}" = {
            sopsFile = "${sopsFolder}/shared.yaml";
            neededForUsers = true;
          };
          "passwords/msmtp" = {
            sopsFile = "${sopsFolder}/shared.yaml";
            neededForUsers = true;
          };
          "keys/u2f_keys" = {
            sopsFile = "${sopsFolder}/shared.yaml";
          };
          "samba/kong" = {
            sopsFile = "${sopsFolder}/shared.yaml";
            owner = "root";
            group = "root";
            mode = "0600";
          };
          "samba/hass" = {
            sopsFile = "${sopsFolder}/shared.yaml";
            owner = "root";
            group = "root";
            mode = "0600";
          };
          "borgbackup/encryption_key" = {
            owner = user;
            group = user;
            mode = "0600";
          };
          "ssh/borgbackup" = {
            owner = user;
            group = user;
            mode = "0600";
          };

        }
      ];

      # The containing folders are created as root and if this is the first ~/.config/ entry,
      # the ownership is busted and home-manager can't target because it can't write into .config...
      # FIXME(sops): We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
      system.activationScripts.sopsSetAgeKeyOwnership =
        let
          ageFolder = "${config.hj.directory}/sops/age";
          # user = config.users.users.${user}.name;
          # inherit (config.users.users.${user}) group;
        in
        ''
          mkdir -p ${ageFolder}
        '';

      environment.systemPackages = [
        install-remote-secrets
      ];

      custom.persist = {
        root.directories = [
          "/var/lib/sops-nix/"
        ];
        home.directories = [
          # ".config/sops"
        ];
      };
    };
}

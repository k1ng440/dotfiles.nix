{ inputs, ...} : {
  flake.modules.nixos.core =
  { lib, config, pkgs, ... }:
  let
    sopsFolder = builtins.toString inputs.nix-secrets + "/sops";
    inherit (config.custom.constants) user hostname;
  in
  {
    sops = {
      defaultSopsFile = "${sopsFolder}/${hostname}.yaml";
      validateSopsFiles = false;
      age = {
        # automatically import host SSH keys as age keys
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };

    sops.secrets = lib.mkMerge [
    {
      # These age keys are are unique for the user on each host and are generated on their own (i.e. they are not derived
      # from an ssh key).
      "keys/age" = {
        owner = config.users.users.${user}.name;
        inherit (config.users.users.${user}) group;
        # We need to ensure the entire directory structure is that of the user...
        path = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
      };
      # extract password/username to /run/secrets-for-users/ so it can be used to create the user
      "passwords/${user}" = {
        sopsFile = "${sopsFolder}/shared.yaml";
        neededForUsers = true;
      };
      "passwords/msmtp" = {
        sopsFile = "${sopsFolder}/shared.yaml";
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
        ageFolder = "${config.users.users.${user}.home}/.config/sops/age";
        # user = config.users.users.${user}.name;
        # inherit (config.users.users.${user}) group;
      in
      ''
      mkdir -p ${ageFolder}
      '';
  };
}
